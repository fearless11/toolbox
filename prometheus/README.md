## 简介

prometheus 监控相关工具

## 数据流

- mysql/redis/kafka/mongodb -- exporter -- kong -- consul -- prometheus （组件）
- docker -- prometheus -- consul -- prometheus（联邦）
- job -- pushgateway -- consul -- prometheus（业务）
- prometheus -- thanos -- grafana （视图）
- prometheus -- alertmanger（告警）
