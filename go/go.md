[toc]

## Go速查

 [pkg.go.dev](https://pkg.go.dev/)

 [gonote-pic](https://note.youdao.com/s/BBDiOQkC)

### 起源

- 2007年开始，2009年11月官方发布。
- Google开源，由Robert Griesemer，Rob Pike 和Ken Thompson开发。

### 环境

- 下载golang安装包 [https://gomirrors.org/](https://gomirrors.org/)

  - windows
  
     ```bash
     # 下载 
     https://studygolang.com/dl/golang/go1.14.4.windows-amd64.zip
     # 解压路径
     D:\Program Files (x86)\
     # 添加windows变量
     桌面 -> 我的电脑(右击) -> 属性 -> 高级系统设置 -> 环境变量 -> 用户变量 -> 新建：
       GOROOT D:\Program Files (x86)\go
       GOPATH D:\gohome
       GO111MODULE on
       GOPROXY https://mirrors.aliyun.com/goproxy/
     # 编辑Path变量
     Path变量编辑 -> 新建：
     %GOROOT%\bin
     %GOPATH%\bin
     # 命令查看验证
     win+R -> cmd -> go version
     ```
  - mac
    ```bash
    # 下载
    wget https://studygolang.com/dl/golang/go1.14.4.darwin-amd64.tar.gz
    tar xf go1.14.4.darwin-amd64.tar.gz -C /usr/local
    mkdir -p /data/go/src
    # 配置
    # root用户
    cp /etc/profile /home
    echo 'export GOROOT=/usr/local/go' >> /etc/profile
    echo 'export GOPATH=/data/go' >> /etc/profile
    echo 'export GO111MODULE=on' >> /etc/profile
    echo 'export GOPROXY=https://mirrors.aliyun.com/goproxy/' >> /etc/profile
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile
    source /etc/profile
    # 普通用户
    cp ~/.bash_profile /home
    echo 'export GOROOT=/usr/local/go' >> ~/.bash_profile
    echo 'export GOPATH=/data/go' >> ~/.bash_profile
    echo 'export GO111MODULE=on' >> ~/.bash_profile
    echo 'export GOPROXY=https://mirrors.aliyun.com/goproxy/' >> ~/.bash_profile
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.bash_profile
    echo 'Source ~/.bash_profile' >  ~/.zshrc
    source ~/.zshrc
    # 验证
    go env
    ```

  - linux
    
    ```bash
    wget https://studygolang.com/dl/golang/go1.14.4.linux-amd64.tar.gz
    tar xf go1.14.4.linux-amd64.tar.gz -C /usr/local
    mkdir -p /opt/go/src
    cp /etc/profile /home
    echo 'export GOROOT=/usr/local/go' >> /etc/profile
    echo 'export GOPATH=/opt/go' >> /etc/profile
    echo 'export GOPROXY=https://mirrors.aliyun.com/goproxy/' >> /etc/profile
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile
    source /etc/profile
    go env
    ```
- 下载vscode编辑器 [https://code.visualstudio.com/Download](https://code.visualstudio.com/Download)

  - 安装golang插件并配置

    ```bash
    # 安装
    快捷键 F1或ctrl+shift+p ——> 输入命令 Extensions:Install Extension ——> 插件管理搜索go后安装

    # 配置
    菜单 — Preferences — User - Extensions - Go - Edit in settings.json
    # windows环境 用户空间  user/settings.json
    {
        "go.goroot": "/usr/local/go",
        "go.gopath": "/data/go",
        "go.buildOnSave": "package",
        "go.lintOnSave": "package",
        "go.formatTool": "goimports",      
        "go.gocodeAutoBuild": false,
        "go.useGoProxyToCheckForToolUpdates":true 
    }
    # 工作空间 F5进行调试，调试配置 .vscode/launch.json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "type": "go",
                "request": "launch",
                "mode": "auto",
                "stopOnEntry": false,
                "program": "${fileDirname}",
                "env": {},
                "args": []
            }
        ]
    }
    ```

  - 安装go的工具 [https://github.com/golang](https://github.com/golang)

    ```bash
    # vscode会提示下载安装，会出现安装失败的
    
    # 直接手动下载安装
    go get -u -v  github.com/mdempsky/gocode 
    go get -u -v  github.com/uudashr/gopkgs/cmd/gopkgs 
    go get -u -v  github.com/ramya-rao-a/go-outline  
    go get -u -v  github.com/acroca/go-symbols  
    go get -u -v  github.com/go-delve/delve/cmd/dlv  
    go get -u -v  github.com/rogpeppe/godef
    go get -u -v  github.com/sqs/goreturns  
    go get -u -v  github.com/cweill/gotests
    go get -u -v  github.com/godoctor/godoctor
    
    # 被墙的，先在下载再安装。也可以设置代理解决
    mkdir -p $GOPATH/src/golang.org/x
    cd $GOPATH/src/golang.org/x
    git clone https://github.com/golang/tools.git tools
    git clone https://github.com/golang/lint.git lint
    git clone https://github.com/golang/net.git net
    
    go install golang.org/x/tools/cmd/guru
    go install golang.org/x/tools/cmd/gorename
    go install golang.org/x/lint/golint
    go install golang.org/x/net/gonet
    ```

### 优点

- 上手快，入门简单，学习成本低
- 原生并发

### 特点

- 静态型编译，打包二进制后即可运行
- goroutine协程，一个线程可执行多个goroutine，由go的逻辑处理器调度，资源占用少可高并发
- channel通道，不要通过共享内存来通信，而应该通过通信来共享内存
- 函数是一等公民
- 组合结构体，实现代码复用，不同结构体之间的合作
- 接口，实现接口的所有方法则实现了接口本身

### 风格

- 变量名：首字符大写
- 常量名：大写字母
- 包名：小写单词，不用下划线或驼峰记法
- 文件名：小写，可加下划线分割
- 结构体名：驼峰法
- 接口名：只包含一个方法的接口的名称加上-er后缀Reader
- 驼峰记法：驼峰记法 MixedCaps 或 mixedCaps
- 左括号：不应将一个控制结构（if、for、switch 或 select）的左大括号放在下一行

### 数据类型

- 值类型：基础数据类型、数组、结构体
- 引用类型：切片、字典、通道、函数、接口 （默认`nil`）
- 值传递：传递副本，会创建新值
- 指针传递：传递地址，共享数据

**基本类型**

```go
// 类型及零值
bool  // false
string  // ""
int  int8  int16  int32  int64  // 0 
uint uint8 uint16 uint32 uint64 uintptr  // 0
float32 float64  // 0
byte  // uint8的别名
rune  // int32的别名，表示一个Unicode码点
complex64 complex128 

var x int  // 变量声明初始化为零值，可以出现在包或函数级别
var x = 1 // 变量声明并初始化
var (  // 声明
	x int
  y string
)
x := 1  // 短变量声明，仅在函数内使用
const PI = 3.14  // 常量
```

- 枚举

```go
// iota: 常量计数器,只能在常量的表达式中使用
type ByteSize float64

const (   
    _           = iota  // 0
  	KB ByteSize = 1 << (10 * iota)  // 1<<(10*1) 2^10=1024B
    MB  // 1<<(10*2)  2^10*2^10=1024*1024B
    GB  // 1<<(10*3)  2^10*2^10*2^10=1024*1024*1024B
    TB
    PB
    EB
    ZB
    YB
)
```

**复合类型**

- 数组

| [0]       | [1]       | [2]       | [3]       | [4]       |
| --------- | --------- | --------- | --------- | --------- |
| 数值/地址 | 数值/地址 | 数值/地址 | 数值/地址 | 数值/地址 |

```go
// 数组：相同的类型的连续存储的集合数据，长度是类型的一部分
var array [3]int  // 声明，初始化为类型的零值
var array [3]int = [3]int{1,2,3} 
var array = [3]int{1,2,3}      

array := [3]int{1,2,3} 
array := [...]int{1,2,3,4}  // ...代替数组长度，根据初始化元素个数确认数组长度
array := [2]*string{"hello","world"}  // 指向字符串的地址
*array[0] = "hi"

multiArr := [2][2]int{ {1,2}, {3,4}} 
multiArr := [4][2]int{ 1:{1,2}, 3:{3,4}}  // 初始化1和3索引的元素
multiArr[0][0] = 10
```

```go
// 性能: 函数间传递数组是很大开销，数组以值传递，不管多长都会被完整复制传递。
func foo(arr [le6]int){}
arr := [le6]int
foo(arr)  // 100万int类型元素，64位架构需要800万字节，8MB内存，每次函数foo调用，必须在栈上分配8MB的内存
foo(&arr) // 指针传递，只需要分配8字节，有效利用内存性能好，注意共享内存可能改变指针指向的值
```

- 切片slice

`初始化切片 p := make([]int,3,5)`

| 地址指针     | 长度/已用容量 | 实际容量 |
| ------------ | ------------- | -------- |
| 指向底层数组 | 3             | 5        |

`nil切片  var p []int 或者 p:=new([]int) 此时*p不能使用 `

| nil指针 | 长度 | 容量 |
| ------- | ---- | ---- |
|         | 0    | 0    |

`空切片  p:=make([]int,0) 或者 p:=[]int{} 此时*p能使用 `

| 地址指针     | 长度 | 容量 |
| ------------ | ---- | ---- |
| 指向底层数组 | 0    | 0    |

```go
// 切片：底层是数组，指向数组的指针、已用容量、实际容量。
var a []int  // 零值nil，底层没有数组
var a []int = []int{1,2,3}  // 声明且初始化
a := []int{1,2,3,4,5}
a := []int{99:0}  // 使用索引初始化第100个元素

// make(type,len,cap)
a := make([]int,3)  // 初始化、长度、容量
fmt.Println(a, len(a), cap(a))  // [0 0 0] 3 3
a := make([]int,3,5)  // 初始化地址、长度、容量
fmt.Println(len(a),cap(a),a)  // [0 0 0] 3 5

b := a[1:3]  // 左闭右开，包含左边数不包含右边。 len=high-low，cap=cap-1
fmt.Println(b, len(b), cap(b))  // [0 0] 2 4
c := a[1:3:4] // 开始:结束:容量  len=end-start，cap=cap-1
fmt.Println(c, len(c), cap(c))  // [0 0] 2 3

a := []int{1, 2}
b := []int{3, 4, 5}
copy(a, b)        // 按照其中较小的那个数组切片的元素个数进行复制
fmt.Println(a, b) // [3 4] [3 4 5]

a = append(a,b...)  // 展开b的参数列表，append是可变参数函数
append([]byte("hi,"),"me"...)  // 将字符追加到字节数组
```

```go
// 动态容量
// 当存储超过底层容量，append会先创建新底层数组，容量翻倍；
// 一旦容量超过多少，则会以某个增长因子1.25增加容量，在把旧的底层数组复制到新的底层数组。

// 切片复制后修改数据是否安全？
// 切片后如果append增加复制切片的长度，使得底层为新数组，修改则安全，取决于底层数组是否共享。

// 性能：函数件传递切片以值的方式传递高效
s1 := make([]int, le6)
func foo(s []int)[]int{}
foo(s1)  // 64位架构机器上，一个切片需24字节内存。指针、长度、内存各8字节

// new & make
// new 用来分配内存，不会初始化内存，只会将内存置零，并返回类型为 *T 的指针
// make 只用于创建切片、映射和信道，并返回类型为 T（而非 *T）的一个已初始化 （而非置零）的值

var p *[]int = new([]int)  // 分配切片结构；*p == nil；基本没用
var v  []int = make([]int, 100)  // 切片 v 现在引用了一个具有 100 个 int 元素的新数组

var p *[]int = new([]int)
*p = make([]int, 100, 100)

v := make([]int, 100)  // 习惯用法
```

[Go切片：用法和本质](https://blog.go-zh.org/go-slices-usage-and-internals)

- 映射map

```go
// 映射：key/value键值对的无序集合，遍历无序因为使用了散列表

var m map[string]string  // 声明，零值nil，无内存空间，操作将painc
m = make(map[string]string)  // 初始化
m1 := map[string]string{"a":"a", "b":"b"}

len(m1)  // 长度
delete(m1,'a')  // 删除
v，ok := m1['a']   // 判断是否存在，key不在则elem为类型零值

type A struct { X int,Y int }
m := map[string]A{ "X":A{1,2} , "Y":{3,4} } // key必须包含，vlaue可以省略类型
```

```go
// 数据结构
map存储数据的两个数据结构：
第一个是一个数组。存储用于选择桶的散列键的高八位值，用与区分每个键值对要存到哪个桶
第二个是一个字节数组。用于存储键值对。先依次存储桶内所有键，在依次存储所有值

// Key有约束，Value没有约束
因为键通过hash算法后存储hash值，故键类型的值必须支持判等操作
键类型不能是函数类型、字典类型、切片类型、接口

// 适合做key的类型条件
求哈希和判等操作的速度越快，对应的类型适合做键类型
求哈希，类型宽度越小速度越快，如bool、int、float、指针。对于string类型，宽度与值的长度有关，故最好对值的长度做限制
不建议高级数据类型作为字典的键类型，不仅因为对其值求哈希和判等速度慢，还因为其值存在变数。比如：对数组所有值求hash进行合并，当删除一个元素后表示为不同hash值

// 哈希的好处
是考虑时间和空间的一种折中处理方式

// map复制不安全 
在函数间传递映射不会复制副本，因此map是不安全的，需要加锁
```

- 指针

```go
// 指针保存了值的内存地址, 即 “间接引用”或“重定向”, go无指针运算。
var p *int  // p是指向int类型的指针，零值nil
i := 1
p = &i  // &取地址操作符，指向int类型的指针
*p = 2 // *取值操作符 
```

- 潜在类型

```go
type Mystr = string  // 别名，为重构而存在

type mystr string  // 潜在类型，不能判等或赋值
var a mystr
var b string = "aaa"

// 类型转换 x = T(v) 
a = mystr(b)  // 基础类型->潜在类型
c := string(a)
```

- 结构体

```go
// 结构体：多种类型和方法集合
// 类：多种类型的属性和方法集合。继承（代码复用）、封装（抽象）、多态（灵活），Go没有类
type A struct{  A int }
type B struct {
 B int
 A  // 组合
}

var a A  // 零值为各个类型的零值
var a A = A{1}  // 初始化
a := A{1}           
a := &A{1}  // 指针

b := []struct{ b1 int,b2 bool }{ {1, true},{2, false} }  // 匿名结构体
struct{}  // 空结构体 不占内存（可用在channel传递信号节约内存）；无属性有方法；任何两个空结构体相同
```

### 运算

**四则运算**

```go
fmt.Println(1 + 1)
fmt.Println(1 - 1)
fmt.Println(1 * 1)
fmt.Println(1 / 1)
a := 1
a++
fmt.Println(a)
```

**位运算**

```go
// 1MB = 1024KB = 1024*1024Byte  1MB=2^10KB=2^20Byte 
// 左移： 右边空缺位补0
var oneMB = 1 << 10  // 1*2^10
fmt.Println(oneMB)  // 1024

// 右移： 左边空缺位补
var oneMB = 1024 >> 10  // 1024/2^10	
fmt.Println(oneMB)  // 1
```

### 流程控制

**条件**

- if

```go
// if
if 条件判断 {
} 

// else
if 初始化语句; 条件判断 {
} else 	{
}

// else if
x := 10
if a := "number:"; x > 0 {
	fmt.Println(a, x)
} else if x == 0 {
	fmt.Println(a, x)
} else {
	fmt.Println(a, x)
}  // number: 10
```

- swith

```go
// 顺序：自上到下，匹配终止
switch 原始 {  // 原始：可以是数值、表达式
 case 目标:  // 每个case后默认break
 	 操作
 		fallthrough  // 后面紧接的case语句无论是否匹配都会被执行
 case 目标:
 		操作
 default:  // 所有case没有选中被执行
 		操作
}

// 例子：输出1 2
x := 1
switch x {
case 1:
	fmt.Println(1)  // 1
	fallthrough
case 2:
	fmt.Println(2)  // 2
default:
	fmt.Println(x)
}

// 类型switch
var i interface{}
i := 1
switch v := i.(type) {
case int:
	fmt.Println(v, i.(int)) // 接口到类型
case float64:
	fmt.Println(v, i.(float64))
case string:
	fmt.Println(v, i.(string))
default:
	fmt.Printf("unkown")
}

// switch等价于switch true
switch { 
}
```

- select

```go
// select 监听通信，用于处理异步操作
// 每个case都是通信channel操作
// 多个case可以运行select会随机选择一个执行，其他不执行
// 否则如果有default则执行，没有default则阻塞直到某个case可执行
select {
  case communication clause :   // 每个case都是通信
     statement(s);      
  case communication clause :
     statement(s);
  default :
     statement(s);
}

// 超时判断 
func main(){
	var ch1 = make(chan int)
	go func() {
		time.Sleep(10 * time.Second)
		ch1 <- 1
	}()
	
	select {
	case data := <-ch1:
		fmt.Println(data)
	case <-time.After(time.Second * 3):
		fmt.Println("timeout")  // timeout
	}  
}

// 判断channel是否阻塞
func main(){
	var ch = make(chan int, 3)
	data := 1
	for {
		select {
		case ch <- data:  // channel没有接收者，所以溢出
		default:
			fmt.Println("channel overflow")  // 根据channel满了做相应操作
			return
		}
	}  
}

// 优雅退出
func mian(){
  ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)
	go waitSign(ch)
	time.Sleep(10 * time.Second)
}

func waitSign(sign chan os.Signal) {
	for {
		select {
		case sg := <-sign:
			switch sg {
			case syscall.SIGHUP:
				fmt.Println("1 hup")
			case syscall.SIGINT:
				fmt.Println("2 ctrl+c")
			case syscall.SIGTERM:
				fmt.Println("15 kill pid")
			default:
				fmt.Println("nothing")
			}
		}
	}
}
```

**循环**

- for

```go
// 初始化语句：第一次迭代前执行；条件表达式：每次迭代前求值；后置语句： 每次迭代的结尾执行  
for 初始化语句; 条件表达式; 后置语句 {
}
 
// 类似while循环
sum := 1
for sum < 10 {
	sum += sum
  if sum == 3 {
		return  // 跳出函数
	}
}

// 无限循环
x := 0
for {
	x++
	if x == 3 {
		continue  // 直接开始下一个循环，后面不执行
	}
	if x == 5 {
		break  // 跳出循环
	}
	fmt.Printf("%v", x)  // 124
}

// 遍历
for _ , v := range 切片|映射|字符串 {
}

// 监听channel
for i := range ch { 
}  

// 循环goto

```

### 函数

- init函数

```go
// 执行顺序
每个文件可包含任意个init()函数，文件内按顺序执行
init()函数在main()函数之前执行
导入包的init()先与main包中init()执行

// 初始化顺序
1. 导入包的顺序初始化常量、变量、init函数、main函数
2. init的goroutine只有在进入main函数之后才可能被执行
3. 其他函数内的goroutine也是进入main函数之后可能被执行
```

- 函数

```go
// 函数：完成某一功能的代码块
func hi() {
	fmt.Println("say hi")
}

// 固定参数，值传递，引用传递
func Add(a int, b *int) int {
	return a + *b
}
a, b := 1, 2
fmt.Println(Add(a, &b))  // 3

// 可变参数
func add(a int, b *int, args ...int) int {
	sum := a + *b
	for _, i := range args {
		sum += i
	}
	return sum
}
a, b := 1, 2
c := []int{3, 4, 5}
fmt.Println(add(a, &b, c...))  // 15

// 函数参数，实现回调
func callback(a, b int, fn func(a, b int) int) (ret int) {
	return fn(a, b)
}
a, b := 1, 2
ret := callback(a, b, func(a, b int) int {
	return a + b
})
fmt.Println(ret) // 3

// 多值返回，隐式返回
func echo(a, b int) (x int, y int) {
	x, y = a, b
	return
}
a, b := 1, 2
fmt.Println(echo(a, b)) // 1,2

// 函数返回
func add(a, b int) func(c int) int {
	return func(c int) int {
		return a + b + c
	}
}
a, b := 1, 2
f := add(a, b)
fmt.Println(f(3))  // 6

// 匿名函数
fn := func(a, b int) int {
		return a + b
}
fmt.Println(fn(1, 2))
```

- 闭包

```go
// 闭包：函数嵌套函数，内部函数可用外部函数的变量，扩大了外部函数作用
func add() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}
f := add()
fmt.Println(f(3)) // 3
fmt.Println(f(4))  // 7

// 闭包与面向对象： 都是函数（过程）与数据结合
// 函数每次被执行时，局部变量sum都会被引用和更新，也就是函数过程和数据结合起来。
// 面向对象是在数据中以方法的形式包含了过程，闭包则是在过程中以环境的形式内含了数据。
```

- defer

```go
// defer 在函数返回时执行，实现数据结构栈，后进先出
// 函数panic后defer仍然会执行
func main() {
 	 defer fmt.Println("world")
	 fmt.Println("hello")
} // hello world
```

- panic & recover

```go
// panic过程：引发后一级一级沿着调用栈传播到main函数，最后Go运行时系统回收，程序终止
// recover：捕获运行时panic
// 默认recover()函数值为nil
// 父级别函数不能recover的子goroutine的painc，要在当前函数中用defer函数来捕获panic

// panic后defer可执行
func hi(){
   defer func(){
       if p := recover(); p != nil {
            fmt.Printf("panic: %s\n", p)
        }
    }()
  // fmt.Printf("no panic: %v\n", recover())  // 错误用法
  panic(errors.New("something wrong"))
}

// 父级recover不能捕获子级painc，可用defer解决
func main(){
	ch := make(chan bool)
	go func(ch chan bool) {
		defer func() {
			fmt.Println("goroutine defer say bye")
			ch <- true
			// if p := recover(); p != nil {
			// 	fmt.Printf("goroutine recover %s\n", p)
			// }
		}()
		fmt.Println("goroutine say hi")
		panic("goroutine painc")
	}(ch)

	defer func() {
		fmt.Println("main defer say bye")
		if p := recover(); p != nil {
			fmt.Printf("main recover %s\n", p)  // 不能捕获子goroutine的painc
		}
	}()
	fmt.Println("main say hi")
	select {
	case c := <-ch:
		fmt.Printf("main get goroutine channel %v\n", c)
	}
}

/*
main say hi
goroutine say hi
goroutine defer say bye
main get goroutine channel true
main defer say bye
panic: goroutine painc

goroutine 6 [running]:
xxx
*/
```

 [defer-panic-recover](https://blog.go-zh.org/defer-panic-and-recover)

- 异常处理

```go
if err != nil {
  fmt.Println(err.Error()
}
```

### 方法

```go
// 方法: 带接收者的函数
func（接收者）方法名(参数) 返回值 {
  主体
}

type A struct {
	num int
}

// 接收者为值类型
func (a A) Get() int {
	return a.num
}

// 接收者为指针类型
func (a *A) Add() int {
	return a.num + 1
}

// 私有方法，包内使用
func(a A)get() int {
  return a.num
}

// 方法是使用值接收者还是指针接收者？
// 根据基于该类型的本质。本质是值的，值接收。本质是非值的，指针接收
type B []int
// 指针接收者
func (b B)Get()[]int{
 	return b
}
```

- 组合

```go
// 组合：Go只有组合没有继承，组合会出现屏蔽现象。代码复用
type A struct {
  aa string  // 私有变量，结构体内使用
	AA int
}

type B struct {
	BB string
  DD int
}

type C struct {
  CC []int
}

type D struct {
  A  // 匿名嵌套，可直接使用AA
  DB B  // 有名嵌套，使用必须B.BB
	DC  // 匿名嵌套，CC为引用类型需初始化
  DD int  // B中存在DD，但是优先是用自身的属性
}

d := D{}
fmt.Println(d.AA)
fmt.Println(d.B.BB)
d.CC = make([]int,3)
fmt.Println(d.CC)
```

### 接口

```go
// 接口: 一系列方法声明的集合，定义方法的类型，有方法的声明，没有方法的实现
// 功能：类似多态，根据不同对象采取不同行为
// 隐式实现：任何数据类型实现接口的所有方法则实现接口，无侵入式，解耦
// 接口组合，不存在"屏蔽"现象，组合接口名称相同直接冲突
// 数据结构：名为接口值。两个字长度。一个执行内部表指针iTable，一个执行存储值的指针 

type A interface {
	   Abs() float64
}

type MyFloat float64
func (f MyFloat) Abs() float64 {  // 实现接口的方法则实现了接口
   if f < 0 {
      return float64(-f)
	 }
   return float64(f)
}  
var a A  // 零值nil，接口值既不保存值也不保存具体类型 
a = MyFloat(-10)  // 接口实例化，iTable指向MyFloat对象，值指针指向存储的值
fmt.Println(a.Abs())  // 10

// 空接口，零个方法，可保存任何类型。可用来处理未知类型的值
interface{}  
var ret interface{}
m := []int{1, 2, 3}
ret = m
fmt.Println(ret)
```

### 并发

- 协程goroutine

```go
// 协程：用户空间运行，号称轻量级别线程
// 幂等性f(f(x)) = f(x)：任意多次执行所产生的影响与一次执行的影响相同

// 竞争：
// go vet main.go 代码静态检测，如无法访问的代码、错误的锁使用、不必要的赋值、布尔运算错误等
func main(){
  runtime.GOMAXPROCS(1)  // 设置cpu的核数
  
  for i := 0; i < 10; i++ {
		go func() {
			fmt.Println(i) // 可能都打印10、随机乱序打印0-10的数字
		}()
	}
	time.Sleep(1 * time.Second)
}

// 改进
func main(){
  for i := 0; i < 10; i++ {
		go func(n int) {
			fmt.Println(n) // 乱序打印0～9
		}(i)
	}
	time.Sleep(1 * time.Second)
}

// 由channel控制并发
func main() {
    ch := make(chan struct{})
    go func() {
        fmt.Println("start working")
        time.Sleep(time.Second * 1)
        ch <- struct{}{}
    }()
    <-ch
    fmt.Println("finished")
}

// 由sync.WaitGroup控制并发
func main(){
  var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(n int) {
			fmt.Println(n)
			wg.Done()
		}(i)
	}
	wg.Wait()  // 等待goroutine结束
}

// Go1.7开始支持由context控制并发
// 用来处理多个 goroutine 之间共享数据，及多个 goroutine 的管理
func main(){
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		time.Sleep(3 * time.Second)
		cancel()
	}()
	printC1(ctx)
}

func printC1(ctx context.Context) {
	select {
	case <-ctx.Done():
		fmt.Printf("printC1 ctx.Done. value: %v\n", v)
	}
}


```

- 通道channel

  不要通过共享内存来通信，而应该通过通信来共享内存

```go
// channel：通道用于线程见通信，发送和接收操作在准备好之前都会阻塞
// 重复关闭channel会panic，向关闭channel发送数据会panic
// 带有类型的管道，操作符为 <-
// 通道本身是引用，所有都是浅拷贝，副本
var ch chan int  // 声明初始化为nil
var ch1 = make(<-chan int,1) //只能收
close(ch)  // 关闭通道
v, ok := <- ch // 判断channel是否关闭，ok为false则关闭

// 无缓冲死锁：fatal error: all goroutines are asleep - deadlock!
func main(){
	ch := make(chan int)
  ch <- 1
  fmt.Println(<-ch)
}

// 解决1：增加一个缓冲
func main(){
	ch := make(chan int, 1)
  ch <- 1
  fmt.Println(<-ch)
}

// 解决2: 增加一个goroutine
func main(){
	ch := make(chan int)
	go func(i chan int) {
			fmt.Println(<-i) // 接收者，先准备
		}(ch)
		ch <- 1 // 发送者，后发送
}

// 带缓冲channel，缓冲填满，发送方才会阻塞；缓冲为空，接收方才会阻塞
func main(){
  ch := make(chan int, 10)
  defer func(){ 
    close(ch)  // 退出关闭通道
  }()
	
  for i := 0; i < 10; i++ {
		go func(n int) {
			ch <- n
		}(i)
	}

	// fatal error: all goroutines are asleep - deadlock!
	// 因channel不会有数据写入，for一直阻塞，所以死锁
	for v := range ch {
		fmt.Println(v)
	}
  
  // 可用下面方式解决死锁
  for i := 0; i < 10; i++ {
		fmt.Println(<-ch)	 // 打印退出
	}
}

// 计数信号量
var sema = make(chan struct{}{},20)
func A(){
  	defer func(){  // 退出释放
      <- sema 
    }()   
  
    sema <- struct{}{}  // 申请使用
}
```

### 反射

```go
// 反射：根据runtime确定数据类型和值，结合interface接口实现
// 静态类型编码时确定的，动态类型系统runtime运行时确定

// Typeof & Valueof
func play(num interface{}) {
	numType := reflect.TypeOf(num)
	numValue := reflect.ValueOf(num)
	fmt.Println(numType, numValue)
}

func main(){
	n1 := 1
	play(n1)  // int 1
	n2 := 1.1
	play(n2)  // float64 1.1
}

// 已知类型强制转换：转换类型一定要完全符合，否则panic
func main(){
  var n float32 = 1.1

	rv1 := reflect.ValueOf(&n)
	rv2 := reflect.ValueOf(n)
	
	cv1 := rv1.Interface().(*float32)
  // cv1 := rv1.Interface().(float32) 引发panic
	cv2 := rv2.Interface().(float32)
	fmt.Println(cv1, cv2)  // 0xc00010c004 1.1
}

// 未知类型：遍历filed获取字段，遍历method获取方法
type A struct {
	AA int
	BB string
}

func (a A) Get() {
	fmt.Println(a.AA)
}

func parse(n interface{}) {
	rt := reflect.TypeOf(n)
	rv := reflect.ValueOf(n)

	for i := 0; i < rt.NumField(); i++ {
		k := rt.Field(i)
		v := rv.Field(i).Interface()
		fmt.Println("reflect field:", k.Name, k.Type, v)
	}

	for i := 0; i < rt.NumMethod(); i++ {
		m := rt.Method(i)
		fmt.Println("reflect method:", m.Name, m.Type)
	}
}

func main(){
  a := A{}
	parse(a)  
}
reflect field: AA int 0
reflect field: BB string 
reflect method: Get func(main.A)

// 指针类型可反射时重新设置值
func main(){
  var a int = 1
	rv := reflect.ValueOf(&a)
	nv := rv.Elem()
	if nv.CanSet() {
		nv.SetInt(2)
	}
	fmt.Println(a)  // 2
}

// 性能慢分析：涉及到内存分配以及后续的GC；reflect实现里面有大量的枚举，也就是for循环，比如类型之类的。
```

### 包

```go
// 包：同一目录下只存在一个包，能够实现代码复用及数据隔离
// 命名：一般与目录名相同，可以不同，不同时导入的是目录，使用时用包名
package 包名

// 导入，本质告诉编译器去磁盘哪里找包
// 顺序： $GOPATH/pkg/mod（有mod依赖管理时） -> $GOROOT/src -> $GOPATH/src
import (
	包名目录  
  别名 包名目录  // 包名相同时可以重命名
  // 不能导入未使用的包，避免得到塞满未使用库的大执行文件
  _ 包名  // 导入不直接使用的包，用做初始化，包内的init函数会在main前执行
)   

// 权限
var a int  // 包级私有
var A int  // 包级公开，首字母大写，其他包可以导入
// 模块级私有，internal目录内internal包，只能父目录和子目录使用公开的方法
```

- 包依赖管理

```go
// 依赖解决方案：godep；vendor；glide；govendor；gomod
// 介绍：go mod
// Go1.11版本开始支持，替换对GOPATH的依赖，不必在$GOPATH/src下创建，包含go.mod的目录都可以
export GO111MODULE=on|off|auto  // 是否启用Go Modules功能

go mod init 项目名  // 初始化go.mod
go mod vendor  // 当前目录下生产vendor
go mod tidy -v  // 添加必要模块移除不必要模块
go mod download  // 下载依赖到本地缓存GOCACHE
```

```go
module app
// require
require (
  golang.org/x/text v0.3.0
  gopkg.in/yaml.v2  v2.1.0
)

exclude (
	old/thing v1.2.3
)

replace (
    gopkg.in/asn1-ber.v1 v1.4.1 => github.com/go-asn1-ber/asn1-ber v1.4.1
  	google.golang.org/appengine v1.3.0 => github.com/golang/appengine v1.3.0 
)
```
### 测试

- 功能测试

```go
// 文件名: xxx_test.go
// 函数名(必须驼峰): TestXxx(t *testing.T)
func TestXxx(t *testing.T) { 
  t.log()        // 打印测试日志，只有失败打印
  t.Logf()
  
  t.Error()     // 打印失败测试日志
  t.Errorf()
}

// 例子 
// play.go
func play(flag bool) (string, error) {
	if !flag {
		return "", fmt.Errorf("error say %v", flag)
	}
	return fmt.Sprintln("play say hi"), nil
}

// play_test.go  go test -run TestPlay
func TestPlay(t *testing.T) {
  flag := true  // true则函数正常返回，false返回报错内容
  str, err := play(flase)
	if err != nil {
		t.Error(err) 
	} else {
		t.Log(conn, str)
	}
}

// TestMain 完成测试的初始化操作，测试前如打开连接，测试后做清理工作等
func TestMain(m *testing.M) {
	fmt.Println("test begin")
	conn = "hi"
	m.Run()
	fmt.Println("test end")
}

//  打印通过PASS
go test -run TestPlay
// 打印正常日志内容t.log
go test -run TestPlay -v 
// 禁止用缓存，加上-count
go test -run TestPlay -count=1 -v
/*
test begin
=== RUN   TestPlay
    main_test.go:17: hi play say hi
        
--- PASS: TestPlay (0.00s)
PASS
test end
ok      tmpl    0.001s
*/


// t.Run控制：顺序执行test case
func TestMainOrder(t *testing.T) {
	t.Run("TestPlay", TestPlay)
	t.Run("TestPlay", TestPlay)
}

// 若设置了缓存目录，则在测试代码没有任何变动时，go test命令直接打印缓存中测试成功的结果
// 清理缓存数据：go clean -cache
```

- 基准测试

```go
// 基准测试：进行并发的性能测试
// 文件名: xxx_test.go
// 函数名(必须驼峰): BenchmarkXxx
func BenchmarkXxx(B *testing.B){
	主体
}

// 
func stringSplice() string {
	var s string
	s += "hello"
	s += "world"
	return s
}

// go test -bench=. -benchmem
func BenchmarkStringSplice(b *testing.B) {
	for i := 0; i < b.N; i++ {
		stringSplice()
	}
}
/*
8核CPU每次执行耗时57.67ns，分配内存16字节，内存分配1次
goos: linux
goarch: amd64
pkg: tmpl
cpu: AMD EPYC 7K62 48-Core Processor
BenchmarkStringSplice-8         21111159                57.67 ns/op           16 B/op          1 allocs/op
PASS
*/


// 性能测试计时器：StartTimer、StopTimer、ResetTimer
//  停止计时间，准备工作后，开始继续计时
func BenchmarkStringSplice(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer() 
		sleep(10) // 准备工作，如生成随机数测试是否是素数
		b.StartTimer()
		stringSplice()
	}
}

// 忽略耗时的准备工作
func BenchmarkStringSplice(b *testing.B) {
	time.Sleep(5 * time.Second)  // 模拟准备的耗时工作
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		stringSplice()
	}
}

// 设置cpu数可以通过runtime.GOMAXPROCS
// 所有基准测试函数，分配4核，执行5次，并发1，压测时间2s，压测显示性能
go test -bench=. -cpu 4 -count=5 -parallel=1 -benchtime=2s -benchmem
// 生成内存分析文件，查看分析文件
go test -bench=. -benchmem -benchtime=3s -cpuprofile=profile.out
go tool pprof profile.out 

// 查看压测覆盖率
// 覆盖率测试将被测试的代码拷贝一份，在每个语句块中加入bool标识变量，测试结束后统计覆盖率并输出成out文件，因此性能上会有一定的影响
go test -bench=. -benchmem -benchtime=3s -coverprofile=cover.out
go tool cover -html=cover.out  // 查看html的测试覆盖报告
/* 
goos: linux
goarch: amd64
pkg: tmpl
cpu: AMD EPYC 7K62 48-Core Processor
BenchmarkStringSplice-8         48780666                72.75 ns/op           24 B/op          2 allocs/op
PASS
coverage: 12.2% of statements
*/
```

- 示例测试

```go
// 文件名: xxx_test.go
// 函数名，参数没有强制规定：Examplexxx
func SayHello() {
	fmt.Println("hello")
	fmt.Println("world")
}

// go test -run=ExampleSayHello -v 
func ExampleSayHello() {
	SayHello()
	// OutPut:
	// hello
	// world
}
```


### 工具

```go
// 查看帮助
go help run|build|test...

// 运行
go run main.go

// 编译
go build -o yy xx.go  // 重命名
go build -x -gcflags="all=-N -l" xx.go  // 查看编译过程
// 设定变量指定编译平台
// export CGO_ENABLED=0;GOOS=linux;GOARCH=amd64

// 格式化
gofmt xx.go 
goimports // 自动格式化代码和解决依赖包

// 文档
go doc fmt Printf  // fmt包的Printf函数
go doc -src fmt Printf  // 含源码
godoc -http=:6060  // 在线文档
godoc -http=:6060 -play  // 在线文档

// 缓存
go env GOCACHE  // 查看缓存目录
go clean -cache  // 清理缓存

// 测试
go test -v
go test -cover  // 覆盖率
go test -run=.  // 正则匹配文件

// 环境变量
go env
export GOPROXY=https://goproxy.io  // 代理设置
export GO111MODULE=on|off|auto  // 是否启用Go Modules功能

// 代码静态检查
govet     

// 代码规范检查（注释、命名等）
golint    
```

```go
// 如何优雅写代码？ 尽量自动化一切能够自动化的步骤，让工程师审查真正重要的逻辑和设计
// 代码规范、目录结构、模块拆分、显示调用、面向接口、单元测试（TDD测试驱动开发）
├── LICENSE.md
├── Makefile
├── README.md
├── api            // api接口
├── assets
├── build
├── cmd            // main入口
├── configs
├── deployments
├── docs
├── examples
├── githooks
├── init
├── internal
├── pkg            // 可以被外部使用代码库
├── scripts
├── test
├── third_party
├── tools
├── vendor
├── web            // static站点
└── website//
```

### 资料

- 网站

[Go指南 tour.go-zh.org](https://tour.go-zh.org/list)

[Go例子 gobyexample.com](https://gobyexample.com/)

[Go实效编程-effective_go](https://go-zh.org/doc/effective_go.html)

[Go官网 pkg.go.dev](https://pkg.go.dev/)

[Go文档中文 go-zh.org](https://go-zh.org/doc)

[CodeReviewComments](https://github.com/golang/go/wiki/CodeReviewComments)

[Go代码风格](https://github.com/golang-standards/project-layout)

[go语言中文网 studygolang.com](https://studygolang.com/dl)

[代理-goproxy.io](https://goproxy.io/)

[命令-go-zh.org/cmd/go](https://go-zh.org/cmd/go/)

- 书籍

[Go实效编程](https://bingohuang.gitbooks.io/effective-go-zh-en/)

[Go语言圣经](https://docs.hacknode.org/gopl-zh/ch0/ch0-01.html)

[the-way-to-go中文](https://github.com/unknwon/the-way-to-go_ZH_CN/blob/master/eBook/directory.md)

- 博客

[如何写出优雅的golang代码](https://draveness.me/golang-101/)

[Go文档汇集](https://www.topgoer.com/)

[飞雪无情 www.flysnow.org](https://www.flysnow.org/)

[狼人 blog.wolfogre.com](https://blog.wolfogre.com)

[力扣-github.com/aQuaYi/LeetCode-in-Go](https://github.com/aQuaYi/LeetCode-in-Go)

[Go核心36讲-极客时间-郝林](https://account.geekbang.org/dashboard/buy)

- 框架&实用

[网站-gin](https://github.com/gin-gonic/gin)

[网站-beego](https://github.com/astaxie/beego)

[数据库-gorm](https://gorm.io/docs/query.html) 

[文档管理-gin-swagger](https://github.com/swaggo/gin-swagger)

[文档管理-redoc](https://github.com/Redocly/redoc)

[https://mholt.github.io/json-to-go/](https://mholt.github.io/json-to-go/)

Mock单元测试 [gomock](https://github.com/golang/mock) [sqlmock](https://github.com/DATA-DOG/go-sqlmock)  [httpmock](https://github.com/jarcoal/httpmock) [monkey](https://github.com/bouk/monkey)

- 项目

[beats社区](https://www.elastic.co/guide/en/beats/devguide/7.0/index.html)

[grafana](https://github.com/grafana/grafana/blob/master/pkg/login/ldap_login.go)