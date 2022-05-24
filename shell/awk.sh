#!/bin/bash
# date: 2022/05/24
# auth: fearless11
# desc: awk

# awk是一个面向行的文本处理工具
# awk 模式 动作

###### 变量
# $0       # 所有Fields
# $1,$n    # 分割Fields后的第1~n字段
# NR       # 第几个records
# NF       # 每个record有多少个Field字段
# RS       # 默认输入记录分割符为换行
# ORS      # 默认输出记录分隔符为换行
# OFS      # 输出连接符，默认空格
awk_var(){
    # 以:为分隔符，打印原始行内容
    awk -F':' '{print $0}' /tmp/password
    # 设置第1个字段为空，输出其他字段
    awk -F':' '{$1="";print $0}' /tmp/password

    # 打印每行第1个、第2个字段
    awk -F':' '{print $1,$2}' /tmp/password
    # 打印每行第最后一个、倒数第2个字段
    awk -F':' '{print $NF,$(NF-1)}' /tmp/password
    # 打印每行行号、按分割符分割后有多少个字段
    awk -F':' '{print NR,NF}' /tmp/password

    # 打印第1个字段、文件名
    awk -F':' '{$1,print FILENAME}' /tmp/password
    # 打印每行第1个、第2个字段，输出字段以@连接，OFS设置字段输出连接符
    awk -F':' -v OFS='@' '{print $1,$2}' /tmp/password
    # 打印每行第1个、第2个字段，输出每行以@连接，ORS设置输出行记录符
    awk -F':' -v ORS='@' '{print $1,$2}' /tmp/password
    # 多行替换为一行，RS设置行记录结束符，多行为一个record，替换record的换行为==
    awk -v RS=EOF '{gsub(/\n/,"=="); print $0}' /tmp/password
    # 输入自定义变量
    awk -v today=`date +%F` '{print today,$1}' /tmp/password
}

###### 模式
# BEGIN  # 在任何input之前执行
# END  # 在所有input之后执行
# BEGINFILE
# ENDFILE                
# /regular expression/  # 处理each input record
# relational expression  
# pattern && pattern
# pattern || pattern
# pattern ? pattern : pattern
# (pattern)
# ! pattern
# pattern1, pattern2
awk_patterns(){
    # BEGIN在执行前操作一次，设置分隔符及打印开始
    awk 'BEGIN{ FS=":" ; OFS="@"; print "====begin==="} {print $1,$2}' /tmp/password 
    # END在执行后操作一次，打印结束
    awk '{print $1,$2} END{ print "===end=="}' /tmp/password 
    # 求和
    awk 'BEGIN{ sum=0 } { sum=sum+NR } END{print "sum:",sum}' /tmp/password 

    # 求空行数
    awk '/^$/{++x} END{ print x}' /tmp/password

    # 统计单词出现次数，原文件每行一个单词
    cat /tmp/a | awk '{count[$1]++} END{ for(i in count) print i,count[i] }'

}

###### 条件声明
# if (condition) statement [ else statement ]
# while (condition) statement
# do statement while (condition)
# for (var in array) statement
# for (expr1; expr2; expr3) statement
# break
# continue
awk_condition(){
    # 统计TCP各状态个数
    netstat -nt | awk '{ stat[$NF]++} END{ for(i in stat) print i,stat[i]}'

    # 统计es中某类索引的每天日志量大小
    curl -s http://127.0.0.1:9200/_cat/indices | 
    awk '{print $3,$(NF-1)}' | grep ^tel | grep `date +%Y.%m.%d` | 
    awk '{ 
        if($NF~/kb/) { gsub(/kb/,//,$NF);kb += $NF } 
        else if($NF~/mb/)  { gsub(/mb/,//,$NF); mb += $NF } 
        else if($NF~/gb/) { gsub(/gb/,//,$NF) ; gb += $NF } 
    }
    END { 
        sum=(kb/1024/1024+mb/1024+gb); printf ("%.2fG\n",sum)
    }'
}

###### 函数
# substr(s, i [, n])  # 源s，i起始位置 ； 从第i位截取s
# match(s, r [, a])   # 源字段s， 正则r， 匹配后存入数组a
awk_function(){
    # 匹配第1个字段为root，替换为abc后输出，输出连接符为@
    awk 'BEGIN{ FS=":"; OFS="@"} gsub(/root/,"abc",$1) {print $0}' /tmp/password 
    # 计算1分钟内网卡速率
    a=`ifconfig eth1 | awk '/RX bytes/ {print substr($2,7)}'` && 
    sleep 60 && 
    a1=`ifconfig eth1 | awk '/RX bytes/ {print substr($2,7)}'` && 
    echo "($a1-$a)/60" | bc 
}
