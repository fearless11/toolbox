#!/bin/bash
# data: 2020/08/06
# auth: vera
# desc: install pushgateway
# doc: https://github.com/prometheus/pushgateway
# https://www.cnblogs.com/xiao987334176/p/9933963.html

ip=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
port=9091
addr=${ip}:${port}
docker_name="pushgateway_${port}"
image="11expose11/pushgateway:v1.2.0"
data=$(pwd)/../data

start() {
  docker run -d --name ${docker_name} \
    -m 1g \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    -v ${data}/pushgateway/data:/data/pushmetrics \
    ${image} \
    --web.enable-admin-api \
    --persistence.file="/data/pushmetrics" \
    --persistence.interval=5m
}

stop() {
  docker stop ${docker_name}
  docker rm ${docker_name}
}

query_status() {
  curl -s -XGET http://${addr}/api/v1/status | python -m json.tool
}

query_metrics() {
  curl -s -X GET http://${addr}/api/v1/metrics | python -m json.tool
}

set_admin() {
  curl -XPUT http://${addr}/api/v1/admin/wipe
}

test_metric() {
  echo "test_metric 6.99" | curl --data-binary @- http://${addr}/metrics/job/pushgateway
}

test_metrics() {
  cat <<EOF | curl --data-binary @- http://${addr}/metrics/job/some_job/instance/some_instance
# TYPE some_metric counter
test_metric{label="val1"} 42
# TYPE another_metric gauge
# HELP another_metric Just an example.
two_metric 2398.283
EOF
}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
test-metric)
  test_metric
  ;;
test-metrics)
  test_metrics
  ;;
status)
  query_status
  ;;
metrics)
  query_metrics
  ;;
admin)
  set_admin
  ;;
*)
  echo "test-metric|test-metrics|status|metrics|admin"
  ;;
esac
