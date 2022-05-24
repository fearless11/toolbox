#!/bin/sh
# date: 2022/03/08
# auth: vera
# desc: clean docker env

docker ps -a |grep Exited | awk '{print $1}' | xargs -I{} docker rm  {}
docker images|grep none|awk '{print $3 }'|xargs docker rmi


