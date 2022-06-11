
## 简介

Prometheus 是的一套开源监控告警方案，最初2012年由SoundCloud公司构建，在2016年加入CNCF（云原生计算基金会）成为继Kubernetes后的第二个托管项目。

## 特点

- 由指标名和KV组成时间序列的多维度数据模型，如：WEB服务器的各种类型、路径的请求量
- 提供能利用多维度数据灵活查询语言PromQL，如：查询WEB服务器的总请求
- 不依赖分布式存储，单个服务器节点本地存储 -- 速度快，单点风险
- 通过HTTP方式pull拉取采集的时间序列数据 -- 管理集中
- 支持通过向中间网关push推送采集数据，由服务器pull拉取网关
- 通过服务发现或者静态配置发现监控对象
- 支持多种仪表盘可视化展示

## 生态

- Prometheus server: 抓取和存储时间序列数据
- client SDK: 应用程序代码的客户端库
- push gateway: 支持短期内push的采集数据，长期建议用pull方式
- exporters: 支持特定服务如MySQl、HAProxy等的采集组件
- alertmanager: 处理告警的组件
- grafana: 数据可视化组件

## 功能
`数据采集 -- 数据存储 -- 告警与可视化`
- 数据采集：exporter/pushgateway提供HTTP接口让Prometheus采集监控数据
- 数据存储：默认是本地存储，可支持远程写
- 数据告警：支持按维度、时间收敛，支持临时屏蔽，支持写PromeQL实现环比/同比
- 数据可视化：grafana支持Promtheus数据源，支持用PromeQL写复杂的查询语句

## 概念
- DATA MODEL：数据模型，由metric指标和labels标签KV组成，命名规则`[a-zA-Z_:][a-zA-Z0-9_:]*`，如 `http_requests_total{ method = "post"} 500`
- Metric types：指标类型即数据的类型，四种：counter只增不减（如访问量）、gauge可增可减（如温度）、histograme计算一段内时间数据所在范围的量（如95%、99%的响应耗时）、summary计算一段内时间数据所在范围的百分比（如95%、99%的响应耗时百分比）
- instances：一个采集实例
- jobs：一组采集实例

## 场景应用

- 适用：记录基于时间序列的数据，架构可靠，方便部署。比如：服务器监控、微服务监控。
- 不适应：数据要求100%准确的数据，比如：金融相关的请求量计费。

## 选型考虑 

`功能是否满足、生态是否完善、社区是否活跃、是否灵活、维护是否方便、性能是否强大`

- 成熟的社区支持。Prometheus是开源监控软件且社区活跃，很好的与云原生环境搭配。
- 完善的生态。开箱即用的组件，提供了多种语言的客户端SDK。
- 易于部署和运维。Promehteus组件是二进制文件无其他依赖，部署方便。
- Pull拉取监控数据。方便集中管理，同时利于控制中心压力。
- 强大的数据模型。支持数据多维度制定，方便数据聚合与计算。
- 强大的查询语言PromQL。支持对数据查询、计算、聚合、告警。
- 高性能。Prometheus单一实例即可处理数以百计的监控指标，每秒处理数十万的数据。

## 实践落地

### 数据流

- mysql/redis/kafka/mongodb -- exporter -- kong -- consul -- prometheus （组件）
- docker -- prometheus -- consul -- prometheus（联邦）
- job -- pushgateway -- consul -- prometheus（业务）
- prometheus -- thanos -- grafana （视图）
- prometheus -- alertmanger（告警）

### 高可用

- Thanos Query: 实现了 Prometheus API，将来自下游组件提供的数据进行聚合最终返回给查询数据的 client
- Thanos Sidecar: 连接 Prometheus，将其数据提供给 Thanos Query 查询，并且/或者将其上传到对象存储，以供长期存储
- Thanos Store Gateway: 将对象存储的数据暴露给 Thanos Query 去查询
- Thanos Ruler: 对监控数据进行评估和告警，还可以计算出新的监控数据，将这些新数据提供给 Thanos Query 查询并且/或者上传到对象存储，以供长期存储
- Thanos Compact: 将对象存储中的数据进行压缩和降低采样率，加速大时间区间监控数据查询的速度
- Thanos Receiver：消除Sidecar，直接Prometheus通过remote write到Receiver。 Reveiver实现一致性哈希，支持集群部署

### QA

- Prometheus消耗内存的原因？  采集量越大内存的数据越多，每隔2小时将内存的数据通过Block数据落盘；查询不合理，从磁盘加载到内存的数据越多，如Group或大范围的rate
- Promtheus的痛点？  节点带宽、CPU、内存、磁盘IO
- 优化方向？  丢弃不重要指标；降低采集频率；设置较短过期时间
- 如何节点分担压力？  部署多套Prometheus，按业务写入
- 如何确保高可用？  每个Promtheus一个冗余副本
- 如何查询所有数据？  采用中间件如thanos查询多套汇总数据后去重
- 如何部署中间件？  Promtheus部署带中间件sidecar和query
- 如何确保实时性？  sidecar换成Prometheus写receiver，query查询receiver
- 如何存储冷数据？  中间件将数据远程写到COS
- 如何查询冷数据？  实现query的API查询，可优化缓存TSDB增加索引，可优化对象存储请求
- 如何提高查询大时区数据速度？  压缩和降低采样频率

### 配置使用

- check rules
```sh
go get github.com/prometheus/prometheus/cmd/promtool
promtool check rules /path/to/example.rules.yml
```
- recording rules
```yaml
# 提前计算保存最新结果，用于查询，适用于大屏，注意时间间隔
groups:
  - name: example-recording-rules
    rules:
    - record: job:http_inprogress_requests:sum  # recording 冒号
      expr: sum(http_inprogress_requests) by (job)
```

- alerting rules
```yaml
# 告警策略触发后发送给alertmanager
groups:
- name: example-alerting-rules
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 5m  # alert的expr触发后，firing前的等待时间
    labels:  # 添加label,存在的key将会被覆盖
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."
```

- PromeQL
```sh
# 非生产环境的GET请求量
http_requests_total{environment=~"testing|development",method!="GET"}

# 两分钟内cpu的增长率
increase(node_cpu[2m]) / 120   

# 两分钟内平均增长率，出现"长尾问题"：某个瞬时cpu100%时无法体现
rate(node_cpu[2m])

# 两分钟内瞬时增长率
irate(node_cpu[2m])

# 一周前每5分钟的平均请求速率
rate(http_requests_total[5m] offset 1w)

# 不同pod的http的总请求
sum(http_requests_total) by (pod)

# 获取前5的请求量
topk(5,http_request_total)
```

- Prometheus API
```sh
# 重载
curl -XPOST  http://localhost:9090/-/reload

# 查询POST方法的请求情况
curl -XGET http://prometheus.oa.com/api/v1/query?query=http_requests_total{method="post"} | jq | more
```

- push gateway
```sh
cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/some_job/instance/some_instance
# TYPE some_metric counter
some_metric{label="val1"} 42
# TYPE another_metric gauge
# HELP another_metric Just an example.
another_metric 2398.283
EOF
```

- relabel_config解释
```yaml
# source_labels: [labelName1,labelName2]  原始label的值
# separator: ;  用于连接上面多个label的值分割符
# target_label: newLabelName  新的label的名字
# regex: (.*)  正则匹配label的值
# replacement:  $1   # 正则分组后的值写入targe_label
# action: replace｜keep｜drop｜labelmap｜labeldrop｜labelkeep  # 正则匹配后的操作
# modulus: 4  # 经过hash计算label的值后保留几位

# 连接两个label的值作为新的label 用逗号隔开
relabel_configs:
   - source_labels:  ["__meta_consul_dc","__meta_consul_service"]
     separator: ,
     target_label: "dc_service"

# 白名单： 只保留包含匹配label的数据，其余的丢弃
relabel_configs:
- source_labels:  ["__meta_consul_dc"]
  regex: "dc1"
  action: keep

# 黑名单： 只丢弃包含匹配label的数据，其余的保留
relabel_configs:
- source_labels:  ["__meta_consul_dc"]
  regex: "dc1"
  action: drop

# label名匹配生成： 增则匹配的内容作为新的label，值为新标签的值
# 如 __meta_kubernetes_node_label_aaa  prometheus 则新label标签为 aaa prometheus
relabel_configs:
- action: labelmap
  regex: __meta_kubernetes_node_label_(.+)

# 黑名单： 包含正则内容为label的标签丢弃，其余保留
relabel_configs:
  - regex: label_should_drop_(.+)
    action: labeldrop

# 白名单： 包含正则内容为label的标签保留，其余丢弃
relabel_configs:
  - regex: label_should_drop_(.+)
    action: labeldrop
```

- metric_relabel_configs
```yaml
# Drop unnecessary metrics
- job_name: cadvisor
  ...
  metric_relabel_configs:
  - source_labels: [__name__]
  regex: '(container_tasks_state|container_memory_failures_total)'
  action: drop

# Drop unnecessary time-series
- job_name: cadvisor
  ...
  metric_relabel_configs:
  - source_labels: [id]
    regex: '/system.slice/var-lib-docker-containers.*-shm.mount'
    action: drop
  - source_labels: [container_label_JenkinsId]
    regex: '.+'
    action: drop  

# Drop sensitive or unwanted labels from the metrics
- job_name: cadvisor
  ...
  metric_relabel_configs:
  - regex: 'container_label_com_amazonaws_ecs_task_arn'
    action: labeldrop

# Amend修改 label format of the final metrics
- job_name: cadvisor
  ...
  metric_relabel_configs:
  - source_labels: [image]
    regex: '.*/(.*)'
    replacement: '$1'
    target_label: id
  - source_labels: [service]
    regex: 'ecs-.*:ecs-([a-z]+-*[a-z]*).*:[0-9]+'
    replacement: '$1'
    target_label: service
```

## 资料

- [promtheus.io](https://prometheus.io/)
- [Prometheus-configure](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [prometheus-configure-example](https://github.com/prometheus/prometheus/blob/release-2.15/config/testdata/conf.good.yml)
- [PromeQL-query](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [google-正则语法](https://github.com/google/re2/wiki/Syntax)
- [Prometheus实战](https://www.bookstack.cn/read/prometheus_practice/ha-prometheus.md)
- [Prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/quickstart)
- [alertmanager-configure-example](https://github.com/prometheus/alertmanager/blob/main/doc/examples/simple.yml)
- [alertmanger-configure-routing-tree-format](https://prometheus.io/webtools/alerting/routing-tree-editor/)
- [grafana-plugins](https://grafana.com/grafana/plugins/?orderBy=weight&direction=asc)
- [grafana-online-demo](https://play.grafana.org/d/000000012/grafana-play-home?orgId=1)
- [thanos.io](https://thanos.io/tip/thanos/getting-started.md)
- [爱奇艺号基于Prometheus的微服务应用监控实践](https://www.toutiao.com/article/6853605670407799303/?tt_from=copy_link&utm_campaign=client_share&timestamp=1595985449&app=news_article&utm_source=copy_link&utm_medium=toutiao_ios&use_new_style=1&req_id=202007290917290100140400933D79F5B4&group_id=6853605670407799303&wid=1654669650849)
- [Prometheus活学活用避坑指南](https://cloud.tencent.com/developer/news/629972)
- [规划Prometheus存储用量](https://www.jianshu.com/p/93412a925da2)
- [打造云原生大型分布式监控系统(一) 大规模场景下 Prometheus 的优化手段](https://www.bilibili.com/video/BV17C4y1x7HE)
- [打造云原生大型分布式监控系统(二): Thanos 架构详解](https://www.bilibili.com/video/BV1Vk4y1R7S9)
- [打造云原生大型分布式监控系统(三): Thanos 部署与实践](https://www.bilibili.com/video/BV16g4y187HD)

