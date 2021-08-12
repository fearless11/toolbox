#!/bin/bash
# date: 2021/08/12
# auth: vera
# desc: build linux image and run 


docker build -t ping_linux .
docker stop my_linux
docker rm my_linux
docker run -d  --name my_linux ping_linux
# docker tag  ping_linux  ccs.yun.com/npd-nmpc/ping_linux
# docker push ccs.yun.com/npd-nmpc/ping_linux

