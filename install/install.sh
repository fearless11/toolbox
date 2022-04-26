#!/bin/bash
# date: 2021/0608
# desc: docker install middleware 


install_mysql57(){
   datadir=/tmp/mysql57/data
   mkdir -p ${datadir} &> /dev/null

   docker run --name=mysql57 \
   -m 1G \
   --net=host \
   --restart=always \
   --log-opt max-size=100m \
   --log-opt max-file=10 \
   --mount type=bind,src=${datadir},dst=/var/lib/mysql \
   -d mysql/mysql-server:5.7

   # 查看密码
   # docker logs mysql57 2>&1 | grep GENERATED | awk '{print NF}'
   # 修改密码
   # docker exec -it mysql57 mysql -uroot -p
   # ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
   # 重新登陆
   # docker exec -it mysql57 mysql -uroot -p
}


install_haproxy(){
    docker run -d --name haproxy17 \
    --net=host \
    -v /tmp/haproxy:/usr/local/etc/haproxy:ro \
    haproxy:1.7.0

    # docker kill -s HUP haproxy17
}



#install_mysql57
install_haproxy




