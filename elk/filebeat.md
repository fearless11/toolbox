[TOC]

## filebeat

 一个文件收集工具。

### reference

- [filebeat5.6-overview](https://www.elastic.co/guide/en/beats/filebeat/5.6/filebeat-overview.html)

- [filebeat5.6-install](https://www.elastic.co/guide/en/beats/filebeat/5.6/filebeat-installation.html)

- [how-filebeat-works](https://www.elastic.co/guide/en/beats/filebeat/5.6/how-filebeat-works.html)
 
- [filebeat5.6-config](https://www.elastic.co/guide/en/beats/filebeat/5.6/filebeat-configuration-details.html)

 
- [filebeat6.6-module](https://www.elastic.co/guide/en/beats/filebeat/6.6/filebeat-modules-overview.html)

### how filebeat wok

工作原理：

prospector(两种类型log、stdin对应代码crawler) --> harvester --> spooler --> publisher --> registrar

- prospector 发现文件，启动harvester，一个文件对应一个harvest
- harvester   读文件或标准输入，将读到的一个事件event发送给spooler，一个event默认为一行
- spooler      将event发送flush到publisher
- publisher    将enevnt发送给各个output,通知registrar记录文件的position
- registrar    记录文件的position
- 最后prospector会使用registrar的信息，决定每个文件重启harvester

### architecture

![1543321458246](https://www.elastic.co/guide/en/beats/filebeat/5.6/images/filebeat.png)

### install

```shell
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.6.8-linux-x86_64.tar.gz
tar xvf filebeat-5.6.8-linux-x86_64.tar.gz -C /usr/local

# 直接debug到终端，调试使用
cd /usr/local/filebeat-5.6.8-linux-x86_64
./filebeat -c filebeat.yml -e  

# 启动
nohup /usr/local/filebeat-5.6.8-linux-x86_64/filebeat -c /usr/local/filebeat-5.6.8-linux-x86_64/filebeat.yml &
```

### configuration

```yaml
# filebeat.yaml
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/nginx/*log
    - /var/log/syslog/*log
  	exclude_files: [".gz$"]
  	ignore_older: 24h

- input_type: log
  paths:
    - /var/log/php-fpm/*log
  # 改变编码方式
  encoding: gbk
  # 多行匹配
  # 每行以2开头的到下一个以2开头的行之间的内容作为一event
  multiline.pattern: ^2      
  # true时匹配到的行为新event，flase时匹配的行追加到上一个event
  multiline.negate: true      
  # before是上一个匹配模式之间，after是到下一个匹配模式之间
  multiline.match: after      
  
  # 单行JSON格式输出 
  json.keys_under_root: true
  # 覆盖已存在的key，覆盖@timestamp格式为2020-02-11T14:56:18.000Z
  json.overwrite_keys: true
  json.add_error_key: true
  
# 额外字段
name: 192.168.1.11
tags: ["web", "test"]
fields:
  env: test
  host: web


output.kafka:
  hosts: ["127.0.0.1:9092"]
  topic: "Internet"
  worker: 3
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  max_message_bytes: 1000000
  compression: none
  version: 0.8.2
  

output.logstash:
  hosts: ["10.10.10.21:5044", "10.10.10.24:5044"]
  # 默认0不压缩，范围1~9，level越高，网络带宽使用降低但是cpu使用增加
  compression_level: 4 
  
# 修改index必须修改template
setup.template.name: "logs"
setup.template.pattern: "logs-*"

output.elasticsearch:
  	hosts: ["127.0.0.1:9200"]
  	index: "logs-%{+yyyy.MM.dd}"
  	# 指定es的ingest node
  	pipeline: "log-pipeline"       
    # 网络限速 
    # filebeat发送event给es前将event进行累积。默认累积50个event发送。
    # 可以提高性能降低发送event的频率
    # 设置过大会增加进程处理时间，导致API errors, killed connections,
    # timed-out publishing requests，最终降低吞吐量。
    bulk_max_size: 100 
     # filebeat发送event给es之间的等待时间，单位s
    flush_interval: 1  


# 输出文件，方便定位问题
output.file:
  enabled: true
  path: /tmp/filebeat
  filename: filegbeat
  # 单位KB，默认一个文件10M
  rotate_every_kb: 10240         
  # 默认只保留7个文件
  number_of_files: 7             
  
# debug, info, warning, error, or critical
logging.level: warning
logging.to_files: true
logging.to_syslog: false
logging.files:
  path: /var/log/mybeat
  name: mybeat.log
  keepfiles: 7
  permissions: 0600
```


### module

 - 实现了收集、解析、可视化日志。  （版本5.2以上）
 - 解析由elastic的 Ingest Node 实现
 
 - 配置
   
   ```bash
   # elastic安装插件，重启
   sudo bin/elasticsearch-plugin install ingest-geoip
   sudo bin/elasticsearch-plugin install ingest-user-agent
   
   
   # filebeat启动模块
   filebeat modules enable nginx 
   ```
   
 - 自定义nginx module 配置
 
   ```yaml
    # cat modules.d/nginx.yml
   - module: nginx
     # Access logs
     access:
       enabled: true
   
       # Set custom paths for the log files. If left empty
       var.paths: ["/usr/local/nginx/logs/za_api_access.log"]
       
       # 和input的配置一模一样
       input:
         exclude_lines: ['\bHEAD\b']
         tail_files: true
         fields:
           app_id: "nginx"
         processors:
         - drop_fields:
             fields: ["beat","log.file.path","event","fileset","input.type","offset"]
   ```
 
 - 对日志字段如何处理可修改ingest的json文件   `cat module/nginx/access/ingest/default.json`
 

[TOC]


## filebeat5.6 二次开发

### reference


- [filebeat 5.6.8](https://github.com/elastic/beats/tree/v5.6.8/filebeat)

- [elastic-plugins-filters-grok](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html)

### 功能

- 增加扫web日志时进行grok解析后存储到elastic
- 增加prometheus client，暴露状态码和请求时间指标


### 思路

  在事件event产生的地方grok同时埋prometheus client即可

  ```bash
  # filebeat5.6的项目结构
  filebeat
  ├── beater
  ├── crawler
  ├── harvester   # log.go中产生event事件故对此操作
  ├── input
  ├── prospector
  ├── registrar
  ├── spooler
  ├── ....
  └── tests
  ```
  
### 代码

-  filebeat.yml

   ```yaml
   input_type: log    
   	paths:     - ./var/phpfpmlog  
   multiline.pattern: ^[           //多行匹配    
   multiline.negate: true    
   multiline.match: after  
   grok_pattern: '[%{DATA:timestamp} PRC] %{DATA:lv}: %{GREEDYDATA:txt}'  //grok表达式 
   output.console:   //输出屏幕验证    
   	pretty: true 
   ```

- harvset.go

   ```go
   type harvesterConfig struct {
       Multiline *reader.MultilineConfig `config:"multiline"`
       GrokPattern  string `config:"grok_pattern"`
       ....
   }
   ```

- log.go

   ```go
   import (
      ....               
      "github.com/vjeantet/grok" // go get github.com/vjeantet/grok 
   )
   
   // 无论是stdin或log的输入类型，最终都在函数进行harvest，故在此处grok解析
   func (h *Harvester) Harvest(r reader.Reader) {
           ....               //省略默认代码
           if h.state.Offset == 0 {
               message.Content = bytes.Trim(message.Content, "\xef\xbb\xbf")
           }
          // grok解析
           if len(h.config.GrokPattern) !=0 {
               msg:=string(message.Content)
               fields:=common.MapStr{}
               g, _ := grok.NewWithConfig(&grok.Config{NamedCapturesOnly: true})
               values,err:=g.Parse(h.config.GrokPattern,msg)
               if err==nil {
                   for k, v := range values {
                       fields[k]=v
                   }   
                   fields["grok"]= true      //grok解析成功
               }else{
                   fields["grok"]= flase     //grok解析失败
               }
               message.Fields=fields
           }
           ......      
   }
   ```

- 验证

   ```go
   #cat ./var/phpfpmlog
   [22-Jul-2018 10:58:35 PRC] PHP Notice:  duplicate class [Channel] found in
   /var/www/to8to/trdn/weixin/app/default/lib/util/Channel.php
   , or please clear the cache in /var/www/to8to/lotusruntime/Autoloader/Autoloader.php on line 357
   
   //运行
   #go run mian.go
   {
     "@timestamp": "2018-07-22T09:47:15.603Z",
     "beat": {
       "hostname": "abc",
       "name": "abc",
       "version": "5.6.8"
     },
     "grok": true,                         //增加的grok解析成功的字段
     "input_type": "log",
     "lv": "PHP Notice",                    // grok解析的lv
     "message": "[22-Jul-2018 10:58:35 PRC] PHP Notice",
     "offset": 232,
     "source": "E:\\gohome\\src\\var\\phpfpmlog",
     "timestamp": "22-Jul-2018 10:58:35",           //grok解析的timestamp
     "txt": " duplicate class [Channel] found in", 
     "type": "log"
   } 
   ```