#!/bin/bash
# date: 2021/08/24
# auth: vera
# desc: clean db table

master=127.0.0.1
slave=127.0.0.2
db=arm
user=abc
password="abc123456"

# 变更背景
# DB是1000GB大小，目前使用率到91%，与开发和运营对齐:
# 1、清理部分无效历史数据，只保留最近6个月数据
# 2、清理掉无效表

# 变更范围
# t_chan_shield
# t_chan_alarm

# 变更操作
# 1、表备份，从db上备份
# 1.4.10.21 执行下面命令，注意执行机器的磁盘空间
for i in t_chan_shield
do
    echo $i
    time mysqldump -h $slave -u${user} -p${password}  --opt --single-transaction --default-character-set=latin1 ${db} $i > $i-`date +%F`.sql
done


# 2、数据检查
# MySQL [arm]>  select count(*) from t_net_chan_shield where create_time <'2021-02-24 00:00:00';
# +----------+
# | count(*) |
# +----------+
# |  7227960 |
# +----------+
# MySQL [arm]>  select count(*) from t_chan_alarm;
# +----------+
# | count(*) |
# +----------+
# |  5636483 |
# +----------+


# 3、数据清理
time mysql -h${master} -u${user} -p${password} --default-character-set=latin1 ${db} -e "truncate table t_chan_alarm;"
time mysql -h${master} -u${user} -p${password} --default-character-set=latin1 ${db} -e "drop table t_chan_alarm;"

for i in $(seq 730)
do
echo $i
time mysql -h${master} -u${user} -p${password} --default-character-set=latin1 ${db} -e "delete from t_net_chan_shield where create_time < '2021-02-24 00:00:00' limit 10000;"
sleep 1
done


# 变更验证
# db释放磁盘空间

# 变更风险
# 分批清理且有sleep， 对db负载可控

# 变更回退
# mysql -h${master} -u${user} -p${password} -d ${db} < t_net_chan_shield-`date +%F`.sql
