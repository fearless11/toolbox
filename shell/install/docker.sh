#!/bin/bash
# date: 2021/08/17
# auth: vera
# desc: install docker


data=/data1/docker


install(){
    # centos7
    yum install -y yum-utils device-mapper-persistent-data lvm2 
    # yum source
    # yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
   
    yum-config-manager --disable docker-ce-stable
    yum install docker-ce docker-ce-cli containerd.io -y 
}


configure(){
cat > /etc/docker/daemon.json <<EOF
{
   "graph": "${data}",
   "default-address-pools": [
       {
            "base": "172.17.0.0/16",
            "size": 24
        }
    ],
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "http://hub-mirror.c.163.com"
    ],
    "insecure-registries" : [ 
        "hub.oa.com",
        "dockerhub.woa.com",
        "docker.oa.com:8080",
        "csighub.tencentyun.com",
        "bk.artifactory.oa.com:8080"
    ]
}
EOF
}


remove(){
    yum remove docker-ce docker-ce-cli containerd.io -y
    rm -rf ${data}
}


start(){
    systemctl start docker
}


stop(){
    systemctl stop docker
}


status(){
    systemctl status docker
}


case $1 in
install)
    install
    configure;;
remove)
    remove;;
start)
    start;;
stop)
    stop;;
status)
    status;;
*)
    echo "$0 install|remove|start|stop|status"
esac
