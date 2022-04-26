#!/bin/bash
# date: 2022/04/24
# auth: vera
# desc: install kong and konga
# https://docs.konghq.com/gateway/latest/install-and-run/docker
# https://github.com/pantsel/konga#production-docker-image

ip=$(ip add | grep inet | grep global | grep -Ev 'docker' | awk '{print $2}' | awk -F/ '{print $1}' | tail -1)
dir_conf=$(pwd)
data=$(pwd)/../data

postgresql() {
    docker run -d --name prom-kong-postgres \
        -p 5432:5432 \
        -e POSTGRES_DB=kong \
        -e POSTGRES_USER=kong \
        -e POSTGRES_PASSWORD=kong \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v ${data}/postgresql/data:/var/lib/postgresql/data/pgdata \
        postgres:9.6
}

kong_prepare_database() {
    docker run --rm \
        --link prom-kong-postgres:prom-kong-postgres \
        -e KONG_DATABASE=postgres \
        -e KONG_PG_DATABASE=kong \
        -e KONG_PG_USER=kong \
        -e KONG_PG_PASSWORD=kong \
        -e KONG_PG_HOST=prom-kong-postgres \
        kong:2.1 \
        /bin/sh -c "kong migrations bootstrap"
}

# http://127.0.0.1:8001/
kong() {
    docker run -d --name prom-kong \
        --link prom-kong-postgres:prom-kong-postgres \
        -e "KONG_DATABASE=postgres" \
        -e "KONG_PG_HOST=prom-kong-postgres" \
        -e "KONG_PG_USER=kong" \
        -e "KONG_PG_PASSWORD=kong" \
        -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
        -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
        -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
        -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
        -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
        -p 8000:8000 \
        -p 8443:8443 \
        -p 8001:8001 \
        -p 8444:8444 \
        kong:2.1
}

konga_prepare_database() {
    docker run --rm \
        --link prom-kong-postgres:prom-kong-postgres \
        pantsel/konga:0.14.9 \
        -c prepare \
        -a postgres \
        -u postgresql://kong:kong@prom-kong-postgres:5432/konga
}

# http://127.0.0.1:1337/
konga() {
    docker run -d --name prom-konga \
        --link prom-kong-postgres:prom-kong-postgres \
        --link prom-kong:prom-kong \
        -e "DB_ADAPTER=postgres" \
        -e "DB_HOST=prom-kong-postgres" \
        -e "DB_PORT=5432" \
        -e "DB_USER=kong" \
        -e "DB_PASSWORD=kong" \
        -e "DB_DATABASE=konga" \
        -e "NODE_ENV=production" \
        -p 1337:1337 \
        pantsel/konga:0.14.9
}

stop() {
    rm -rfv /tmp/postgresql/data
    docker stop prom-kong-postgres
    docker rm prom-kong-postgres

    docker stop prom-kong
    docker rm prom-kong

    docker stop prom-konga
    docker rm prom-konga
}

case $1 in
postgresql)
    postgresql
    ;;
kong-db)
    kong_prepare_database
    ;;
kong)
    kong
    ;;
konga-db)
    konga_prepare_database
    ;;
konga)
    konga
    ;;
stop)
    stop
    ;;
*)
    echo "postgresql|kong-db|kong|konga-db|konga|stop"
    ;;
esac
