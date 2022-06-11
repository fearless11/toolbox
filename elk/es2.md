[toc]


## elastic 常用命令


### reference

[elastic-backup-eslasticdump](https://github.com/taskrabbit/elasticsearch-dump?utm_source=dbweekly&utm_medium=email)

[elastic5.6-disk-allocator](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/disk-allocator.html)

[elastic6.5-query-dsl](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/query-dsl.html) 

### dump

```bash
# install npm
cd /opt/
wget https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-x64.tar.xz
xz -d node-v10.16.0-linux-x64.tar.xz
tar -xvf node-v10.16.0-linux-x64.tar
ln -s /opt/nodejs/node-v10.16.0-linux-x64/bin/node /usr/local/bin/node
ln -s /opt/nodejs/node-v10.16.0-linux-x64/bin/npm /usr/local/bin/npm
cp ~/.bash_profile /home/bash_profile
echo 'export PATH=$PATH:/opt/node-v10.16.0-linux-x64/bin' >> ~/.bash_profile
source ~/.bash_profile

# global  install elasticdump 
npm install elasticdump -g

# test
elasticdump --help

# backup mapping & data
elasticdump --input=http://elastic:elastic@10.11.40.66:9200/gitlab-2020.04.28 \
--output=gitlab_mapping.json \
--type=mapping

elasticdump --input=http://elastic:elastic@10.11.40.66:9200/gitlab-2020.04.28 \
--output=gitlab_data.json \
--type=data

# restore mapping 
elasticdump --input=gitlab_mapping.json --output=http://127.0.0.1:9200 --type=mapping
  
  
# es-a transfer es-b
elasticdump --input=http://elastic:elastic@10.11.40.66:9200/gitlab-2020.04.28 --output=http://10.51.1.31:9201/gitlab-2020.04.28 --type=mapping
elasticdump --input=http://elastic:elastic@10.11.40.66:9200/gitlab-2020.04.28 --output=http://10.51.1.31:9201/gitlab-2020.04.28 --type=data

```

### cat

```bash
# 查看集群名与版本等
curl -XGET 'localhost:9200/'
GET /

# 查看集群nodes
curl -XGET 'localhost:9200/_cat/nodes'
GET /_cat/nodes
curl -XGET 'localhost:9200/_cat/nodes?v'
GET /_cat/nodes?v

# 查看分片
curl -XGET 'localhost:9200/_cat/shards'
GET /_cat/shards?v

# 查看分片失败原因
curl -X GET "localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason"
curl -s http://localhost:9200/_cluster/allocation/explain?pretty
curl -s http://localhost:9200/_cat/shards  | grep -i unassigne | wc -l

# 查看segment
curl -XGET 'localhost:9200/_cat/segments'
GET /_cat/segments?v

# 查看某天的indices
curl -XGET 'localhost:9200/_cat/indices/*-2020.01.14?h=index'
GET /_cat/indices/*-2020.01.14?h=index
```

### document

```bash
# 根据查询内容删除
curl -X POST "localhost:9200/twitter/_delete_by_query?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { 
    "match": {
      "message": "some message"
    }
  }
}'

POST twitter/_delete_by_query
{
  "query": { 
    "match": {
      "message": "some message"
    }
  }
}
```

### search

```bash
# search on all documents across all types within the twitter index
GET /twitter/_search?q=user:kimchy

#  search all tweets with a certain tag across several indices
GET /kimchy,elasticsearch/tweet/_search?q=tag:wow

# search all tweets across all available indices
GET /_all/tweet/_search?q=tag:wow

# search across all indices and all types
GET /_search?q=tag:wow

# 搜索一条数据
GET /twitter/_search?size=1

# 默认搜索十条
GET /twitter/_search

# 指定搜索条数
GET /_search
{
    "from" : 0, "size" : 10,
    "query" : {
        "term" : { "user" : "kimchy" }
    }
}

# 聚合查询：按ip聚合逆向排序的前100条
POST /internet-nginx-2019.11.05/_search
{
  "size": 0,
  "aggs": {
    "ips": {
      "terms": {
        "field": "client_ip",
        "size":100,
        "order":{"_count":"desc"}
      }
    }
  }
}

```

### cluster
```bash
#  get a very simple status on the health of the clust
GET _cluster/health?pretty

# get just the specified indices health
GET /_cluster/health/test1,test2

# getting the cluster health at the shards level
GET /_cluster/health/twitter?level=shards

# return everything for these two indices
$ curl -XGET 'http://localhost:9200/_cluster/state/_all/foo,bar'

# Return only blocks data
$ curl -XGET 'http://localhost:9200/_cluster/state/blocks'

# settings
# Transient cluster settings > persistent cluster settings > elasticsearch.ym config file.

# cluster.routing.allocation.disk.watermark.low
# It defaults to 85%, meaning ES will not allocate new shards to nodes once they have more than 85% disk used. 

# cluster.routing.allocation.disk.watermark.high
# It defaults to 90%, meaning ES will attempt to relocate shards to another node if the node disk usage rises above 90%.

# cluster.info.update.interval
# How often Elasticsearch should check on disk usage for each node in the cluster. Defaults to 30s.

# 设置磁盘高低水位
curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
  "transient": {
    "cluster.routing.allocation.disk.watermark.low": "80%",
    "cluster.routing.allocation.disk.watermark.high": "50gb",
    "cluster.info.update.interval": "1m"
  }
}'

# 查看所有设置
GET /_cluster/settings?include_defaults=true

# 避免脑裂 设置(master-node/2)+1
PUT _cluster/settings
{
  "transient": {
    "discovery.zen.minimum_master_nodes": 2
  }
}
```
### node
```bash
# return just indices
GET /_nodes/stats/indices

# return just os and process
GET /_nodes/stats/os,process

# return just process for node with IP address 10.0.0.1
GET /_nodes/10.0.0.1/stats/process
```

### template
```bash
# 新建索引前模板匹配设置
curl -X PUT "127.0.0.1:9200/_template/log-idc-template" -H 'Content-Type: application/json' -d'
{
  "template": "log-*",
  "settings": {
     "number_of_replicas" : "0" 
  },
  "mappings": {}
}'

# 需要设定字段属性，grafana对数字类型要求long
curl -XPUT "localhost:9200/_template/template_1"  -H 'Content-Type: application/json' -d'{
  "template": "baoan-proxy*",
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "doc": {
     settings	
      "properties": {
        "response_time": {
          "type": "long"
        },
        "response_status": {
          "type": "long"
        },
		"response_bytes": {
		  "type": "long"
		}
      }
    }
  }
}'

# 设置nginx中geoip解析地图
PUT /_template/tmpl_internet_nginx
{
  "template": "internet-nginx*",
  "mappings": {
    "doc": {
      "properties": {
        "geoip": {
          "properties": {
            "location": {
              "type": "geo_point",
              "ignore_malformed": "true"
            }
          }
        }
      }
    }
  }
}
```

### index
```bash
POST /_all/_open
POST http://localhost:9200/<index_name>/_open
POST http://localhost:9200/<index_name>/_close


# 合并segement， 磁盘碎片化清理
# 注意：
# This call will block until the merge is complete. If the http connection is lost,
# the request will continue in the background, and any new requests will block
# until the previous force merge is complete.
POST /twitter/_forcemerge
POST /kimchy,elasticsearch/_forcemerge
POST /_forcemerge
```



### Query DSL


- 聚合查询agg

```bash
# 查询4月28日00:00 - 10:30, 根据user、userip分组查询聚合查询
# curl -XPOST "http://10.51.1.31:9201/gitlab-2020.04.28/_search" -H 'Content-Type: application/json' -d'
POST /gitlab-2020.04.28/_search
{
  "size": 0,
  "query": {
     "range": {
      "@timestamp": {
        "gte":1588003200000,
        "lte":1588041000000
      }
    }
  }, 
  "aggs": {
    "users": {
      "terms": {
        "script": "doc['user'].values + '@' + doc['userip'].values", 
        "exclude": ".*-.*", 
        "size": 1000
      }
    }
  }
}


# 匹配后聚合： 统计所有入口流量的不同状态码总数
GET /packetbeat-7.5.1-2021.08.17/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "terms": {
          "server.ip": [
            "10.11.202.13",
            "10.11.203.13",
            "10.11.152.13",
            "10.11.153.13"
          ]
        }
      },
      "boost": 1.2
    }
  }
  , "aggs": {
    "status": {
      "terms": {
        "field": "http.response.status_code",
        "size": 10
      }
    }
  }
}

```

- 精确查找 term 

  ```
  SELECT document FROM   products WHERE  price = 20
  
  GET /my_store/products/_search
  {
      "term" : {
          "price" : 20
      }
  }
  
  GET /my_store/products/_search
  {
      "query" : {
          "constant_score" : {   // 将term转换成filter
              "filter" : {       //单个过滤器
                  "term" : { 
                      "price" : 20
                  }
              }
          }
      }
  }
  ```

- 组合过滤器 bool 

  ```
  {
     "bool" : {
        "must" :     [],    且
        "should" :   [],    或
        "must_not" : [],    非
     }
  }
 
  
  SELECT product FROM   products WHERE  (price = 20 OR productID = "XHDK-A-1293-#fJ3")  AND  (price != 30)
  
  GET /my_store/products/_search
  {
     "query" : {
        "filtered" : { 
           "filter" : {
              "bool" : {    
                "should" : [
                   { "term" : {"price" : 20}},   
                   { "term" : {"productID" : "XHDK-A-1293-#fJ3"}} 
                ],
                "must_not" : {
                   "term" : {"price" : 30} 
                }
             }
           }
        }
     }
  }
  ```

- 查找多个精确值 terms

  ```
  SELECT document FROM   products WHERE  price = 20 OR price = 30
  
  GET /my_store/products/_search
  {
      "query" : {
          "constant_score" : {
              "filter" : {
                  "terms" : { 
                      "price" : [20, 30]
                  }
              }
          }
      }
  }
  ```

- 精确相等

  ```
  GET /my_index/my_type/_search
  {
      "query": {
          "constant_score" : {
              "filter" : {
                   "bool" : {
                      "must" : [
                          { "term" : { "tags" : "search" } },
                          // 单个标签为search的文档，而不是包含search的文档
                          { "term" : { "tag_count" : 1 } }   
                      ]
                  }
              }
          }
      }
  }
  ```

- 范围  range

  ```
  gt: > 大于（greater than）
  lt: < 小于（less than）
  gte: >= 大于或等于（greater than or equal to）
  lte: <= 小于或等于（less than or equal to）

  SELECT document FROM   products WHERE  price BETWEEN 20 AND 40
  
  GET /my_store/products/_search
  {
      "query" : {
          "constant_score" : {
              "filter" : {
                  "range" : {
                      "price" : {
                          "gte" : 20,
                          "lt"  : 40
                      }
                  }
              }
          }
      }
  }
  ```

- 查询过去15m分钟数据

  ```
  GET /crm-nginx-2019.04.30/_search
  {
    "query": {
      "constant_score": {
        "filter": {
          "range": {
            "@timestamp": {
              "gte": "now-15m"
            }
          }
        },
        "boost": 1.2
      }
    }
  }
  ```

- 查询500的数据

  ```
  GET /crm-frontend-nginx-2019.03.22/_search
  {
      "query": {
          "match": {
            "status" : 500
          }
      }
  }
  ```

- 查询与过滤

  ```
  GET /_search
  {
    "query": { 
      "bool": { 
        "must": [
          { "match": { "title":   "Search"        }}, 
          { "match": { "content": "Elasticsearch" }}  
        ],
        "filter": [ 
          { "term":  { "status": "published" }}, 
          { "range": { "publish_date": { "gte": "2015-01-01" }}} 
        ]
      }
    }
  }
  ```

[toc]



## 实战elastic

### reference

[elastic6.5-analysis-pattern](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/analysis-pattern-analyzer.html)

[elsatic5.6-search-scroll](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/search-request-scroll.html)

[大规模Elasticsearch集群管理心得](https://mp.weixin.qq.com/s/04N6bjYHY3ahKQxTnld89w)

[elastic-kibana-热力图](https://elasticsearch.cn/article/494)


### 分词器

把一段话进行切割分成词组的方式。

```bash
# 利用kibana的DEV Tools调试

# 分词器测试
# 搜索jobhandler查询不到结果
POST _analyze
{
  "analyzer": "whitespace",
  "text": "com.crm.job.executor.service.jobhandler.wechat.ResourceRegisterJob"
}
# 搜索jobhandler查询不到结果
POST _analyze
{
  "analyzer": "standard",
  "text": "com.crm.job.executor.service.jobhandler.wechat.ResourceRegisterJob"
}
# 搜索jobhandler查询不到结果
POST _analyze
{
  "analyzer": "keyword",
  "text": "com.crm.job.executor.service.jobhandler.wechat.ResourceRegisterJob"
}
# 按照单词分词， 搜索jobhandler能查到
POST _analyze
{
  "analyzer": "pattern",
  "text": "com.crm.job.executor.service.jobhandler.wechat.ResourceRegisterJob"
}
# 支持中文分词
POST _analyze
{
  "analyzer": "ik_max_word",
  "text": ".s.PassiveActivityAdminService  : 活动报名列表查询:ApplyListQueryForm"
}


# 索引设置 指定字段使用的分词器
PUT twitter
{
  "mappings": {
    "_doc": {
      "properties": {
        "message": {
          "type": "text",
          "analyzer": "ik_max_word"
        }
      }
    }
  }
}

PUT twitter/_doc/2
{
  "user":"test",
  "@timestamp":"2019-09-25T01:09:21.969Z",
  "message": "com.crm.job.executor.service.jobhandler.wechat.ResourceRegisterJob"
}

DELETE /twitter


# 模板设置 索引默认分词器和特定字段分词
GET /_template/template_server_log

DELETE /_template/template_server_log

PUT /_template/template_server_log
{
  "index_patterns": ["crm-cache*"],
  "settings": {
      "index.analysis.analyzer.default.type": "ik_max_word"
     }
  },
   "mappings": {
    "doc": {
      "properties": {
        "message": {
          "type": "text",
          "analyzer": "ik_max_word"
        }
      }
    }
  }
}

GET /crm-cache-master-2019.09.23/_search
GET /crm-cache-master-2019.09.23/_mapping
```

### 分页scroll

elastic数据查询默认返回10条，可以设置`from to`和分页`scroll`查询大量数据。

scroll不是为用户实时请求数据，而是一次处理大量数据的请求。例如，将一个索引内容滚动到新索引。

```bash
# 初始化scroll请求
# scroll=1m 设置这个查询的会话时间
# 单位 d:days h:hours m:minutes s:seconds ms:milliseconds micros:microseconds nanos:nanoseconds
# size=5 一页返回5条数据
POST /cdn-1d/doc/_search?scroll=1m
{
  "size": 5,
   "query": {
     "match": {
       "domain": "cdn.wx.zhenai.com"
     }
   }
}


# 根据游标scroll_id分页取数据，直到hits返回为空
GET /_search/scroll?scroll=1m&scroll_id=DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMFjBiSG

POST /_search/scroll
{
    "scroll" : "1m", 
    "scroll_id" : "DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMFjBiSG" 
}


# check how many search contexts are open 
GET /_nodes/stats/indices/search


# clear scroll API
# 默认当scroll会话时间过期将自动移除scroll任务
DELETE /_search/scroll/DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMFjBiSG

DELETE /_search/scroll
{
    "scroll_id" : "DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMFjBiSG"
}

DELETE /_search/scroll
{
    "scroll_id" : [
      "DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMFjBiSG",
      "DnF1ZXJ5VGhlbkZldGNoBQAAAAAA3lqMF"
    ]
}

# All search contexts can be cleared
DELETE /_search/scroll/_all
```

### 索引冷热分离

 将不是当天的索引迁移到性能低的机器，隔离存储，减少对实时数据的影响。

#### node节点打tag区分hot或cold

  ```bash
  # cat elasticsearch.yml  
  node.attr.tag: cold|hot
  
  # bin/elasticsearch -d -Enode.attr.box_type=hot|cold
  ```

####  template设置新索引到hot节点 
   ```bash
   PUT /_template/template_hot_node   
     {
         "index_patterns" : ["a*","b*","c*","d*","e*","f*","g*","h*","i*"],
         "settings" : {
             "number_of_shards" : 5,
     		    "number_of_replicas" : "1",
     		    "index.routing.allocation.include.tag" : "hot"
         },
         "aliases" : {
             "alias" : {}
         }
     }
```
    
#### 定期迁移旧索引到cold节点

  ```bash
  #!/bin/bash
     
  es="127.0.0.1:9200"
  yesterday=`date -d '-1days' +%Y.%m.%d`
  important_index="crm-provider-finance|crm-server-localhost-common"
  migration_index=$(curl -s -XGET "http://x:9200/_cat/indices/*-${yesterday}?h=index" | grep -v '^\.')
  replication_index=$(curl -s -XGET "http://x:9200/_cat/indices/*-${yesterday}?h=index" | grep -Ev "^\.|${important_index}")
     
  function migration_index_to_cold(){
     for i in `echo $1` 
     do
       curl -X PUT "${es}/${i}/_settings" -H 'Content-Type: application/json' -d'{
           "index.routing.allocation.include.tag": "cold"
        }'
      done
  }
     
  function replication_index_to_zero(){
      for i in `echo $1` 
       do
        curl -XPUT -H "Content-Type: application/json" "${es}/${i}/_settings" -d '{
             "number_of_replicas": 0
        }'
      done
  }
     
  migration_index_to_cold "$migration_index"
  replication_index_to_zero "$replication_index"   
  ```

- 查看是否生效 `GET /xxx-2020.03.09/_settings`


### 热力图

#### logstash的grok出ip地址为geoip

```yaml
filter {
    if [fields][project] =~ "vera" {
        grok {
           match => {
               "message" => '\[%{HTTPDATE:timestamp}\] %{IPV4:client_ip} (.*) \"%{GREEDYDATA:client_real_ip}\"'
             }
        }

        urldecode {
            all_fields => true
        }

        geoip {
            source => "client_real_ip"
        }
   }
}
```

#### template设置mapping中geo_point类型

```yaml
# 设定经纬度类型为geo_point 
PUT /_template/tmpl_nginx 
{
  "template": "nginx-test*",
	"mappings": {
		"doc":{
		   "properties": {
			  "geoip": {
				  "properties": {
					"location": {             
						"type": "geo_point",  
						"ignore_malformed": "true" 
						}
					}
				}
			}    
		}
	}
}
```

#### kibana绘制

`visualize` —> `Maps（coordinate Map）`




