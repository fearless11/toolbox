#!/bin/bash
# date: 2021/12/29
# desc: install postgresql
# auth: vera
# note: https://juejin.cn/post/7046989978873626660/

start(){
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
}

stop(){
   docker stop postgresql
   docker rm postgresql
}

docker_exec(){
   docker exec -it postgresql bash
}

docker_log(){
   docker logs -f postgresql
}


case $1 in
start)
  start;;
stop)
  stop;;
ex)
  docker_exec;;
log)
  docker_log;;
esac
