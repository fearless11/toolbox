#!/bin/sh
# date: 2020/09/08
# auth: vera
# desc: install consul
# https://learn.hashicorp.com/tutorials/consul/deployment-guide
# https://mp.weixin.qq.com/s/yPyTWvMlia7YknMXdrsOXA

ip=$(/usr/sbin/ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
port=8501     # default: 8500
serf_lan=8311 # consul cluster conn
client_port=8502
addr=${ip}:${port}
image_prefix="docker.io/11expose11"
image="${image_prefix}/consul:1.8.0"
conf=$(pwd)/../conf
data=$(pwd)/../data/consul/data
consul_server_name="consul_server_${port}"
consul_client_name="consul_client_${client_port}"

consul_dev() {
  # http://127.0.0.1:8500
  docker run -d --name consul_dev \
    --net=host \
    -m 256m \
    ${image}
}

consul_server() {
  docker run -d --name ${consul_server_name} \
    -m 2g \
    --net=host \
    --restart=always \
    --log-opt max-size=100m \
    --log-opt max-file=10 \
    -v ${data}:/consul/data \
    -v ${conf}:/etc/consul/conf \
    --net=host \
    ${image} \
    agent \
    --server=true \
    -datacenter=prometheus \
    -config-file=/etc/consul/conf/consul_server.json \
    --client=0.0.0.0 \
    --data-dir=/consul/data \
    --node=consul-server-${ip} \
    --bind=${ip} \
    --retry-join=100.119.150.13:8311 \
    -ui
}

consul_client() {
  docker run -d --name ${consul_client_name} \
    -m 4g \
    --net=host \
    -v ${conf}:/etc/consul/conf \
    ${image} \
    agent \
    --server=false \
    -datacenter=prometheus \
    --client=0.0.0.0 \
    -config-file=/etc/consul/conf/consul_client.json \
    --node=consul-client-${ip} \
    --bind=${ip} \
    --retry-join=127.0.0.1:8311 \
    --retry-join=127.0.0.2:8311 \
    --retry-join=127.0.0.3:8311
}

docker_stop() {
  docker stop ${consul_server_name}
  docker rm ${consul_server_name}

  docker stop ${consul_client_name}
  docker rm ${consul_client_name}
}

query_datacenter() {
  curl -s http://${addr}/v1/catalog/datacenters
}

query_nodes() {
  curl -s http://${addr}/v1/catalog/nodes | python -m json.tool
}

query_service() {
  curl -s http://${addr}/v1/agent/services
}

test_register() {
  curl --request PUT \
    --url http://${addr}/v1/agent/service/register \
    --header 'content-type: "application/json"' \
    --data '{
    "id": "test-127.0.0.1",
    "name": "node_exporter",
    "tags": ["test"],
    "address": "127.0.0.1",
    "port": 8500,
    "checks": [
        {
            "http": "http://127.0.0.1:8500",
            "interval": "35s"
        }
    ]
   }'
}

test_delregister() {
  curl -XPUT "http://${addr}/v1/agent/service/deregister/$1"
}

usage() {
  if [ $# != 2 ]; then
    echo "usage: $0 $1 $msg"
    exit 1
  fi
}

case $1 in
dev)
  consul_dev
  ;;
server)
  consul_server
  ;;
client)
  consul_client
  ;;
datacenters)
  query_datacenter
  ;;
nodes)
  query_nodes
  ;;
service)
  query_service
  ;;
register)
  test_register
  ;;
delregister)
  msg="service_id"
  usage $*
  test_delregister $2
  ;;
stop)
  docker_stop
  ;;
*)
  echo "$0 dev|server|client|datacenters|nodes|service|register|delregister|stop"
  ;;
esac
