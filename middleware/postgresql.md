[toc]

# PostgreSQL

## 安装

```sh
   docker run -d -p 5432:5432 --name=postgresql \
    --net=host \
    --privileged \
    --ulimit nofile=655350 \
    --ulimit memlock=-1 \
    --memory=800M \
    --memory-swap=-1 \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    -v /data/backup/pgdata/grafana:/var/lib/postgresql/data \
    -v /data/backup/pgdata:/var/lib/postgresql/backup \
    postgres:10.6
```

## 命令

- 交互式

```sh
# 本地登录
su - postgres
psql

# 本地退出
\q

# 查看帮助
\help
\h select

### 数据库
# 创建库
create database test11;
# 查看库
\l
# 进入库
\c test11
# 删除库
drop database test11;
# 删除库 不存在不报错仅警告
drop database if exists test;

### 数据表
# 场景表
create table t_test( 
    id int,
    num int,
    name char(30),
    primary key(id)
);
# 查看表
\d
# 查看表信息
\d t_test;
# 删除表
drop table t_test;


### 数据
# 插入
insert into t_test(id,num,name) values(1,11,'aaaa');
# 多行插入
insert into t_test(id,num,name) values(3,33,'cccc'),(2,22,'bbbb');
# 查询
select * from t_test;
# 单引号
select * from public.user where login='admin'; 
# 条件查询
select * from t_test where id>=2;
# 表达式查询
select current_timestamp as now,count(*) from t_test;
# where子句查询
select * from t_test where id in (1,2);
# 更新
update t_test set name='c1' where id=3;
# 删除
delete from t_test where id=3;
# 删除表
delete from t_test;


### 模式
# 一个模块可以包含多个表，模式不能嵌套
# 创建模式
create schema testschema;
# 创建模式表
create table testschema.t_test13(
   id int not null,
    num int,
    name char(30),
    primary key(id)
);
# 查看表
select * from testschema.t_test13;
# 删除模块
drop schema testschema;
# 删除模式所有信息
drop schema testschema cascade;


### 索引
# 查看
select * from pg_indexes where tablename='data_source';
select * from pg_statio_all_indexes where relname='log';
# 创建
CREATE UNIQUE INDEX "UQE_data_source_org_id_uid" ON "data_source" ("org_id","uid");
# 删除 双引号
drop index "UQE_data_source_org_id_uid";


### 约束
# 查看
select * from information_schema.table_constraints;
# 删除
alter table data_source drop constraint data_source_pkey1;
```

- 命令行

```sh
# 远程登录
psql -h localhost -p 5432 -U postgres test12
# 远程创库
createdb -h localhost -p 5432 -U postgres test12
# 远程删库
dropdb -h localhost -p 5432 -U postgres test12


# 备份库
 pg_dump -h localhost -p 5432 -U postgres -d grafana -f grafana.sql
# 恢复库
psql -h localhost -p 5432 -U postgres -d grafana_test -f grafana.sql 


# 全量备份
pg_basebackup -Ft -z -h localhost -p 5432 -U postgres -X stream -D /backup
# 全量恢复
mkdir /recover
tar xvf /backup/base.tar.gz -C /recover
tar xvf /backup/pg_wal.tar.gz -C /recover/recover/pg_wal/
# 重启pg
./pg_ctl -D /recover start
```

## 资料
- [https://www.postgresql.org/docs/10/index.html](https://www.postgresql.org/docs/10/index.html)
- [https://hub.docker.com/_/postgres](https://hub.docker.com/_/postgres?tab=tags)

