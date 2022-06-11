---
title: MySQL
date: 2020-10-11 8:00
tags: 中间件
description: MySQL开源数据库
toc: true
---

[toc]

# MySQL

## 安装

- Linux

```sh
# 注意：在CentOS7中，默认的数据库为Mariadb，当执行yum install mysql时只更新Mariadb数据库，并不会装MySQL
# 检查
rpm -qa | grep -i mariadb
rpm -qa | grep mariadb | xargs rpm -e --nodeps
rpm -qa | grep -i mariadb

# 更新yum源 /etc/yum.repos.d/
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm

# 安装
yum repolist all | grep mysql 
yum install mysql-server
rpm -qa | grep mysql
 
# 设置开机启动 
systemctl enable mysqld.service 
systemctl start mysqld.service 
systemctl restart mysqld.service 
systemctl stop mysqld.service 
```

- Docker

```sh
datadir=/tmp/mysql/data
mkdir -p ${datadir} &> /dev/nulldocker run --name=mysql \
   -m 1G \
   --net=host \
   --restart=always \
   --log-opt max-size=100m \
   --log-opt max-file=10 \
   --mount type=bind,src=${datadir},dst=/var/lib/mysql \
   -d mysql/mysql-server:5.7
   
# 查看密码
# docker logs mysql 2>&1 | grep GENERATED | awk '{print $NF}'
# 修改密码
# docker exec -it mysql mysql -uroot -p
#  ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
# 重新登陆
# docker exec -it mysql mysql -uroot -p
```

## 命令

- 常用

```sh
# 登录
mysql -uroot
mysql -h 127.0.0.1 -u root -p

# 监控 queries、Opens、Flush tables、Open tables、Queries per second avg信息
mysqladmin -uroot status

# 变量
show global variables;   
show variables;   
# 慢查询
show global variables like '%slow%'; 
# 编码
show variables like 'char%';
# 数据库
show create database mysql;
# 表
show create table mysql.user\G;
# 索引
show index from t_t1;

# 临时设置
set global long_query_time=120;  
set set long_query_time=60;
# ERROR 1067 (42000): Invalid default value for 'create_time'
# 允许create_time默认为0000-00-00 00:00:00 update NO_ZERO_DATE to ALLOW_INVALID_DATES
set sql_mode='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

# 备份
mysqldump -h localhost -uroot -p test,alarm > db_test_alarm.sql
# innodb不加锁
# --single-transaction option sets the transaction isolation mode to REPEATABLE READ
mysqldump -hlocalhost -uroot -p --opt --single-transaction --quick test > db_test.sql
# 表
mysqldump -h localhost -uroot -p test t_test > t_test.sql
# 表结构
mysqldump -h localhost -uroot -p test t_test --no-data > t_test_table.sql
mysqldump -h localhost -uroot -p test t_test --where id=1 > t_test_where.sql

# 恢复
mysqladmin create test;
mysql test < db_test_alarm.sql;

# 导出
mysql -h127.0.0.1 -uroot -p -e "select * from mysql.user" > /tmp/user.xls
mysql -h127.0.0.1 -uroot -p -e "select * from user" mysql > /tmp/user.xls

# 导入
mysql -hlocalhost -uroot -p -d test < db_test.sql
mysql>use test;
mysql>set names utf8;
mysql>source /t_test.sql;

# 授权
grant select on test.* to 'read_user'@'%' identified by '123456' with grant option;
grant all privileges on test.* to test@'%' identified by '123456' with grant option;
flush privileges;
```

- DDL（Data Definition Statements） 

```sh
# DDL:  隐性提交，不能回滚
# DDL:  create alter drop rename truncate

# create
create database test;
create table test.t_test (number int);
create table test.t_t1 (
     id int not null auto_increment,
     name varchar(255) not null,
     product varchar(255) not null,
     number int not null,
     key(id)
    )engine=InnoDB default charset=utf8;
# 复制表结构
create table t_t2 like t_t1;
# 复制表及数据
create table t_t3 as select * from t_t1;

# alter
alter database test character set utf8;
alter user 'test'@'%' identified with mysql_native_password by '123456';
# 索引
alter table t_t1 add index i_name (name);
# 新增自增主键
alter table t_test add id int;
alter table t_test change id id int not null auto_increment primary key;

# drop
drop database test;
drop table t_1;
drop user 'test'@'%';
drop index i_name on t_t1;

# rename
rename table t_test to t_test1
rename table t_test1 to t_test, t_2 to t_t1;

# truncate
# To achieve high performance, it bypasses the DML method of deleting data.
# Thus, it cannot be rolled back, it does not cause ON DELETE triggers to fire,
# and it cannot be performed for InnoDB tables with parent-child foreign key relationships.
truncate table t_test;
```

- DML (Data Manipulation Statements)

```sh
# DML:  可以手动控制事务的开启、提交和回滚
# DML:  insert delete select update call do hanler load replace

# insert
insert into t_test (id,number) values(1,11);
insert into t_test (id,number) values(2,22),(3,33),(4,44);
insert into t_test select id,number from t_t1;

# delete

# update
update t_t1 set product="orange" where id=4;

# select
select version();
# 时间
select now(), curdate(), curtime(), unix_timestamp(), to_days(curdate());
# select unix_timestamp('2021-06-10 12:33:55');
# select from_unixtime('1623328435','%Y-%m-%d %T');
# select from_unixtime('1623328435','%Y-%m-%d %H:%i:%s');

# 去重
select distinct name from t_test;
# 联合分组, 购买不同产品的用户
select product,group_concat(distinct name) from t_t1 group by product;
# 产品的平均销量
select product,avg(number) from t_t1 group by product;
# 销量大于80的产品
select product,avg(number) from t_t1 group by product having avg(number) > 80;
# 销量非60的产品置0
select product,case when number > 60 then number else 0 end as case_number from t_t1;
```

## 资料

- [https://dev.mysql.com/doc/refman/5.7/en/installing.html](https://dev.mysql.com/doc/refman/5.7/en/installing.html)
- [https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html](https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html)
- [https://repo.mysql.com/yum](https://repo.mysql.com/yum)
- [https://dev.mysql.com/doc/refman/5.7/en/docker-mysql-getting-started.html](https://dev.mysql.com/doc/refman/5.7/en/docker-mysql-getting-started.html)
- [DDL-https://dev.mysql.com/doc/refman/5.7/en/sql-data-definition-statements.html](https://dev.mysql.com/doc/refman/5.7/en/sql-data-definition-statements.html)
- [DML-https://dev.mysql.com/doc/refman/5.7/en/sql-data-manipulation-statements.html](https://dev.mysql.com/doc/refman/5.7/en/sql-data-manipulation-statements.html)
- [https://www.percona.com/software/database-tools/percona-toolkit](https://www.percona.com/software/database-tools/percona-toolkit)
