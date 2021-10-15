### elastic管理相关脚本

#### 清理索引

```bash
#!/bin/bash
# date: 2019/05/29
# desc: clean elastic index

es_server="127.0.0.1:9200"
userpass="elastic:abc"
all_index=`curl -s -u $userpass http://${es_server}/_cat/indices?h=index | sort |sed 's/[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}//g'| uniq`

# 清理索引 每次清理执行时间前三天，防止某天执行失败
function clean_indices() {
    for i in `echo "0 1 2 3"`;
	do
	   day=`echo $1+$i | bc`
	   time=$(date -d "$day days ago" '+%Y.%m.%d')
	   echo "index $2$time will delete!"
       curl -u $userpass -XDELETE http://${es_server}/$2$time
	done
}

function clean_strategy(){
	index=`echo $all_index | tr ' ' '\n'  | grep $2`	
    if [[ x$index  != x ]];then
		for i in `echo ${index}`;
		do
			clean_indices $1 $i
		done
    fi
}

function default_strategy(){
	index=`echo $all_index | tr ' ' '\n'  | egrep -v $2`	
    if [[ x$index  != x ]];then
		for i in `echo ${index}`;
		do
			clean_indices $1 $i
		done
    fi
}

# 一般索引保留策略 默认2天
default_strategy 2 ${special_index}

# 特殊索引保留策略 
clean_strategy 30 "^k8s"
clean_strategy 5 "^crm"
clean_strategy 2 "^nginx"
```

#### 迁移索引分片

```bash
#!/bin/bash
# date: 2018/11/29
# desc: setting elastic 5.6.0 cluster reroute

es="127.0.0.1:9200"
from_node="node-1"
to_node="node-2"

function close_reroute(){
	curl  -X PUT "${es}/_cluster/settings?flat_settings=true" -H 'Content-Type: application/json' -d'
	{
		"transient" : {
			"cluster.routing.allocation.enable" : '\"$1\"'
		}
	}'
}

function get_reroute_shard(){
	info=($(curl -s  http://${es}/_cat/shards |grep "${from_node}" |grep "STARTED" | awk '{print $1"@"$2}' | tr '\n' ' '))
	for var in ${info[*]}; 
	do 
		index=$(echo $var | awk -F@ '{print $1}');
		shard=$(echo $var | awk -F@ '{print $2}');
		echo $index;echo $shard; 
		if [[ -n $index ]] ; then 
			reroute_es_shard $index $shard
		fi
	done
}

function reroute_es_shard(){
	curl -X POST "${es}/_cluster/reroute" -H 'Content-Type: application/json' -d'
	{
		"commands" : [
			{
				"move" : {
					"index" : '\"$1\"', 
					"shard" : '$2',
					"from_node" : '\"${from_node}\"', 
					"to_node" : '\"${to_node}\"'
				}
			}
		]
	}'	
}


# 关闭重新路由
close_reroute none
# 开启重新路由
close_reroute all
# 迁移索引分片
get_reroute_shard
```

#### 优化集群分片速度

[elastic6.5-recovery](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/recovery.html) 
 & [elastic6.5-cluster-settings](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/cluster-update-settings.html)

```bash
#!/bin/bash
# date: 2018/11/29
# desc: optimize shard recovery

# 默认40mb，设置为null时恢复默认值
indices.recovery.max_bytes_per_sec: 100mb
# 默认并发数2个
cluster.routing.allocation.node_concurrent_recoveries: 5

# 临时设置
# 注意: 即使把传输速度调高，也与磁盘性能IO有关。并发设置了，如果cpu是2核，只能造成cpu排队（用vmstat查）
curl -X PUT "127.0.0.1:9201/_cluster/settings?flat_settings=true&pretty" -H 'Content-Type: application/json' -d'
{
    "transient" : {
        "indices.recovery.max_bytes_per_sec" : "100mb"
        "cluster.routing.allocation.node_concurrent_recoveries":5
    }
}'
```

#### 修复索引未分片

[elastic6.5-cluster-reroute](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/cluster-reroute.html)  & [stackoverflow-fix-es](https://stackoverflow.com/questions/19967472/elasticsearch-unassigned-shards-how-to-fix?r=SearchResults)

```bash
#!/bin/bash
# date: 2018/11/29
# desc: fix up elastic 5.3.0 unassign shard

es_server="127.0.0.1:9200"
node="node-2"
tmpFile=/tmp/unassignShards

function fix_unassign_shard(){
	curl -H "Content-Type:application/json"  -X POST "${es_server}/_cluster/reroute" -d'{
	  "commands": [
		{
		  "allocate_stale_primary": {
			"index": "'$1'",
			"shard": '$2',
			"node": "'$node'",
			"accept_data_loss": true
		  }
		}
	  ]
	}'
}

function check_es_status(){
	status=$(curl -s http://${es_server}/_cluster/health?pretty|awk '{if($0~/status/) print $0}' | sed 's/"status"\s:\s"\(.*\)",/\1 /' |tr -s ' ' | tr -d ' ')
	if [[ $status != "green" ]];then
		curl -s http://${es_server}/_cat/shards | grep -i unassign > ${tmpFile}
		while read line
		do
			index=$(echo "$line"|awk '{print $1}')
			shard=$(echo "$line"|awk '{print $2}')
			fix_unassign_shard $index $shard
		done < ${tmpFile} 
	fi
}

# 检查es状态修复未分片
check_es_status
```

#### 启动分片重新分配

[elastic5.6-shard-allocation](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/shards-allocation.html#_shard_allocation_settings) &  [elastic5.6-cluster-setting](https://www.elastic.co/guide/n/elasticsearch/reference/5.6/cluster-update-settings.html)

   ```bash
   #!/bin/bash
   # date: 2019/11/29
   # desc: optimize shard recovery
   
   # 官网关键字搜索： cluster route allocation
   # cluster.routing.allocation.enable     //字段
   # Enable or disable allocation for specific kinds of shards:
   # 1. all - (default) Allows shard allocation for all kinds of shards.
   # 2. primaries - Allows shard allocation only for primary shards.
   # 3. new_primaries - Allows shard allocation only for primary shards for new indices.
   # 4. none - No shard allocations of any kind are allowed for any indices
   
 
   # Settings updated can either be persistent (applied across restarts) or transient (will not survive a full cluster restart)
   curl -X PUT "127.0.0.1:9200/_cluster/settings?flat_settings=true" -H 'Content-Type: application/json' -d'{
   		"transient" : {
   			"cluster.routing.allocation.enable" : "none"
   		}
   }'
   
   # 设置磁盘水位
   curl -X PUT "localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
   {
       "persistent" : {
          "cluster.routing.allocation.disk.threshold_enabled": true,
          "cluster.routing.allocation.disk.watermark.low":"75%",
          "cluster.routing.allocation.disk.watermark.high":"78%"
       }
   }'
   ```

#### 监控es集群状态

```
#!/bin/sh
# date：2019/05/27
# desc: monitor elastic status

es_server="127.0.0.1:9201"
es_status="green"
es_node_num="11"
now=`date +"[%F %T]"`
mkdir /data/logs &> /dev/null

function alert(){
       alerts1='{
   	   "alertname": "ElasticProblem",    
	   "from": "prod",
	   "level" : "C",                        
	   "txt": "'$1'"
       }'
     curl -XPOST -d "$alerts1" http://alert.abc.com/api/v1/alert
}

status=`curl -s http://${es_server}/_cluster/health?pretty | grep status | tr '"' ',' | awk -F',' '{print $4}'`
if [[ $status != $es_status ]];then
    txt="集群状态是$status"
    echo "$now $txt" > /data/logs/es-alert.log
    alert $txt
fi

node_num=`curl -s  http://${es_server}/_cat/nodes | wc -l`
content=` curl -s  http://${es_server}/_cat/nodes | awk '{print $NF}' | sort -r | tr '\n' ';'`
if [[ $node_num != $es_node_num ]];then
    txt="集群节点个数少于11,$content"
    echo "$now $txt" > /data/logs/es-alert.log
    alert $txt
fi
```

#### 监控es的索引大小
```
#!/bin/bash
# date: 2019/06/05
# desc: monitoring elastic index size

source ./alert.sh

yesterday=`date -d '-1days' +%Y.%m.%d`
content=`curl -s http://localhost:9201/_cat/indices | grep ${yesterday} | awk '{if($NF ~ "gb") print $NF,$3}'| awk -F'gb' '{if($1 > 300.0) print $1$2";"}' | tr ' ' '@' `

alert $content &> /data/logs/es-alert.log
```

#### 监控服务进程

```bash
#!/bin/bash
# date: 2019/05/29
# desc: process monitoring

source /etc/profile &> /dev/null

# 必须的log日志清理
 function clean_log(){
      find $1/logs/*.log -type f -mtime +3 -exec rm {} \;
 }

function check_process(){
    if ! `ps aux | grep -v grep |grep $1  |grep $2 &>/dev/null` ;then 
       $3 &>/tmp/restart_process.log &
    fi
}

check_process kibana    kibana-rpc  "/usr/local/kibana/bin/kibana -c /usr/local/kibana/config/kibana-rpc.yml"
check_process kibana    kibana-uat  "/usr/local/kibana/bin/kibana -c /usr/local/kibana/config/kibana-uat.yml"
```