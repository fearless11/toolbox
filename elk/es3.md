[toc]


## elastic管理工具


### reference

[elastic最全常用工具](http://mp.weixin.qq.com/s?__biz=MzI2NDY1MTA3OQ==&mid=2247484088&idx=1&sn=16598e20a98417416bbe6efa5e0d1c7c&chksm=eaa82a90dddfa386e276b81ef3079041538faecf5feae28e67c193eb5a239b062b01d4a076e5&mpshare=1&scene=1&srcid=0714elqfLsQbs6GoMVUpxvmB&sharer_sharetime=1567765265373&sharer_shareid=9f96fe5b1bdd806687fd14b4d85202d9#rd)

[cerebro](https://github.com/lmenezes/cerebro)


[elastic-curator](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html) 
  
[curator](https://github.com/elastic/curator)

[curator-config](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/configfile.html) 
  
[curator-action](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actionfile.html)
  
[curator配置-简书](https://www.jianshu.com/p/bb58e42e968c)


### cerebro 

- install

  ```bash
  # 访问 http://localhost:9000
  
  #  docker
  docker search cerebro
  docker run -d -p 9000:9000 --name cerebro yannart/cerebro:0.8.1
  docker exec -it cerebro sh
  
  
  # docker-compose up -d 
  # docker-compose.yaml
   version: "2"
    services:
      cerebro:
          container_name: cerebro
          image: yannart/cerebro:0.8.1
          ports:
              - "9000:9000"
          volumes:
              - ./conf/:/opt/cerebro/conf/
              - ./logs/:/opt/cerebro/logs/
          restart: always
          ulimits:
              memlock:
                  soft: -1
                  hard: -1
                  
         
  # linux
  #!/bin/bash
  pgrep -f  cerebro  | xargs kill -9
  if ! /usr/bin/pgrep -f /usr/local/cerebro;then
    nohup /usr/local/cerebro/bin/cerebro -Duser.dir=/usr/local/cerebro -Dhttp.port=9000 -Dhttp.address=10.10.10.10 &
  fi
  ```
 
### curator 

管理es的索引的工具

- install

```bash
# yum安装
# 下载公钥
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# centos7
cat >/etc/yum.repos.d/curator.repo <<EOF
[curator-5]
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
baseurl=https://packages.elastic.co/curator/5/centos/7
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF

# install
yum install elasticsearch-curator -y
# curator --version
curator, version 5.7.6



# 离线安装
https://packages.elastic.co/curator/5/centos/7/Packages/elasticsearch-curator-5.4.1-1.x86_64.rpm
rpm -ivh elasticsearch-curator-5.4.0-1.x86_64.rpm
rpm -e elasticsearch-curator   # 卸载
```

- 命令行curator_cli

 ```bash
  curator_cli --help        
  curator_cli show_indices --help
  # 管理索引
  curator_cli --host 127.0.0.1 --port 9201 show_indices --verbose
  myindex-2019.09.04   open 230.0B  0   1   0 2019-09-06T07:19:03Z
  ```

- 程序curator



  ```bash
  curator --help    
  curator [OPTIONS] ACTION_FILE
  # 启动
  curator --config curator.yml action.yaml 
  ```
 curator.yml

  ```yaml
  # cat curator.yml 
  # Remember, leave a key empty if there is no value.  None will be a string,
  # not a Python "NoneType"
  client:
    hosts:
      - 127.0.0.1
    port: 9201
    url_prefix:
    use_ssl: False
    certificate:
    client_cert:
    client_key:
    ssl_no_validate: False
    http_auth:
    timeout: 60
    master_only: False
  
  logging:
    loglevel: INFO
    logfile: /data/logs/curator.log    # 日志
    logformat: default
    blacklist: ['elasticsearch', 'urllib3']
  ```

 action.yml

  ```yaml
  # cat action.yml
  actions:
  1:
    action: delete_indices
    description: "超过100G相关日志保留3天"
    options:
      # action开关，为True表示不执行这个action，默认False
      disable_action: False
      # 发现错误后，继续执行下一个索引操作，默认False
      continue_if_exception: True 
      # ignore_empty_list标识忽略选项，默认False，
      # 如果为True，则在filters空列表时，继续下一个action处理而不是退出程序。
      ignore_empty_list: True
    filters:
    - filtertype: pattern
      kind: regex
      value: '(^k8s-datalogs-zhenai-crm-wechat-master).*$'
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 3 

  2:
    action: delete_indices
    description: "nginx保留15天"
    options:
      # action开关，为True表示不执行这个action，默认False
      disable_action: False
      # 发现错误后，继续执行下一个索引操作，默认False
      continue_if_exception: True 
      # ignore_empty_list标识忽略选项，默认False，
      # 如果为True，则在filters空列表时，继续下一个action处理而不是退出程序。
      ignore_empty_list: True
    filters:
    - filtertype: pattern
      kind: regex
      value: '(.*-nginx-|^k8s-datalogs-zhenai-crm-wechat-master).*$'
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y.%m.%d'
      unit: days
      unit_count: 15 
  ```
  

### elastic工具集合

```bash
2.1 基础类工具
1、Head插件
1）功能概述：ES集群状态查看、索引数据查看、ES DSL实现（增、删、改、查操作）比较实用的地方：json串的格式化
2）地址：http://mobz.github.io/elasticsearch-head/

2、Kibana工具
除了支持各种数据的可视化之外，最重要的是：支持Dev Tool进行RESTFUL API增删改查操作。比Postman工具和curl都方便。
地址：https://www.elastic.co/products/kibana

3、ElasticHD工具
强势功能——支持sql转DSL，不要完全依赖，可以借鉴用。
地址：https://github.com/360EntSecGroup-Skylar/ElasticHD

2.2 集群监控工具
4、cerebro工具
地址：https://github.com/lmenezes/cerebro

5、Elaticsearch-HQ工具
管理elasticsearch集群以及通过web界面来进行查询操作
地址：https://github.com/royrusso/elasticsearch-HQ

2.3 集群迁移工具
6、Elasticsearch-migration工具
支持多个版本间的数据迁移，使用scroll+bulk
地址：https://github.com/medcl/elasticsearch-migration

7、Elasticsearch-Exporter
将ES中的数据向其他导出的简单脚本实现。
地址：https://github.com/mallocator/Elasticsearch-Exporter

8、Elasticsearch-dump
移动和保存索引的工具。
地址：https://github.com/taskrabbit/elasticsearch-dump

2.4 集群数据处理工具
9、elasticsearch-curator
elasticsearch官方工具，能实现诸如数据只保留前七天的数据的功能。
地址：https://pypi.python.org/pypi/elasticsearch-curator
另外 ES6.3（还未上线）  有一个 Index LifeCycle Management 可以很方便的管理索引的保存期限。

2.5 安全类工具
10、x-pack工具
地址：https://www.elastic.co/downloads/x-pack

11、search-guard 第三方工具
Search Guard  是 Elasticsearch 的安全插件。它为后端系统（如LDAP或Kerberos）提供身份验证和授权，并向Elasticsearch添加审核日志记录和文档/字段级安全性。
Search Guard所有基本安全功能（非全部）都是免费的，并且内置在Search Guard中。  Search Guard支持OpenSSL并与Kibana和logstash配合使用。
地址：https://github.com/floragunncom/search-guard

2.6 可视化类工具
12、grafana工具
地址：https://grafana.com/grafana
grafana工具与kibana可视化的区别：
如果你的业务线数据较少且单一，可以用kibana做出很棒很直观的数据分析。
而如果你的数据源很多并且业务线也多，建议使用grafana，可以减少你的工作量
对比：https://www.zhihu.com/question/54388690

2.7 自动化运维工具
elasticsearch免费的自动化运维工具
13、Ansible
https://github.com/elastic/ansible-elasticsearch

14、Puppet
https://github.com/elastic/puppet-elasticsearch

15、Cookbook
https://github.com/elastic/cookbook-elasticsearch
以上三个工具来自medcl大神社区问题的回复，我没有实践过三个工具。

2.8 类SQl查询工具
16、Elasticsearch-sql 工具
sql 一款国人NLP-china团队写的通过类似sql语法进行查询的工具
地址：https://github.com/NLPchina/elasticsearch-sql
ES6.3+以后的新版本会集成sql。

2.9 增强类工具
17、Conveyor 工具
kibna插件——图形化数据导入工具
地址：http://t.cn/REOhwGT

18、kibana_markdown_doc_view 工具
Kibana文档查看强化插件，以markdown格式展示文档
地址：http://t.cn/REOhKgB

19、 indices_view工具
indices_view 是新蛋网开源的一个 kibana APP 插件项目，可以安装在 kibana 中，快速、高效、便捷的查看elasticsearch 中 indices 相关信息
地址：https://gitee.com/newegg/indices_view

20、dremio 工具
支持sql转DSL，
支持elasticsearch、mysql、oracle、mongo、csv等多种格式可视化处理；
支持ES多表的Join操作
地址：https://www.dremio.com/

2.10 报警类
21、elastalert
ElastAlert 是 Yelp 公司开源的一套用 Python2.6 写的报警框架。属于后来 Elastic.co 公司出品的 Watcher 同类产品。
官网地址: http://elastalert.readthedocs.org/
使用举例：当我们把ELK搭建好、病顺利的收集到日志，但是日志里发生了什么事，我们并不能第一时间知道日志里到底发生了什么，运维需要第一时间知道日志发生了什么事，所以就有了ElastAlert的邮件报警。

22、sentinl
SENTINL 6扩展了Siren Investigate和Kibana的警报和报告功能，使用标准查询，可编程验证器和各种可配置操作来监控，通知和报告数据系列更改 - 将其视为一个独立的“Watcher” “报告”功能（支持PNG / PDF快照）。
SENTINL还旨在简化在Siren Investigate / Kibana 6.x中通过其本地应用程序界面创建和管理警报和报告的过程，或通过在Kibana 6.x +中使用本地监视工具来创建和管理警报和报告的过程。
官网地址：https://github.com/sirensolutions/sentinl
```


[TOC]

## Elastic中遇到的问题

###  磁盘不足触发高水位导致索引只读

- 现象

  kibana查不到数据，集群状态为red
- 报错 

  logstash日志 [ClusterBlockException: blocked by: [FORBIDDEN/12/index read-only / allow delete (api)]](https://www.aityp.com/解决elasticsearch索引只读/)

- 分析解决

  触发es高水位（默认90%）导致所有索引锁住，logstash无法创建新的index

   ```bash
   # 清理磁盘上大于1G的容器日志
   du -sh /var/lib/docker/containers/*/*-json.log | grep G |awk '{print $2}' | xargs -i sed -i '1,$d' {}
   
   # 设定索引读写状态
   curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_all/_settings -d '{
   			"index.blocks.read_only_allow_delete": false
   }'
   
   # 在kibana操作
   PUT _settings  
   { "index": {  "blocks": {  "read_only_allow_delete": "false" }  } }
   ```

### 线程池打满导致logstash日志code: 429

- 现象

  ```txt
  # logstash日志
  logstash    | [2019-05-06T16:24:17,476][INFO ][logstash.outputs.elasticsearch] retrying failed action with response code: 429
  ({"type"=>"es_rejected_execution_exception", "reason"=>"rejected execution of processing of [833922829][indices:data/write/
  bulk[s][p]]: request: BulkShardRequest[[crm-provider-permission-2019.05.06][4]] containing [153] requests, target allocation 
  id: x8vav1ixQ_6ILskMY6IsYw, primary term: 1 on EsThreadPoolExecutor[name = node-hot-2/write, queue capacity = 5000,
  org.elasticsearch.common.util.concurrent.EsThreadPoolExecutor@4958db63[Running, pool size = 17, active threads = 17, 
  queued tasks = 5004, completed tasks =598685703]]"})
  ```

- 分析解决

  [Why am I seeing bulk rejections in my Elasticsearch cluster?](<https://www.elastic.co/cn/blog/why-am-i-seeing-bulk-rejections-in-my-elasticsearch-cluster>)
  
   [Increasing the size of the queue in Elasticsearch?](https://stackoverflow.com/questions/33110310/increasing-the-size-of-the-queue-in-elasticsearch)

  ```bash
  # 查看线程池情况
  # curl -s -XGET "http://127.0.0.1:9200/_cat/thread_pool/write?v&h=node_name,name,active,rejected,completed"
  # GET /_cat/thread_pool/write?v
  node_name     name  active queue rejected
  node-7        write      0     0        0
  node-master-2 write      0     0        0
  
  # GET /_cat/thread_pool/write?v&h=node_name,name,active,rejected,completed
  node_name     name  active rejected completed
  node-8        write      0     2393 133703661
  node-7        write      0        0  27376561
  
  
  # 调整线程池
  # es5后版本不能动态调整"transient setting [thread_pool.write.queue_size], not dynamically updateable"
  PUT _cluster/settings
  {
      "transient": {
        "thread_pool": {
          "bulk": {
            "queue_size": "1000"
          }
        }
      }
  }
  
  
  # 配置文件
  # cat elasticsearch.yml
    thread_pool:
        write:
            size: 32     
            queue_size: 100000
    processors: 32 
  ```

### 日志延迟之docker跑logstash的瓶颈

- 现象

  kibana搜索日志持续延迟

- 分析
  ```txt
  链路：filebeat - ckafka - logstash - elastic
  查看ckafka发现大量堆积，es集群监控没有明显问题
  
  # logstash日志
  {"log":"[2019-09-19T17:34:32,102][WARN ][org.apache.kafka.clients.consumer.internals.ConsumerCoordinator] [Consumer clientId=logstash-3, groupId=qcloud-es] Synchronous auto-commit of offsets {k8s-ingress-5=OffsetAndMetadata{offset=16998, metadata=''}} failed: Commit cannot be completed since the group has already rebalanced and assigned the partitions to another member. This means that the time between subsequent calls to poll() was longer than the configured max.poll.interval.ms, which typically implies that the poll loop is spending too much time message processing. You can address this either by increasing the session timeout or by reducing the maximum size of batches returned in poll() with max.poll.records.\n","stream":"stdout","time":"2019-09-19T09:34:32.103452687Z"}
  
  
  通过xpack.monitoring查看Events Received Rate才80/s，并且在日志中出现WARN,关于session timeout
  ```

- 解决

  去掉docker层 

   [Logstash-Kafka Commit cannot be completed since the group has already rebalanced and assigned the partitions to another member.](https://github.com/Cyb3rWard0g/HELK/issues/73)
   
   ```bash
   # 查看logstash的性能数据
   wget https://github.com/elastic/support-diagnostics/releases/download/7.0.9/support-diagnostics-7.0.9-dist.zip
   
   # 当前目录生成logstash-diagnostics-20190921-095257.tar.gz
   ./diagnostics.sh --host localhost --type logstash --port 9600
   ```

   ```bash
  1. 调整pipeline.batch.size: 125 pipeline.batch.delay:50为默认值，观察无报错，正常消费
  2. 调整pipeline.batch.delay:50为500会出现WARN
  3. 去掉docker后event received rate由最好的800/s可以达到10000/s以上，此时es集群写入速度达到4w条每秒
  
  # logstash性能参数
  pipeline.workers: 10
  pipeline.batch.size: 3000   # 可适当调大
  pipeline.batch.delay: 50    # 建议默认值
  config.reload.automatic: true
  pipeline.output.workers: 10
  
  # pipeline.conf调整
  input {
     kafka {
         bootstrap_servers => "10.11.4.61:9092"
         topics => ["k8s-ingress"]
         group_id => "qcloud-es"
         ##### optimizing availablity #####
         consumer_threads => 8
         #session_timeout_ms => "10000"
    	   max_poll_records => "500"   # 默认500
    	  # max_poll_interval_ms => "300000"
     }
  }
  ```

### 导致索引UNASSIGNED未分片状态的原因

- 现象

  集群健康状态非green（red存在基础分片未分配，yellow存在复制分片未分配）
  
   ```bash
    # 查看分片情况
    curl -s http://localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason |grep -i unassigned
    curl -s http://localhost:9200/_cluster/allocation/explain?pretty
    ```

- 解决

  [how-to-resolve-unassigned-shards-in-elasticsearch](https://fashengba.com/post/how-to-resolve-unassigned-shards-in-elasticsearch.html)  
  [elasticsearch-unassigned-shards](https://www.datadoghq.com/blog/elasticsearch-unassigned-shards/#reason-2-too-many-shards-not-enough-nodes)

#### 分片有目的性延迟

```bash
   动态调整延迟时间
   curl -XPUT 'localhost:9200/<INDEX_NAME>/_settings' -d 
   '{
       "settings": {
          "index.unassigned.node_left.delayed_timeout": "30s"
       }
   }'
   
   如果需要修改所有索引的阀值，则可以使用_all替换<INDEX_NAME>
```

#### 分片太多，节点不够

```bash
因为主分片不会分配给其副本相同的节点，同一分片的两个副本不会分配给同一节点。如果没有足够的节点，分片将处于未分片状态。计算公式： N >= R + 1 （N是集群节点数量，R是索引的最大分片复制因子）
   
解决：增加节点数，或者减少复制因子
curl -XPUT 'localhost:9200/<INDEX_NAME>/_settings' -d '{"number_of_replicas": 1}'
```

#### 重新启用分片分配

```bash
当有新的节点加入集群，但是尚未分片，可以重新启用分片分配
curl -XPUT 'localhost:9200/_cluster/settings' -d
   '{ "transient":
       { "cluster.routing.allocation.enable" : "all" 
       }
   }'
   
重新分配指定分片
curl -XPOST 'localhost:9200/_cluster/reroute' -d'{ "commands" :
        [{
            "move" : {
                "index" : "log-java-idc-2018.07.12",
                "shard" : 0,
                "from_node" : "node-2",
                "to_node" : "node-10.10.11.48"
            }
        }]
}'
```

####  分片数据不在存在集群中 

[elastic5.3- cluster-reroute](https://www.elastic.co/guide/en/elasticsearch/reference/5.3/cluster-reroute.html#cluster-reroute)

```
强制重新分片，会丢数据
curl -XPOST 'localhost:9200/_cluster/reroute' -d'{ "commands" :
         [ { "allocate_empty_primary" : 
             { "index" : "log-java-idc-2018.07.10", "shard" : 0, "node": "node-10.10.11.63","accept_data_loss":true  }
         }]
   }'

```

#### 磁盘低水位

```bash
   调整低水位阈值
   curl -XPUT 'localhost:9200/_cluster/settings' -d
      '{
          "transient": {  
                "cluster.routing.allocation.disk.watermark.low": "90%"
          }
      }'
      
   低水位&高水位理解：
   低水位： 集群不会分配新的分片给该节点
   高水位： 集群将该节点的分片尝试迁移到其他节点
   即达到低水位将不再ES集群将不再向该节点写数据，为了防止磁盘被其他程序写满导致ES问题，ES在节点达到高水位时，会尝试迁移节点分片
     
```

#### 磁盘不足触发高水位导致索引被锁住为只读




###  索引太多触发腾讯云JVM OLD熔断

- 现象

  kibana查看集群为red状态

- 报错

  `plugin:security@6.4.3	 [status_exception] pressure too high, smooth bulk request circuit break`

  [腾讯云 ES 自研熔断器及常见问题](https://cloud.tencent.com/document/product/845/35547)

- 分析解决

  Elasticsearch 提供了多种官方的熔断器（circuit breaker），用于防止内存使用过高导致 ES 集群因为 OutOfMemoryError 而出现问题。

  腾讯云 ES 的自研熔断器监控 JVM OLD 区的使用率，当使用率超过`85%`时开始拒绝写入请求，若 GC 仍无法回收 JVM OLD 区中的内存，在使用率到达`90%`时将拒绝查询请求。

  ```bash
  #### 释放内存
  # 查看索引的字段占用内存
  curl -XGET -u abc:123 'http://10.1.1.10:9200/_cat/indices?v&h=index,fielddata.memory_size&s=fielddata.memory_size:desc' > /tmp/es-fielddata.log
  
  # 从第二行开始显示，过滤出大于等于1mb的索引
  tail -n +2 es-fielddata.log|egrep -w -v '[0-9.]*[k]?b'|awk '{print $1}' > /tmp/fielddata
  
  # 清理字段内存fielddata
  while read index
  do
   curl -XPOST -u abc:123 "http://10.1.1.10:9200/${index}/_cache/clear?fielddata=true"
  done < /tmp/fielddata
  
  # 每个 segment 的 FST 结构都会被加载到内存中，并且这些内存是不会被 GC 回收的。
  # 清理segment可以通过删除部分不用的索引，关闭索引，或定期合并不再更新的索引等方式缓解
  # 过滤出非.开头、非2020年的索引
  tail -n +2 /tmp/es-fielddata.log | awk '{print $1}' |egrep -v '^\.|2020.[0-9]{2}.[0-9]{2}' | egrep '[0-9]{4}.[0-9]{2}.[0-9]{2}' > /tmp/clear-index

  # 清理不必要索引 （产生原因，其他人配置的grok解析日期字段有问题）
  while read index
  do
   curl -XDELETE -u abc:123 "http://10.11.40.66:9200/${index}"
  done < /tmp/clear-index
  ```

- 附带操作

  - 考虑日志是否丢失，查看kafka的健康状况以及消费情况

    https://cloud.tencent.com/document/product/597/30059

    ```bash
    # kafka中consumer group的状态说明
    Dead：消费者组内无成员并且 Metadata 已经被移除。
    Empty：消费分组内当前没有任何成员。如果组内所有offset都已过期，则会变为Dead状态。一般新创建的 Group 默认为 Empty 状态。开源 Kafka 0.10.x 版本规定，当消费分组内没有任何成员且状态持续超过7天，此消费分组将会被自动删除。
    Stable：消费分组中各个消费者已经加入，处于稳定状态。
    ```

  - logstash与kibana出现的报错

    **logstash**

    `[ERROR][logstash.outputs.elasticsearch] Encountered a retryable error. Will Retry with exponential backoff  {:code=>403, :url=>"http://10.11.40.66:9200/_bulk"`

    https://elasticsearch.cn/question/6927

    分析：logstash里面配置的是索引的别名，然后由于重复建索引导致有多个相同的别名，logstash不知道往哪个里面写，es返回的400

    **kibana**

    `Help us improve the Elastic Stack by providing basic feature usage statistics? We will never share this data outside of Elastic.`

    https://blog.51cto.com/michaelkang/2298689

    ```bah
    # 允许es临时创建索引后点击kibana页面的yes
    PUT _cluster/settings
    {
       "transient" : { "action.auto_create_index": "true" }
    }
    ```


