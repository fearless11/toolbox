#!/bin/bash
# date: 2022/05/24
# auth: fearless11
# desc: sed


# sed是一个非交互的流式面向行的文本处理程序
# 原理：
# 先读入一行，去掉尾部换行符，存入pattern space，执行编辑命令。
# 处理完毕，把现在的pattern space打印出来，在后边打印曾去掉的换行符。
# 把pattern space置空。接着读下一行处理。

# 模式空间
# pattern space: 流内容的处理空间
# hold space: 可临时存储处理数据的空间

###### 命令
# -n  # 只输出处理后的数据，不把pattern space输出
# -e script  # 允许执行多个操作
# -i [SUFFIX]  # 修改写入源文件，设置后缀可备份源文件
# -f  #将sed的操作写入文件，-f 文件的形式执行
# a  后面新增行 
# i  前面插入行
# c  取代行
# d  删除行
# p  打印
# s  替换
sed_pattern(){
    # 两行并做一行，N提前读下一行到模式空间，替换\n为空格
    sed 'N; s/\n/ /' 1.txt

    # 打印第2行
    sed -n '2p' /tmp/password
    # 打印匹配root行
    sed -n '/root/p' /tmp/password
    # 打印第33到最后一行
    sed -n '33,$p' /tmp/password
    # 打印2022-05-24中9点到10点的日志
    sed -n '/2022-05-24 09:[0-9][0-9]:[0-9][0-9]/,/2022-05-24 10:[0-9][0-9]:[0-9][0-9]/ p' /var/log
    # 打印匹配到最后一行
    sed -n '/root/,$p' /tmp/password 
    # 打印行号
    sed -n '/root/=' /tmp/password 
    # 打印行号及内容
    sed -n '/root/{=;p}' /tmp/password 

    # 删除第2到最后一行，打印第1行
    sed '2,$d' /tmp/password
    # 删除root开头的行
    sed '/^root/d' /tmp/password
    
    # 打印替换的行
    sed -n 's/root/abc/g p' /tmp/password
    # 替换nologin为login，false为true
    sed 's/nologin/login/g; s/false/true/g' /tmp/password
    sed -e 's/nologin/login/g' -e 's/false/true/g' /tmp/password
    # 替换第1到第5行中的/bin为/sbin，自定义分隔符?
    sed '1,5 s?/bin?/sbin?g' /tmp/password  | head
    # 替换后首字母大写Hello World
    echo 'hello world' | sed 's/\b[a-z]/\U&/g'
    # 替换每行内容为正则分组\1的内容 \1内容为(.?)，等价于 awk -F':' '{print $1}'
    sed -r 's/(.?):.*/\1/' /tmp/password 
    # 替换每行内容为正则分组\1的内容和 yes
    sed -r 's/(.?):.*/\1 yes/' /tmp/password 
    # 替换文本中换行符为空格，:a标记 N读取下一行 t跳转到标记处
    sed ':a;N; s/\n/ /; t a' /tmp/password
    # 匹配root的下一行，替换其中的bin为123
    sed '/root/{n;s/bin/123/g;}' /tmp/password
    # 替换中文为空
    sed -r 's/[\x81-\xFE][\x40-\xFE]+//g' /tmp/a

    # 追加2行，在第1行、第2行后面追加add newline
    sed '1,2 a \add newline' /tmp/password | head
    # 插入2行，在第1行、第2行后面前面插入insert newline
    sed '1,2 i \insert newline' /tmp/password | head

    # 取代第一行内容为hello
    sed '1 c hello' /tmp/password
    # 取代root开头的为 hello
    sed '/^root/c \ hello' /tmp/password

    # 写入文件，写入内容为第1～2行
    sed -n '1,2 w out.txt' /tmp/password
}


# d    Delete pattern space.  Start next cycle.
# h H  Copy/append pattern space to hold space.
# g G  Copy/append hold space to pattern space.
# x    Exchange the contents of the hold and pattern spaces.
sed_hold(){
    # hold sapace与pattern space交换后输出
    # hold space第一行为空，所以输出内容为文件第一行为空后面不变
    sed 'x' /tmp/a

    # 反序文件，从最后一行到第一行打印文件
    # 1!G —— 只有第一行不执行G命令，将hold space中的内容append回到pattern space
    # h —— 第一行都执行h命令，将pattern space中的内容拷贝到hold space中
    # $!d —— 除了最后一行不执行d命令，其它行都执行d命令，删除当前行
    sed '1!G;h;$!d' /tmp/password
}