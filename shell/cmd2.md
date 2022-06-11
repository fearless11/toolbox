[toc]

## 系统分析命令

### Information

#### /etc

```sh
cat /etc/os-release
cat /etc/issues
cat /etc/redhat-release
/usr/share/zoneinfo/Asia/Shanghai  # 时区
/etc/machine-id # 在安装或首次启动操作系统时生成的唯一ID
```

#### /proc

```sh
cat /proc/version
cat /proc/cpuinfo  
cat /proc/memoryinfo
cat /proc/net/sockstat
cat /proc/mounts

# 查看随机端口
cat /proc/sys/net/ipv4/ip_local_port_range

# 查看已经监听的所有duan k
awk -F '[: ]+' '{print strtonum("0x"$4)}' /proc/net/tcp  | sort | uniq
```

#### systemctl

```sh
# centos7 
# 查看服务是否设置开机自启动
systemctl list-unit-files | grep docker

# 查看服务状态
systemctl status docker.service
systemctl start docker.service
systemctl stop docker.service
```

#### uname

```sh
uname -a     # 查看所有
uname -r     # 查看内核版本
3.10.0-514.21.1.el7.x86_64 
Linux 3.10.0-514.21.1.el7.x86_64 (VM_0_99_centos)
```

#### lsb_release

```sh
yum provides lsb_release        # 查看提供命令的包
yum install redhat-lsb-core -y  # 安装包
lsb_release -a                  # linux系统版本
```

#### getconf

```sh
getconf LONG_BIT     # 查看64位还是32位
```

#### getenforce
```sh
getenforce     # 临时修改
setenforce 0   # 永久修改
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

#### dmidecode

```sh
dmidecode | grep Name  # 查看物理机还是虚拟机
```
#### systctl
```sh
# sysctl - configure kernel parameters at runtime
# 对应/proc/sys目录
# 例如：/proc/sys/net/ipv4/tcp_invalid_ratelimit
# 对应：net.ipv4.tcp_invalid_ratelimit = 500
# 查看所有
/sbin/sysctl -a                   
# 正则查看
/sbin/sysctl -a --pattern forward
/sbin/sysctl -a --pattern forward$
/sbin/sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'
/sbin/sysctl --system --pattern '^net.ipv6'
# 查看某个值
/sbin/sysctl -n kernel.hostname
# 改某个值
/sbin/sysctl -w kernel.domainname="example.com"
# 根据文件更改
/sbin/sysctl -p /etc/sysctl.conf
```

### hardward


#### ipcs

```sh
# 查看系统进程通信IPC
# 查看系统信号量限制
ipcs -ls
# 查看系统信号量使用情况
ipcs -s
# 查看使用某信号量的pid
ipcs -s -i semid
# 删除某个泄露的信号量 pid找不到对应进程
ipcrm -s semid


# 临时调整系统限制    对应关系如下
sysctl -w kernel.sem="262 32000 250 128"
# ipcs -ls
------ Semaphore Limits --------
max number of arrays = 128
max semaphores per array = 262
max semaphores system wide = 32000
max ops per semop call = 250
semaphore max value = 32767

# zabbix占用的泄露的信号
# ipcs -s|grep zabbix | awk '{print $2}' | xargs -I{} ipcrm -s {}
```

#### omreport

http://linux.dell.com/repo/hardware/OMSA_7.4.0/

[omreport查看硬盘信息](https://blog.csdn.net/a226433955/article/details/101145936)

```sh
# 戴尔服务器使用omreport（OMSA）查看监控硬件信息 （没用。。。）
wget -q -O - http://linux.dell.com/repo/hardware/OMSA_7.4.0/bootstrap.cgi | bash
# 关键  /etc/yum.repos.d/dell-system-update.repo
yum install -y srvadmin-all 
ln -s  /opt/dell/srvadmin/sbin/omreport /usr/bin/omreport

# 主要组件的常规
omreport chassis
# 内存
omreport chassis memory 
# 组件温度
omreport chassis temps
# 磁盘陈列
omreport storage adisk controller=0 
# 物理磁盘
omreport storage pdisk controller=0 
# 虚拟硬盘
omreport storage vdisk controller=0 
# 控制器(即RAID卡)的属性
omreport storage controller
# enclosure的属性
omreport storage enclosure controller=0 
# 电池
omreport storage battery 
# 格式化 -fmt
omreport chassis info -fmt ssv
omreport storage controller -fmt ssv
```

### cpu（usage、status）

#### nproc

```sh
# cpu的核心数
nproc      
```

#### lscpu

#### dstat

```sh
# 统计系统资源
dstat -c           # 查看cpu资源
dstat --top-cpu    # 占用cpu最多的进程
```

#### mpstat

```sh
# 报告每个内核相关状态
mpstat           # 总的cpu内核信息
mpstat -P ALL    # 每个cpu信息

%usr     用户空间
%nice    调整nice值的用户空间
%sys     内核空间
%iowait  cpu空闲，等待i/o请求
%irq     硬中断
%soft    软中断
%steal   运行虚拟机时，虚拟机分配的cpu占比
%guest   虚拟机中进程用cpu的占比
%gnice   虚拟机中nic进程用cpu占比
%idle    cpu空闲，不包括i/o请求
```

### 内存memory （usage、swap）

#### free

```sh
# 显示内存使用情况
free  -m       # 单位M

# buff/cache/swap
buff    提高吞吐，比如磁盘写入    （ sync手动刷新buff ）
cache   加快速度，提高命中率，比如cpu的cache （可释放）
swap    虚拟内存。把硬盘上空间当成内存用，当内存不足时，将内存中不常用的刷到硬盘，腾空间，等需要时取回

# cache释放 （坑：内核2.6上无法改回0，除非重启）
sync; echo 1 > /proc/sys/vm/drop_caches  # 释放pagecache
sync; echo 2 > /proc/sys/vm/drop_caches  # 释放dentries和 inodes
sync; echo 3 > /proc/sys/vm/drop_caches  # 释放pagecache，dentries 和 inodes：
sync; echo 0 > /proc/sys/vm/drop_caches  # 默认0为不释放，让系统自己调节
```

### 磁盘disk （usage、IO）

#### df

```sh
# 统计文件系统的实用情况
df -Th       # 统计文件系统类型及系统usage
df -ih       # inode的使用情况
```

#### LVM
```sh
# 思路： pv --- vg --- lv --- mount

# 扩展lv后重新加载生效
lvremove /dev/cl/home
lvextend -L +900GB /dev/cl/root 
# resize2fs /dev/cl/root  报错Bad magic number in super-block
# cat /etc/fstab | grep centos-home
# /dev/mapper/cl-root     /   xfs     defaults        0 0
# 重新加载
xfs_growfs /dev/cl/root

#### 卸载lvm
umount data
# 移除lv
lvremove /dev/vg0/lv0
vgdisplay
# 移除vg
vgremove vg0
vgscan
# 移除pv
pvremove /dev/vdb1
# 删除自动挂载
vim /etc/fstab 
```
```sh
#!/bin/bash
#磁盘格式化

#判断vdb是否已挂载
df -h|grep vdb
if [ $? -eq 0 ];then
echo -e "\033[31m vdb has been mounted \033[0m"
exit 1
fi
echo -e 'n\n\n\n\n\nt\n8e\nw\n' | sudo fdisk /dev/vdb
sudo pvcreate /dev/vdb1
#判断vg0和lv0是否存在
ls /dev/mapper/|grep vg0 || ls /dev/mapper/|grep lv0
if [ $? -eq 0 ];then
echo -e "\033[31m vg0 or lv0 exists. \033[0m"
exit 1
fi
sudo vgcreate vg0 /dev/vdb1
sudo lvcreate -n lv0 vg0 -l 100%VG
sudo mkfs.xfs -n ftype=1 /dev/mapper/vg0-lv0
sudo mkdir -p /data
cat /etc/fstab|grep vg0-lv0
if [ $? != 0 ];then
echo "/dev/mapper/vg0-lv0            /data                xfs        defaults              0 0" | sudo tee -a /etc/fstab
fi
sudo mount -a
df -h|grep vg0
if [ $? -eq 0 ];then
echo -e "\033[31m vdb format to lvm successfully. \033[0m"
fi

df -h
```

#### iostat

```sh
# 查看磁盘io情况
iostat -xdm 1
```

#### pidstat

```sh
# 查看进程pid情况
pidstat -d 1
```

#### vmstat

```sh
# 报告虚拟机状态
vmstat -t 1 5 # -t在末尾显示时间戳，间隔1s，共采集5次数据
vmstat -d     # 查看每一块磁盘读写状况

# proc
r   可运行的进程数 （运行或在等待运行的）
b   不可中断的进程数
```

### 网络network （flux、status）

#### telnet

```bash
# 去掉交互式
echo -a | telnet -e a 127.0.0.1 8083 
```

#### ssh
```bash
# debug ssh connection
ssh -v git@github.com
```

#### iptables
```bash
# 备份与恢复
iptables-save > iptables-`date +%F`
iptables-restore < iptables-`date +%F`

# 限制本机外其他主机访问2375
iptables -I INPUT -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 2375 -j REJECT

# 追加到INPUT链
iptables -A INPUT -p tcp -s 192.168.56.101 --dport 9100 -j ACCEPT

# 插入到INPUT链指定位置为2
iptables -I INPUT 2 -p tcp -s 192.168.56.101 --dport 9100 -j ACCEPT

# 放开8080端口
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT

# 查看
iptables -L -n --line-number 

# 删除 第2条
iptables -D INPUT 2
```

#### brctl
```bash
# 查看桥接到宿主机器的情况
brctl show
```

#### ethtool
```sh
# query or control network driver and hardware settings
```

#### lspci
```sh
# list all PCI devices
```

#### host
```sh
# 名字解析器 （namesever可配置三个）
cat /etc/resolv.conf
nameserver 8.8.8.8      //google服务器
nameserver 8.8.4.4      //google备用服务器
domain tuc.noao.edu     //不完全域名自动补充后缀

# 查询域名对应的ip
host -v www.baidu.com 
```

#### fping

```sh
fping 
 -A    将目标地址以ip显示
 -u    显示不可达的目标
 -c n  ping探测次数
 
# fping -A -u -c 4 192.168.1.1 192.168.1.20
192.168.1.1  : xmt/rcv/%loss = 4/4/0%, min/avg/max = 1.54/2.30/4.32
192.168.1.20 : xmt/rcv/%loss = 4/4/0%, min/avg/max = 0.07/0.07/0.08
```

#### ifconfig
```bash
# 获取网卡IP
/sbin/ifconfig `/sbin/route|grep '^default'|awk '{print $NF}'`|grep inet|awk '{print $2}'|awk -F ':' '{print $NF}'|head -n 1
```

#### route
```bash
# 添加默认网关
route add default gw 192.16.128.254
```

#### nc

```sh
watch nc -v 192.168.1.43 40002 -w 1
nc -w1 -u 10.11.100.19 514 <<< "<15>logging from remote by UDP 514"                        # 远程写rsyslog日志
logger -p user.info "testing 123"  # 本地写rsyslog日志

# 测试是连通
nc -w 1 9.230.92.21 9100 < /dev/null && echo "9.230.92.21 9100 tcp port ok"

# 模拟http请求
nc -l 9090 < filename
curl http://127.0.0.1:9090

## 端口测试
# v 显示多点信息（verbose），z 不发送数据
nc -vz 192.168.1.2 8080
# 端口范围扫描 w3 超时时间为 3 秒。
nc -v -v -w3 -z 192.168.1.2 8080-8083

## 传输测试
#  netcat + shell script 可写 一个http 服务器
# 开启监听 8080 端口
nc -l -p 8080
# 连通后发送数据
nc 192.168.1.2 8080

## 测试UDP会话
# 监听udp的8080端口
nc -u -l -p 8080
# 连接udp
nc -u 192.168.1.2 8080

## 文件传输
# 监听端口
nc -l -p 8080 > image.jpg
#  老版本 GNU / OpenBSD 的 netcat 在文件结束（标准输入碰到 EOF），发送文件一端就会关闭连接
nc 192.168.1.2 8080 < image.jpg
# 新版本需要比较，或者加上-N参数，文件传输结束时关闭
/bin/nc.openbsd -N 192.168.1.2 8080 < image.jpg

## 网速吞吐量测试
# 加上 -v -v 参数后，结束时会统计接收和发送多少字节， n 不要解析域名
/bin/nc.traditional -v -v -n -l -p 8080 > /dev/null
# 回车后执行十秒钟按 CTRL+C 结束， netcat 统计的数值是 32 位 int，如果传输太多就回环溢出成负数
time nc -n 192.168.1.2 8080 < /dev/zero
# 对于 OpenBSD 版本的 nc 我们可以用管道搭配 dd 命令进行统计， -N 代表 stdin 碰到 EOF 后就关闭连接
dd if=/dev/zero bs=1MB count=100 | /bin/nc.openbsd -n -N 192.168.1.2 8080
dd if=/dev/zero bs=1MB count=100 | /bin/nc.traditional -n -q0 192.168.1.2 8080
# 统计时，根据接受字节数/时间。上面计算了建立连接的握手时间以及 TCP 窗口慢启动的时间

# 精准测试网速
#  pv 命令（监控统计管道数据的速度）pv 实时状态：353MiB 0:00:15 [22.4MiB/s] [          <=>  ]
nc -l -p 8080 | pv
# 发送数据
nc 192.168.1.2 8080 < /dev/zero

## 系统后门
# 打开bash，用完注意将 /tmp/f 这个 fifo 文件删除
mkfifo /tmp/f
cat /tmp/f | /bin/bash 2>&1 | /bin/nc.openbsd -l -p 8080 > /tmp/f
# 登录后可执行shell
nc 192.168.1.2 8080
```

#### mtr

```sh
mtr 10.10.10.145   # 追踪路由
```

#### tcpdump

```sh
# 抓取指定端口流量
tcpdump -iany port 6617

# 统计抓包情况
ip=10.12.212.147
port=22000
tcpdump -i any -nn  \( src host ${ip}  and src port ${port} \) or \( dst host ${ip} and dst port ${port} \) &> log-19001
cat log-19000  | awk '{print $5'} | grep ^1 | sort | uniq -c

# 抓包保存到文件
tcpdump tcp -i eth1 -t -s 0 -c 100 and dst port ! 22 and src net 192.168.1.0/24 -w ./target.cap

# 从文件读取
tcpdump -r packet.pcap
```


#### ss

#### netstat
```sh
# 获取指定范围内的随机端口
get_random_port(){
    temp=0
    while [ $temp == 0 ];do
      random=$(shuf -i 3000-4000 -n1)
      netstat -an | grep -w ":${random}" | grep 'LISTEN' && continue
      temp=${random}
   done
   return $temp
}

# 查看tcp连接状态
netstat -n  | awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}'
```


#### nethogs

```sh
# 每个进程的网络带宽  （类似top）
yum install nethogs -y  # 安装
nethogs -d 1            # 指定刷新间隔1s
nethogs em1             # 查看某个网卡设备

# 交互式操作
m  改变查看模式 KB/s KB MB B
r  接收字节排序
s  发送字节排序
q  退出
```

#### iftop

```sh
# 实时流量监控工具
yum install epel-release -y
yum install iftop -y
-P 混杂promiscuous模式，机器网卡接收经过它的数据流，不论目的地址是否是它
-i 设定监测的网卡，如：# iftop -i eth1
-B 以bytes为单位显示流量(默认是bits)，如：# iftop -B
-n 使host信息默认直接都显示IP，如：# iftop -n
-N 使端口信息默认直接都显示端口号，如: # iftop -N
-P 显示所有主机所有端口
-t 非交互式

# 说明
中间的<= =>这两个左右箭头，表示的是流量的方向。
TX：发送流量
RX：接收流量
TOTAL：总流量
Cumm：运行iftop到目前时间的总流量
peak：流量峰值
rates：分别表示过去 2s 10s 40s 的平均流量

# 交互式操作
1/2/3 按第一列2s/第二列10s/第三列40s排序

# 常用
iftop -PnN -i bond1
iftop -tNPn -i bond1 -o 2s # 屏幕输出，按第一列排序
```

#### socat

```sh
http://www.dest-unreach.org/socat/download/

# 网络打通工具，建立数据通道，支持多协议连接 
nohup输出到指定文件
nohup socat -T 600 UDP4-LISTEN:9996,reuseaddr,fork UDP4:10.21.16.51:9996  >> /root/socat.log 2>&1 &
```

#### rinetd

```sh
# 网络打通工具
https://boutell.com/rinetd/

#vim /etc/rinetd.conf
#将所有发往本机8080端口的请求转发到172.19.94.3的8080端口
0.0.0.0 8080 172.19.94.3 8080

rinetd -c /etc/rinetd.conf   #启动转发
pkill rinetd                 #关闭进程
```


### 进程process 

#### ps （Process Status）
```sh
# 说明
列出的是当前那些进程的快照，动态的显示用top。

# 进程5种状态
  R   runnable (on run queue) # 运行(正在运行或在运行队列中等待) 
  S   sleeping  # 中断(休眠中, 受阻, 在等待某个条件的形成或接受到信号) 
  T   traced or stopped # 不可中断(收到信号不唤醒和不可运行, 进程必须等待直到有中断发生) 
  D   uninterruptible sleep (usually IO) # 停止(进程收到SIGSTOP, SIGSTP, SIGTIN, SIGTOU信号后停止运行运行) 
  Z   a defunct ("zombie") process # 僵死(进程已终止, 但进程描述符存在, 直到父进程调用wait4()系统调用后释放) 
  
# 区别
# ps -aux  -aux"打印用户名为"x"的用户的所有进程 
ps aux     # aux是BSD风格，会截断command列
ps -ef     # System V风格，不会截断command列

# 检查机器上进程情况
 ps -elf | egrep -v 'kworker|/usr/local/sa|/usr/local/tencent|docker|sshd|/usr/local/sbin/|ksoftirqd|fcoethread|scsi_eh|\[|/usr/lib/systemd|/data/saltstack|/usr/sbin/|TsysAgent|safe_TsysProxy|polkit|agetty|sleep|init|bash|ps|systemd'
```

#### top

[top](https://www.cnblogs.com/xuxm2007/archive/2012/06/05/2536294.html)

```sh
# 重点关注wa、cpu
top
```

#### lsof

[lsof](https://blog.csdn.net/kozazyh/article/details/5495532)

```bash
# 查看进程打开的所有文件
lsof -p pid
```

#### sar

#### jstat & jmap

```sh
# java在GC时处理
jstat -gcutil 11867 1 10
jmap -histo 11867
```

### 压测

#### sysbench

#### fio

#### tpcc

#### wrk

```bash
# 30s内发起100个连接，超时时间为12s
wrk -t12   -d30s  -c100  https://www.baidu.com
```
