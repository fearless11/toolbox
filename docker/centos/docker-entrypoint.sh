#!/bin/bash
# date: 2022/05/31

if [ "$1" == "ping" ]; then
    exec ping 127.0.0.1 &>/dev/null &
fi

# as process pid is 1
exec "$@"
