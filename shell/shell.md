[TOC]

## shell

[man.linuxde.net](https://man.linuxde.net/)

[https://github.com/koalaman/shellcheck](https://github.com/koalaman/shellcheck)

Linux是一种多用户多作业的操作系统。

特殊功能的程序，提供用户与内核进行交互操作的接口。

一门脚本语言，以解释方式运行不需要编译。

### 基本元素

```bash
#!/bin/xx
#!指定一个文件类型的特殊标记，告诉系统指定哪种解释器来解释脚本
常见解释器：bash、sh、zch、、awk、sed
注释：以#开头，除第一行外

# shell的基本元素：命令
# 命令名称、选项、参数
内建命令 ： 不创建子shell
外部命令 ： 创建子shell

# linux用户
root、虚拟用户ftp、普通用户

# shell分类
bash   Bourne Shell
dash   简化的bash
tcsh   C编程
ksh    兼容bash和tcsh，内建很多数学函数


# shell模式
正常模式
限制模式： set -r # 基于安全考虑，禁用一些操作

# 特殊符合
while :   # 永远为真
:> file   # 清空文件
: $var    # 不做任何事情，只展开var变量参数

# 登录shell读取
/etc/profile => /etc/bashrc
~/.profile =>  ~/.bashrc => /etc/bashrc

# 非登录shell读取
~/.bashrc => /etc/bashrc

profile 设置环境变量别名
bashrc 设置终端颜色等
```

### 编程风格

```bash
# 缩进 : 推荐4个字符

# {}
function_name 
{
    
}
function_name {
    
}

# 空格和空行 不占用内存空间

# 命名规范
# 匈牙利命名法
# 驼峰法：首字母小写 cityName
# 帕斯卡：首字母大写 CityName

# 注释

# 建议
#!开头指定解释器，没有则为默认解释器
必要注释：时间、作者、用途、注意事项、参数
参数规范：判断是否合理
命名规范：小写字母、下划线
变量：减少硬编码
太长分行  反斜杠\
增加日志
密码移除 .env
脚本结构化 使用main函数
使用func(){}来定义函数，而不是func{}
使用[[]]来代替[]
使用$()将命令的结果赋给变量，而不是反引号
尽量使用printf代替echo进行回显
巧用heredocs，一种多行输入的方法，`cat >> /test.txt <<EOF xxxx EOF`生成模板文件
获取当前脚本的路径script_dir=$(dirname $(readlink -f $0 ))
命令并发：通过”&”以及”wait”命令
简单的if尽量使用&& ||，写成单行
会使用trap捕获信号，并在接受到终止信号时执行一些收尾工作
使用mktemp生成临时文件或文件夹
利用/dev/null过滤不友好的输出信息
会利用命令的返回值判断命令的执行情况
使用文件前要判断文件是否存在，否则做好异常处理
静态检查工具shellcheck 
```

### 变量

- 本地变量

  ```bash
  # 赋值与使用
  variable=value
  echo ${variable}
  ```

- 环境变量

  ```bash
  # 查看所有
  env   
  # 重要的环境变量
  $PWD $OLDPWD $PATH $HOME $USER $UID 
  $PPID      # 当前进程的父进程号
  $PS1 $PS2
  $IFS      # 分割符，默认空格
  # 使用环境配置文件
  source .bash_profile/.bashrc/.bash_logout
  . .bash_profile/.bashrc/.bash_logout
  
  # 定义和清除
  APPPATH=/usr/local/app
  export APPPATH
  echo $APPPATH
  unset APPPATH
  
  # /etc/profile
  export PS1='\[\e[32m\][\u@\H:\[\e[m\]\[\e[33m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\$ '
  ```

- 位置参数

  ```bash
  # 脚本的pid
  $$   
  # 脚本名
  $0
  # 脚本参数数量
  $#
  # 脚本所有参数
  $* 
  $@
  # 脚本参数
  $1 $2 $3 ... $9 ${10} ${11} ...
  # 命令退出 0正常，非0错误
  $?
  ```
  
### 传参

```bash
# shift
# 将命令行参数位置偏移一位
#!/bin/bash
# 实现一个不限制参数的倒三角
while [ "$#" -gt 0 ]
do
    echo $*
    shift
done
# sh a.sh 1 2 3
# 1 2 3
# 1 2
# 1


# getopts
# 判断命令行参数，匹配不成功在为？
# 
while getops "ab:" options
do
    case $options in
    a)
        echo "You enter -a as an option."
        echo 
        ;;
    b)
        echo "You enter -b as an option."
        ;;
    \?)
        echo "Please input a/b" >&2
        exit 0
        ;;
    :)
        echo "no argument value for option"
        ;;
    esac
done
# sh a.sh -a 

### 引用

```bash
""   # 双引号，引用除$、反引号``和反斜线\
''   # 单引号，引用所有字符
``   # 反引号，执行系统命令
$()  # 执行系统命令
\    # 转移
```

### 数组

```bash
# 声明
declare -a strarr

# 组合
aa=(a b c)
bb=(e f g)
cc=(${aa[@]} ${bb[@]})


# 赋值 
# ${city[1]}为hunan ${city[3]}为空
city=(beijing hunan shenzhen)
# 指定位置 
# ${city[6]}为shanghai
city=(beijing [5]=jiangsu shanghai)
city=(beijing [5]=jiangsu [2]=yunnan)

# shell将变量看成只有一个元素的数组
onearr=Hello
# 查看所有元素
echo ${onearr[@]}
echo ${onearr[*]}
# 用引号时@与*的区别
"${onearr[@]}"   # 所有元素分行打印
"${onearr[*]}"   # 所有元素打印为一行

# 长度 
# 数组
echo ${#onearr[*]}
# 第一个元素
echo ${#onearr[1]}

# 抽取、替换、删除
city=(Nanjing Anhui Meiao Meihua)
# 抽取
# 从第2个元素到结束
echo ${city[*]:2}
# 从0到第2个元素
echo ${city[*]:0:2}
# 替换
# 第一次M*a的子串替换为Year
echo ${city[*]/M*a/Year}
# 所有M*a的子串替换为Year
echo ${city[*]//M*a/Year}
# 删除
# 最短的M*a的子串
echo ${city[*]#M*a}
# 最长的M*a的子串
echo ${city[*]##M*a}
```

### 测试

- 测试结构

  ```bash
  # 测试整数
  test "1 -eq 1"
  echo $?
  0
  [ 1 -eq 1 ]
  echo $?
  0
  
  # 测试字符
  a=
  test $a
  echo $?
  1
  [ 'X'$a == 'X' ]  # 判空
  ```

- 整数运算符

  ```bash
  num1 -eq  num2  # ==
  num1 -ge  num2  # >=
  num1 -gt  num2  # >
  num1 -le  num2  # <=
  num1 -lt  num2  # <
  num1 -ne  num2  # !=
  ```

- 字符串运算符

  ```bash
  string        # 是否不为空
  -n string     # 是否不为空
  -z string     # 为空
  str1 = str2   # ==
  str1 != str2  # !=
  ```

- 文件操作符

  ```bash
  -d dir  
  -e file       # 存在
  -f file       # 普通文件
  -r|w|x file   # 读、写、可执行
  -L file       # 链接
  ```

- 逻辑运算符

  ```bash
  ! 表达式
  表达式1 -a 表达式2   # &&
  表达式1 -o 表达式2   # ||
  ```


### 判断

```
# 列表 cmd的返回0为TRUE  1为FALSE
cmd1 && cmd2 && cmd3  # TRUE继续
cmd1 || cmd2 || cmd3  # FALSE继续

# if-fi
if [ -x file ];then
   echo "no execute"
   exit 1
fi

if [ 100 -gt 99 ];then
   echo "yes"
   exit 0
fi


# if-else-fi
if [ ! -e "$1" -o 2 -eq "$2" ];then
   echo "file do not exist"
   exit 1
else
   echo "file exist"
fi

# if-elif-else-fi
if [ ! -e "$1" -o 2 -eq "$2" ];then
   echo "file do not exist"
   exit 1
elif [ ! -x "$1" ];then
   echo "no exec"
   exit 1
else
   echo "yes"
fi
```

### 循环

```bash
break     # 跳出循环
continue  # 执行下一次循环

# for
for i in $(seq 1 2 10)
do
   echo $i
done

sum=0
for (( i = 1; i <= 100; i = i + 2 ))
do
   let "sum += i"
done

# while
# :表示永远真 TRUE
while :
do
    if (( i >= 10 ))
    then
        break
    fi
    
    echo $((++i))
done

function while_read_LINE_bottm(){
  While read LINE
  do
    echo $LINE
  done  < $FILENAME
}

function While_read_LINE(){
  cat $FILENAME | while read LINE
  do
    echo $LINE
  done
}

function While_read_LINE(){
  cat $FILENAME | while read LINE
   do
    echo $LINE
  done
}
```

### expr

```bash
# 操作字符
string="speeding up small jobs in hadoop"
echo $(string:1:8)
peeding
expr substr "$string" 1 8
peeding


# 操作数字 
# 空格和转义
expr 2 \* 3
expr 8 - 3
# 计算保留小数
var1=20
var2=3.1415
var3=`echo "scale=5;$val ^ 2" | bc`
# 计算圆的面积保留小数点后5位
var4=`echo "scale=5;$var3 * $var2" | bc`
```

### eval

```bash
# 作用：将参数作为命令行，让shell重新执行该命令
pipe="|"
# 执行报错
ls $pipe wc -l
ls：无法访问|，没有文件或目录
# 正常解析 等价效果 ls | wc -l
eval ls $pipe wc -l
```

### 子shell并发

```bash
# 子shell只能继承父shell的一些属性，但不能反过来改父shell的属性。用export导入导出也无用。
# ()将其中的命令运行在子shell

# 并发
#!/bin/bash
# 子shell 后台运行
(grep -r "root" /etc/* | sort > part1) &
(grep -r "root" /usr/local/* | sort > part2) &
(grep -r "root" /lib/* | sort > part3) &
# 等待后台执行结束
wait
cat part1 part2 part3 | sort > parttotal
# 输出脚本执行时间
echo "Run time is: $SECONDS" 


# 并发执行等待结束，不能并发太多
func(){
    #do sth
｝
for((i=0;i<10;i++))do
    func &
done
wait
```

### 函数

```bash
# 函数返回值只能为退出状态0或状态1

# 函数
function_name(){
    command1
    command2
}

hello(){
    echo "hello"
}
hello

# 传参&返回  
# 返回 return & echo
# return返回只能是数字，echo 可以返回其他
#!/bin/bash

text="global variable"
count()
{
   # 作用域函数内部
   local text="local variable"
   if [ $# -ne 3 ]
   then
      echo "the number of arguments is not 3"
   fi
   
   let "s = 0"
   
   case $2 in
   +)
      let "s = $1 + $3"
      echo "$1 + $3 = $s"
      # 用return返回
      return 0;;
   -)
      let "s = $1 - $3"
      echo "$1 - $3 = $s"
      return 0;;
  \*)
      let "s = $1 * $3"
      echo "$1 * $3 = $s"
      return 0;;
  \/)
      let "s = $1 / $3"
      echo "$1 / $3 = $s"
      return 0;;

   *)
      echo "what you input is wrong"
      return 1;;
   esac
}

echo "please type your word:(eg:1+1)"
read a b c
# 判断函数的返回
if count $a $b $c
then 
   echo "success"
else
  echo "faile"
fi


# 返回调用
print_now() {
  now=$(date +"%F %T")
  echo ${now}
}
t1=`print_now`
echo $t1
```

### /dev /proc

```bash
# 伪文件系统
# /dev/null 黑洞，只写文件，写入它的内容都会永远丢失，而尝试从它那儿读取内容则什么也读不到
* * * * * >/dev/null 2>&1
* * * * * &>/dev/null 

# /dev/zero 伪文件系统，产生一个特定大小的空白文件
dd if=/dev/zero of=file bs=40 count=10

# /proc 伪文件系统，只存在内存中，不占用外存空间
# 查看系统中断
cat /proc/interrupts
# 网络
cat /proc/net/sockstat
```

### 调试

```bash
# 测试语法错误但不会实际执行命令
sh -n a.sh
# 执行命令前每个命令打印到标准输出
sh -x a.sh
```

## 实例

### 批量用户sudo

```sh
#!/bin/bash

if [[ $# -ne 1 ]];then
    echo "usage: sh add-user.sh name"
    exit 1
else
    name=$1
    useradd ${name}
    echo "${name}" | passwd --stdin ${name}
    /bin/cp -f /etc/sudoers /home/
    sed   "/^root/a \\${name}    ALL=(ALL)    NOPASSWD: ALL" /etc/sudoers  |grep root -A 1
    sed -i   "/^root/a \\${name}    ALL=(ALL)    NOPASSWD: ALL" /etc/sudoers 
fi
```

### 蓝鲸例子

```
#!/bin/bash

anynowtime="date +'%Y-%m-%d %H:%M:%S'"
NOW="echo [\`$anynowtime\`][PID:$$]"

##### 可在脚本开始运行时调用，打印当时的时间戳及PID。
function job_start
{
    echo "`eval $NOW` job_start"
}

##### 可在脚本执行成功的逻辑分支处调用，打印当时的时间戳及PID。 
function job_success
{
    MSG="$*"
    echo "`eval $NOW` job_success:[$MSG]"
    exit 0
}

##### 可在脚本执行失败的逻辑分支处调用，打印当时的时间戳及PID。
function job_fail
{
    MSG="$*"
    echo "`eval $NOW` job_fail:[$MSG]"
    exit 1
}

job_start
# 写脚本
```