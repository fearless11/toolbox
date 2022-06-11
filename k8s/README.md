[toc]

# K8s

## 云计算

### 经典架构

- IaaS （Infrastructure as a Service）基础设施即服务：网络、存储资源
- PaaS （Platform as a Service）平台即服务：数据库服务、监控服务
- SaaS （Software as a Service）软件即服务：软件系统，用户通过浏览器即可使用

### 容器Docker 

- 2013年Docker出现，Docker是一个轻量级虚拟化技术。覆盖解决IaaS和PaaS层的各类问题。
- 安装Docker要求
  - 只支持64位CPU架构计算机；
  - Linux内核3.10以上；
  - Linux开启cgroups和namespace；
  - Windows和OS X需要安装Boot2Docker工具。
- Docker优点：屏蔽底层差异在虚拟化一层实现跨平台支持、环境标准化、资源利用与隔离。
- Docker问题：如何编排、部署、调度。

### 容器云kubernetes

- 容器云以容器位资源分割和调度的基本单位。例如：Flynn、Deis、Mesos、kubernetes等
- 2015年出现，kubernetes是一个全新的基于容器技术的分布式架构领先方案。基于Google内部大规模集群管理工具Borg。

- kubernetes解决了什么问题？
  - 实现了应用部署、高可用管理和弹性伸缩等基本功能；
  - 成为一套完整、简单易用的RESTful API对外提供服务。

- kubernetes设计哲学： 维护应用容器集群一直处于用户所期望的状态。
- kubernetes恢复机制：容器自动重启、自动调度、自动备份等。

## kubernetes

### 简介

pod是基本单位。k8s集群分为两部分：Master & Node。

- Master上关键进程：
  1. Kubernetes API Server：提供HTTP Rest接口对所有资源CURD，控制集群入口。
  2. Kubernetes Controller Manager：对所有资源自动化控制。
  3. Kubernetes Scheduler：资源调度pod调度。
  4. etcd：保存所有资源对象。
- Node上关键进程：
  1. kubelet：负责pod对于容器的创建与起停，与master通信管理集群。
  2. kube-proxy：实现与k8s service通信是实现负载均衡机制。
  3. Docker Engine：Docker引擎，负责本机的容器创建与管理。

### 术语

- 资源对象：Node、Pod、Service等大部分概念都属于资源对象，可以通过API进行增删改查
- Master：负责整个集群的管理和控制，所有控制命令的管理。
- Node：可以是物理机或虚拟机，动态增加k8s中。
- Pod：  基本单位，管理一组工作负载(docker容器)，默认包含一个Pause容器。
- Service：服务的访问入口地址。Service与Pod间通过Label实现对接。
- Volume：与Pod的生命周期相同，容器的终止或重启volume数据不会丢失。
- Namespace：多租户资源隔离，范围Pod、RC、Service、Demployment。
- Label：KV 资源对象捆绑标签分组管理。比如：版本标签、环境标签、架构标签、分区标签。
- Annotation：KV 便于外部工具查找。

### pod如何管理？

同一个pod的多个容器：

- 每个pod都有一个pause容器，判断pod的存活。

- 存储管理：pod级别挂在后，同一pod的容器可以共享使用。
- 配置管理（configMap、sercet）：1、环境变量使用configMap； 2. 通过volumeMount使用configMap。

#### 静态pod

特点：由kubelet管理，存在特定Node上，不通过API Server管理，kubelet无法对它们进行健康检测。

创建：配置文件、HTTP方式也是通过下载配置文件实现。

删除：只能通过删除配置文件。

#### 管理

生命周期： pending、running、succeeded、failed、unknown

重启策略：always、onfailure、never

健康检测：livenessProbe（判断容器存活running）、ReadinessProbe（判断启动完成ready）

扩容缩容：手动（命令解决）、自动（HPA控制器实现，pod设置resources.requests.cpu让heapster知道cpu情况，提供HPA操作）

升级回滚：滚动升级（pod是一个一个替换为最新版）、回滚（查看历史后rollback）、暂停

初始化容器： init container 执行一次在其他pod里的容器之前执行，如等待关联组件启动、环境变量等

#### 调度

- Deployment/RC：全自动调度
- NodeSelector：定向调度（精准匹配，结合给node打标签实现）
- NodeAffinity ：Node亲和性调度（模糊匹配，又分为硬限制--不符合不调度、软限制--不符合调度到其他node）
- PodAffinity ：Pod亲和与互斥（模糊匹配，分为硬限制、软限制）
- Taints & Tolerations：污点和容忍  （给node标记为taints后拒绝pod在上运行，除非pod设置tolerations--实现pod的驱逐）
- Daemonset：每个Node上调度一个pod。 日志采集、性能监控
- Job：批处理调度  启动多个work pod处理任务
- Cronjob：定时任务。Minute Hours Day Month Week Year
- 自定义调度器：通过对接接口实现某个pod调度到某个node
- StatefulSet：有状态服务。每个pod由固定的标识和后端存储，这样pod重启后访问和存储都不变。（结合Headless service、共享存储与StorageClass对接实现动态存储供应模式）

### service如何访问？

#### 集群内部访问  

- podIP:port ：  pod的podIP是不可靠，当pod调度到不同node将变化。而且多个pod时还需要负载均衡
- clusterIP:port ：service的clusterIP负载均衡到后端多个pod。（负载均衡策略：RoundRobin轮询、SessionAffinity=ClientIP同以客户IP将绑定到固定后端pod上）
- 多端口： clusterIP:port1 、clusterIP:port2
- 外部服务service： 创建service时不选择Selector即无法选择后端pod，手动创建同名的Endpoint执向实际的后端访问。
- Headless service：自己控制负载均衡策略。创建service时不设置clusterIP（clusterIP:None），仅仅通过标签Selector选择后端的pod列表。 stateful通过headless service为客户端返回多个服务地址。

#### 集群外部访问

- hostPort：为pod的容器设置hostPort：  nodeIP:hostPort
- 设置pod网络为hostNetwork=true：nodeIP:port
- service端口映射到NodePort：nodeIP:nodePort

#### DNS

域名： service_name.namespace_name.domain、 service_name.namespace_name.svc.domain

- 实现逻辑
  1. 通过调用k8s master的API获取集群所有service信息，持续监控service
  2. kubelet通过--cluster_dns后解析域名的ip  
  3. 容器应用程序通过访问服务名字访问服务

- 自定义DNS

  pod的DNS策略： Default（继承pod所在node的/etc/resolv.conf）、 ClusterFirst（DNS查询发送到kube-dns服务进行解析）

#### Ingress 7层路由机制

- Ingress Controller： Daemonset的方式部署到每个node上，类似在node上部署了nginx
- Ingress：访问策略，即哪个域名访问到哪个service:port。类似nginx的server_name及location （可设置TLS）

（自己电脑访问配置/etc/host哈）

### volume如何管理？

用途：作为一种资源被pod使用

#### 类型

- emptyDir： 临时空间 ，无保存（多容器共享目录）
- hostPath：用于日志文件（单机测试）
- gcePersistentDisk：谷歌云提供的永久磁盘
- awsElasticBlockStore：亚马孙公有云
- NFS
- ...

#### PV —> PVC

- pv只是网络存储，不属于任何Node； 不定义在pod上，独立与pod之外
- pod使用某中类型的pv，需要先定义一个PVC PersistentVolumeClaim，PVC会消费PV

#### StorageClass

- 优点
  - 减轻用户对于存储资源细节关注。对用户设置的PVC申请屏蔽后端存储细节。
  - 减轻手工管理PV的工作。系统自动完成PV的创建与绑定，实现动态的资源供应。

## 资料

[k8s-github](https://github.com/kubernetes/kubernetes)

[k8s-zh-community](https://www.kubernetes.org.cn/)

[https://kubernetes.io/zh/docs/concepts/overview/components/](https://kubernetes.io/zh/docs/concepts/overview/components/)


[https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)

