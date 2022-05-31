#!/bin/bash
# date: 2022/05/31

docker build -t centos .
docker run --rm linux ping 127.0.0.1

docker stop centos 
docker rm centos

docker run -d  --name ping-centos centos

