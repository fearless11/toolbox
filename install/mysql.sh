#!/bin/bash
# date: 2021/06/23
# auth: vera
# desc: install mysql

docker_name=mysql
datadir=/tmp/mysql/data
mkdir -p ${datadir} &> /dev/null

# 首次需要修改密码
# 查看
# docker logs mysql 2>&1 | grep GENERATED | awk '{print $NF}'
# 修改
# docker exec -it mysql mysql -uroot -p
# ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
# 登陆
# docker exec -it mysql mysql -uroot -p

docker_start(){
   docker run --name=${docker_name} \
   -m 1G \
   --net=host \
   --restart=always \
   --log-opt max-size=100m \
   --log-opt max-file=10 \
   --mount type=bind,src=${datadir},dst=/var/lib/mysql \
   -d mysql/mysql-server:5.7
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
    docker exec -it ${docker_name} mysql -uroot -p'123456' -A
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

