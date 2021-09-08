#!/bin/bash
# date: 2021/08/17
# auth: vera

# crontab
# 30 */2 * * * sh /data/images/ops-exporter/check_exporter.sh > /dev/null 2>&1 

DIR="/data/images/ops-exporter"
APP="control_exporter.sh"
cd ${DIR}
cat mysql.conf kafka.conf haproxy.conf > all.conf
date > log
sh ${APP} reg all.conf >> log

