#!/bin/bash
# date: 2020/09/09
# auth: vera
# desc: install alertmanager
# https://github.com/prometheus/alertmanager

ip=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
port=9093
addr=${ip}:${port}
docker_name="alertmanager_${port}"
image_prefix="docker.io/11expose11"
conf=$(pwd)/../conf

docker_start() {
  docker run -d \
    --name ${docker_name} \
    -m 800m \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    -u root \
    -v ${conf}:/etc/alertmanager \
    ${image_prefix}/alertmanager:v0.18.0 \
    --config.file=/etc/alertmanager/alertmanager.yaml \
    --cluster.advertise-address=0.0.0.0:${port}
}

docker_stop() {
  docker stop ${docker_name}
  docker rm ${docker_name}
}

query_metrics() {
  curl -s http://${addr}/metrics
}

send_alert() {
  content='[{
    	"labels": {
       	       "alertname": "test-disk",
       	       "dev": "sda1"
          },
       "annotations": { "info": "The disk sda1 is running full" }
     },
     {
          "labels": {
               "alertname": "test-disk",
                "dev": "sdb1",
                "instance": "example3",
                "severity": "critical"
      }
    }]'
  curl -XPOST -d"$content" http://${addr}/api/v1/alerts
}

case $1 in
start)
  docker_start
  ;;
stop)
  docker_stop
  ;;
metric)
  query_metrics
  ;;
alert)
  send_alert
  ;;
*)
  echo "$0 start|stop|metric|alert"
  ;;
esac
