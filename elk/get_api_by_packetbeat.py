# coding: utf-8
import requests
import json
import datetime
import MySQLdb

# date: 2021/09/08
# auth: vera
# desc: 从packetbeat解析接口访问量与访问耗时
# version: python2

'''
# 注意: basic token
# crontab
0 1 * * * cd /data/tools; python xxx_api.py >>  /tmp/log/xxx_api.log 2>&1

# 创建表
create table `t_alarm_request` (
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `x200` int  COMMENT '200',
    `x000`  int COMMENT '其他状态码',
    `x999`  int COMMENT '所用状态码',
    `x0ms` int COMMENT '0~10ms',
    `x10ms` int COMMENT '10~100ms',
    `x100ms` int COMMENT '100~500ms',
    `x500ms` int COMMENT '500~1000ms',
    `x1000ms` int COMMENT '1s+',
    `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    unique index(`create_time`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
'''


def output_db(create_time,x200,x000,x999,x0ms,x10ms,x100ms,x500ms,x1000ms):
    conn = MySQLdb.connect(host="127.0.0.1", user="root", passwd="123456", db="test", port=3306)
    cursor = conn.cursor()
    sql="insert into t_alarm_request(create_time,x200,x000,x999,x0ms,x10ms,x100ms,x500ms,x1000ms) values('%s',%s,%s,%s,%s,%s,%s,%s,%s)" % (create_time,x200,x000,x999,x0ms,x10ms,x100ms,x500ms,x1000ms)
    try:
        cursor.execute(sql)
        conn.commit()
    except Exception,e:
        conn.rollback()
        print e
    cursor.close()


def get_api_request(url):
    x200, x000, x999 = 0, 0, 0
    # 指定代理地址 server.ip
    payload = "{\"size\": 0,\"query\": {\"constant_score\": {\"filter\": {\"terms\": {\"server.ip\": [\"10.11.202.135\",\"10.19.203.135\",\"10.11.152.135\",\"10.11.153.135\"]}},\"boost\": 1.2}},\"aggs\": {\"status\": {\"terms\": {\"field\": \"http.response.status_code\",\"size\": 10}}}}"
    headers = {
        'authorization': "Basic xxxxxxxxxxxxxxxx=",
        'content-type': "application/json"
    }

    response = requests.request("GET", url, data=payload, headers=headers)
    result = json.loads(response.text)

    total,other = 0,0
    try:
        for i in result["aggregations"]["status"]["buckets"]:
            total = total + i["doc_count"]
            if i["key"] == 200:
                x200 = i["doc_count"]
            else:
                other = other + i["doc_count"]
        x000 = other
        x999 = total

    except Exception,e:
        print e

    return x200, x000, x999


def get_api_time(url):
    # event.duration Duration of the event in nanoseconds. 
    x0ms, x10ms, x100ms, x500ms, x1000ms = 0, 0, 0, 0, 0
    payload = "{\"size\": 0,\"query\": {\"constant_score\": {\"filter\": {\"terms\": {\"server.ip\": [\"10.11.202.135\",\"10.11.203.135\",\"10.11.152.135\",\"10.11.153.135\"]}},\"boost\": 1.2}},\"aggs\": {\"response_time\": {\"range\": {\"field\": \"event.duration\",\"ranges\": [{\"from\": 0,\"to\": 10000000},{\"from\": 10000000,\"to\": 100000000},{\"from\": 100000000,\"to\": 500000000},{\"from\": 500000000,\"to\": 1000000000},{\"from\": 1000000000}]}}}}"
    headers = {
        'authorization': "Basic xxxxxxxxxxxx=",
        'content-type': "application/json"
    }

    response = requests.request("GET", url, data=payload, headers=headers)
    result = json.loads(response.text)
    
    try:
        for i in result["aggregations"]["response_time"]["buckets"]:
            if i["key"] == "0.0-1.0E7":
                x0ms = i["doc_count"]
            elif i["key"] == "1.0E7-1.0E8":
                x10ms = i["doc_count"]
            elif i["key"] == "1.0E8-5.0E8":
                x100ms = i["doc_count"]
            elif i["key"] == "5.0E8-1.0E9":
                x500ms = i["doc_count"]
            elif i["key"] == "1.0E9-*":
                x1000ms = i["doc_count"]

    except Exception,e:
        print e

    return x0ms,x10ms,x100ms,x500ms,x1000ms

def get_yesterday(count=1):
    if count == 1:
        today = datetime.date.today()
        oneday = datetime.timedelta(days=int(count))
        yesterday = today - oneday
    else:
        today = datetime.date.today()
        yesterday = today - datetime.timedelta(days=int(count))
        today = today - datetime.timedelta(days=int(count) - 1)
    
    return str(yesterday), yesterday.strftime("%Y.%m.%d")

if __name__ == "__main__":
    yesterday,yesterdayYmd = get_yesterday(count=1)
    create_time = "%s 00:00:00" % (yesterday)
    url = "http://127.0.0.1:9200/packetbeat-7.5.1-%s/_search" % (yesterdayYmd)
    x200,x000,x999 = get_api_request(url)
    x0ms,x10ms,x100ms,x500ms,x1000ms = get_api_time(url)
    output_db(create_time,x200,x000,x999,x0ms,x10ms,x100ms,x500ms,x1000ms)
