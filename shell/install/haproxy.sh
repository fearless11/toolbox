#!/bin/bash
# date: 2021/09/03
# auth: vera
# desc: install haproxy

# reference
# http://www.haproxy.org
# http://demo.haproxy.org
# https://hub.docker.com/_/haproxy


docker_name=haproxy

start(){
    mkdir /etc/haproxy &> /dev/null
    cp -r conf/haproxy.cfg /etc/haproxy

    docker run -d --name ${docker_name} \
    --net=host \
    -v /etc/haproxy/:/usr/local/etc/haproxy/:ro \
    haproxy:1.7.0
}

stop(){
    docker stop ${docker_name}
    docker rm ${docker_name}
}

reload(){
    cp -r conf/haproxy.cfg /etc/haproxy/
    docker kill -s HUP ${docker_name}
}

bash(){
   docker exec -it ${docker_name} bash
}

log(){
   docker logs --tail=10 ${docker_name}
}

case $1 in
start)
    start;;
stop)
    stop;;
reload)
    reload;;
bash)
    bash;;
log)
    log;;
*)
    echo "$0 start|stop|bash|reload|log"
esac



