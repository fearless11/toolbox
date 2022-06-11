[toc]

# kafka

## 概念

Producer：生产者
Consumer：消费者
Streams：流式处理
Connector： 转换关系型数据库中table内容

kafka作为集群，运行一个或多个；
kafka通过topic对存储流数据分类；
每条记录一个key、一个value、一个timestamp
一个topic对应一个或多个分区
一个topic可以被一个或多个消费者订阅

## 特点

可靠性：分布式、分区、复制、容错
可扩展性：轻松缩放
耐用性：分布式提交日志，消息尽可能保持在磁盘上
性能：高吞吐量。速度快，执行2百万写/秒
存储: 一条记录是否会被抛弃释放磁盘空间，与kafka的性能和数据大小无关，由保留策略设置时间决定

## 应用

1. 构造实时数据流管道，消息队列
2. 构建实时流式应用程序，流处理（stream api）
  
## QA 

- 分布式有何优点、怎么实现？
    - 确保容错性
    1. 日志的分区分布在集群服务器上，每个服务器在处理数据和请求时，共享日志的分区
    2. 每个日志分区都会在配置服务器上进行备份
   （一个公共的地方存放日志信息，集群中服务器在操作时共享日志分区，同时日志分区进行备份。）
   
    - 实现负载均衡
    1. 每个分区都有一台server作为leader，零台或多台server作为follwers。
    2. leader处理一切对分区的读写操作，follwers只是被动同步。
    3. 当leader挂了时followers中一台自动成为新的leader。
    4. 集群中每台server都会成为某些分区的leader和某些分区的follwer。 （一组服务器组成集群，每台服务器既是一些分区的处理者，又是另一些分区的备份者。）
  
- 消息系统是什么、有什么问题？
   
传统消息系统有两个模块： 队列、发布-订阅
【队列】
消费者可多个实现并行处理，可扩展，但一旦数据某个进程读取后会被丢弃。
   
【发布-订阅】
消费者可多个实现并发处理，无法扩展，每条记录被广播给所有订阅者。
   
【传统消息队列问题】
记录并行消费 vs 记录重复消费 
   
【kafka如何解决同时实现并行消费 vs 重复消费的问题】
在分区上增加一层topic，一个topic对应一个或多个partion，一个topic可被一个或多个消费组订阅。
topic可以被不同消费组重复消费，topic中多个分区时可被消费组中不同进程并行消费。
一个分区只能被一个进程处理。
一个消费组中的一个进程可以处理一个或多个分区。
  
## 安装

- linux

  ```bash
  ## jdk
  # 下载
  wget https://repo.huaweicloud.com/java/jdk/8u201-b09/jdk-8u201-linux-x64.tar.gz
  tar xvf jdk-8u201-linux-x64.tar.gz -C /usr/local
  echo 'export JAVA_HOME=/usr/local/jdk1.8.0_201' >> /etc/profile
  echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
  source /etc/profile
  # 验证
  java -version
  
  
  ## zookeeper
  # 下载
  wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.6.1/apache-zookeeper-3.6.1-bin.tar.gz
  tar xvf apache-zookeeper-3.6.1-bin.tar.gz -C /usr/local/
  cd /usr/local/apache-zookeeper-3.6.1-bin/conf
  cp zoo_sample.cfg zoo.cfg
  mkdir /data/zk
  sed -i '/^dataDir/c dataDir=\/data\/zk' zoo.cfg
  # 启动
  cd /usr/local/apache-zookeeper-3.6.1-bin/bin
  ./zkServer.sh start
  ./zkCli.sh 
  # 停止
  ./zkServer.sh stop


  ## kafka
  # 下载
  wget https://mirrors.bfsu.edu.cn/apache/kafka/2.5.0/kafka_2.12-2.5.0.tgz
  tar xvf kafka_2.12-2.5.0.tgz -C /usr/local/
  
  # 单实例
  # 启动
  cd /usr/local/kafka_2.12-2.5.0/
  ./bin/kafka-server-start.sh config/server.properties &
  # 停止
  ./bin/kafka-server-stop.sh config/server.properties  
  
  # 集群
  cd /usr/local/kafka_2.12-2.5.0/
  cp config/server.properties config/server-one.properties
  cp config/server.properties config/server-two.properties 
  # 修改关键配置 
  # vim config/server-one.properties 
  broker.id=1 
  listeners=PLAINTEXT://:9093   # 因同一台机器则改端口
  log.dirs=/tmp/kafka-logs-one  
  # config/server-two.properties 
  broker.id=2
  listeners=PLAINTEXT://:9094   # 因同一台机器则改端口
  log.dirs=/tmp/kafka-logs-two  
  # 启动
  cd /usr/local/kafka_2.12-2.5.0/
  ./bin/kafka-server-start.sh config/server-one.properties
  ./bin/kafka-server-start.sh config/server-two.properties 
  ```

## 命令

- 分区

  ```bash
  # 列出
  kafka-topics.sh --bootstrap-server localhost:9092 --list
  
  # 创建
  kafka-topics.sh --bootstrap-server localhost:9092 --create --replication-factor 3 -partitions 1 -topic alarm_center_test

  # 查看
  kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic alarm_center_test
  
  # 修改
  kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic alarm_center_test --partitions 16
  
  # 删除
  kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic alarm_center_test
  ```
  
- 分组

  ```bash
  # 列出
  kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list --all-groups 
  
  # 查看
  kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group console-consumer-38941
  ```

- 生产-消费

  ```bash
  # 生产
  kafka-console-producer.sh --broker-list localhost:9092 --topic alarm_center_test
  
  # 消费
  kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic alarm_center_test --from-beginning
  ```

- 错误处理
   - [java.net.BindException: Address already in use -- JMX_PORT](https://github.com/wurstmeister/kafka-docker/issues/171)

  ```bash
  ## When JMX_PORT specified, cannot use kafka-console-producer/consumer
  unset JMX_PORT
  ```

## 资料

- [doc-kafka.apachecn.org](https://kafka.apachecn.org/intro.html)
- [sdk-cwiki.apache.org](https://cwiki.apache.org/confluence/display/KAFKA/Clients)
- [go-cnosumergroup](https://github.com/Shopify/sarama/blob/master/examples/consumergroup/main.go)
