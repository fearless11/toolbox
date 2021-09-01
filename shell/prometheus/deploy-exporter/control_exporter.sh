#!/bin/sh
# date: 2021/09/01
# auth: verajiang
# desc: 安装exporter并注册到kong和consul
# file: control_exporter.sh

filename=test.conf
url_ops_exporter="ops-exporter.cloud-exporter.tencent-cloud.com:8080"
ip_local=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}'|tail -1)
default_port=9000
echo `date +%F-%T` > fail.ip

# 获取临时端口
get_random_port(){
   temp=0
   while [ $temp == 0 ];do
      random=$(shuf -i 3000-4000 -n1)
      netstat -an | grep -w ":${random}" | grep 'LISTEN' && continue
      temp=${random}
   done
   export listen_port=$temp
}

# 解析配置文件中字段
# 类型,IP:PORT,说明业务,版本,用户;密码
# kafka,10.240.92.58:9092,测试kafka,[version],[user];[passwd]
parse_field(){
   line=$(echo $1)
   echo $line | grep "^#" &> /dev/null && continue 
   export middleware=$(echo $line | awk -F, '{print $1}')
   export ip=$(echo $line | awk -F, '{print $2}' | awk -F: '{print $1}')
   export port=$(echo $line | awk -F, '{print $2}' | awk -F: '{print $2}')
   export addr=$(echo $line | awk -F, '{print $2}')
   export docker_name=${middleware}-${ip}-${port}
   export business_name=$(echo $line | awk -F, '{print $3}')
   export version=$(echo $line | awk -F, '{print $4}')
   export user=$(echo $line | awk -F, '{print $5}' | awk -F';' '{print $1}')
   export passwd=$(echo $line | awk -F, '{print $5}' | awk -F';' '{print $2}')
   get_random_port
   export exporter=${ip_local}:${listen_port}
}

# 启动中间件的容器
docker_start(){
    while read line
    do
        parse_field $line
        #echo "$exporter"

        # 检查网络是否连通
        which nc &> /dev/null || yum install nmap-ncat -y &> /dev/null
        nc -w 1 ${ip} ${port}  < /dev/null &> /dev/null 
        if [[ $? == 1 ]];then 
            echo "check network fail ${ip} ${port}" | tee -a  fail.ip
            continue
        fi

        # 检查容器是否运行 
        docker ps | grep ${docker_name} && continue 
        echo ${docker_name} 

        case ${middleware} in
        mysql)
            deploy_mysql;;
        redis)
            deploy_redis;;
        kafka)
            deploy_kafka;;
        mongodb)
            deploy_mongodb;;
        memcached)
            deploy_memcached;;
        haproxy)
            deploy_haproxy;;
        *)
            echo "${middleware} no match"
            continue;;
        esac
 
        exporter_register
        
    done < ${filename}
}

# 停止中间件的容器
docker_stop(){
    while read line
    do
        echo " "
        parse_field $line
        docker stop ${docker_name}
        docker rm ${docker_name}
        exporter_deregister
    done < ${filename}
}

# 查看容器日志
docker_log(){
    while read line
    do
      parse_field $line
      echo ${docker_name}
      docker logs --tail 1 ${docker_name}
    done < ${filename}
}

# 容器注册
docker_register(){
    while read line
    do
      parse_field $line
      docker ps | grep ${docker_name} &> /dev/null
      if [[ $? == 1 ]];then
           echo "${docker_name} not running"
           continue
      fi

      pid=$(docker inspect ${docker_name} | grep -iw pid | awk -F: '{print $2}' | tr -d ',')
      export listen_port=$(netstat -nlput |grep "${pid}/" | awk -F: '{print $4}' |tr -d ' ')
      export exporter=${ip_local}:${listen_port}
      
      echo "listen_port: $listen_port $docker_name $exporter"
      # num=$(curl -s http://${exporter}/metrics | wc -l)
      # echo "metrics: ${num}"
      exporter_register &> /dev/null
    done < ${filename}

}

# 注册exporter到kong和consul
exporter_register(){
    curl -s -XPOST ${url_ops_exporter}/v1/service -d '{
        "name": "'${middleware}'",
        "alias": "'${business_name}'",
        "ip": "'${ip}'",
        "port": '${port}',
        "addr": "'${exporter}'"
    }'
    echo " "
}

# 在kong和consul中注销exporter
exporter_deregister(){
    curl -s -XDELETE  "${url_ops_exporter}/v1/service?name=${middleware}&ip=${ip}&port=${port}"
}

# 部署mysql_exporter（兼容5.0以下低版本）
deploy_mysql(){
      if [ ${version} == "5.0" ]
      then
       docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        -e DATA_SOURCE_NAME="${user}:${password}@(${ip}:${port})/" \
        mirrors.tencent.com/nops/mysqld-exporter:0.8.1 \
        --web.listen-address=":${listen_port}" 
      else
       docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        -e DATA_SOURCE_NAME="${user}:${password}@(${ip}:${port})/" \
        mirrors.tencent.com/nops/mysqld-exporter:v0.12.1 \
        --web.listen-address=":${listen_port}" 
      fi
}

# 部署redis_exporter 
deploy_redis(){
      # 默认自建无账号 1.0 密码  2.0 账号密码
      if [[ ${version} == "1.0" ]]
      then
        docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        mirrors.tencent.com/nops/redis_exporter:qcloud \
        -web.listen-address=:${listen_port} \
        -redis.addr=redis://${ip}:${port} \
        -redis.password=${passwd} 
      elif [[ ${version} == "2.0" ]]
      then
        docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        mirrors.tencent.com/nops/redis_exporter:qcloud \
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
         mirrors.tencent.com/nops/redis_exporter:v1.10.0 \
         -web.listen-address=:${listen_port} \
         -redis.addr=redis://${ip}:${port}
      fi
}

# 部署kafka_exporter (兼容0.10)
deploy_kafka(){
      if [ "x$version" == "x0.1" ]
      then
          docker run -d \
            --name ${docker_name} \
            -m 256m \
            --net=host \
            --restart=always \
            --log-opt max-size=100m \
            --log-opt max-file=10 \
            mirrors.tencent.com/nops/kafka-exporter:v1.2.1 \
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
            mirrors.tencent.com/nops/kafka-exporter:v1.2.1 \
            --kafka.server=${ip}:${port} \
            --web.listen-address=":${listen_port}" \
            --log.level=info
      fi
}

# 部署mongodb_exporter (兼容是否有密码设置)
deploy_mongodb(){
      if [ "x$version" == "x2.0" ]
      then
        docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        -e MONGODB_URI="mongodb://${user}:${passwd}@${ip}:${port}" \
        mirrors.tencent.com/nops/mongodb-exporter:0.9.0 \
        --web.listen-address=":${listen_port}"
      elif [[ ${version} == "1.0" ]]
      then
        docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        -e MONGODB_URI="mongodb://${user}:${passwd}@${ip}:${port}" \
        mirrors.tencent.com/nops/mongodb-exporter:0.9.0 \
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
        mirrors.tencent.com/nops/mongodb-exporter:0.9.0 \
        --web.listen-address=":${listen_port}"
      fi
}

# 部memcached_exporter
deploy_memcached(){
        docker run -d \
        --name ${docker_name} \
        -m 256m \
        --net=host \
        --restart=always \
        --log-opt max-size=100m \
        --log-opt max-file=10 \
        mirrors.tencent.com/nops/memcached-exporter:v0.8.0 \
        --memcached.address="${ip}:${port}" \
        --web.listen-address=":${listen_port}" 
}

# 部haproxy_exporter
deploy_haproxy(){
    docker run -d \
    -m 256m \
    --name  ${docker_name} \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    mirrors.tencent.com/nops/haproxy-exporter:v0.12.0 \
    --haproxy.scrape-uri="http://iyunwei.oa.com/haproxy_stats/${ip}/haproxy1;csv" \
    --web.listen-address=:${listen_port}
}

usage() {
  if [ $# != 2 ]
  then
     echo "usage: $0 $1 configure_file"
     exit 1
  fi
  filename=$2
}

case $1 in
start)
    usage $*
    docker_start;;
stop)
    usage $*
    docker_stop;;
log)
    usage $*
    docker_log;;
reg)
    usage $*
    docker_register;;
*)
    echo "start|stop|log|reg configure_file"
esac
