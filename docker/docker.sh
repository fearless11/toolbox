#!/bin/bash
# date: 2022/06/22
# auth: vera
# desc: intsll Docker Engine on CentOS

# https://docs.docker.com/engine/install/centos/

# list version
# yum list docker-ce --showduplicates | sort -r
version="19.03.1"

install() {
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager \
        --add-repo \
        http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    yum install -y docker-ce-${version} docker-ce-cli-${version} containerd.io docker-compose-plugin
}

uninstall() {
    yum remove docker-ce-${version} docker-ce-cli-${version} containerd.io docker-compose-plugin

    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
}

start() {
    systemctl start docker
    systemctl enable docker
}

stop() {
    systemctl stop docker
}

status() {
    systemctl status docker
}

run() {
    docker run hello-world
}

case $1 in
install)
    install
    ;;
uninstall)
    uninstall
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
status)
    status
    ;;
run)
    run
    ;;
*)
    echo "$0 install|uninstall|start|stop|status|run"
    ;;
esac
