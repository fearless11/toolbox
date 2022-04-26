#!/bin/bash
# date: 2020/09/09
# auth: vera
# desc: install thanos
# doc: https://thanos.io

image="quay.io/thanos/thanos:v0.14.0"
conf=$(pwd)/../conf
data=$(pwd)/../data/thanos/data
addr_prometheus="127.0.0.1:9090"

thanos_sidecar() {
  docker run -d --name thanos_sidecar \
    -m 1g \
    --net=host \
    -v ${conf}:/etc/cos \
    -v ${data}/prometheus/data:/prometheus/data \
    ${image} \
    sidecar \
    --tsdb.path=/prometheus/data \
    --prometheus.url="${addr_prometheus}" \
    --objstore.config-file=/etc/cos/thanos_cos.yaml \
    --http-address=0.0.0.0:19191 \
    --grpc-address=0.0.0.0:19090 \
    --shipper.upload-compacted \
    --log.level=info
}

thanos_store() {
  docker run -d --name thanos_store \
    -m 1g \
    --net=host \
    -v ${conf}:/etc/cos \
    -v ${data}/thanos/store:/thanos/store \
    ${image} \
    store \
    --data-dir=/thanos/store \
    --objstore.config-file=/etc/cos/thanos_cos.yaml \
    --http-address=0.0.0.0:19193 \
    --grpc-address=0.0.0.0:19093
}

# http://127.0.0.1:19192
thanos_query() {
  docker run -d --name thanos_query \
    -m 1g \
    --net=host \
    ${image} \
    query \
    --http-address=0.0.0.0:19192 \
    --grpc-address=0.0.0.0:19092 \
    --store=${data}/prometheus/data \
    --store=${data}/thanos/store
}

stop() {
  docker stop thanos_sidecar
  docker rm thanos_sidecar

  docker stop thanos_store
  docker rm thanos_store

  docker stop thanos_query
  docker rm thanos_query
}

usage() {
  if [ $# != 2 ]; then
    echo "usage: $0 $1 $msg"
    exit 1
  fi
}

case $1 in
sidecar)
  thanos_sidecar
  ;;
store)
  thanos_store
  ;;
query)
  thanos_query
  ;;
stop)
  stop
  ;;
*)
  echo "$0 sidecar|store|query|stop"
  ;;
esac
