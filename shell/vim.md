---
title: vim
date: 2020-06-15 14:46:00
tags: vim
description: vim is an advanced text editor
toc: true
---
vim一种编辑器 Check [documentation](http://vimdoc.sourceforge.net/) [GitHub](https://github.com/vim/vim) for more info. 


### Quick Start

``` bash
$ vimtutor
```

### option

```bash
# 编辑文件，光标定位到第n行
vi +n file 
# 编辑并定位到最好一行
vi + file 
# 编辑搜索定位到string所在的行
vi +/string file
```


### 四种模式

   - 普通模式   （Esc切换）
   - 插入模式   （iaosIAOS进入）
   - 可视模式   （shift+v 行模式 ctrl+v 块模式）
   - 命令模式   （:进入）

### 普通模式

#### 移动

``` bash
  # 字母
  k         上移
  j         下移
  h         左移
  l         右移
  0         本行的开始
  $         本行的末尾

  # 单词
  w         下一个单词的开头
  e         下一个单词的末尾
  b         上一个单词的开头

  # 行
  gg        文件第一行起始位置
  G         文件最后一行起始位置
  NG或Ngg   文件第 N 行的起始位置

```

#### 搜索

``` bash
  fa        本行光标后第一个a字母的位置
  3fa       本行光标后第三个a字母的位置
  /str      正向搜索字符串str
  ?str      反向搜索字符串str
  n         继续搜索下一个str字符串
  N         继续搜索上一个str字符串
```

#### 替换

``` bash
  # 字母
  rc        替换当前字母为c
  nrc       替换当前字母及后n-1个字母都为c

  # 大小写
  ~         反转光标所在字符的大小写
  U|u       可视模式下选中文本变为大写或小写
  
  # 普通模式大小写转换
  gggUG       全文转换为大写, 解释 gg定位行首 gU替换为大写  G定位到行尾
  ggguG       转换为小写
  gUw、gUe    光标后单个单词转换为大写
  guw、gue    转换为小写
  gu5w、gu5e
```

#### 删除

``` bash
  # 字母
  x          删除光标字母
  nx         删除光标字母及后n-1个字母
  nX         删除光标前n个字母

  # 单词
  dw         删除光标右侧单词
  ndw        删除光标右侧n个单词
  db         删除光标左侧单词
  ndb        删除光标左侧n个单词

  # 行
  dd         删除光标所在行
  ndd        删除(剪切)光标及后n-1行
  nD         删除光标字符后及n-1行

  d$         删除光标起到行尾
  d0         删除光标起到行首
 
 {visual}d   删除高亮的文本
```

#### 撤销
```bash
   u       撤回上一个操作
   nu      撤回上n个操作

   CTRL-C  重做上一个撤销操作
```

#### 连接

```bash
  nJ         用空格连接当前行及后n-1行
 {visual}J   用空格连接高亮的行
```

#### 格式化

```bash
  <<          向左缩进一个shiftwidth
  n<<         当前行及后n-1行向左缩进一个shiftwidth
  >>          向右缩进一个shiftwidth
  n>>         当前行及后n-1行向右缩进一个shiftwidth

  :ce(nter)   当前行居中
  :le(ft)     当前行靠左
  :ri(ght)    当前行靠右

  =           当前行按书写规则缩排好
  n=          当前行及后n-1行格式缩进
  {visual}=   选择的可视化行格式缩进
```

#### 代码相关

```bash
  # 代码中函数跳转
  CTRL-]             跳到函数定义处
  CTRL-T 或 CTRL-o   跳回到上一级调用处

  # 折叠
  zo|l  打开折叠
  zc    关闭折叠
  zO    打开所有光标行上的折叠用 
  zC    关闭所有光标行上的折叠用 
  zd    删除一个光标行上的折叠用 
  zD    删除所有光标行上的折叠用 
```

### 插入模式

```bash
  # 进入
  i     光标前
  a     光标后
  I     当前行行首
  A     当前行末尾
  o     行后插入新行
  O     行前插入新行
  s     删除光标字符插入
  S     删除当前行插入
  
  # 离开
  Esc            结束插入模式，回到普通模式
  CTRL-C         同Esc

  # 补全
  CTRL-N         
  CTRL-P         
  CTRL-X ...     以各种方式补全光标前的单词

  # 删除
  CTRL-W         删除光标前的一个单词
  CTRL-U         删除光标到行首字符
```


### 命令模式

```bash
  # 检查
  :set spell    开启拼写检查
  :set nospell  关闭拼写检查

  # 替换
  :s/from/to/       当前行第一from单词替换为to
  :s/from/to/g      当前行所有from单词替换为to
  :s/from/to/gc     是否将当前行所有from单词替换为to
  :%s/from/to/gc    是否将文本中所有from单词替换为to
  :%s/^/xxx/g       文本行首插入xxx
  :%s/$/xxx/g       文本行尾插入xxx
  :%s/^[a-z]/\U&/g  文本中所有首字母大写

  # 删除
  :%d       删除全文

  # 范围
  %:       所有行
  .:       当前行
  0:       文本首行
  $:       文本尾行

  # 撤销
  :undo 5    撤销5个改变
  :undolist  撤销历史
```

### 更新版本

- 升级

  ```bash
   # 查看
   vim  --version
   
   # 脚本
  cat <<EOF > vim-update.sh
  #!/bin/bash
  # Update vim to the latest version
  
  yum -y install  perl perl-devel python-devel  perl-ExtUtils-Embed ncurses-devel ctags
  wget https://github.com/vim/vim/archive/master.zip
  unzip master.zip && cd vim-master/src/
  
  ./configure --enable-multibyte \
  --enable-pythoninterp=dynamic \
  --enable-cscope \
  --enable-gui=auto \
  --with-features=huge \
  --enable-fontset \
  --enable-largefile \
  --disable-netbeans \
  --enable-fail-if-missing
  
  make && make install
  EOF
  
  # 更新
  sh vim-update.sh  
  ```

- 汉化帮助
  ```bash
  # 安装
  wget http://nchc.dl.sourceforge.net/sourceforge/vimcdoc/vimcdoc-1.5.0.tar.gz \
  --no-check-certificate
  tar xf vimcdoc-1.5.0.tar.gz && cd vimcdoc-1.5.0
  ./vimcdoc.sh -i
  
  # 查看中文帮助
  :help   
   
  # 命令模式设置
  :set helplang=en (英)
  :set helplang=cn (中)
  ```

### 配置

- 查看配置文件
  ```bash
  # vim --version
     system vimrc file: "/etc/vimrc"
     user vimrc file: "$HOME/.vimrc"
  ```

- 配置示例

  ```bash
  # vim $HOME/.vimrc
  # "代表注释

  " 编码
  set encoding=utf-8

  " 插入行时自动对齐上一行缩进格式
  set autoindent
  set smartindent

  " 开启语法检测
  syntax enable
  syntax on

  " 缩进
  " tabstop是一个tab占几个space
  " shiftwidth是自动缩进的时候用几个space
  " softtabstop是当编辑的时候一个tab表现为几个space
  set tabstop=4
  set shiftwidth=4
  set softtabstop=4
  set expandtab
  
  " 为使代码风格保持一致，不允许在代码使用TAB符，以4个空格代替
  " 编辑c和cpp文件时实行这种设置
  " autocmd FileType c,cpp set shiftwidth=4 | set expandta

  " 显示行号
  set number
  
  " 为单词左右补充{}  首字母按下\c
  map \c i{<Esc>ea}<Esc>    
  " 为单词左右补充()  首字母按下\p
  map \p i(<Esc>ea)<Esc>    
  " 解释 i{<Esc>代表插入{后退出插入模式 ；e代表移动到词尾；a}<Esc>代表插入}后退出插入模式
  ```
  
  reference: [vim的tabstop shiftwidth](https://my.oschina.net/uniquejava/blog/222868)  

### 插件

 -   全局插件：用于所有类型的文件
 - 文件类型插件：仅用于特定类型的文件

#### snippets

- 代码自动补全
  ``` bash
    # 安装
    yum install -y unzip zip
    mkdir ~/.vim   
    wget https://www.vim.org/scripts/download_script.php?src_id=11006 \
    --no-check-certificate -O snipMate.zip
    unzip snipMate.zip -d ~/.vim/

    # shell补全snippets
    ~/.vim/snippets/sh.snippets 

    # 使用
    # if+Tab补全if函数,同理wh+Tab补全while函数
    # 只需要简单的按tab可跳到下一处修改
    vim a.sh
    if [[ condition ]]; then 
        statements   
    fi

    # 自定义
    # 按re+Tab自动补全 return true
    vim ~/.vim/snippets/sh.snippets
    snippet    re        # 间隔为tab键
    	return ${1:true}
    ```
    reference: [代码补全插件vim-snippets](https://github.com/garbas/vim-snipmate/blob/master/doc/SnipMate.txt)   [自定义snippet](http://www.cnblogs.com/litifeng/p/5658587.html)

### 插件管理

#### vundle

- [Vundle.vim](https://github.com/VundleVim/Vundle.vim)

   ```bash
    # 安装
    mkdir -p ~/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    # 配置
    vim ~/.vimrc
    set nocompatible
    " 必要的配置
    filetype off    
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " 管理插件
    Plugin 'gmarik/Vundle.vim'
    " 在下面写需要安装的插件
    " snippets
    Plugin 'honza/vim-snippets'
    Plugin 'fatih/vim-go'
    call vundle#end()
    filetype plugin indent on
  
    # 执行
    :PluginInstall                   # 命令行模式
    vim  vim +PluginInstall +qall    # 终端

    # 查看帮助
    :h vundle 
    ```
    
- [vim-go](https://github.com/fatih/vim-go-tutorial)  [Go官方推荐插件 ](https://github.com/golang/go/wiki/IDEsAndTextEditorPlugins) 

    ```bash
    # 添加  go插件要求vim版本8.0+
    vim ~/.vimrc
    Plugin 'fatih/vim-go'  

    # 安装
    :PluginInstall

    # Go二进制必要的包
    :GoInstallBinaries
    ```

    reference: [vim配置及插件管理](https://blog.csdn.net/namecyf/article/details/7787479#commentBox) 