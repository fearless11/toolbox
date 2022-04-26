#!/bin/sh
# date: 2020/09/08
# auth: vera
# desc: install prometheus
# doc: https://prometheus.io/docs/introduction/overview/

ip=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
port=9090
addr=${ip}:${port}
docker_name="prometheus_${port}"
image_prefix="docker.io/11expose11"
conf=$(pwd)/../conf
data=$(pwd)/../data/prometheus/data
campus=test

docker_start() {
  sed "s/CAMPUS/${campus}/g; s/SELFADDR/${addr}/g" ../conf/prometheus.tmpl >${conf}/prometheus.yaml
  mkdir ${data} &>/dev/null
  chmod 777 ${data}

  docker run -d --name=${docker_name} \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    -m 8g \
    -v ${conf}:/etc/prometheus \
    -v ${data}:/prometheus/data \
    ${image_prefix}/prometheus:2.19.2 \
    --config.file=/etc/prometheus/prometheus.yaml \
    --storage.tsdb.path=/prometheus/data \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.console.templates=/etc/prometheus/consoles \
    --web.enable-admin-api \
    --storage.tsdb.min-block-duration=2h \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.retention=2d \
    --web.enable-lifecycle \
    --log.level=info
}

docker_stop() {
  docker stop ${docker_name}
  docker rm ${docker_name}
}

# https://prometheus.io/docs/prometheus/latest/management_api/
reload() {
  curl -XPOST http://${addr}/-/reload
}

targets() {
  curl -XGET "http://${addr}/api/v1/targets" | python -m json.tool
}

# https://prometheus.io/docs/prometheus/latest/querying/api/
metrics() {
  curl -XGET "http://${addr}/api/v1/query?query=$1" | python -m json.tool
}

usage() {
  if [ $# != 2 ]; then
    echo "usage: $0 $1 $msg"
    exit 1
  fi
}

case $1 in
start)
  msg="campus_name"
  usage $*
  campus=$2
  docker_stop
  docker_start
  ;;
stop)
  docker_stop
  ;;
reload)
  reload
  ;;
targets)
  targets
  ;;
metrics)
  msg="metric_name"
  usage $*
  metrics $2
  ;;
*)
  echo "start|stop|reload|targets|metrics"
  ;;
esac
