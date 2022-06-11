---
title: MongoDB
date: 2022-06-10 8:00
tags: 中间件
description: MongoDB是一个文档数据库，一条记录类似一个json数据
toc: true
---

[TOC]

# MongoDB

## 安装

```bash
docker pull mongo       
docker image ls 
docker run -p 27017:27017 -v /data/mongo:/db/mongo --name mongodb -d mongo
docker inspect mongodb
docker stop mongodb
docker start mongodb
docker exec -it mongodb mongo admin
```

## 命令

- 基本

```bash
# 查看
show dbs
show collections
show users
use db
db.help()
db.foo.help()

# 备份
docker exec mongodb mongodump -o  /backup/mongodb
# 恢复
docker exec alert-mongo mongorestore /backup/mongodb


# 新增
db.fruit.insert({"name":"banana"})
db.fruit.insert({"name":"banana","city":"xian","num":6,"ts":new Date()})

# 更新
db.receiver.update(
	{ usergroup:"canal-group" },
	{
	  $set: {
		"useremails" : [
			"abc@oa.com",
			"edf@oa.com"
		]
	   },
	}
)
```

- 查询

```bash
# SELECT * FROM inventory
db.inventory.find({}).pretty()  

# SELECT * FROM inventory WHERE status = "D"
db.inventory.find( { status: "D" } )

# SELECT * FROM inventory WHERE status in ("A", "D")
db.inventory.find( { status: { $in: [ "A", "D" ] } } ) 

# SELECT * FROM inventory WHERE status = "A" AND qty < 30
db.inventory.find( { status: "A", qty: { $lt: 30 } } )

# SELECT * FROM inventory WHERE status = "A" OR qty < 30
db.inventory.find( { $or: [ { status: "A" }, { qty: { $lt: 30 } } ] } )

# SELECT * FROM inventory WHERE status = "A" AND ( qty < 30 OR item LIKE "p%")
db.inventory.find( {  status: "A", $or: [ { qty: { $lt: 30 } }, { item: /^p/ } ]} )

# SELECT count(*) FROM inventory WHERE status = "A"
db.inventory.find( { status:"A"}).count()

# SELECT item FROM sales GROUP BY item
db.sales.aggregate( [ { $group : { _id : "$item" } } ] )

# SELECT tid,COUNT(*) FROM note_record Where status = 2 AND send_time > 1531298435 GROUP BY tid
db.note_record.aggregate([
    { $match:{ status:2, send_time: { $gt:1531298435 }  }  },
    {  $group: { 
            _id : "$tid" ,
            count:{$sum:1}
        }
    }
])

# 以json格式打印返回结果
db.inventory.find( { status:"A"} ).count().forEach(printjson)

# 以函数定义格式打印返回结果
db.note_record.aggregate([
    { $match:{ status:2, send_time: { $gt:1531298435 }  }  },
    {  $group: { 
            _id : "$tid" ,
            count:{$sum:1}
        }
    }
]).forEach( function(msg) { print(msg._id,msg.count) })

# 根据name为维度分组，查询每组出现的次数
db.fruit.aggregate([{ "$group": { _id: "$name", num:{ "$sum": 1}  }  }])

# 匹配查询
db.fruit.aggregate([  {  "$match":{"name":"banana"}  } ,{ "$group": { _id: "$name", num:{ "$sum": 1}  } } ] )

# 非交互式，脚本查询
cat <<EOF > /tmp/mongo.js
cursor = db.collection.find();
while ( cursor.hasNext() ) {
    printjson( cursor.next() );
}
EOF
mongo localhost:27017/test --shell /tmp/mongo.js

# 非交互式，命令查询
mongo localhost:27017/test --eval "db.collection.find().forEach(printjson)"
```

## 资料
- [www.mongodb.com](https://www.mongodb.com/what-is-mongodb)
- [MongoDB-SDK-go](https://docs.mongodb.com/ecosystem/drivers/go/)
- [find](https://docs.mongodb.com/v3.0/reference/method/db.collection.find/index.html)