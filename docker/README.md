[toc]

# docker

## 介绍
Docker是一个用于开发、交付和运行应用程序的开放平台。使用的是client-server架构。Docker daemon监听请求管理images、containers、networks、volumes对象。Docker clinet是用户与Docker交互的基本方式。

## 特点
- 快速、一致地开发交付程序。容器环境标准化后简化开发生命周期，适合CI/CD的工作流程
- 响应式部署和扩展程序。Docker容器运行平台支持多种，服务器、虚拟机、云
- 相同硬件运行更多负载。Docker是轻量快速，可以使用更少资源运行程序，提高基础硬件资源使用率

## 概念原理：是什么、怎么运行
- Docker 容器平台
- images 镜像是一个只读模板，里面包括创建容器的说明。通常一个镜像是基于另一个镜像制作
- container 容器是镜像的运行实例。与其他容器是隔离，可设置网络、存储等隔离

## 安装

- [install on centos7](https://github.com/fearless11/toolbox/blob/master/docker/docker.sh)
- [docker guide](https://github.com/fearless11/toolbox/tree/master/docker/guide)

## 配置

```bash
# 配置根目录、容器网段池、镜像仓库及安全仓库
cat <<EOF > /etc/docker/daemon.json1
{
  "data-root": "/data/docker",
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
  "insecure-registries": ["hub.oa.com", "dockerhub.woa.com"]
}
EOF

# 重启服务
systemctl stop docker
systemctl start docker

# 查看配置
docker info | grep -i data-root
```

## 命令

- Docker

```bash
# 帮助
docker help

# 版本
docker version

# 配置
docker info

# server 指定监听的端口
docker daemon -H ip:port
# client
docker -H tcp://ip:port version
```

- 镜像

```bash
# 登陆远程仓库
docker login
docker login -u admin -p *** harbor.oa.com

# 退出远程仓库
docker logout

# 拉取镜像
docker pull centos
docker pull www.oa.com/library/mq-sender:v1
docker pull host:port/mq-sender:v1

# 推送镜像
docker push centos
docker push www.oa.com/library/mq-sender:v1
docker push host:port/mq-sender:v1

# 查看镜像
docker image ls
docker images
docker images | grep none | awk '{print $3 }'| xargs docker rmi

# 查看镜像分层信息
docker history name:tag
docker history name:tag --no-trunc  # 不截断

# 查看镜像详情
docker inspect name:tag 

# 镜像打标记
docker tag name:tag name1:tag1

# 搜索自动创建星级为3以上的带ngnix的镜像
docker search --automated -s 3 nginx

# 删除镜像，只有所有tag删除才是最后删除
docker rmi name:tag

# 创建，基于当前目录Dockerfile创建
docker build -t name:tag .
# 创建，基于当前运行容器
docker commit -m "add a configure file" -a "vera" containerID  name:tag
# 创建，基于容器快照，当时的快照状态，没有历史记录和元信息
docker export -o test_haproxy.tar test_haproxy
docker export test_haproxy > test_haproxy.tar
docker import test_haproxy.tar - register/name:tag
# 创建，基于模板 http://openvz.org/Download/templates/precreated
wget http://download.openvz.org/template/precreated/centos-6-x86-devel.tar.gz
docker import centos-6-x86-devel.tar.gz centos6:devel
cat centos-6-x86-devel.tar.gz | docker import - name:tag

# 导出导入
docker save -o xxx.tar name:tag
docker load --input xxx.tar
docker load < xxx.tar
```

- 容器

```bash
# 一次性运行
docker run --rm centos date

# 后台运行
docker run -d --name=test_haproxy \
	--net=host \
	--restart=always \
  --privileged \
  --ulimit nofile=655350 \
  --ulimit memlock=-1 \
  --memory=800M \
  --memory-swap=-1 \
  --log-opt max-size=100m \
  --log-opt max-file=10 \
	hparoxy:latest

# 挂载
docker run -d --name haproxy -v /hproxy/conf:/etc/haproxy haproxy
docker run -d --name haproxy -v /hproxy/conf:/etc/haproxy:ro haproxy

# 端口，一个、多个、指定ip、随机端口
docker run -d -p 5000:5000 --name web1 name:tag
docker run -d -p 5000:5000 -p 3000:80 --name web1 name:tag 
docker run -d -p 127.0.0.1:5000:5000 --name web1 name:tag
docker run -d -p 127.0.0.1::5000 --name web1 name:tag

# 启动与停止
docker start test_haproxy
docker stop test_haproxy
docker restart test_haproxy

# 删除
docker rm test_haproxy
docker rm -f test_haproxy

# 查看
docker ps
docker ps -a
docker ps -a |grep Exited | awk '{print $1}' | xargs -I{} docker rm  {}

# 查看详情
docker inspect test_haproxy | grep -iw Pid

# 查看日志
docker logs test_haproxy --tail=10

# 进入
docker exec -it test_haproxy /bin/bash
docker exec -it test_haproxy /bin/bash -c 'date'
```

- [docs.docker.com](https://docs.docker.com/language/golang/)
- [docker-config](https://docs.docker.com/engine/reference/commandline/dockerd/)
- [hub.docker.com](https://hub.docker.com/)
- [docker从入门到实战](https://yeasy.gitbook.io/docker_practice/introduction)
- [镜像-阿里-mirrors.aliyun.com](https://mirrors.aliyun.com/mirror/)
- [镜像-163-mirrors.163.com](http://mirrors.163.com/centos/7/isos/x86_64/)
- [镜像-华为-mirrors.huaweicloud.com](https://mirrors.huaweicloud.com/)
- [镜像-中科大-mirrors.ustc.edu.cn](http://mirrors.ustc.edu.cn/) 
