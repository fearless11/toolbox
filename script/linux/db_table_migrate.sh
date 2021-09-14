#!/bin/bash
# date: 2021/09/14
# auth: vera
# description: 清理大表数据

###### 风险评估 ######
# 1. 操作数据量过大导致mysql的cpu飙升
# 2. 删除数据量过大导致磁盘故障

###### 操作步骤 ###### 
# 1. 全量备份表
# 2. 创建临时表
# 3. 迁移保留数据到临时表
# 4. 重命名原表为备份表，临时表为原表
# 5. 删除备份表数据
# 6. 删除备份表


host="127.0.0.1"
user="root"
password="123456"
db_name="test"
exec_mysql="mysql -h ${host} -u${user} -p${password} --default-character-set=uft8 ${db_name} -e"
sleep_time=1

table_name="t_test"
table_tmp="${table_name}_tmp"
table_bak="${table_name}_bak"

# 保留多长时间
time_table_new_start=0
time_table_new_end=180

# 新增数据
time_table_insert_start=`date +"%F %T"`
time_table_insert_end=`date +"%F %T"`


function print_now() {
    now=$(date +"%F %T")
    echo ${now}
}

function table_backup(){
    mkdir bak &> /dev/null
    table_old=$1
    t1=$(print_now)
    time mysqldump -h ${host} -u${user} -p${password}  --opt --single-transaction --default-character-set=utf8 test ${table_old} > bak/${table_old}-`date +%F`.sql
    t2=$(print_now)
    echo "start $t1 end $t2 mysqldump -h ${host} -u${user} -p${password}  --opt --single-transaction --default-character-set=utf8 test ${table_old} > bak/${table_old}-`date +%F`.sql"
}


function create_table(){
    table_old=$1
    table_new=$2
    ${exec_mysql} "create table ${table_new} like ${table_old}" 
    # 添加索引
    ${exec_mysql} "ALTER TABLE ${table_new} ADD INDEX idx_create_time (create_time)"
}


function migration_data(){
    table_old=$1
    table_new=$2
    start_time=$3
    end_time=$4
    for i in $(seq ${start_time} ${end_time})
    do
        time=$(date +%F -d "$i day ago")
        for hour in $(seq -w 0 23)
        do
            ${exec_mysql} "insert into ${table_new} select * from ${table_old} where create_time >= \"${time} ${hour}:00:00\" and create_time <= \"${time} ${hour}:59:59\""
            sleep ${sleep_time}
        done
    done
}


function rename_table(){
    table_old=$1
    table_new=$2
    ${exec_mysql} "alter TABLE ${table_old} rename to ${table_bak}"
    ${exec_mysql} "alter TABLE ${table_new} rename to ${table_old}"
}


function insert_data(){
    table_old=$1
    table_new=$2
    end_time=$3
    # 查询临时表的最后时间为新增数据的开始时间
    last_time=$(${exec_mysql} "select create_time from ${table_new} order by create_time desc limit 1")
    start_time=$(echo ${last_time} | awk '{print $2" "$3}')
    ${exec_mysql} "insert into ${table_new} select * from ${table_old} where create_time > \"${start_time}\" and create_time <= \"${end_time}\""
}


function drop_table(){
    table_old=$1
    ${exec_mysql} "truncate table ${table_old}"
    ${exec_mysql} "drop table ${table_old}"
}


function table_split_migrate(){
    # 1. 建立临时表
    t1=$(print_now)
    time create_table $table_name $table_tmp
    t2=$(print_now)
    echo "start $t1 end $t2 create_table $table_name $table_tmp"

    # 2. 迁移保留数据到临时表
    t1=$(print_now)
    time migration_data $table_name $table_tmp $time_table_new_start $time_table_new_end
    t2=$(print_now)
    echo "start $t1 end $t2 migration_data $table_name $table_tmp $time_table_new_start $time_table_new_end"

    # 3. 重命名原表为备份表，临时表为原表
    t1=$(print_now)
    time rename_table $table_name $table_tmp
    t2=$(print_now)
    time_table_insert_end=`date +"%F %T"`
    echo "start $t1 end $t2 rename_table $table_name $table_tmp"

    # 4. 补全迁移过程新增数据
    t1=$(print_now)
    time insert_data $table_bak $table_name "$time_table_insert_end"
    t2=$(print_now)
    echo "start $t1 end $t2 insert_data $table_bak $table_name $time_table_insert_end"
}


function table_split_drop(){
    # 5. 清理备份表
    t1=$(print_now)
    time drop_table $table_bak
    t2=$(print_now)
    echo "start $t1 end $t2 dorp_table $table_bak"
}

function delete_data(){
    table_old=$1
    start_time=$2
    end_time=$3
    for i in $(seq ${start_time} ${end_time})
    do
        time=$(date +%F -d "$i day ago")
        for hour in $(seq -w 0 23)
        do
            ${exec_mysql} "delete from ${table_old} where create_time >= \"${time} ${hour}:00:00\" and create_time <= \"${time} ${hour}:59:59\""
            sleep ${sleep_time}
        done
    done
}

function delete_data_table(){
    # 定期删除六个月前的数据
    delete_data ${table_name} 180 185 &> logs/table_delete.log
}


function table_split(){
    mkdir logs &> /dev/null
    table_backup ${table_name} &> logs/table_sql.log
    table_split_migrate &> logs/table_migrate.log  
    table_split_drop &> logs/table_drop.log
}

case $1 in
split)
    table_split;;
delete)
    delete_data_table;;
*)
   echo "$0 split|delete"
esac

