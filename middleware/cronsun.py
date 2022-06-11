#!/usr/bin/env python3
# coding: utf-8

"""
@date 2021-08-06
@auth vera
@desc 通过cronsun接口进行任务处理
"""

import time
import json
import requests
from requests.adapters import HTTPAdapter, Response

url = "http://9.135.91.98:7079"

def put(url, data):
    s = requests.Session()
    # set request retry
    s.mount('http://', HTTPAdapter(max_retries=3))
    s.mount('https://', HTTPAdapter(max_retries=3))

    try:
        t1 = time.time()
        r = s.put(url,data,timeout=20)
        t2 = time.time()
        request_cost = '%.4f' % (t2 - t1)
        return request_cost,r.status_code,r.text
    except requests.exceptions.RequestException as e:
        print(e)
        print(time.strftime('%Y-%m-%d %H:%M:%S'))


def get():
    pass


def create_job():
    request_data = {
        "id": "task20210809",  # 任务唯一id
        "kind": 2,  # 0:普通任务 1:单机单进程 2:组级别普通任务
        "name": "task20210809",
        "oldGroup": "",
        "group": "default",  # 任务组，可自定义
        "user": "",
        "cmd": "bash /data/project/dial/clean_log.sh",  # 执行任务
        "pause": False,  # 任务状态 False:运行 True:暂停
        "parallels": 0,
        "timeout": 0,
        "interval": 0,
        "retry": 0,
        "rules": [
        {
            "gids": ["8736ea16"],  # 节点组,与执行组级别普通任务关联. 查看组ID http://127.0.0.1:7079/v1/node/groups
            "nids": [],   # 指定执行节点.  查看节点ID http://127.0.0.1:7079/v1/nodes
            "exclude_nids": [],  # 指定不执行节点
            "timer": "0 * * * * *"  # 执行周期 秒 分 时 日 月 周
        }
        ],
        "fail_notify": False,  # 失败邮件通知
        "log_expiration": 0,
        "to": []  # 通知人
    }

    data = json.dumps(request_data)
    url_job = url + '/v1/job'
    response = put(url_job,data)
    print(response)


if __name__ == '__main__':
    create_job()
