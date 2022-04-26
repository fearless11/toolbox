#!/bin/bash
# date: 2022/04/24
# auth: vera
# desc: install grafana and mongodb_grafana

grafana="grafana"
mongodb_grafana="mongodb_grafana"
image_prefix="docker.io/11expose11"

grafana_start() {
  # add some grafana plugin, eg: mongodb-grafana
  docker run -d \
    --name ${grafana} \
    -m 800m \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    ${image_prefix}/grafana:6.7.2
}

grafana_stop() {
  docker stop ${grafana}
  docker rm ${grafana}
}

# https://github.com/JamesOsgood/mongodb-grafana
mongodb_grafana_start() {
  # grafana config mongodb datasource
  # grafana ——> mongodb-grafana ——> mongodb
  # 一个mongdb-grafana对应一个mongodb
  docker run -d \
    --name ${mongodb_grafana} \
    -m 800m \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    ${image_prefix}/mongodb-grafana:0.0.1
}

mongodb_grafana_stop() {
  docker stop ${mongodb_grafana}
  docker rm ${mongodb_grafana}
}

case $1 in
start)
  grafana_start
  ;;
stop)
  grafana_stop
  ;;
mongodb-grafana_start)
  mongodb_grafana_start
  ;;
mongodb-grafana-stop)
  mongodb_grafana_stop
  ;;
*)
  echo "grafana_start|grafana_stop|mongodb-grafana_start|mongodb-grafana_stop"
  ;;
esac
