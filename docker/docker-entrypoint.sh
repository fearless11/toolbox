#!/bin/bash
# date: 2022/05/31

# 来自cmd的命令参数
if [ "$1" == "test" ]; then
    echo "test"
fi

# 提升进程号为1，可接受来向容器发送的信号
exec "$@"
