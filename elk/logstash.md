[TOC]



## logstash

一个收集数据后解析的工具。

### reference

[logstash5.6-guide](https://www.elastic.co/guide/en/logstash/5.6/index.html)

[logstash6.3-settings-file](https://www.elastic.co/guide/en/logstash/6.3/logstash-settings-file.html)

[logstash6.3-multiple-pipelines](https://www.elastic.co/guide/en/logstash/6.3/multiple-pipelines.html#multiple-pipeline-usage)

[logstash6.3-config-examples](https://www.elastic.co/guide/en/logstash/6.3/config-examples.html)

[logstash6.3-how-monitoring-works](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/how-monitoring-works.html)

[logstash6.3-node-stats-api](https://www.elastic.co/guide/en/logstash/6.3/node-stats-api.html)

[logstash6.3-monitoring-ui](https://www.elastic.co/guide/en/logstash/6.3/logstash-monitoring-ui.html)

[logstash-filters-date-match](https://www.elastic.co/guide/en/logstash/current/plugins-filters-date.html#plugins-filters-date-match)

[grokdebug](http://grokdebug.herokuapp.com/)  

[logstash-pattern-github](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)

[logstash6.3-input](https://www.elastic.co/guide/en/logstash/6.3/input-plugins.html) 

[logstash6.3-filter](https://www.elastic.co/guide/en/logstash/6.3/filter-plugins.html) 

[logstash6.3-date](https://www.elastic.co/guide/en/logstash/6.3/plugins-filters-date.html)

[logstash6.3-grok](https://www.elastic.co/guide/en/logstash/6.3/plugins-filters-grok.html)

[logstash-if](https://www.elastic.co/guide/en/logstash/current/event-dependent-configuration.html)

[logstash-Kafka时reblance问题](https://github.com/Cyb3rWard0g/HELK/issues/73)


### install

```bash
# 依赖java
wget http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/ \
jdk-8u144-linux-x64.tar.gz?AuthParam=1501346908_907cdcc5a265a61a3c88ae2f31c0be32
tar xfvz jdk-8u144-linux-x64.tar.gz -C /usr/local/
echo "export JAVA_HOME=/usr/local/jdk1.8.0_144" >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar' >> /etc/profile
source /etc/profile
# java -version
java version "1.8.0_144"

# logstash
wget https://artifacts.elastic.co/downloads/logstash/logstash-5.6.8.tar.gz
tar xf logstash-5.6.8.tar.gz -C /data/
cd /data/logstash-5.6.8/

# 交互式启动
./bin/logstash -e 'input { stdin { } } output { stdout {} }'
hello   
hello

# 配置文件方式启动
# 检查配置文件格式
bin/logstash -f first-pipeline.conf --config.test_and_exit
# 热加载配置文件
bin/logstash -f first-pipeline.conf --config.reload.automatic 
# 启动
nohup /data/logstash-5.6.8/bin/logstash -f /data/logstash-5.6.8/config/first-pipeline.conf &
```

### configure

- 命令行flag高于配置文件
- 支持环境变量PTAH `node.name: ${NODENAME}`

#### files

- setting files

    ```bash
    # logstash.yml
    # 监控配置
    xpack.monitoring.enabled: true
    xpack.monitoring.elasticsearch.url: ["http://es-node1:9200", "http://es-node2:9200"] 
    xpack.monitoring.elasticsearch.username: "logstash_system" 
    xpack.monitoring.elasticsearch.password: "changeme"
    xpack.monitoring.elasticsearch.sniffing: false

    # 性能调优
    # 并发执行fileter和output阶段的pipeline数量,提高cpu使用率
    pipeline.workers: 8         
    # 每个worker线程从inputs读取的最大events数,默认125,越大越有效但内存将增加,可配合调整jvm.options
    pipeline.batch.size: 3000
    # 发送下一批event之前,前一批中每个event等待的时间。默认50ms
    pipeline.batch.delay: 50
    pipeline.output.workers: 8
    
    # 常用参数
    # 热加载配置，改变将触发SIGHUP信号reload,默认false
    config.reload.automatic: true
    # trace、debug、info、warn、error、fatal,默认info
    log.level: info
    # json or plain, 默认plain
    log.format: plain
    ```
  
- pipeline configuration files
 
    ```yaml
    # vim logstash-6.3.1/config/pipelines.yml
     - pipeline.id: to_es
       path.config: "logstash-6.3.1/config/pipeline"
       # 事件event的缓存 memory or persisted, 默认memory
       queue.type: memory
       
    # 在目录logstash-6.3.1/config/pipeline下写pipeline.conf
    ```

#### input

```yaml
input { 
    # 标准输入
    stdin { } 

    # beat
    beats {
        port => 5044
        # 可用来区分多个beat
        add_field => { "myid" => "java" }
    }
    
    # beat
    beats {
        port => 5045
        add_field => { "myid" => "php" }
    }
    

    # 文件
    file {
        # 递归 /var/log/**/*.log
        path => ["/var/log/*","/var/log/**/*.log"]
        exclude => ["*.gz"]
        # 设置读取文件的位置
        start_position => "beginning"
    }


    # kafka
    kafka {
        bootstrap_servers => "xxx:9092"
        topics => ["__TOPIC__"]
        group_id => "to_es"
        consumer_threads => 8
        # 调优参数
        # 与kafka的心跳时间,时间必须低于session.timeout.ms,一般是其1/3
        # 调低可以控制正常的rebalances时间,默认不设置
        heartbeat_interval_ms => 
        # 超时后,如果poll_timeout_ms没触发将引起comsumer的rebalance,默认不设置
        session_timeout_ms =>  
        # 单个poll池的最大records数,默认不设置
        max_poll_records => 
        # 触发下个poll是最大延迟时间,值必须大于request_timeout_ms,默认不设置
        max_poll_interval_ms => 
        # 连接kafka的最大响应时间,默认不设置
        request_timeout_ms => 
    }
}
```

#### filter

```yaml
filter {

    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
        # TIMESTAMP_ISO8601 %{YEAR}-%{MONTHNUM}-%{MONTHDAY}[T ]%{HOUR}:?%{MINUTE}(?::?%{SECOND})?%{ISO8601_TIMEZONE}?
        match => { "message" => "(?:^(?<timestamp1>%{TIMESTAMP_ISO8601})|^[\[](?<timestamp1>%{TIMESTAMP_ISO8601}))"}
    }

    date {
        # ISO8601 time 中T字符的处理 "2015-01-01T01:12:23" "yyyy-MM-dd'T'HH:mm:ss"
        match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
    
    mutate {
		copy => { "source" => "sourcetmp" }
        copy => { "[host][ip][0]" => "[host][ip]" }
    	split => ["sourcetmp","/"] 
    	
    	
		add_field => {
	    	"[fields][app]" => "%{[sourcetmp][3]}"
	    	 # filebeat6.6版本后支持采集host信息
	    	 # [host][ip][0]不存在则作为字符显示%{[host][ip][0]}
	    	 "[beat][ip]" => "%{[host][ip][0]}"
	    }
	    remove_field => "message"
	    rename => { "HOSTORIP" => "client_ip" }
	}
}
```

#### output
```yaml
output {
    # 标准输出
    stdout { codec => rubydebug }

    # 输出到es
    elasticsearch {
        hosts => ["127.0.0.1:9200"]
        index => "%{[fields][project]}-%{[fields][app]}-%{+YYYY.MM.dd}"
        user => "elastic"
        password => "xxx"
    }
}
```

#### if

```yaml
# You can use the following comparison operators:
# equality: ==, !=, <, >, <=, >=
# regexp: =~, !~ (checks a pattern on the right against a string value on the left)
# inclusion: in, not in

# The supported boolean operators are:
# and, or, nand, xor

# The supported unary operators are:
# !

if EXPRESSION {
  ...
} else if EXPRESSION {
  ...
} else {
  ...
}
```


#### grok-nginx

- format
    ```
    log_format  main  '$host $remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent $upstream_response_time "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for" "$uid_got" "$uid_set" "$http_x_tencent_ua" "$upstream_addr" "$upstream_http_x_cached_from"    "$upstream_http_cache_control"';
    ```
- 日志
    ```bash
    # 多个upstream
    secure.to8to.com 10.20.12.12 - - [19/Apr/2019:10:52:39 +0800] "GET /api/getAreaInfo.php?callback=jQuery1102029247559671811807_1555642358909&act=getIp&_=1555642358910 HTTP/1.1" 200 180 0.027 "https://www.to8to.com/ask/k7794159.html" "Mozilla/5.0" "111.206.222.213, 39.105.242.161" "-" "-" "-" "10.10.10.81:80" "-" "no-cache"

    # upstream为空
    to8to.com 119.145.230.168 - - [19/Apr/2019:10:52:38 +0800] "HEAD / HTTP/1.1" 301 0 0.000 "-" "-" "-" "-" "-" "-" "10.10.10.56:80" "-" "-"

    # upstream为upstream_name
    secure.to8to.com 10.20.12.12 - - [19/Apr/2019:10:52:39 +0800] "GET /api/getAreaInfo.php?callback=jQuery1102029247559671811807_1555642358909&act=getIp&_=1555642358910 HTTP/1.1" 200 180 0.027 "https://www.to8to.com/ask/k7794159.html" "Mozilla/5.0" "to8to_com" "-" "-" "-" "10.10.10.81:80" "-" "no-cache"
    ```
- grok正则
    ```bash
    %{USERNAME:domain} %{IPV4:client_ip} (.*) \[%{HTTPDATE:timestamp}\] (.*) %{URIPATH:path}(.*)\" (?:%{INT:response_status}|-) (?:%{INT:response_bytes}|-) (?:%{NUMBER:response_time}|-)%{DATA:other} (%{DATA:url}) (%{DATA:agent}) \"(?:%{USERNAME:upstream}|-)(.*) (.*)
    ```
    
    
### 抛错

- `Exception in thread "main" java.lang.UnsupportedClassVersionError: org/logstash/Logstash : Unsupported major.minor version 52.0`

  ```bash
  # 多JAVA环境指定JAVA版本
  # grep "^export JAVA" logstash/bin/logstash.lib.sh 
  export JAVA_CMD="/usr/local/jdk1.8.0_121/bin/"
  export JAVA_HOME="/usr/local/jdk1.8.0_121"
  ```
  
- `"status"=>400, "error"=>{"type"=>"mapper_parsing_exception", "reason"=>"failed to parse [host]"`
    
   ```bash
   # 去掉host字段
   filter{
    mutate {
       add_field => {
           "hostip" => "10.1.1.17"
       }
       remove_field => ["@version","timestamp","host"]
    }
   }
   ```
 