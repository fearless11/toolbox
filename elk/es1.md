[TOC]


## elastic

  一个实时可伸缩开源全文本搜索和分析引擎，时序数据库。

### reference

 [elk-download](https://www.elastic.co/cn/downloads/past-releases)

 [elastic5.6-basic_conceptes](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/_basic_concepts.html)
 
 [elastic5.6-node](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html)
 
 [elastic5.6-split-brain](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html#split-brain)
 
 [elastic6.8-index-lifecycle-management](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/index-lifecycle-management.html)
 

### 基础概念

-  Cluster集群
 
   一个或多个node的结合，保留数据、提供联邦索引和搜索。node根据Cluter name加入集群

- Node节点

  一个es实例，存储数据、参与集群的索引搜索。node由UUID(Universally Unique IDentifier)标识

-  Index索引

   一个index是由相似特征的文档组成的一个集合

- Type类型

   一个type是index的一个逻辑区分，具体意义由用户自行定义，一个index可定义一个或多个type

- Document文档

  信息能够被检索到的基础单元。document为JSON格式。一个document表面是在一个index中，实际是登记在index的类型中

- shard分片

  默认一个index分为10个shard分片，在集群中shard分布在不同的node中，水平分割索引，提高性能和吞吐量。
  
  默认每个index有5个primary shard和5个replica shard，即一个index有10个分片 
  
  注意：创建时可设定primary shard和replicas shard。创建后，replicas可以动态修改，但primary不可修改。
  
  
- Replicas复制分片

  防止shard所在的node失联，保证高可用，允许每个shard创建副本replicas分片。
  
  前提：replicas与shard不在同一个node上。
   
  优点：增强shard出问题时容错性；repliacs可搜索扩展了搜索吞吐量。

- Segment分段 

   segment是内部实际存储元素，存储索引数据，具有不可变特性。一个shard实际是一个Lucene index，一个Lucene index有多个segment组成。小的segment周期性合并为大的segment保证index的大小。定期合并segment类似磁盘碎片清理。
   
### 集群角色

 ```bash
    # 集群中node能够处理HTTP和Transport请求
    HTTP     ： 9200        （REST client）
    Transport： 9300 - 9400 （Java TrasportClient）
    
    # 默认master、data、ingest的node是启动的
```

- Master-eligible node
  
  ```bash
  # 担任master节点，负责集群范围工作。
  创建、删除index
  跟踪管理集群中的node
  决定shard分配到哪个node

  # 防止脑裂
  配置discovery.zen.minimum_master_nodes默认是1
  计算公式： (master_eligible_nodes / 2) + 1
  如master_eligible_node有三个，则3/2+1可设置为2
  
  # 配置
  node.master: true 
  node.data: false 
  node.ingest: false 
  discovery.zen.minimum_master_nodes: 2 
  ```
- Data node

  ```bash
  # 数据节点，要求I/O、CPU、Memory
  存储index中document的所有shard
  处理data相关操作，如CRUD、search、aggrations
  
  # 配置
  node.master: false 
  node.data: true 
  node.ingest: false 
  # The path.data 
  # defaults to $ES_HOME/data 
  # ./bin/elasticsearch -Epath.data=/var/elasticsearch/data
  path.data:  /var/elasticsearch/data
  # 集群node可以共享path.data，但建议每个服务器上只运行一个es的node
  node.max_local_storage_nodes: 1
  ```
- Ingest node
  
  ```bash
  # ingest节点，最好分开部署
  执行预处理的pipelines，组成一个或多个ingest进程
  
  # 配置
  node.master: false 
  node.data: false 
  node.ingest: true 
  # Disable cross-cluster交叉集群 search
  search.remote.connect: false  
  ```
  
- Tribe node
 
  ```bash
  # 部落节点，tribe.*设置
  协调一个node能够连接多个集群，通过连接的所有集群来提高搜索或其他操作
  ```

- Coorinationg only node

  ```bash
  # 唯一的协调节点， 承担聪明的负载均衡器
  仅仅能够处理路由请求，处理搜索，批量的索引。
  
     Coordinating only nodes can benefit large clusters by offloading 
   the coordinating node role from data and master-eligible nodes.
  
  # 注意
    Adding too many coordinating only nodes to a cluster can increase 
  the burden on the entire cluster. because the elected master node
  must await acknowledgement of cluster state updates from every node! 
  The benefit of coordinating only nodes should not be overstated
  data nodes can happily serve the same purpose.
  
  # 设置
  node.master: false 
  node.data: false 
  node.ingest: false 
  search.remote.connect: false 
  ```

- X-Pack node

  ```bash
  # 安装X-Pack
  
  # 所有master node配置
  node.master: true 
  node.data: false 
  node.ingest: false 
  node.ml: false 
  # 其余node不需要配置该项
  xpack.ml.enabled: true 
  ```

- Machine learning node

  ```bash
  # 机器学习node
  运行jobs
  处理机器学习API的请求
  
  # 说明
    If xpack.ml.enabled is set to true and node.ml is set to false,
  the node can service API requests but it cannot run jobs.
  
    If you want to use X-Pack machine learning features in your cluster, 
  you must enable machine learning (set xpack.ml.enabled to true) on all
  master-eligible nodes. 
  
  
  #  创建一个机器学习的node
  node.master: false 
  node.data: false 
  node.ingest: false 
  search.remote.connect: false 
  node.ml: true 
  xpack.ml.enabled: true 
  ```
  
### 索引生命周期（冷热分离）

- 时间序列索引的四个生命周期

  - Hot—​the index is actively being updated and queried.
  - Warm—​the index is no longer being updated, but is still being queried.
  - Cold—​the index is no longer being updated and is seldom queried. The information still needs to be searchable, but it’s okay if those queries are slower.
  - Delete—​the index is no longer needed and can safely be deleted.
 
- 索引管理不同阶段的不同策略

  - 滚动索引：The maximum size or age at which you want to roll over to a new index.
  - 索引设置：The point at which the index is no longer being updated and the number of primary shards can be reduced.
  - 合并索引：When to force a merge to permanently delete documents marked for deletion.
  - 迁移索引：The point at which the index can be moved to less performant hardware.
  - 不冗余：The point at which the availability is not as critical and the number of replicas can be reduced.
  - 过期索引：When the index can be safely deleted.
 
- example

  1. When the index reaches 50GB, roll over to a new index.
  2. Move the old index into the warm stage, mark it read only, and shrink it down to a single shard.
  3. After 7 days, move the index into the cold stage and move it to less expensive hardware.
  4. Delete the index once the required 30 day retention period is reached.

### 集群健康状态

- red： primary shard没有分配
- yellow：primary shard分配，replica shard未分配
- green：all shard都分配了


[TOC]


## ELK日志系统

### reference



[elk-downloads](https://www.elastic.co/cn/downloads/past-releases)

[community-beats](https://www.elastic.co/guide/en/beats/libbeat/current/community-beats.html)

[elasticsearch中文社区](https://elasticsearch.cn/)

[elastic-grafana](https://zturn.cc/elkbook/elasticsearch/other/grafana.html)

[support-diagnostics](https://github.com/elastic/support-diagnostics)

[tips-elasticsearch-for-high-performance](https://www.loggly.com/blog/nine-tips-configuring-elasticsearch-for-high-performance/)

 [elastic-铭毅天下](https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzI2NDY1MTA3OQ==&scene=124#wechat_redirect)

### 架构
```
# 架构
rsyslog —> logstash —> elastic
filebeat —> logstash —> elastic —> kibana  
filebeat —> kafka —> logstash —> elastic —> kibana 

# 用户访问
user —> kibana
user —> nginx —> kibana
```

### FAQ

```
elastic中角色
```

[TOC]


## elastic

### reference

[filebeat5.6-elastic-output](https://www.elastic.co/guide/en/beats/filebeat/5.6/elasticsearch-output.html)

[elastic5.6-ingest](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/ingest.html)

[elastic5.6-grok-patterns](https://github.com/elastic/elasticsearch/blob/5.6/modules/ingest-common/src/main/resources/patterns/grok-patterns)

[elastic5.6-grok-processor](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/grok-processor.html)

### install

```bash
# 安装
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.8.tar.gz
tar xf elasticsearch/elasticsearch-5.6.8.tar.gz -C /usr/local
useradd es  && chown es:es /usr/local/elasticsearch-5.6.8
 
 # 修改系统参数
/bin/cp  /etc/sysctl.conf /home/
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
sysctl -p
/bin/cp /etc/security/limits.conf /home/
echo -e "es hard nofile 65536\nes soft nofile 65536" >> /etc/security/limits.conf
/bin/cp /etc/security/limits.d/90-nproc.conf /home
echo "es  soft nproc  4096" >> /etc/security/limits.d/90-nproc.conf

# 启动
su - es -c "/usr/local/elasticsearch-5.6.8/bin/elasticsearch  -d"
```

### configure

```yaml
# cat /usr/local/elasticsearch-5.6.8/config/elasticsearch.yml
cluster.name: idc.log
node.name: node-10.10.10.47
node.master: true
node.data: true
node.ingest: true         # 默认都是true
path.data: /data/es-idc-log/data
path.logs: /data/es-idc-log/log
network.host: 10.10.10.47
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.10.11.63","10.10.11.48"]
discovery.zen.minimum_master_nodes: 2
bootstrap.system_call_filter: false

# jvm调整
# grep 8g /usr/local/elasticsearch-5.6.8/config/jvm.options 
-Xms8g
-Xmx8g
```

### pipeline

 filebeat直接到elastic通过pipeline实现解析

- filebeat

  ```bash
  # egrep -v '^$|#' /usr/local/filebeat-5.6.8/filebeat.yml
  filebeat.prospectors:
  - input_type: log
    paths:
      - /var/logs/*.log
      exclude_files: [".gz$"]
      ignore_older: 24h
    name: 127.0.0.1

  output.elasticsearch:
    # 指定 ingest node的 pipeline
    hosts: ["127.0.0.1:9200"]
    index: "logs-%{+yyyy.MM.dd}"
    pipeline: "log-pipeline"  
  ```

- elastic

    ```yaml
    # cat log-pipeline.json 
	{ 	 
	     "description" : "log-pipeline",
	     "processors" : 
	      [{  "grok" : {
        	         "field" : "message",
        	         # 正则解析文件 [2018-06-24 18:29:41] [INFO ] [Task::RequestTask] code=0,task_id=null
  	      	         "patterns" : [ "\\[(?<mydate>.*?)\\] \\[(?<lv>.*?)\\] (?<txt>.*)"],  
                      "on_failure" : [{ 
                           "set" : {    
                               "field" : "error",
                                "value" : "{{ _ingest.on_failure_message }}"
                            }
            			}]
                  }
            },
            {   "date": {
           		    "field": "mydate",
                    "target_field" : "@timestamp",  # 替换es的timestamp时间
                    "formats": ["yyyy-MM-dd HH:mm:ss"],
                    "timezone": "Asia/Shanghai",
                    "on_failure" : [{ 
                           "set" : {
                                "field" : "error",
                                "value" : "{{ _ingest.on_failure_message }}"
                            }
            			}]
                   }
            },
            {    "remove": {
                      "field": ["mydate","type","offset","input_type"], # 去掉不必要的字段
                       "on_failure" : [{ 
                           "set" : {
                                "field" : "error",
                                "value" : "{{ _ingest.on_failure_message }}"
                            }
            			}]
                   }
           }]
       }
    ```
    
   es导入pipeline
   
   ```bash
    curl -H 'Content-Type: application/json' -XPUT 'http://127.0.0.1:9200/_ingest/pipeline/log-pipeline' -d@log-pipeline.json
   ```

- 模拟调试pipeline

```bash
curl -XPOST '192.168.1.78:19200/_ingest/pipeline/_simulate?pretty' -H 'Content-Type: application/json' -d'{
	"pipeline" :{
		"description": "_description",
    	"processors": [{
        	"grok" : {
          	"field" : "message",
          	"patterns" : ["^(?<domain>%{IP:ip}|(?:%{NOTSPACE:subsite}\\.)?(?<site>[-a-zA-Z0-9]+?).com|%{NOTSPACE:unknown}) %{IPORHOST:remoteip} - (?<user>[a-zA-Z\\.\\@\\-\\+_%]+) \\[%{HTTPDATE:timestamp}\\] \"(?:%{WORD:verb} (?<biz>\/[^/?]*)(?:%{URIPATH:urlpath})(?:%{URIPARAM:request_param})?) HTTP/%{NUMBER:httpversion}\" (?:%{NUMBER:response}|-) (?:%{NUMBER:bytes}|-) (?<durations>(%{BASE10NUM:request_duration})%{NOTSPACE:otherduration}?) (?:\"(?:%{URI:referrer}|-)\"|%{QS:referrer}) %{QS:agent} \"(?:%{IPORHOST:clientip}(?:[^\"]*)|-)\" (?:%{QS:uidgot}|-) (?:%{QS:uidset}|-) (?:%{QS:tencentua}|-) \"(?:[^\" ]* )*(?<upstream>[^ \"]*|-)\" (?:%{QS:cachedfrom}|-) (?:%{QS:cachectrl}|-)"],
		  	"on_failure" : [{
              	"set" : {
              	"field" : "error",
              	"value" : "{{ _ingest.on_failure_message }}"
            	}
        	 }]
      	  }
      }]
  },
  "docs": [
    {
      "_index": "index",
      "_type": "type",
      "_id": "id",
      "_source": {
        "message": "www.abc.com 44.44.44.44 - - [05/Mar/2018:21:04:54 +0800] \"GET /crm/index.php/ajax/replydata?a=1 HTTP/1.1\" 200 33 0.059 \"http://www.abc.com/crm/index.php/Projects/manual/index\" \"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36\" \"-\" \"-\" \"-\" \"-\" \"124.251.49.151:80\" \"-\" \"no-cache\""
      }
    }
  ]
}'
```


