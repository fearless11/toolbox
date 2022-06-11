---
title: kong (一)
date: 2020-10-11 8:00
tags: kong
description: API网关初识
toc: true
---

## kong是什么

- 简介
   
  Kong 是服务和服务间通信的API网关服务，通过插件扩展功能。
  
  插件用 Lua 编写，在 API 请求响应循环的生命周期中被执行。
  
  插件功能：认证、日志、限流、监控 ...

  可理解：Kong = Nginx + Lua
  
- 组件

  - Kong Server：基于nginx的服务器，用来接收 API 请求。
  - Apache Cassandra：用来存储操作数据

- 带来什么革新

  ![](./kong3.png)

## 怎么用

- 部署
  
  ```shell
  1. 部署postgresql
  2. 初始化postgresql的kong数据库
  3. 部署kong (服务器192.168.11.11)
  4. 初始化postgresql的konga数据库 （konga是管理kong的UI）
  5. 部署konga

  kong:
  代理： http://test.kong.iyunwei.oa.com/
  API： http://test.kongapi.iyunwei.oa.com/
  ```



- 功能
  
   - service ： 对应nginx的service
   - upstream ：对应nginx的upstream
   - route ：对应nginx的location


- API基本操作
 
  ```shell
  案例：
    按照下面4步骤创建代理qq.iyunwei.oa.com到真实后端www.qq.com。
    由kong代理访问： 
    curl -H "host:qq.iyunwei.oa.com" http://192.168.11.11:8080
  ```

  - upstream
    
    ```shell
    curl --request POST \
    --url http://test.kongapi.iyunwei.oa.com/upstreams \
    --header 'content-type: application/json' \
    --data '{
        "name": "example-qq"
    }'
    ```

  - targets

    ```shell
    # 137fdaa5-4950-4774-b57c-a0d655be32f1 为上面upstream返回body中的id
    curl --request POST \
    --url http://test.kongapi.iyunwei.oa.com/upstreams/137fdaa5-4950-4774-b57c-a0d655be32f1/targets \
    --header 'content-type: application/json' \
    --data '{
        "target": "www.qq.com:80",
        "weight": 10
    }'
    ```

  - service
    
    ```shell
    curl --request POST \
    --url http://test.kongapi.iyunwei.oa.com/services \
    --header 'content-type: application/json' \
    --data '{
        "name": "example-qq",
        "host": "example-qq",
        "port": 80,
        "path": "/"
    }'
    ```

  - route

    ```shell
    curl --request POST \
    --url http://test.kongapi.iyunwei.oa.com/routes \
    --header 'content-type: application/json' \
    --data '{
        "name": "example-qq",
        "hosts": ["qq.iyunwei.oa.com"],
        "paths": ["/"],
        "service": {
            "name": "example-qq"
        }
    }'
    ```

## 参考

- [k8s部署kong-oschina](https://my.oschina.net/wecanweup/blog/4268636)
- [docker部署kong-stackoverflow](https://stackoverflow.com/questions/63714115/docker-kong-error-to-get-connection-with-postgres)
- [k8s部署kong-git](https://github.com/Kong/kong-dist-kubernetes)
- [konga简单入门配置](https://www.cnblogs.com/sunhongleibibi/p/12024386.html)
