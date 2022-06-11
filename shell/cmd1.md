[toc]

## 基础命令

### 日常

#### help
```sh
# 获得命令帮助
cmd --help
man cmd
info cmd
```

#### alias & unalias
```sh
# 临时生效
alias gitee='cd /data/gitee.com'
unalias gitee

# 永久生效
echo "alias gitee='cd /data/gitee.com'" >> ~/.bashrc
```

#### export
```sh
export PS1='\[\e[32m\][\u@\H:\[\e[m\]\[\e[33m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\$ '
```

#### jq
```sh
# json校验
sh test.sh | jq
sh test.sh | python -m json.tool
```

#### systemctl
```sh
# 临时关闭
systemctl stop firewalld  

# 禁止启动   
systemctl disable firewalld   
```

#### seq
```sh
# 遍历数字
seq 1 10  
# 1 2 3 4 5 6 7 8 9 10

# 等长数字
seq -w 1 10  
# 01 02 03 04 05 06 07 08 09 10
```

#### bc
```sh
# 1～10求和
seq -s + 1 10 | sed 's/+$//g' | bc

# 浮点数比较
if [[ $(echo "2.0 > 100.0"| bc) == 1 ]] ; then echo ok; fi
```

#### ntpdate
```sh
# 选择时区
tzselect

# 设置时区
export TZ='Asia/Shanghai'
echo "export TZ='Asia/Shanghai'" >> /etc/profile

# 更新时间
yum install ntp -y  
ntpdate 1.cn.pool.ntp.org  
ntpdate cn.pool.ntp.org 
```

#### ls
```sh
# 查看目录文件
ls -lthsi /data
-l 长格
-s 大小
-i 节点信息
-h 字节单位
-t 修改时间排序
-R 递归显示
-a 显示所有子目录和文件 包含隐藏文件

# 查看目录
ls -ld dir

# 查看文件
ls -l test
-rw------- 1 root root 1086 07-29 18:35 test
文件属性 连接数 拥有者 群组 实际用去的大小 最后被修改的时间 文件名
第2字段：
连接数 == 目录下子目录的个数
如果是链接目录：起始值是1
普通空目录：起始值是2，表示该目录下有两个隐藏的子目录"."和".."

# 不排序强制输出，当目录下文件过多
ls -f -1 /path/to/dir  

硬链接和软链接的区别
1.共享一个inode节点，但是目录项不同，指向的block块一样，
   不能对目录作硬链接
   不能跨文件系统(分区)
   删除源文件，链接文件不会受到影响
2.软链接源文件和链接文件的inode号不一样，链接文件根据文件名找到inode号，通过inode table表找到block块，里面存放者源文件的绝对路径，根据绝对路径找到源文件inode，最后找到block文件内容
   能对目录作软连接
   能跨越文件系统
    删除源文件，链接文件受到影响
 链接文件是根据文件名来判断是否失效
3.对原文件的修改,软、硬链接文件内容也一样的修改，因为都是指向同一个文件内容的
```

#### cd
```sh
# 进入家目录
cd ~

# 进入当前目录
cd .

# 进入上一层目录
cd ..

# 进入上一次目录
cd -
```

#### dos2unix  & unix2dos
```sh
# 换行
# MAC OS下：dakdhih \r
# LINUX下：dakdhih \n
# DOS\WINDOWS下：dakdhih \r\n

# window 转 linux
yum install dos2unix -y 
dos2unix file
sed -i'' "s//r//" file

# k时间戳不变, n保存为新文件
dos2unix -k -n oldfile newfile

# linux 转 window
yum -y install unix2dos*
unix2dos file
```

#### date
```sh
# 解析时间戳
date -d @1523440200  

# 生成时间戳
date +%s -d '2017-10-20'   

# 一天前
date +%s -d "1 day ago"          

# 显示UTC时间，可用于作为es中的timestamp
date -u +"%FT%T.000Z" 
date -u +"%FT%T.000Z" -d '1 hours ago'  

# 计算具体现在多少天
echo $(expr $(date +%s) - $(date +%s -d '20210718')) / 86400 | bc
```

#### pwd

#### whoami

#### time

```sh
time cmd   # 命令执行的real真实、user用户、sys系统时间
```

#### basename

```sh
basename 绝对路径 # 截取路径的最后一层 (pwd |xargs basename)
```

#### dirname

```sh
dirname 绝对路径 # 只不截取路径的最后一层 (pwd |xargs dirname)
```

#### grep

```bash
# count数量
grep -c "str" file
# 忽略大小写
grep -i "Str" file
# 不显示文件名
grep -h "str" file
# 只显示文件名
grep -l "str" file
# 显示行号
grep -n "str" file
# 大写字母开头
grep ^[[:upper:]] file
grep ^[A~Z] file
# 精确匹配 the
grep "\<the\>" file


# POSIX 增加的特殊编码
[:upper:]  ==  [A~Z]
[:lower:]  ==  [a~z]
[:digit:]  ==  [0~9]
[:alnum:]  ==  [0~9a-zA-Z]
[:space:]  ==  空格或tab
[:alpha:]  ==  [a~zA~Z]
```

#### xargs

```sh
# 从standard input标注输入执行命令
# 将标准输入内容都会换成一个空格分割，默认命令/bin/echo
-I 必须指定替换字符　
－i 是否指定替换字符-可选

pwd | xargs basename         # 允许不支持管道的命令执行
ls /tmp | xargs -I '{}' du /tmp/{}   # -I将标准输入保存到{}
ls /tmp | xargs -I 'sth' du /tmp/sth # 同上 

ls /config/pipeline/*.conf   | xargs -If  cp f ./ 
```

#### readlink

#### which & whereis

```sh
# 查找shell命令的全路径 （根据PATH）
which cd     # 查找cd的绝对路径
which -a cd  # 查找所有PATH下的cd绝对路径，默认找第一个停止

# 查找命令的二进制、源码、man手册 （根据PATH）
whereis cd      # 查找cd相关
whereis -b cd   # 只找cd的命令绝对路径
whereis -m cd   # 只招手册
whereis -s cd   # 只招源码
```

#### locate

```sh
# 通过关键字找文件 （根据update管理的数据库）
# 操作前
updatedb         # 更新数据库，默认十分钟corn操作一次
locate  tmp      # 找绝对路径中包含tmp的文件或目录
locate -b tmp    # 找绝对路径中basename中包含tmp的文件或目录
locate -b "\tmp" # 精确找绝对路径中basenamne是tmp的文件或目录
locate -b -c tmp # 统计找的绝对路径个数
```

#### find

```sh
# 找到两天前文件压缩
find /data/remotesyslog/test/ -type f -name "*.log" -mtime +2 | xargs -If gzip f;
# 查找权限
find . -name "t*" -perm 744 -print 
# 查找当天内的log文件
find .  -name "*.log" -mtime 0 -exec ls -l {} \;
find .  -name "*.log" -mtime -1 -exec ls -l {} \;
# 查找昨天的log文件
find .  -name "*.log" -mtime 1 -exec ls -l {} \;
# 查找昨天以前的log文件
find .  -name "*.log" -mtime +1 -exec ls -l {} \;
```

#### du

```sh
# 统计文件占用磁盘大小
du -ah /tmp       # 递归目录下所有文件的大小
du -sh /tmp       # 统计目录的大小
du -ch /tmp /var  # 统计总的大小
du --exclude "*.txt" /tmp  # 排除某类文件
du --max-depth 2 /tmp  # 显示深度2层
du -d 2 /tmp           # 同上

# 统计/下目录的大小，排除data和proc目录
du -h -d 1 --exclude="proc" --exclude="data" /

# 删除文件
du -sh /usr/local/NMServer/bin/* | grep G | awk '{print $NF}' | xargs -I{} dd if=/dev/null of={} > /dev/null 2>&1
```

#### sort

```bash
# 指定排序的行
sort -k 1 test.txt

# 指定行逆序排列
sort -k 1 -r test.txt
```


#### kill

```bash
# 查看kill能发出的所有信号
kill -l

HUP 1 重新加载程序
TERM 15 终端终止kill pid
KILL 9 强制终止
QUIT 3 退出，同ctrl+c

kill -HUP pid
kill -15 pid
kill -9 pid
```

### shuf

```bash
# 获取随机数
shuf -i 1000-2000 -n1
```

### screen

```bash
# 多个任务运行不切换窗口的神器
# 安装
yum install screen
# 新建一个session
screen -S test 
# 查看
screen -ls 
# 进入session
screen -r test
# 退出
screen -d test
# 退出并关闭
screen -d -r test
```

### trap
```bash
# 捕捉信号后执行命令
trap cmd sig1

# 捕捉到INT信号（crtl+c）后脚本退出
#!/bin/bash
trap "echo 'You hit crtl+c'" INT
while :
do
  let count=count+1
  echo "this is $count sleep"
  sleep 5
done

# 忽略对TERM INT信号的处理
trap "" TERM INT
```


#### mount

```sh
mount -t iso9660 /dev/cdrom /mnt # linux挂载光盘
mount -o loop filename.iso /mnt  # linux挂载ISO
```

#### curl

[curl](https://www.cnblogs.com/ruiy/p/curl.html)

```sh
# 查看公网ip
curl ipinfo.io/ip

# 用户密码
curl -u user:passwd http://test.com curl 

# 获取http_code
curl -sL -o /dev/null -w "%{http_code}\n" 'http://res.qaxlist.com'

# 保存js文件
 curl -O  https://code.jquery.com/jquery-3.4.1.min.js

# 查询本机公网IP
curl ifconfig.me 

# 访问时间
curl -X POST -w %{time_namelookup}:%{time_connect}:%{time_starttransfer}:%{time_total} "http://test.com?id=123"

# 拨测加cookie
curl  -H 'Cookie: env=idc'  -H'Host:boss.we.com' "http://10.10.10.142" 

# 计算es的索引大小
curl -s http://localhost:9201/_cat/indices | grep ${yesterday} | awk '{print $NF}' | grep mb | awk -F'mb' '{print $1}'| tr '\n' '+' | sed 's/+$/ /g'| xargs -I@  echo \(@\)/1000 | bc

curl -sv  -XPOST http://192.168.1.196:8080/v1/jobs  -H "Content-Type:application/json" -d'{}'
“-s”的用作为：不显示创造的进度
“-v”的作用为：显示请求和响应
```

#### shutdown & poweroff & reboot

```sh
# 关机 重启
shutdown -h now    # 立刻关机
shutdown -h 8:00   # 8点关机
shutdown -h +10    # 系统再过十分钟自动关机
shutdown -c        # 取消命令 
```

### 文件

#### cat
```sh
# 非交互式写入文件
cat <<EOF > /tmp/test.xtx
hello world
EOF
```

#### touch

```shell
touch aa    # 文件存在则更新访问修改改变时间为当前时间
touch -md 20141227 文件   # 指定修改时间
touch -ad 时间 文件       # 指定访问时间
```

#### rm

```shell
rm -rfv 文件   # 强制递归删除
```


#### sed
```sh
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


# hold sapace与pattern space交换后输出
# hold space第一行为空，所以输出内容为文件第一行为空后面不变
sed 'x' /tmp/a

# 反序文件，从最后一行到第一行打印文件
# 1!G —— 只有第一行不执行G命令，将hold space中的内容append回到pattern space
# h —— 第一行都执行h命令，将pattern space中的内容拷贝到hold space中
# $!d —— 除了最后一行不执行d命令，其它行都执行d命令，删除当前行
sed '1!G;h;$!d' /tmp/password
```

#### awk
```sh
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

# 计算1分钟内网卡速率
a=`ifconfig eth1 | awk '/RX bytes/ {print substr($2,7)}'` && 
sleep 60 && 
a1=`ifconfig eth1 | awk '/RX bytes/ {print substr($2,7)}'` && 
echo "($a1-$a)/60" | bc 

# 替换文本开头空格
awk '{sub(/^[ \t]+/,""); print $0}' /tmp/a
```

#### stat

```shell
# stat
  File: ‘aa’
  Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
Device: fd01h/64769d	Inode: 484648      Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2020-02-09 14:39:36.427313631 +0800
Modify: 2020-02-09 14:39:36.427313631 +0800
Change: 2020-02-09 14:39:36.427313631 +0800
 Birth: -
```

#### diff

```shell
# 比较两个文件不同之处
diff 2.txt 1.txt |grep "<"|awk ' $1 = " " '
```

#### cp & scp

```shell
cp -r 目录  新目录
cp -a file1 file2 目录   # 复制并保留文件属性
cp -u 源文件 目标文件     # 只有源文件比目标文件更新时才复制

# 远程copy
scp file1 10.0.10.108:/tmp/      # 当前文件复制到远程tmp目录
scp 10.0.10.108:/tmp/file1  ./   # 远程文件复制当前目录
sshpass -p passwd scp -P 22 -r /tmp/aa user@it.abc.com:/10.11.9.156/tmp/ # 免密递归copy
scp -P 22 -o StrictHostKeyChecking=no file1 10.0.10.108:/tmp/               # scp传输跳过第一次yes验证
```

#### rsync
```
# 通过ssh或daemon为媒介
# 考虑：文件属性、时间、权限、软链、断电续传、带宽、压缩

-P 包含显示进度和断点续传
-z 压缩
-a 包含所有文件权限、属性、时间等
--delete 目标目录和传输目录保持一致
--bwlimit 1000 默认单位KBytes
--partial  断点续传，传输中断不删除临时文件
--progress 显示进度

# 保持源、目标文件一致
rsync -avP --delete test root@192.168.1.183:/tmp/test
# 限制传输速度为1M
rsync -avPz --bwlimit=1000 aa root@192.168.1.183:/tmp/aa
# 指定协议
rsync -avPz -e 'ssh -p 223' aa root@192.168.1.183:/tmp/aa

# 迁移本地数据
rsync -avz /var/lib/docker/ /data/docker
```

#### sz & rz

```sh
yum install lrzsz -y 
sz file  # xshell文件传输
```

#### tar

```bash
# 归档排除某个目录
tar zcvf zabbix.tgz  --exclude=zabbix/scripts  zabbix
```

### zip
```bash
zip -r filename.zip filesdir
zip file.zip file1 file2

sudo yum install unzip -y
# 查看
unzip -v large.zip
unzip file.zip
```

#### gzip

```sh
节省空间和网络传输时间
gzip testfile           # 压缩文件为testfile.gz
gzip -l testfile.gz     # 查看
gzip -dv testfile.gz    # 解压
```

#### mv

```shell
mv file1 file2 dir1 目标dir
# -p 保持权限
mv -p file1 dir1
```

#### ln

```sh
ln 源文件 链接文件        # 硬链接
ln -s 源文件 链接文件 == cp -s 源文件 链接文件 # 软链接
# 源文件要用绝对路径创建软链接
# 在软链接目录中 查看真实的路径： pwd -P

# 硬链接和软链接的区别
# 因指向同一文件，故对源、软、硬链接文件的任一修改都会修改
硬链接
1. 共享inode节点
2. 不能对目录作硬链接
3. 不能跨文件系统(分区)
4. 删除源文件，链接文件不会受到影响

软链接
1. 不共享inode节点
2. 能对目录作软连接
3. 能跨越文件系统
4. 删除源文件，链接文件失效

# 文件内容查找过程
文件名——inode号——inode表——block块——内容数据 （硬链接和源文件）
文件名——inode号——inode表——链接文件的源文件名——inode号——inode表——block块——内容数据 （软链接）

# 硬盘格式化分为两个区域
1.inode table 区域(数据索引值)
2.数据存储区域
```

#### cat

```
# 添加系统启动
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF

systemctl start node_exporter
systemctl enable node_exporter
```

#### tac

#### more

```shell
# 全屏方式分页查看
enter 向下逐行显示
空格   向下翻一屏 （末尾退出）
b键   向上翻一屏 
q    退出
```

#### less

```shell
# 交互操作 （vim适用） 
enter 向下逐行显示
空格   向下翻一屏 （末尾不退出）
b键   向上翻一屏
q    退出
G    末尾
gg   开头
```

#### head

```sh
head file      # 查看前10行
head -n 3 file   # 查看前3行
head -c 3 file   # 查看前c字节的内容，一字母一字节
```

#### tail

```sh
tail file         # 最后十行
tail -n 3 file    # 最后三行
tail -n +3 file   # 从第三行开始到结束
tail -f file      # 监控追加到文件的内容，ctrl+c结束
tail -n +10 file | head -1 # 显示第十行
head file | tail -n 1
```

#### mkdir & rmdir

```shell
mkdir -m 777 -p /aa/bb/cc  # 创建多级目录指定权限
rmdir -p /aa/bb/cc         # 删除多级目录
```

#### lsyncd

[lsyncd](https://lifeimpressions.net/?z=56408&c=55kB*tUbi2E&l1=158121&l2=104666&l3=&l4=56cd1de15d25bf083ddf7a4b&l5=PM_ADSIZE_WIDTH&l6=PM_ADSIZE_HEIGHT&source_id=56cd1de15d25bf083ddf7a4b&f1=222261&f2=222262&f3=222263)


#### cron

```bash
# 全局性计划任务时，修改/etc/crontab或者/etc/cron.d
echo '* * * * * root cd /usr/local/mymon && ./mymon -c etc/myMon.cfg' > /etc/cron.d/mymon

# 写脚本时先判断
[ -f /etc/cron.d/n9e ] || echo '* * * * * root cd /usr/local/n9e-agent/;./control start &> /dev/null' > /etc/cron.d/n9e
```

### 用户

#### passwd

```bash
# 锁定
passwd -l user
# 解锁
passwd -u user
# 强制下次登录修改密码
passwd -f user
```


### 场景

#### 清空日志
```sh
# 重定向方式
> access.log
cat /dev/null> access.log
echo > access.log

# 命令
cp / dev/null access.log
dd if=dev/null of=access.log
truncate -s 0 access.log
```
