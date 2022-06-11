#!/bin/bash
# date: 20220/06/24
# auth: expose
# desc: Docker get start guide

# https://docs.docker.com/language/golang/build-images/

# build image
docker build -t docker-gs-ping .
docker image ls | grep docker-gs
docker run -d -p 8080:8080 --name docker-ping docker-gs-ping
curl localhost:8088
docker stop docker-ping
docker restart docker-ping
docker rm docker-ping

# build multistage image
docker build -t docker-gs-ping:multistage -f Dockerfile.multistage .
docker image ls | grep docker-gs
docker run -d -p 8088:8080 --name docker-ping docker-gs-ping:multistage
curl localhost:8088

# use contianers for development
docker volume create roach
docker volume list
docker network create -d bridge mynet
docker network list
docker network inspect mynet | grep Gateway -B 1
ip route show
