#!/bin/bash
# date: 2021/09/17
# auth: vera
# desc: install dkron by docker 

# https://www.codeleading.com/article/33045824429
# https://dkron.io/api/#/executions/listExecutionsByJob

start(){
    docker run -d -p 8080:8080 -v /usr/local/python3.6:/usr/local/python3.6 -v /data/project/dial:/data/project/dial  -v ~/dkron.data:/dkron.data --name dkron dkron/dkron agent --server --bootstrap-expect=1 --data-dir=/dkron.data
}

stop(){
    docker stop dkron
    docker rm dkron
}

execit(){
    docker exec -it dkron bash
}

log(){
    docker logs --tail=20 dkron
}

createjob(){
curl 9.135.91.98:8080/v1/jobs -XPOST -d '{
  "name": "job2",
  "schedule": "@every 60s",
  "timezone": "Asia/Shanghai",
  "owner": "vera",
  "owner_email": "vera@123.com",
  "disabled": false,
  "tags": {
    "server": "true:1"
  },
  "metadata": {
    "user": "8080"
  },
  "concurrency": "allow",
  "executor": "shell",
  "executor_config": {
    "command": "python3 /data/project/dial/dial.py"
  }
}'

}

case $1 in
start)
    start;;
stop)
    stop;;
exec)
   execit;;
cjob)
    createjob;;
log)
   log;;
esac

