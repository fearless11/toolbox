#!/bin/bash
# date: 2021/09/03
# auth: vera
# desc: install clickhouse

# https://clickhouse.tech/docs/zh/getting-started/install/

install(){
    grep -q sse4_2 /proc/cpuinfo
    if [[ $? != 0 ]];then
       echo "SSE 4.2 not supported"
       exit 1 
    fi
   
    sudo yum install yum-utils -y
    sudo rpm --import https://repo.clickhouse.tech/CLICKHOUSE-KEY.GPG
    sudo yum-config-manager --add-repo https://repo.clickhouse.tech/rpm/stable/x86_64
    # check version
    # yum list | grep clickhouse
    sudo yum install clickhouse-server-21.8.5.7-2.x86_64 clickhouse-client-21.8.5.7-2.x86_64 -y
}

configure(){
    # configure data dir path
    mkdir -p /data/clickhouse &> /dev/null
    chown -R  clickhouse:clickhouse /data/clickhouse 
    cat > /etc/clickhouse-server/config.d/path.xml <<EOF
<?xml version="1.0"?>
<yandex>
    <path>/data/clickhouse/</path>
    <tmp_path>/data/clickhouse/tmp/</tmp_path>
    <user_files_path>/data/clickhouse/user_files/</user_files_path>
</yandex>
EOF
}

start(){
   /etc/init.d/clickhouse-server start
}

stop(){
   /etc/init.d/clickhouse-server stop
}

status(){
   /etc/init.d/clickhouse-server status
}

log(){
   tail -n 10 /var/log/clickhouse-server/clickhouse-server.log
}

logerr(){
   tail -n 10 /var/log/clickhouse-server/clickhouse-server.err.log
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
log)
    log;;
logerr)
    logerr;;
*)
    echo "$0 install|start|stop|status|log|logerr"
esac

