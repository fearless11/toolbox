#!/bin/bash
# date: 2021/06/28
# auth: vera
# desc: docker install redis

docker_name=redis
datadir=/tmp/redis/data
mkdir -p ${datadir} &> /dev/null


docker_start(){
   docker run --name=${docker_name} \
   -m 1G \
   --net=host \
   --restart=always \
   --log-opt max-size=100m \
   --log-opt max-file=10 \
   -v ${datadir}:/data \
   -d redis:6.0 \
   redis-server --appendonly yes
}

docker_stop(){
    docker stop ${docker_name}
    docker rm ${docker_name}
}

docker_logs(){
    docker logs --tail 10 ${docker_name}
}

docker_exec(){
    # docker exec -it ${docker_name} bash
    docker exec -it ${docker_name} redis-cli
}

case $1 in
start)
    docker_start;;
stop)
    docker_stop;;
logs)
    docker_logs;;
exec)
    docker_exec;;
esac

