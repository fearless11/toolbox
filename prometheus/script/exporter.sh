#!/bin/sh
# date: 2021/09/01
# auth: vera
# desc: docker deploy exporter and register to consul|kong

filename=conf/exporter.conf
url_ops_exporter="127.0.0.1:8080"
image_prefix="docker.io/11expose11"
ip_local=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
default_port=9000
echo $(date +%F-%T) >fall.ip

# 获取临时端口
get_random_port() {
    temp=0
    while [ $temp == 0 ]; do
        random=$(shuf -i 3000-4000 -n1)
        netstat -an | grep -w ":${random}" | grep 'LISTEN' && continue
        temp=${random}
    done
    export listen_port=$temp
}

# 解析配置文件
parse_field() {
    line=$(echo $1)
    echo $line | grep "^#" &>/dev/null && continue
    export middleware=$(echo $line | awk -F, '{print $1}')
    export ip=$(echo $line | awk -F, '{print $2}' | awk -F: '{print $1}')
    export port=$(echo $line | awk -F, '{print $2}' | awk -F: '{print $2}')
    export addr=$(echo $line | awk -F, '{print $2}')
    export docker_name=${middleware}_${ip}_${port}
    export business_name=$(echo $line | awk -F, '{print $3}')
    export version=$(echo $line | awk -F, '{print $4}')
    export user=$(echo $line | awk -F, '{print $5}' | awk -F';' '{print $1}')
    export passwd=$(echo $line | awk -F, '{print $5}' | awk -F';' '{print $2}')
    get_random_port
    export exporter=${ip_local}:${listen_port}
}

# 启动容器
docker_start() {
    while read line; do
        parse_field $line

        # 检查网络是否连通
        which nc &>/dev/null || yum install nmap-ncat -y &>/dev/null
        # nc -w 1 $ip $port  < /dev/null &> /dev/null && echo "ok $ip $port" || echo "fail $ip $port"
        nc -w 1 ${ip} ${port} </dev/null &>/dev/null
        if [[ $? == 1 ]]; then
            echo "check network fail ${ip} ${port}" | tee -a fall.ip
            continue
        fi

        # 检查容器是否运行
        docker ps | grep ${docker_name} && continue
        echo ${docker_name}

        case ${middleware} in
        mysql)
            deploy_mysql
            register_kong_consul
            ;;
        redis)
            deploy_redis
            register_kong_consul
            ;;
        kafka)
            deploy_kafka
            register_kong_consul
            ;;
        mongodb)
            deploy_mongodb
            register_kong_consul
            ;;
        memcached)
            deploy_memcached
            register_kong_consul
            ;;
        haproxy)
            deploy_haproxy
            register_kong_consul
            ;;
        node)
            deploy_node_exporter
            register_consul
            ;;
        process)
            deploy_process_exporter
            register_consul
            ;;
        cadvisor)
            deploy_cadvisor
            register_consul
            ;;
        *)
            echo "${middleware} no match"
            continue
            ;;
        esac

    done <${filename}
}

# 停止容器
docker_stop() {
    while read line; do
        echo " "
        parse_field $line
        docker stop ${docker_name}
        docker rm ${docker_name}
        deregister_kong_consul
    done <${filename}
}

# 查看容器日志
docker_log() {
    while read line; do
        parse_field $line
        echo ${docker_name}
        docker logs --tail 1 ${docker_name}
    done <${filename}
}

# 运行容器注册
docker_register() {
    while read line; do
        parse_field $line
        docker ps | grep ${docker_name} &>/dev/null
        if [[ $? == 1 ]]; then
            echo "${docker_name} not running"
            continue
        fi

        pid=$(docker inspect ${docker_name} | grep -iw pid | awk -F: '{print $2}' | tr -d ',')
        export listen_port=$(netstat -nlput | grep "${pid}/" | awk -F: '{print $4}' | tr -d ' ')
        export exporter=${ip_local}:${listen_port}

        echo "listen_port: $listen_port $docker_name $exporter"
        register_kong_consul &>/dev/null
    done <${filename}

}

# 注册到kong和consul
register_kong_consul() {
    curl -s -XPOST ${url_ops_exporter}/v1/service -d '{
        "name": "'${middleware}'",
        "alias": "'${business_name}'",
        "ip": "'${ip}'",
        "port": '${port}',
        "addr": "'${exporter}'"
    }'
    echo " "
}

# 注销在kong和consul
deregister_kong_consul() {
    curl -s -XDELETE "${url_ops_exporter}/v1/service?name=${middleware}&ip=${ip}&port=${port}"
}

# 注册consul
register_consul() {
    curl -XPOST "${url_ops_exporter}/v1/consul/service" -d'{
        "name": "'${middleware}'",
        "alias": "'${business_name}'",
        "ip": "'${ip}'",
        "port": '${port}',
        "addr": "'${exporter}'"
    }'
}

# 注销consul
deregister_consul_service() {
    curl -X DELETE "${url_ops_exporter}/v1/consul/service?service=${middleware}"
}

# mysql_exporter https://github.com/prometheus/mysqld_exporter
deploy_mysql() {
    # CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'XXXXXXXX' WITH MAX_USER_CONNECTIONS 3;
    # GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
    if [ "x$version" == "x5.0" ]; then
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            -e DATA_SOURCE_NAME="$user:$passwd@($ip:$port)/" \
            ${image_prefix}/mysqld-exporter:0.8.1 \
            --web.listen-address=":${listen_port}"
    else
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            -e DATA_SOURCE_NAME="${user}:${passwd}@(${ip}:${port})/" \
            ${image_prefix}/mysqld-exporter:v0.12.1 \
            --web.listen-address=":${listen_port}"
    fi
}

# redis_exporter https://github.com/oliver006/redis_exporter https://github.com/fearless11/redis_exporter
deploy_redis() {
    # 默认自建无账号  1.0 密码  2.0 账号密码
    if [ "x$version" == "x1.0" ]; then
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            ${image_prefix}/redis_exporter:qcloud \
            -web.listen-address=:${listen_port} \
            -redis.addr=redis://${ip}:${port} \
            -redis.password=${passwd}
    elif [ "x$version" == "x2.0" ]; then
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            ${image_prefix}/redis_exporter:qcloud \
            -web.listen-address=:${listen_port} \
            -redis.addr=redis://${ip}:${port} \
            -redis.password=${user}@${passwd}
    else
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            ${image_prefix}/redis_exporter:v1.10.0 \
            -web.listen-address=:${listen_port} \
            -redis.addr=redis://${ip}:${port}
    fi
}

# kafka_exporter https://github.com/danielqsj/kafka_exporter
deploy_kafka() {
    if [ "x$version" == "x0.1" ]; then
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            ${image_prefix}/kafka-exporter:v1.2.1 \
            --kafka.server=${ip}:${port} \
            --kafka.version=0.10.0.1 \
            --web.listen-address=":${listen_port}" \
            --log.level=info
    else
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            ${image_prefix}/kafka-exporter:v1.2.1 \
            --kafka.server=${ip}:${port} \
            --web.listen-address=":${listen_port}" \
            --log.level=info
    fi
}

# mongodb_exporter https://github.com/percona/mongodb_exporter
deploy_mongodb() {
    if [ "x$version" == "x2.0" ]; then
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            -e MONGODB_URI="mongodb://${user}:${passwd}@${ip}:${port}" \
            ${image_prefix}/mongodb-exporter:0.9.0 \
            --web.listen-address=":${listen_port}"
    else
        docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            -e MONGODB_URI="mongodb://${ip}:${port}" \
            ${image_prefix}/mongodb-exporter:0.9.0 \
            --web.listen-address=":${listen_port}"
    fi
}

# memcached_exporter https://github.com/prometheus/memcached_exporter
deploy_memcached() {
    docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        ${image_prefix}/memcached-exporter:v0.8.0 \
        --memcached.address="${ip}:${port}" \
        --web.listen-address=":${listen_port}"
}

# haproxy_exporter https://github.com/prometheus/haproxy_exporter
deploy_haproxy() {
    docker run -d \
        -m 256m \
        --name ${docker_name} \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        ${image_prefix}/haproxy-exporter:v0.12.0 \
        --haproxy.scrape-uri="http://127.0.0.1:8080/haproxy_stats/${ip}/haproxy1;csv" \
        --web.listen-address=:${listen_port}
}

# node_exporter https://github.com/prometheus/node_exporter
deploy_node_exporter() {
    docker run -d --name=${docker_name} \
        --net=host \
        --pid=host \
        -m 2g \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        --volume=$(pwd)/plugin:/plugin \
        --volume=/:/host:ro,rslave \
        --volume=/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
        ${image_prefix}/node-exporter:v1.0.1 \
        --path.rootfs=/host \
        --path.procfs=/proc \
        --path.sysfs=/sys \
        --web.disable-exporter-metrics \
        --collector.textfile.directory=/plugin \
        --collector.systemd \
        --log.level=info \
        --web.listen-address=":9100"

    export exporter=${ip_local}:9100
}

# process_exporter https://github.com/ncabatoff/process-exporter
deploy_process_exporter() {
    docker run -d --name=${docker_name} \
        --net=host \
        -m 2g \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        --privileged \
        --volume=/proc:/host/proc \
        --volume=$(pwd)/conf/:/config \
        ${image_prefix}/process-exporter:v0.7.5 \
        --procfs=/host/proc \
        -threads=false \
        -config.path=/config/process_exporter.yaml \
        --web.listen-address=":9256"

    export exporter=${ip_local}:9256
}

# cadvisor https://github.com/google/cadvisor
deploy_cadvisor() {
    # mount -o remount,rw '/sys/fs/cgroup'
    # ln -s /sys/fs/cgroup/cpu,cpuacct /sys/fs/cgroup/cpuacct,cpu
    docker run -d \
        --name=${docker_name} \
        --restart=always \
        --net=host \
        -m "800m" \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        --volume=/:/rootfs:ro \
        --volume=/var/run:/var/run:rw \
        --volume=/sys:/sys:ro \
        --volume=/sys/fs/cgroup/:/sys/fs/cgroup/:ro \
        --volume=/var/lib/docker/:/var/lib/docker:ro \
        --volume=/dev/disk/:/dev/disk:ro \
        --privileged=true \
        --device=/dev/kmsg \
        --detach=true \
        ${image_prefix}/cadvisor:0.36.0 \
        --port=8080 \
        -disable_metrics="disk,diskIO,network,tcp,udp,percpu,sched,process" \
        -docker_only=true \
        -raw_cgroup_prefix_whitelist="/docker"

    export exporter=${ip_local}:8080
}

usage() {
    if [ $# != 2 ]; then
        echo "usage: $0 $1 configure_file"
        exit 1
    fi
    filename=$2
}

main() {
    case $1 in
    start)
        usage $*
        docker_start
        ;;
    stop)
        usage $*
        docker_stop
        ;;
    log)
        usage $*
        docker_log
        ;;
    reg)
        usage $*
        docker_register
        ;;
    *)
        echo "start|stop|log|reg configure_file"
        ;;
    esac
}

main
