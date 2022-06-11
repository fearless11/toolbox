---
title: python3
date: 2022-06-01 13:00
tags: 编程语言
description: python动态编程解释型语言
toc: true
---

[toc]

# python

## 介绍

- 动态解释型语言
- 应用领域：爬虫、机器学习、运维开发

## 编程风格与规范

- 四个空格缩进、每行最多120个字符、表达式的赋值符号、操作符左右至少有一个空格
- 括号：tuple 元组不允许逗号结尾，显式增加括号规避，即使一个元素也加上括号
- 空行：一级函数与类之间两个空行，类中函数之间一个空行，源文件必须使用一个换行符，每个语句独占一行
- 编码：源文件编码统一使用UTF-8编码，头部增加 `# -*- coding: utf-8 -*-`
- Shebang：`#!/usr/bin/env python3`
- import：每个导入一行，导入总应该放在文件顶部，位于模块注释和文档字符串之后，模块全局变量和常量之前。导入应该按照从最通用到最不通用的顺序分组, 每个分组之间，需要空一行（标准-第三方-本地）
- 模块中的魔术变量(dunders)：对于两个 _ 开头和两个 _ 结尾的变量， 如 __all__，__author__，应该放在模块文档之后， 其他模块导入之前（__future__ 除外）
- 注释：注释的每一行都应该以#和一个空格开头，行内注释#与代码离开至少2个空格，TODO 注释需要加上名字 `# TODO(lisi): fix the bug`
- 文档字符串：第一行应为文档名，空一行后，输入文档描述。 `"""xxx blank desc blank :param: xxx\n"""`
- 类型提示： 模块级变量，类和实例变量以及局部变量的注释应在冒号后面有一个空格 `code: int = 10`
- 文件和sockets： 在文件和sockets结束时，显式的关闭它
- Main：所有的文件都应该可以被导入。 对不需要作为程序入口地方添加 `if __name__ == '__main__'`
- 命名：用单下划线_开头表示是protected的，用双下划线__开头表示类内私有或者代表不需要的变量，类名大些字母开头`AaaBbb`，模块名小写加下划线`aaa_bbb.py`
- None条件的判断： 为提升可读性，在判断条件中应使用 is not `if foo is not None:`
- lambda函数：使用 def 定义简短函数而不是使用 lambda。
工具：flake8、pylint、black、EditorConfig

### 环境准备

- 下载python安装包

  [https://www.python.org/downloads/](https://www.python.org/downloads/release/python-368)  
  [镜像源https://npm.taobao.org/mirrors/python](https://npm.taobao.org/mirrors/python/)

  - windows
  
    ```bash
    # 安装时勾选添加到环境变量，安装到    D:\Program Files (x86)\python
    https://www.python.org/ftp/python/3.8.    3/  python-3.8.3.exe
    
    # 或者手动添加环境变量
    桌面右击我的电脑 -> 属性 -> 高级系统设置 -> 环境变量 -> 用户变量 -> Path变量编辑 -> 新建
    D:\Program Files (x86)\python\Scripts\
    D:\Program Files (x86)\python\
    
    # 验证 
    win+R -> cmd —> python3
    ```
   - mac

      ```bash
      wget https://npm.taobao.org/mirrors/python/3.6.8/python-3.6.8-macosx10.6.pkg
      
      # 点击安装验证
      python3
      pip3

      # 安装django
      pip3 install django
      pip3 install django=x.x.x #版本
      ```
- 下载vscode编辑器 [https://code.visualstudio.com/Download](https://code.visualstudio.com/Download)

  - 安装python插件并配置

    ```bash
    # 插件
    快捷键F1或ctrl+shift+p ——> 输入命令 Extensions:Install Extension —> 插件管理搜索python安装启用

    # 配置工作空间 .vscode/settings.json
    # python部分 
    {
       "python.pythonPath": "/usr/local/bin/python3",
       "python.pipenvPath": "/usr/local/bin/pip3",
       "python.linting.flake8Enabled": true,
       "python.formatting.provider": "yapf",
       "python.linting.flake8Args": [
           "--max-line-length=248"
       ],
       "python.linting.pylintEnabled": false,
       "python.linting.enabled": true
    }   
    ```

  - 安装python工具
    
    ```bash
    # 检查安装好的第三方包
    pip3 list    
    # flake8检查编写代码不规范和语法错误
    pip3 install flake8  
    # yapf格式化工具
    pip3 install yapf    
    ```

[toc]

## python

### 资料

- [https://docs.python.org/3.6/tutorial/index.html](https://docs.python.org/3.6/tutorial/index.html)
- [https://www.python.org/downloads/release](https://www.python.org/downloads/release)

### 简介

- xxx发布python2，xxx发布python3
- python是动态类型（不用声明变量）、解释型(不用编译和链接)语言

### 风格

- 模块: 小写命名，尽量不要用下划线(除非多个单词，且数量不多的情况) `module_name.py`
- 类名: 驼峰(CamelCase)命名，首字母大写，私有类用一个下划线开头 `class ExamplePublic` `class _ExamplePrivate`
- 函数: 小写命名,用下划线隔开 `def example_func`
- 变量名: 小写命名,用下划线隔开 `var example_var`，私有变量前两个下划线，，全局变量前一个下划线
- 常量: 大写命名,下划线分隔的 `const EXAMP_CONST`
- 文件类型：源代码(.py) 、字节代码(.pyc)、优化代码 (.pyo python -o -m py_compile hello.py)
- 内部没有普通类型，任何类型都是对象 type(i)  id(i)

### 解释器

- 解释器：类似不同语言的翻译器，要解释程序先安装对应的解释器。 linux系统默认安装python2.7
- 编码：加载文件后用什么规则来识别解析文件内容。 python2默认用ASSCI编码， python3默认用UTF-8。
- 调用解释器的方式： 交互式、命令执行
- 在`xxx.py`文件第一行设置解释器路径： `#!/usr/local/bin/python3.5`
- 在文件第二行设置编码： `# -*- coding: utf-8 -*-` `# condig:utf-8` `# coding=utf-8`  代码中编码和解码 `str.decode('gbk').encode('utf-8')`

### 安装配置

- python2
```sh
# install
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
tar xf Python-2.7.13.tgz 
cd Python-2.7.13
./configure --prefix=/usr/local/
make && make install 

mv /usr/bin/python /usr/bin/pythonold 
ln -s /usr/local/python2.7/bin/python2.7 /usr/bin/python   

# 修改yum
# vim /usr/bin/yum
#!/usr/bin/pythonold

# 设置环境变量
# vim /etc/profile
PATH=$PATH:/usr/local/python2.7/bin/
export PATH

# source /etc/profile
python -v


# install setuptools
wget --no-check-certificate https://pypi.python.org/packages/1f/7a/6b239a65d452b04ad8068193ae313b386e6fc745b92cd4584fccebecebf0/setuptools-25.1.6.tar.gz
tar xf setuptools-25.1.6.tar.gz
cd setuptools-25.1.6
python setup.py install

# 问题: Ignoring ensurepip failure: pip 7.1.2 requires SSL/TLS
# 解决: yum install openssl-devel -y

# install pip-9.0
wget --no-check-certificate https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz#md5=35f01da33009719497f01a4ba69d63c9
tar xf pip-9.0.1.tar.gz
cd pip-9.0.1
python setup.py install
pip -V

# 安装依赖，指定多个源，忽略已安装情况
pip install tegmonitor==2.1.4 -i https://mirrors.abc.com/repository/pypi --extra-index-url https://mirrors.tencent.com/pypi/simple  --ignore-installed PyYAML
```

- python3

```sh
# install
wget https://www.python.org/ftp/python/3.6.11/Python-3.6.11.tgz
tar xf Python-3.6.11.tgz
./configure --prefix=/usr/local/python3.6 --enable-optimizations
make
make install
# check
/usr/local/python3.6/bin/python3 -V

# configure
echo -e 'PATH=$PATH:/usr/local/python3.6/bin\nexport PATH' >> /etc/profile
source /etc/profle
python3 -v

# install module
pip install mysql

# set code
#encoding=ututf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')
```

- vscode
```yaml
# 插件
# 快捷键F1或ctrl+shift+p —> 输入Extensions:Install Extension —> 插件管理搜索python安装启用

# 配置
# vim .vscode/settings.json
{
   "python.pythonPath": "/usr/local/bin/python3",
   "python.pipenvPath": "/usr/local/bin/pip3",
   "python.linting.flake8Enabled": true,
   "python.formatting.provider": "yapf",
   "python.linting.flake8Args": [
       "--max-line-length=248"
   ],
   "python.linting.pylintEnabled": false,
   "python.linting.enabled": true
}   

# 检查安装的第三方包
pip3 list    
# flake8检查编写代码不规范和语法错误
pip3 install flake8  
# yapf 格式化工具
pip3 install yapf  
# pylint 格式化工具
pip3 install pylint
```

#### help

```python
# 交互式查看模块信息 （有可能看到github的链接）
>>> from rediscluster import StrictRedisCluster
>>> help(StrictRedisCluster)

# 查看安装模块信息
# pip list | grep -i redis
# pip show redis-py-cluster 
Name: redis-py-cluster
Version: 1.3.0
Summary: Cluster library for redis 3.0.0 built on top of redis-py lib
Home-page: http://github.com/grokzen/redis-py-cluster
Author: Johan Andersson
Author-email: Grokzen@gmail.com
License: MIT
Location: /usr/lib/python2.7/site-packages/redis_py_cluster-1.3.0-py2.7.egg
Requires: redis
Required-by: 
```


### 数据类型

基本类型：`int float bool ...`

#### int

```python
# 数字 加减乘除
2 + 2  # 4
50 - 5*6  # 20
(50 - 5*6) / 4  # 5
17 / 3  # 5
17 % 3  # 2
5 ** 2  # 25
```

#### string

```python
# 字符串文本 单引号、双引号、三引号  元素不可变  
'apple'      
"banana"     
"""apple     
banana
orange"""  # 可换行

# 字符串表达式
str1 = 'apple'
str2 = "banana"

# 长度
len(str1) # 5

# 拼接 
str3 = ('apple' "banana")   
str3 = str1 + str2
str3 = str1 + 'orange'

# 索引
fruit = "apple"
fruit[0]   # a 从左到右
fruit[-1]  # e 从右到左
fruit[0] = 'b'  # 报错，字符串文本不可变

# 切片
fruit[:]   # apple
fruit[0:2] # app
fruit[:2]  # app
fruit[-2:]  # le

# 转义 \
word = 'hello\nword'  # hello world
```

#### list

```python
# 列表 中括号 元素可变可重复 
# 类似可变长度的数组
list1 = [1, 'a']
list2 = [[1, 2, 3], ['a', 'aa']]
list3 = list(range(3))  # [0, 1, 2]
list3 = [1, 2, 3, 4, 5]  # [1, 2, 3, 4, 5]

# 长度
len(list2)  # 2

# 拼接
list1 + ['b']  # [1, 'a', 'b']

# 索引
list1[0]  # 1
list1[1] = 'aa'  

# 切片
list3[2:4]  # [3, 4, 5]
list3[:] = []  # []

# 删除
del list1[1]
list1  # 'a'
del list1  # 删除整个变量

# 方法
list1.index('a')  # 1 所在位置
list1.sort()  # [1, 'a'] 顺序
list1.reverse()  # ['a',  1] 逆序 
list1.append('b')  # [1, 'a', 'b']
list1.extend(list3) #  [1, 'a', 'b', 1, 2, 3, 4, 5]
list1.insert(0,'c') # ['c', 1, 'a', 'b', 1, 2, 3, 4, 5]
list1.remove('c')  #  [1, 'a', 'b', 1, 2, 3, 4, 5]
list1.count(1)  # 2 出现次数
list1.pop(0)  #  ['a', 'b', 1, 2, 3, 4, 5]
list1.clear() # [] 清空 等价于 del list1[:] 
list1.copy()  

# 遍历二元列表
mylist=[["aa","vb"],["cc","ss"],["dd","ff"]]
for i in range(len(mylist)):
    print("mylist[%d]" %i ,":",end='')
	  for j in range(len(mylist[i])):
	    print(mylist[i][j],end=' ')
    print()

# 列表推导式
list4 = [x*2 for x in range(5)]  # [0, 2, 4, 6, 8]
# 等价于
list4 = []
for x in range(5):
  list4.append(x*2)

list5 = [(x, y) for x in [1,2] for y in [3,4] if x != y] # [(1, 3), (1, 4), (2, 3), (2, 4)]
# 等价于
list5 = []
for x in [1, 2]:
  for y in [3, 4]:
    if x != y:
      list5.append((x, y))
      
# 行列交换 zip函数
list6 = [[1, 2], [3, 4]]
list(zip(*list6))  # ([1, 3], [2, 4])
```

#### tuple

```python
# 元组  括号 元素不可变 
# 类似不可变长度的数组
tuple1 = ()  # ()
tuple2 = 123,  # (123,) 注意逗号
tuple3 = 1, 'a', 3  # (1, 'a', 3)
x, y, z = tuple3  # x = 1, y = 'a', z = 3 元组拆分，多重赋值

# 长度
len(tuple3)  # 3

# 索引
tuple3[0]  # 1
tuple3[0] = 2  # 报错，元组不可变

# 切片
tuple3[1:]  # ('a', 3)

# 遍历二元元组 
mytuple=(("aa",33),("bb",22),("lemon",))
for i in mytuple:
	for j in i:                
	    print (j)

# 元组推导式
tuple4 = ( x for x in range(1,5) )
tuple(tuple4)  # (1, 2, 3, 4) 
```

#### set

```python
# 集合 大括号/set() 元素无序不重复
set1 = set()  # set([]) 只能用函数创建空元素
set1 = {"apple"}  # set(['apple'])
set2 = set('abc')  # set(['a', 'b', 'c'])
set3 = set('bcd')  # set(['b', 'c', 'd'])

# 是否
'apple' in set1  # True
'orane' in set1  # False

# 差集
set2 - set3  # set(['a'])

# 交集
set2 & set3  # set(['b', 'c'])

# 联合
set2 | set3  # set(['a', 'b', 'c', 'd'])

# 对称差集
set2 ^ set3  # set(['a', 'd']) 在set2或set3

# 集合推导式
set4 = {x for x in 'apple' if x not in 'al'}  # {'p', 'p', 'e'}
```

#### dict

```python
# 无序字典 大括号 键值对key:value  要求key是不可变类型 
# python3.6后dict默认是有序的
dict1 = {}  # {}
dict2 = {'b':2, 'a':1 , 'c':3}  # {'b':2, 'a':1, 'c':3}
dict3 = dict(a=1, b=2, c=3)  # {'a':1, 'b':2, 'c':3}
dict4 = dict([('a',1), ('b',2), ('c',3)])  # {'a':1, 'b':2, 'c':3}

# 索引
dict3['a']  # 1
dict3['a'] = 5

# 方法
dict2.items()  # [('a',1), ('b',2), ('c',3)] 读取key-value
sorted(dict2.keys())  # ['a', 'b', 'c'] 对所有key排序
dict2.setdefault("f","efficiency") # 如果没设值value则默认为none
dict2.clear() # 清空dict

# 字典推导式
dict5 = {x:x*2 for x in [1, 2, 3]}  # {1:2, 2:4, 3:6}

# 遍历
fruit={"apple":"red", "banana":"yellow"}
for k, v in fruit.items():
  print k,v
  
# 浅拷贝(多配置一把钥匙)、深拷贝(重新造房间)
import copy
Adict={'a':"apply",'b':{'c':"city",'e':"efficiency"}}
Bdict=copy.copy(Adict)         #浅拷贝，也可以是Adict.copy()
Cdict=copy.deepcopy(Adict)     #深拷贝
Bdict['b']['c']="copy"         #修改Bdict，Adict里的字典值也会改变
print(Adict)
print(Bdict)
print()
Cdict['b']['e']="effctive"     #修改Cdict，Adict不改变
print(Adict)
print(Cdict)
```

#### OrdereDict

```python
# 有序字典   有序是指按照输入顺序，不是默认顺序或逆序
import collections

dict1 = collections.OrderedDict()
dict1['d'] = 1
dict1['c'] = 2
dict1['a'] = 3
dict1['b'] = 4

# 设置有序后按照输入顺序打印，否则打印结果可能不是按照输入顺序
for k,v in dict1.items():
     print k,v
    
# d 1
# c 2
# a 3
# b 4
```

### 流程控制

#### `in/is`

```python
# in 和 not in 比较值是否在一个区间之内
list1 = [1, 2, 3]  # [1, 2, 3]
1 in list1  # True

# is 和 is not 比较对象是否相同


# 从左到右传递比较，比较是否a小于b且b等于c
a < b = c  

# 从左到右一旦匹配则停止，比较a和b为真时不会解析c
a and b and c  
```

#### if

```python
# 条件判断
if x < 0:
  print('x < 0')
elif x == 0:
  print('x = 0')
elif x == 1:
  print('x=1')
else:
  print('not match')
```

#### for

```python
# 遍历列表
for i in ['apple', 'orange', 'banana']:
  print(i, len(i))  # ('apple', 5) ('orange', 6) ('banana', 6)

# 遍历可迭代对象
for i in range(0, 10, 2):  # range(起，始，步长)
  print(i)  # 0, 2, 4, 6, 8

# break 跳出循环
for i in range(2, 5):
  if 9 % i == 0:
    print(i)  # 3
    break
  print(i)  # 2

# continue 跳过循环
for i in range(3):
  if i == 1:
    continue
  print i  # 0 2
  
# for...for...else  
for i in range(2, 5):
  for j in range(2, i):
    if i % j == 0:
      print(i, j)  # (4,2)
      break  # 跳出后不执行else
  else:
    print(i) # 2 3
```

#### while

```python
# pass
while True: # 占位
  pass
  
# 依次打印   
numbers=input("输入5个数字，以逗号为分割: ").split(",")  
x=0
while x < len(numbers):              
  	print (numbers[x])       
    x+=1
else: # 循环结束后的处理,可有可无
  	print(x)
```

### 异常处理

#### with

#### try...except

```python
# 如果在except后将异常类型设置为Exception,异常处理程序将捕获除程序终端外的所有异常。
因为Exception类是其他所有异常类的基类
try子句的代码块放可能出现的异常语句，except子句代码是处理异常
当出现异常时，python会自动生成一个异常对象，该对象包括异常的具体对象，以及异常的种类和错误位置

try:
    f=open("hel.txt","r")     # 尝试打开一个不存在的文件
    print("读文件")
except FileNotFoundError:    # 捕获FileNotFoundError异常
    print("文件没找到")
except:                      # 其他异常
    print("程序异常")
    
    
# 程序执行时，python将产生traceback对象，记录异常信息和当前程序的状态。
import sys
try:
    x = 10/0 
except Exception as ex:
    print(ex)
    print(sys.exc_info())    # 输出异的类型，traceback对象等信息
```
    
#### try...except...else

```python
try:
    result = 10/2
except ZeroDivisionError:      
    print("0不能被整除")
else:                          #没有出发异常正常执行以下代码
    print(result)

# 异常语句嵌套
try:
    s = "hello"
    try:
        print(s[0]+s[1])
        print(s[0]-s[1])
    except TypeError:
        print("字符串不支持减法操作")
except:
    print("异常")
```
    
#### try...finally

```python
# finally的作用：无论异常是否发生，finall子句都会被执行
# try...except嵌套语句通常用于释放已经创建的系统资源
try:
    f = open("hello.txt","r")    # 如果文件不存在，不用释放资源
    try:
        print(f.read(100))
    except:
        print("读取文件异常")
    finally:
        print("释放资源")
        f.close()
except FileNotFoundError:
    print("文件没找到"
```

#### raise

```python
# 如果程序中出现异常，python会自动引发异常，也可以通过raise语句显示异常
# 一旦执行了raise语句，raise语句后的代码将不能被执行
# Raise语句通常于抛出自定义异常，不会被python自动抛出，应该使用raise
try:
    s = None
    if s is None:
        print("s是空对象")  # 抛出NameError异常的错误，后面的终止不会执行
        raise NameError         
    print(len(s))
except TypeError:
    print("空对象没有长度")
```
    
#### 自定义异常

```python
# python允许程序员自定义异常类型，用于描述python异常体系中没有涉及的异常情况
# 自定义异常必须继承Exception类，自定义异常按照命令规范以Error结尾
# 显式地告诉程序员该类是异常类，自定义异常使用raise引发，而且只能通过手工方式触发。
from  __future__ import division

class DivisionException(Exception):
    def __init__(self,x,y):
        Exception.__init__(self,x,y)
        self.x = x
        self.y = y

if __name__ == "__main__":
    try:
        x = 3 
        y = 2
        if x % y > 0 :
            print(x,y)
            raise DivisionException(x,y)     # 引发异常
    except DivisionException as div:                # 捕获自定义异常 
        print("DivisionException: x/y = %.2f" % (div.x/div.y))
        print(type(div))  
```
        
#### assert

```python
# assert语句用于检测某个条件表达式是否为真
# assert语句又称为断言语句，assert认为检测的表达式永远为真
# if语句中的条件判断都可以使用assert语句检测，如果assert断言失败，会引发AssertionError异常
t = "hello"
assert len(t) >= 1 
# assert语句可以传递提示信息给AssertionError异常
t = "hello"
assert len(t) == 1 , "字符t长度大于1"      
```

### 函数/类

#### def

```python
# python中任何东西都是对象，所以参数只支持引用传递的方式。

# 函数 def xxx_yyy():

# 无 return 返回 None
def fib(n):
  """文档字符串docstring: 生成有边界的斐波那契数列."""
  a, b = 0, 1
  while a < n:
    print(a)
    a, b = b, a+b

f10 = fib(10)  # 0 1 1 2 3 5 8
print f10  # None
print(fib.__doc__) # 文档字符串docstring: 生成有边界的斐波那契数列.


# return 返回列表
def fib_return(n):
  """Return a list containing the Fibonacci series up to n."""
  result = []
  a, b = 0, 1
  while a < n:
    result.append(a)
    a, b = b, a+b
  return result

f10 = fib(10)
print f10  # [0, 1, 1, 2, 3, 5, 8]


# 默认参数值  name必选参数，fruit可选默认参数(放最后)
def display(fruit="apple"):
  print(fruit) 

display()  # apple
display("orange")  # orange
display(fruit="banana")  # banana


# 关键字参数 key=value
def display_one(name, fruit="apple"):
  print(name, fruit) 

display(1)  # 1, apple
display(2, "orange")  # 2, orange
display(fruit="banana", name=3)  # 3, banana
    

# 可变参数列表  *args为元组 **kvs为字典,key必须之前没出现过
def display_two(name, *args, **kvs):
    print("name", name)
    print("*args", args)
    print("**kvs", kvs)
  
display_two(1, 2, aa=11 )  # ('name', 1) ('*args', (2,)) ('**kvs', {'aa': 11})
args = list(range(3))
kvs = dict(aa=11, bb=22)
display_two(1, *args, **kvs )  # ('name', 1) ('*args', (0, 1, 2)) ('**kvs', {'aa': 11, 'bb': 22})


# 多值返回
# 把值“打包”到元组，在调用返回时元组“解包”
def func(x,y,z):
	l=[x,y,z]
    l.reverse()
	numbers=tuple(l) # 打包
    return numbers

x,y,z=func(1,2,3) # 解包
print(x,y,z)


# 闭包
# 内部函数使用外部函数的变量
def a(x):
    def b(y):
        return x+y
    return b
    
# 递归
# 自己调用自己，内存溢出
def refunc(n):
    i=n
    if n > 1:
	    i=n
	    n=n*refunc(n-1)          #递推
	print("%d!="% i,n)
	return n                     #回归

refunc(5)
```

#### lambda

```python
# 语法糖：短小匿名函数
f1 = lambda x,y:x+y
f1(1,3)  # 4

# 等价于
def f1(x, y):
  return x + y
```

#### 自建函数

```python
# filter
# filter(function or none,sequnence) 
# 对指定序列过滤处理，判断自定义函数的参数返回结果是否为真来过滤，并一次性返回处理结果。
def func(number):
    if number > 0 :
  	    return number
  
result=filter(func,range(-9,10))       
print(type(result)) # <calss "filter">      
print(list(result))        


# reduce
# reduce(func，sequence[,inital])
# 对序列中元素的连续操作可以通过循环来处理。
def sum(x,y):
    return x+y
  
from functools import reduce
print(reduce(sum,range(1,5)))        #返回1+..+4=10
print(reduce(sum,range(1,5),10))     # 20 ,因为初始值sum=10
print(reduce(sum,range(0,0),1))      # 1 ，range(0,0)不包含任何数


# map
# map(func,*iterable)  
# 对多个序列的每个元素都执行相同的操作，并返回一个map对象
def mypower(x): 
    return x**x
  
result=map(mypower,range(1,5))   
print(type(result))            #<class 'map'> 
print(list(result))            #[1,4，27，256]
```

#### class

```python
# 最小类
class EmptyClass: 
  pass
  
# object默认是所有类的基类

# 类的函数至少有1个参数self
class Fruit:
    def __init__(self):        # __init__为类的构造函数
        self.name = "name"                    
        self.color = "color"
    
    def grow(self):            # 定义grow方法
        print("Fruit grow...")    
                
# 当一个对象被创建后，包含3个特性：对象的句柄、属性和方法
# 句柄用于区分不同的对象，该对象会获取一定的存储空间，存储空间的地址即为对象的标识
if __name__ == "__main__":
    fruit = Fruit()         # 实例化
    fruit.grow()
属性和方法
# 类的属性是对数据的封装，而类的方法是对对象具有的行为
# python中的构造函数、析构函数、私有属性或方法都是通过名称约定区分的    
# 私有属性：属性以两个下划线__开头
# 公有属性：没有使用双下划线的开始
# python的属性：
# 实例属性：实例属性是以self作为前缀的属性,类中其他方法定义的变量是局部变量
# 静态属性：可以被类直接调用，而不是被实例化对象调用。
          # 当创建新的实例化对象后，静态变量不会获得新的空间，而是使用类创建的内存中间
          # 静态变量能够被多个实例化对象共享。pyhon中的静态变量称为类变量
          
class  Fruit:
    price = 0                  # 属性
    
    def  __init__(self):
        self.color = "red"    # 实例属性 
        self.__size = 5       # 私有属性的实例属性 
        zone = "China"        # 局部变量
 
if __name__ == "__main__":
    print(Fruit.price)
    apple = Fruit()
    Fruit.price = Fruit.price + 10
    print("实例属性：",apple.color)     # 输出实例属性的值
    print("对象访问静态属性(类变量)：",apple.price)
    apple.price = apple.price - 5
    print("对象访问修改后的静态属性",apple.price)
    print("类访问静态属性：",Fruit.price)
    Fruit.price = Fruit.price - 2
    banana = Fruit()
    print("不同对象访问静态属性：",banana.price)
    
# 类的一些内置属性
class  Fruit:
    def  __init__(self):
        self.__color = "red"   
        self.zone = "China"
        
class Apple(Fruit):
    '''This is  Apple's doc'''
    price = 10
    def  Size(self):
        self.__size = 5   
    pass
    
if __name__ == "__main__":
    fruit = Fruit()
    apple = Apple()
    print(Apple.__bases__)          # 输出基类组成的元组
    print(apple.__dict__)           #输出对象中构造函数的实例属性组成的字典
    print(apple.__module__)         #输出是mian还是被调用
    print(apple.__doc__)
```
    
#### 垃圾回收

```python
# python提供垃圾回收机制，提供gc模块释放不在使用的对象。
# 垃圾回收机制有许多种算法，python中采用引用计数的方式，当对象在作用域内引用计数为0时，
# python自动清除该对象。垃圾回收机制很好的避免了内存泄漏的发生
# 垃圾回收器在后台执行，对象被释放的时间是不确定的

import gc
class Fruit:
    def __init__(self,name,color):
        self.__name = name
        self.__color = color
         
class FruitShop:
    def __init__(self):
        self.fruits = []
        
    def addFruit(self,fruit):
        fruit.parent = self
        self.fruits.append(fruit)
        
    def getFruit(self):
        print(self.fruits)
    
if __name__ == "__main__":
    shop = FruitShop()
    shop.addFruit(Fruit("apple","red"))
    shop.addFruit(Fruit("banana","yellow"))
    shop.getFruit()    # 返回Fruit类对象的地址空间
    print(gc.get_referrers(shop))  #列出shop关联的的其他对象
    del shop      #释放shop对象，但是没有释放掉关联的对象
    print(gc.collect())   #调用collect()释放shop对象关联的其他对象
```

### 模块/包

#### `module xxx.py`

```python
# 模块：一个xxx.py文件
# 模块搜索路径：解释器内置模块 --> sys.path（当前目录、环境变量PYTHONPATH目录、python默认安装目录）
# 模块缓存：编译后文件xxx.pyc。 Python会检查源文件与编译版的修改日期以确定它是否过期并需要重新编译，没有源文件则不对比。
# 缓存作用：来自 .pyc 文件或 .pyo 文件中的程序不会比来自 .py 文件的运行更快；.pyc 或 .pyo 文件只是在它们加载的时候更快一些。
# 主模块名字是__main__

# 模块文件
cat module_fib.py
# -*- coding: utf-8 -*-
import sys
def fib(n):
  a, b = 0, 1
  while b < n:
    print(b)
    a, b = b, a + b
    
if __name__ == "__main__":
  fib(int(sys.argv[1]))


# 导入模块
import module_fib
module_fib.fib(5)  # 1 1 2 3

# 导入模块中函数
from module_fib import fib
fib(5)  # 1 1 2 3

# 导入模块中所有定义，除_开头的命名
from module_fib import *

# 脚本执行
python module_fib.py 5  # 1 1 2 3

# 查看模块定义: 变量、函数、模块
import sys
dir(sys)
```

#### `package __init__.py`

```python
# 包：一个包含__init__.py的目录
cat package/__init__.py
# -*- coding:utf-8 -*-
__all__ = ['module1', 'module_xxx']  # 指定import *时导出的模块


# 导入包特定模块
import package.module_xxx

# 导入包特定模块函数
from package.module_xxx import def_xxx, var_xxx

# 导入所有在__all__中包含的模块
from package import *

# 基于当前模块命名相对导入, 因为主模块名字是__main__，所以主模块必须是绝对导入
from . import module_xxx
from .. import module_xxx
```

### 迭代器/生成器

#### iterator

#### generate

```python
# 生成器generate一次产生一个数据项，并把数据项保存。
# yield 返回值后,程序继续往后执行,越界抛出stopiteration
# return 返回值后，程序将终止

def func(n):
    for i in range(n):
    	yield i
 
r=func(3)
print(r)              # generator地址
print(next(r))        # 0
print(next(r))        # 1
print(next(r))        # 2
print(next(r))        # 抛出错误，stopIteration
```

### 其他

#### print
```sh
created=u'生命'
print created.__class__
```

#### virtualenv

```sh
# 多个Python相互独立环境，互不影响
# export PIP_REQUIRE_VIRTUALENV=true

pip install virtualenv
# 初始化，默认依赖系统环境site packages
virtualenv testapp 
virtualenv --no-site-packages testapp
# 启动
cd testapp
source ./bin/activate  # Linux
Script\active  # Windows
# 安装模块
pip install xxx
# 退出
deactivate
```

#### UWSGI 

WSGI = Web Server Gateway Interface

```sh
pip install uwsgi

# vim hi.py
def application(env, start_response):
   start_response('200 OK', [('Content-Type','text/html')])
   return [b"Hello World"]

# start
uwsgi --http :8001 --wsgi-file hi.py
curl http://127.0.0.1:8001
```

#### Django

- [https://www.djangoproject.com/](https://www.djangoproject.com)
- [http://c.biancheng.net/django/](http://c.biancheng.net/django)


```sh
pip install Django==1.8.17

# 查看
python -m django --version

# django
django-admin startproject blog
cd blog
yum install sqlite-devel -y
python manage.py runserver 0.0.0.0:8002
curl http://127.0.0.1:8002/   # It‘s work


# uwsgi + django
# 配置
# vim blog/django_wsgi.py
#!/usr/bin/env python
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "blog.settings")
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
# 运行
uwsgi --http :8000 --chdir blog --module django_wsgi
curl http://127.0.0.1:8000/   # It‘s work


# nginx + uwsgi + django
# 配置 nginx
# vim nginx.conf
  server {
	listen       80;
	server_name  127.0.0.1;
    access_log /myenv/logs/access.log;
    error_log /myenv/logs/error.log;

    location / {
	    uwsgi_pass 127.0.0.1:8077;
     	include uwsgi_params;
        #uwsgi_param UWSGI_SCRIPT index;
        #uwsgi_param UWSGI_PYHOME $document_root;
    	#uwsgi_param UWSGI_CHDIR  $document_root;
    	}
  }
# 配置 uwsgi
# vim  blog/blog.ini
[uwsgi]
vhost = false
plugins = python
socket = 127.0.0.1:8077
master = true
enable-threads = true
workers = 1
wsgi-file = /blog/django_wsgi.py
virtualenv = /blog
 
# 启动
nohup uwsgi --ini /myenv/mysite/mysite.ini &
curl http://127.0.0.1:8000/   # It‘s work
```

#### Flask

- [http://docs.jinkan.org/docs/flask/quickstart.html#quickstart](http://docs.jinkan.org/docs/flask/quickstart.html#quickstart)

#### 编码

```python
# 编码转换
>>> a="\u53d1\u4fe1IP\u65e0\u6743\u9650"
>>> print(a.encode("utf-8").decode('unicode_escape'))
发信IP无权限

# latin1编码先用GBK解码在转成utf-8
# GBK2312:  6763 个汉字
# GBK: 21886 个汉字和图形符号
v=typ.decode('GBK2312').encode('utf-8')
v=typ.decode('GBK').encode('utf-8')

# 查数据编码
alarm_type='华为BGP告警'
typ=alarm_type.decode('utf-8').encode('gbk')
sql = "select create_time from {} where type = '{}' order by create_time desc limit 1".format(self.table,typ)
```

### 入门教程

- 菜鸟教程python3 [https://www.runoob.com/python3/python3-tutorial.html](https://www.runoob.com/python3/python3-tutorial.html)

### 其他资料

- [django框架 https://www.djangoproject.com/](https://www.djangoproject.com/)
- [django框架基础教程 http://c.biancheng.net/django/](http://c.biancheng.net/django/)

