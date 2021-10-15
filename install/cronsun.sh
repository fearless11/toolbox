#!/bin/bash
# date: 2021/08/06
# auth: vera
# desc: install cronsun 
# 分布式任务系统
# Git https://github.com/shunfei/cronsun
# webUI http://127.0.0.1:7079/ui/#/

mkdir -p /opt/soft &> /dev/null

install_depend(){
    # mongodb
    cd /opt/soft
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.2.tgz
    tar -xf mongodb-linux-x86_64-4.0.2.tgz
    cd /opt/soft/mongodb-linux-x86_64-4.0.2
    mkdir -p data/db logs &> /dev/null
cat > mongodb.conf <<EOF
dbpath=/opt/soft/mongodb-linux-x86_64-4.0.2/data/db
logpath=/opt/soft/mongodb-linux-x86_64-4.0.2/logs/mongo.log
bind_ip=0.0.0.0
port=27017
logappend=true
fork=true
EOF
    ./bin/mongod -f mongodb.conf

    # etcd
    cd /opt/soft
    wget https://github.com/etcd-io/etcd/releases/download/v3.4.13/etcd-v3.4.13-linux-amd64.tar.gz
    tar -xf etcd-v3.4.13-linux-amd64.tar.gz
    cd /opt/soft/etcd-v3.4.13-linux-amd64
    mkdir data  &> /dev/null
    nohup ./etcd --advertise-client-urls=http://0.0.0.0:2379 --listen-client-urls=http://0.0.0.0:2379 --data-dir=/opt/soft/etcd-v3.4.13-linux-amd64/data &
}

install_by_zip(){
    # cronsun
    cd /opt/soft
    wget https://github.com/shunfei/cronsun/releases/download/v0.3.5/cronsun-v0.3.5-linux-amd64.zip
    unzip cronsun-v0.3.5-linux-amd64.zip
    cp -ar cronsun-v0.3.5/* /data/cronsun
    sed -i 's/"Enabled": true/"Enabled": false/g' /data/cronsun/conf/web.json 
}

install_source_code(){
    mkdir -p /opt/github &> /dev/null
    cd /opt/github
    git clone https://github.com/shunfei/cronsun.git
    cd cronsun
    rm go.sum
    go clean -modcache
    go mod vendor
    sh build.sh
    cp -ar dist/* /data/cronsun/
    sed -i 's/"Enabled": true/"Enabled": false/g' /data/cronsun/conf/web.json 
}

install(){
    install_depend
    mkdir -p /data/cronsun &> /dev/null
    install_by_zip
    # install_source_code
}

start(){
    cd /data/cronsun
    nohup ./cronnode -conf conf/base.json >> ./node.log 2>&1 &
    nohup ./cronweb -conf conf/base.json >> ./web.log 2>&1 &
}

stop(){
    ps aux |egrep -E 'cronweb|cronnode' | grep -v grep | awk '{print $2}' | xargs kill
}

status(){
    ps aux |egrep -E 'cronweb|cronnode' | grep -v grep
}

case $1 in
install)
    install;;
start)
    start;;
stop)
    stop;;
status)
    status;;
*)
    echo "$0 install|start|stop|status"
esac

