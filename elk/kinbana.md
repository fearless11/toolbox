[TOC]

## kibana

### reference

[query-string](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html)
 
[kibana-visualize](https://www.elastic.co/guide/en/kibana/6.5/visualize.html)


### install

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.6.8-linux-x86_64.tar.gz
tar xf kibana-5.6.8-linux-x86_64.tar.gz -C /usr/local
mv /usr/local/kibana-5.6.8-linux-x86_64/ /usr/local/kibana5.6.8

nohup /usr/local/kibana5.6.8/bin/kibana -c /usr/local/kibana5.6.8/config/kibana-idc.yml &

# 一个kibana启动多个配置文件，改端口
nohup /usr/local/kibana5.6.8/bin/kibana -c /usr/local/kibana5.6.8/config/kibana-uat.yml &
```

### configure

```bash
# egrep -v '^$|#' /usr/local/kibana5.6.8/config/kibana-idc.yml
server.port: 5604 
server.host: "10.10.10.160"

# 当设置在nginx代理后需要配置 location /logs/idc/ { proxy_pass http://10.51.1.31:5601/;}
server.basePath: "/logs/idc"     

elasticsearch.url: "http://10.10.11.46:9200"
logging.dest: /var/log/kibana5.6.8.log
```

###  搜索

```shell
查询框支持短语句查询
（1）全文搜索
      直接输入查询字符串，如"esb"，则会在所有字段里搜索值为esb的结果
      
（2）字段搜索
      输入 proj: esb，则只在proj字段搜索esb
      
（3）逻辑搜索（与或非）
      AND表示与，OR表示或， AND NOT表示非。
      输入 proj: (esb OR dw-item )，查询proj 为esb 或者 dw-item的结果
      输入 proj: (esb OR dw-item) AND NOT iid: HttpESB1_661，查询 proj为esb或 dw-item，且 iid不为HttpESB1_661
      
 (4) 范围查询
      count: [1 TO 5]，表示查询  1<=count<=5
      count: {1 TO 5}，表示查询  1<count<5
      
（5）精确查询
      proj:"XXX-XXX-XXX"    只搜索XXX-XXX-XXX服务
```

 

