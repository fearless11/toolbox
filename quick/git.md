## git

简介 ：开源分布式版本控制系统

资料 ：[ProGit](https://git-scm.com/book/zh/v2) 

同类产品 ： [gitea](https://docs.gitea.io/zh-cn/) svn

**总结：本地操作、分支操作、远程操作、工作流程、快捷配置、底层原理**

### install

 [download](http://git-scm.com/download)

```sh
# tar
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel \ 
asciidoc xmlto docbook2x -y
# wget https://www.kernel.org/pub/software/scm/git/git-2.15.1.tar.xz
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.18.0.tar.gz
tar xf git-2.18.0.tar.gz
cd git-2.18.0
./configure 
make prefix=/usr all doc info       # as yourself
make prefix=/usr install install-doc install-html install-info  # as root
make install

# linux
yum install git-core

# Ubuntu/Debian
apt-get install git-core
```
- git 报错 ssl fatal error
```bash
# 调试curl
 export GIT_CURL_VERBOSE=1
     
 # 查看
 git clone https://github.com/Valloric/YouCompleteMe.git
 nns 12900      # 详细报错

# 解决 
ntpdate pool.ntp.org    # 更新同步系统时间
yum update nss         # 升级nss模块
```


### config

#### ssh

```sh
# gitlab配置ssh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub    # copy到gitlab的SSH-KEY设置
ssh -T git@repo.we.com   # 验证
Welcome to GitLab, xxx.jiang!


# 配置ssh端口
# 查看jenkins_agent的运行用户（这里是publish）
# su - pulish
cp  ~/.ssh/config /home/
cat > ~/.ssh/config <<EOF
Host gitlab.zhenai.com
HostName gitlab.zhenai.com
Port 16333
EOF
chmod 600 ~/.ssh/config 


# ssh不允许rootlogin
sudo git clone ssh://git@gitlab.zhenai.com:16333/huan.jiang2/alert.git
   fatal: Could not read from remote repository.
sudo cp /etc/ssh/ssh_config /data/backup/
sudo sed -i 's/^PermitRootLogin no/#PermitRootLogin no/g' /etc/ssh/ssh_config


// X509问题
  // go get git.code.oa.com/zhiyan-log/sdk-go: unrecognized import path "git.code.oa.com/zhiyan-log/sdk-go": https fetch: Get "https://git.code.oa.com/zhiyan-log/sdk-go?go-get=1": x509: certificate signed by unknown authority
  // 重写https增加insecure
  git config --global url."git@git.code.oa.com:".insteadOf "https://git.code.oa.com/"
  go get -insecure git.code.oa.com/zhiyan-log/sdk-go
```

#### http协议时输入密码
```bash
# http协议输入秘密是否保存
git config --global --unset credential.helper
git config --global credential.helper store
```

#### file

```sh
# 配置文件
/etc/gitconfig : 影响所有用户   git config --system
~/.gitconfig   ：影响当前用户   git config --global 
.git/config    ：影响当前目录   git config

# 用户级别配置 
git config --global user.name "abc"
git config --global user.email abc@example.com
git config --global core.editor emacs|vi|vim
git config --global merge.tool vimdiff|opendiff
git config --global core.autocrlf true      # 格式化，windows—>linux把行结束符CRLF转换成LF
git config --global core.autocrlf input     # 把CRLF转换成LF

# 服务器配置
git config --system receive.fsckObjects true  # 检查库的完整性
git config --system receive.denyDeletes true  # 阻止删除分支和标签

# Git属性配置
# 比较word二进制文档，先转换纯文本再比较
echo '*.doc diff=word' >> .git/info/attributes 
# Git使用strings程序，把Word文档转换成可读的文本文件后比较
git config diff.word.textconv strings  
# 比较图片差异
echo '*.png diff=exif' >> .gitattributes
git config diff.exif.textconv exiftool
diff --git a/image.png b/image.png 

# 查看所以配置，重复的变量用最后一个
git config --list      

# 查看特定
git config user.name

# 查看子命令帮助
git help <verb>
git <verb> --help
man git-<verb>
git help config

# 项目太大，扩大buffer
# error: RPC failed; curl 18 transfer closed with outstanding read data remaining
git config --global http.postBuffer 524288000  #设置为500M

# 因服务器的SSL证书没有经过第三方机构的签署
# error: RPC failed; curl 56 OpenSSL SSL_read: SSL_ERROR_SYSCALL, errno 10054
env GIT_SSL_NO_VERIFY=true    # 临时忽略

# git https 无法获取，请配置本地的 git，关闭 https 验证
git config --global http.sslVerify false

# git协议替换为https协议
npm ERR! code 128
npm ERR! Command failed: git clone --mirror -q git://github.com/adobe-webplatform/eve.git C:\Users\Administrator\AppData\Roaming\npm-cache\_cacache\tmp\git-clone-a577808b\.git --config core.longpaths=true
# 解决
git config --global url."https://".insteadOf git://

```

#### 自动补全

```sh
# tab补全，补全脚本存放在Git项目源码/contrib/completion
# Bash shell
cp git-completion.bash ∼/.git-completion.bash
cp git-completion.bash ∼/.git-completion.bash
source ~/.git-completion.bash 
source ~/.git-completion.bash >> ~/.bashrc

# linux
cp git-completion.bash  /etc/bash_completion.d/ 

# Mac
cp git-completion.bash /opt/local/etc/bash_completion.d

# 两次tab补全命令
git logs s<tab>
git co<tab>

# 每次都要输入账号密码
git config --global credential.helper store
```

#### alias

```sh
 git config --global alias.br branch
 git config --global alias.ci commit
 git config --global alias.st status
 # 查看最后一次提交
 git config --global alias.last 'log -1 --state' 
 

 # 查看提交历史图
 git config --global alias.graph 'log --pretty=format:"%h %s" --graph'
 
 
 # fileA从暂存区推到工作区
 # git unstage fileA 等价于 git reset HEAD fileA
 git config --global alias.unstage 'reset HEAD --'  
```

#### submodules

```sh
# git clone --recurse-submodules git@github.com:fearless11/record.git
# git submodule add https://github.com/tufu9441/maupassant-hexo.git themes/maupassant
# git submodule add https://github.com/YunYouJun/hexo-theme-yun.git themes/hexo-theme-yun
# cat .submodule
```


#### hooks挂钩

```sh
# 挂钩  工作流程中额外的操作
# 脚本文件 .git/hooks/*.sample 

# 客户端挂钩
pre-commit   提交信息前运行，用来检查即将提交的快照，例如，检查是否有东西被遗漏、测试是否运行、检查代码
prepare-commit-msg  挂钩在提交信息编辑器显示之前，默认信息被创建之后运行
commit-msg   挂钩接收一个参数
post-commit  挂钩在整个提交过程完成后运行，作为通知之类使用
pre-rebase   挂钩在衍合前运行，脚本以非零退出可以中止衍合的过程

# 服务器挂钩
# 提交对象推送到服务器前被调用，在推送到服务器后被调用
```

### 原理

#### 集中式&分布式

-  集中化版本控制系统

  共同开发；中央服务器单点；客户端只提取最新版本的文件快照,有历史更新信息丢失的风险

- 分布式版本控制系统

  共同开发；客户端克隆原始代码仓库的镜像,相当于对代码仓库的完整备份

#### 工作区&文件状态

- 工作区域
  - 工作目录
  - 暂存目录
  - 仓库目录
- 管理的文件状态
  - 已修改 （工作区）
  - 已暂存 （暂存区）
  - 已提交 （仓库区）
- 文件状态
  - 已跟踪
  - 未跟踪 （没归git管）

#### 特性

1. 直接快照,而非比较差异

   如果文件有变化,直接对文件快照,而非只快照文件差异

   如果文件没有变化,直接对之前的文件做软链接，类似文件系统

2. 时刻保证数据完整性

   用SHA-1算法计算数据的校验和,对文件内容或目录结构计算哈希值40个十六进制字符
   
3. 高效快速

#### 协议

- 本地协议

  优点：简单，保留现存文件的权限和网络访问权限

  缺点：能从不同的位置访问的共享权限难以架设，先挂载远程硬盘，但通过NFS访问仓库通常会比SSH慢

  ```sh
  # 克隆一个本地仓库，共享的文件系统NFS
  # 使用硬链接或者直接复制它需要的文件，比file://快
  git clone /opt/git/project.git          
  git remote add local_proj /opt/git/project.git
  
  # 通过网络来传输数据的工序，而效率相对很低，需要一个不包含无关引用或对象的干净仓库副本的时候
  git clone file:///opt/git/project.git   
  ```

- SSH协议

  优点：安全、传输前压缩数据更高效

  缺点：不能通过它实现仓库的匿名访问

  ```sh
  # SSH 也是唯一一个同时便于读和写操作的网络协议，另外两个网络协议 (HTTP 和 Git)通常都是只读的
  git clone ssh://user@server:project.git
  git clone user@server:project.git     # 默认ssh
  ```

- Git协议

  Git 软件包中的特殊守护进程; 它会监听一个提供类似于 SSH 服务 的特定端口(9418)，而无需任何授权。

  优点：现存最快的传输协议，使用与 SSH 协议相同的数据传输机制，省了加密和授权的开销。

  缺点：缺少授权机制，只读权限。企业级防火墙一般不允许对这个非标准端口9418的访问。

  ```sh
  git clone git@gitee.com:fearless11/alertmanager.git
  ```

- HTTP协议

  只要把 Git 的纯仓库文件放在 HTTP 的文件根目录下，配置一个特定的 post-update 挂钩(hook)，就搞定了！

  优点：易于架设，https可加密，企业级防火墙通常都允许其端口通信。

  缺点：客户端效率更低，克隆或者下载仓库内容可能会花费更多时间，HTTP 传输的体积和网络开销比其他任何一个协议都大。

  ```sh
  # 建立Web站点并设置挂钩
  cd /var/www/htdocs/
  # --bare 把一个仓库克隆为纯仓库，纯仓库的目录名以.git结尾
  git clone --bare /path/to/git_project gitproject.git
  cd gitproject.git
  mv hooks/post-update.sample hooks/post-update
  chmod a+x hooks/post-update
  
  # 使用
  git clone http://example.com/gitproject.git
  ```

### 命令

#### local

```sh
# 生存.git目录仓库
git init
git clone xxx/a.git        # 项目名为a
git clone xxx/a.git test	 # a重命名为test           
git clone git@gitee.com:fearless11/alertmanager.git  # git://协议
git clone ssh://git@repo.we.com:22/a.git            # user@server:/path.git表示的ssh协议
git clone http://aa%40abc.com:1234567@git.za.com/a.git # http//协议带密码 （%40代表@）

# 查看文件状态  （未跟踪、已修改、已暂存、已提交）
git status

# 查看具体更新内容
git diff                    # 工作区与暂存区的差异
git diff --staged|--cached  # 暂存区与上一次提交到仓库区的差异
git diff master             # 查看当前分支与master分支的不同
git diff master dev         # 查看master和dev的不同
git diff master...dev       # 便捷的 ... 语法，看到的master和dev分支中要引入的新代码


# add作用跟踪新文件；已跟踪放暂存区；合并时标记冲突为已解决
git add READAME
git add DIR         # 递归跟踪所有文件

# 提交
git commit -m 'add READAME'
git commit -a -m 'fix something'  # 工作区直接提交仓库区

# 删除文件
git rm file                 # 删除工作目录
git rm -f file              # 删除暂存区记录
git rm --cached readme.txt  # 不跟踪文件，从暂存区删除
git rm log/\*.log           # 删除所有 log/ 目录下扩展名为 .log 的文件
git rm \*~                  # 删除当前目录及子目录下以~结尾的文件
git commit -m 'rm file'
git rm -r --cached path     # 删除缓存中信息

# 回退
git reset --hard HEAD^        # 回退到上个版本
git reset --hard HEAD~3       # 回退到前3次提交之前，以此类推n次
$ git reset --hard commit_id  # 退到指定commit
git reset HEAD file           # 取消暂存a.rb文件  （暂存区到工作区）
git checkout -- file          # 取消对文件的修改   （工作区）
git commit --amend            # 撤消刚才的提交操作 （仓库区到暂存区）

# 查看日志
git log
git log -p -2         # -p 提交的内容差异,-2最近两次commit
git log --stat        # 仅显示简要的增改行数统计
git log --pretty=oneline   # 每个提交放在一行显示
git log --abbrev-commit --pretty=oneline  # 查看简写的commitID，七个字符
git log --pretty=format:"%h - %an,%ad %s"    # 定制要显示的记录格式
 	%H    commit对象的完整哈希字串40位
	%h    commit对象的简短哈希字串7位 
  %an   作者的name
	%ae   作者的email
	%ad	  作者修改的日期
	%ar   作者修改的日期，按多久以前的方式显示
	%cn   提交者的name	
	%s    提交说明   
git log --graph          # 显示ASCII图形表示的分支合并历史
git log --pretty=format:"%h %s" --graph 
git log --after=2.minutes|2.weeks # 2分钟之内的提交
git log --before="20018-01-11"   # 2018/01/11之前的提交
git log --author=mary			      # 显示mary相关的提交
git log --pretty="%h:%s" --author=gitster --since="2008-10-01" \ --before="2008-11-01" --no-merges -- t/    # 2008年10月期间，Junio Hamano提交的但未合并的测 试脚本(位于项目的 t/ 目录下的文件)
git log --abbrev-commit  --pretty=oneline    # 简短SHA-1值

# 图形化工具查阅提交历史
gitk 

# 查看一个分支的最后一次提交对象
git show commitID      # 最后一次
git show dev           # 分支名

# 查看分支的40位的SHA值
git rev-parse dev

# 引用日志
# 记录HEAD和分支引用的日志，日志引用信息只存在于本地，克隆引用日志是空的
git reflog
git show HEAD@{5}         # 仓库中 HEAD 在五次前的值 @{n}
git show master@{yesterday}   # 查看的 master 分支昨天在哪

# 查看上一次提交，HEAD 的父提交
git show HEAD^
git show HEAD~
# 查看HEAD的上上个提交
git show HEAD^^
git show HEAD^2       # 之前提交必须存在三方合并，否则执行失败
git show HEAD~~
git show HEAD~2
```

#### remote
```sh
# 远程仓库通常只是一个 纯仓库(bare repository)，没有当前工作目录
# 远程分支：
#   本地无法移动;只有在进行Git的网络活动时才会更新；
#   远程分支就像是书签，提醒着你上次连接远程仓库时上面各分支的位置
#   远程分支表示为 (远程仓库名)/(分支名) 

# 查看
git remote               # 远程仓库的别名
git remote -v            # 显示别名和对应的克隆地址 —verbose的简写

# 查看远程仓库信息
git remote show [remote-name]
git remote show origin   # origin仓库的详细信息

# 添加
git add dev git://github.com/test.git # 别名dev对应远程仓库

# 抓取
git fetch dev  # 抓取仓库数据但不自动合并到当前工作分支
git pull dev   # 抓取仓库数据自动合并到当前分支（分支已跟踪）

# 推送
git push [远程名] [本地分支]:[远程分支]
git push origin master          # 本地的master分支推送到origin的master
git push origin dev:test        # 本地dev到远程test分支 
git push origin master --force  # 强推

# 重命名
git remote rename pb paul    # 把 pb 改成 paul
git remote rm paul           # 移除对应的远端仓库paul

# 删除远程分支
git push origin :serverfix   

# 默认跟踪分支
# matching 本地当前分支 对应 匹配的远程分支 
# simple   本地当前分支 对应 git pull获取的代码的分支
git config --global push.default matching 
git branch --set-upstream-to=origin/master master
# 取消
git branch --unset-upstream [branch-name]
# 查看
git branch -vv 或 cat .git/config

# 跟踪分支 
# 默认master分支跟踪origin/master分支，故直接git pull或git push
git checkout -b [分支名] [远程名]/[分支名]
# serverfix分支跟踪远程origin/serverfix分支
git checkout -b serverfix origin/serverfix   

# 合并到当前分支，当前分支跟踪远程分支
git merge origin/serverfix  

# 无关联问题 ：fatal: refusing to merge unrelated histories
git merge master --allow-unrelated-histories
git pull origin master --allow-unrelated-histories
```

#### tag

```sh
# 查看
git tag
git show v1.0   # 查看标签内容

# 新建
git tag -a v1.0 -m "v1.0"    # -a为含附注tag，git仓库的独立对象
git tag -a v1.2 commitID     # 后期加注标签，针对commitID
git tag v1.1                 # 轻量级tag，当前commit对象的一个引用
git tag -s v1.5 -m 'my signed 1.5 tag'   # 签署标签
git tag -v v1.4.2.1          # 验证标签

# 推送
git push origin v1.0    # 默认不推送
git push origin --tags  # 一次推送所有tag
```
#### gitignore

```sh
# 某些文件既不需要纳入git版本管理库，又不需要在未跟踪列表显示时，可以加入到.gitignore文件
# glob模式：指shell简化了的正则表达式
# 格式规范
  所有空行或者#开头的行被git忽略
  标准glob模式匹配
  模式匹配最后加/为忽略目录
  模式前加!为取反
  ? 只匹配任意一个字符
  * 匹配零个或多个字符
  [abc] 匹配a或b或c
  [0-9] 匹配所有0到9的数字

# 文件例子
vim .gitignore
#example      注释将被 Git 忽略
*.a           忽略所有 .a 结尾的文件
!lib.a        但 lib.a 除外
/TODO         忽略项目根目录下的 TODO 文件，不包括 subdir/TODO
build/        忽略 build/ 目录下的所有文件
doc/*.txt     忽略 doc/notes.txt 但不包括 doc/server/arch.txt
```

#### gitattributes

```bash
# 设置文件属性
# 文件中的一行定义一个路径的若干个属性
匹配的文件模式 属性1 属性2 ...


# 在github上，如果未指定语言，Linguist来自动识别你的代码应该归为哪一类,
# 它是根据某种语言的代码量来决定是哪种语言的项目。
# 如果识别有误，可以新建.gitattributes文件来进行设置。
*.html linguist-language=go

# 对任何文件，设置text=auto，表示文件的行尾自动转换
*           text=auto
# 对于txt文件，标记为文本文件，并进行行尾规范化。
*.txt		text

# 对于jpg文件，标记为非文本文件，不进行任何的行尾转换。
*.jpg		-text

# 对于vcproj文件，标记为文本文件，在文件入Git库时进行规范化，即行尾为LF。
# 但是在检出到工作目录时，行尾自动转换为CRLF。
*.vcproj	text eol=crlf

# 对于sh文件，标记为文本文件，在文件入Git库时进行规范化，即行尾为LF。
# 在检出到工作目录时，行尾也不会转换为CRLF（即保持LF）。
*.sh		text eol=lf

# 对于py文件，只针对工作目录中的文件，行尾为LF
*.py		eol=lf
```

#### branch

- 一个文件提交后创建三个对象：commit对象—> tree对象 —> blob对象

- 分支过程：创建一个分支其实就是创建一个指针指向commit，当新分支提交时创建新的commit对象；旧分支修改创建另一个新的commit对象；通过HEAD指针指向当前工作的分支。

- 轻量级：由于 Git 中的分支实际上仅是一个包含所指对象校验和(40 个字符长度 SHA-1 字串)的文件，所以新建一个分支就是向一个文件写入 41 个字节 

  ```sh
  # 一个分支的本质： 写入SHA-1的文件
  refs/heads/master 1a410efbd13591db07496601ebc7a059dd55cfe9
  ```

- 切换分支注意：转换分支的时候最好保持一个清洁的工作区域

```sh
# 创建并切换分支
git checkout -b iss53  
git branch iss53
git checkout iss53
git branch dev commitID     # 根据指定的commitID创建分支

# 查看
git branch               # 分支前的*字表示当前所在的分支
git branch -v            # 查看各个分支最后一次 commit
git branch --merged      # 与当前分支合并的分支
git branch --no-merged   # 尚未合并的分支

# 删除
git branch -d testing
git branch -D testing  # 强制

# 切换master，合并hotfix到master分支
git checkout master 
git merge hotfix 

# 合并冲突，先解决手动冲突文件后提交
git add .
git commit -m 'conficts file...'

# 查看所有分支
git branch -a
# 删除远程分支
git push origin --delete dev

```

#### merge&rebase

- merge

  快进：分支指针前移

  三方合并：某两个commit和它们的共同祖先commit三方计算后合并提交新的commit

  ```sh
  # 修问题
  git checkout -b iss53
  echo "hello world" >> index.html
  git commit -a -m 'added a new footer [issue 53]'
  
  # 紧急bug修复
  git checkout master
  git checkout -b 'hotfix'
  echo "email" >> index.html
  git commit -a -m 'fixed the broken email address'
  git checkout master
  git merge hotfix         # 只是快进
  git branch -d hotfix
  
  # 继续修问题
  git checkout iss53
  echo "finish" >> index.html
  git commit -a -m 'finished the new footer [issue 53]'
  
  # 工作结束
  git checkout master
  git merge iss53          # 三方合并
  git branch -d iss53
  ```

- rebase

  衍合：可理解为打补丁。在c1中直接重放一次c2的操作

  目的：能够保持线性的提交历史

  原理：回到c1和c5的共同祖先，提取c5每次提交时产生的差异(diff)，把这些差异分别保存到临时文件里，然后后在c1中衍合入的c5分支，依序施用每一个差异补丁文件。形成一条线，在c1后有一个c5。

  风险：永远不要衍合那些已经推送到公共仓库的commit。否则远程仓库会出现两个有着不同的 SHA-1值的commit对象，但却拥有一样的作者日期与提交说明，令人费解，别人还得再次合并。

  应用：在分享commit之前进行衍合，使得操作历史是线性，清晰易懂

  ```sh
  # merge和rebase区别
  1.生成树
    rebase的是线性的
    merge的有很多分支，当然merge后可以删除不必要的分支
  2.提交日志
    rebase查看的log没有时间顺序
    merge查看的log按时间顺序
  3.是否产生commit
    rebase没有新的commit，但SHA-1校验值不一样
    merge会有新的commit
  ```

  ```sh
  # 一次完整的衍合，包括衍合与快进。看生成树是线性的
  # 切换到dev分支，然后在master上衍合dev操作，即master后接上dev的操作
  git checkout dev
  git rebase master        
  git checkout master    # 快进master到dev
  git merge dev
  git branch -d dev
  
  # 先检出特性分支server，然后在主分支master上重演
  git rebase master server
  git checkout master 
  git merge server
  git branch -d server
  
  # 检出client分支，找出client和server分支的共同祖先之后的变化，然后把它们在master上重演一遍
  git rebase --onto master server client
  git checkout master
  git merge client
  git branch -d client
  ```

### 服务器Git

- 简单的Git服务器

  ```sh
  # 在一个不公开的项目 上合作的话，仅仅是一个 SSH 服务器和纯仓库就足够
  # 把一个仓库克隆为纯仓库，并对该仓库加入可写的组
  git clone --bare --shared my_project my_project.git
  # 将纯目录转移到服务器
  cp -r my_project.git user@git.example.com:/opt/git
  # 其他对该服务器具有 SSH 访问权限可以读取 /opt/git 的用户
  git clone user@git.example.com:/opt/git/my_project.git
  ```

- 小型安装

  每个人都对仓库有写权限可提供 SSH 连接。

  如何让每个人都有访问权？

  - 反复的运行 adduser并且给所有人设定临时密码
  - 建立一个 git 账户，让每个需要写权限的人发送一个 SSH 公钥，其加入 git 账户的 ~/.ssh/authorized_keys 文件，这样所有人都将通过 git 账户访问主机
  - 让 SSH 服务器通过某个 LDAP 服务，或者其他已经设定好的集中授权机制，来进行授权

- 权限管理Gitosis

- Gtihub（公共：git://xx/xxx.git  私人：git@github.com:xx/xxx.git）

### 工作流程

- 集中式工作流  （但合并操作发生在客户端而非服务器）

  ```sh
  # 私有小型团队
  # 一个分支，每个成员在每次提交前先拉去远程的，合并后在提交
  git clone john@githost:simplegit.git
  git fetch origin                   
  git merge origin/master
  git push origin master   
  ```

- 特性分支工作流 

  ```sh
  # 私有大规模团队
  # 每个项目都有管理员，更新主仓库的master
  # 在特性分支测试好后，才由管理员合并到master分支
  master分支 ： 稳定代码
  特性分支：    开发代码
  ```

- 公开的小型项目

  fork后发送request-pull请求

  ```sh
  # 以github为例
  # 先fork项目后pull request发送请求，等待对方决定是否接受
  # 保持自己的master分支和官方origin/master同步: 发送pullrequest请求
  
  # 克隆项目开发后推送到fork的仓库
  git clone fork的url
  cd project
  git checkout -b featureA
  git commit
  git remote add myfork fork的url
  git push myfork featureA
  # request-pull第一个参数是项目原始分支，第二个是对方抓取的url分支
  git request-pull origin/master myfork
  ```

- 公共的大型项目

  接受补丁流程，多数项目允许开发者邮件列表接收补丁

  ```sh
  git checkout -b topicA
  git commit
  git commit
  # 生成一个.patch后缀的mbox文件
  git format-patch -M origin/master
  
  # ~/.gitconfig文件中配置imap项，命令发送邮件
  git send-email *.patch
  
  # 接收补丁处理，应用到选定分支
  # apply命令
  git apply --check 0001-seeing-if-this-helps-the-gem.patch   # 先检查补丁
  # 当前目录进行补丁操作，运行patch -p1打补丁类似
  git apply /tmp/patch-ruby-client.patch
  # 也可用am命令
  git am 0001-limit-log-function.patch
  
  # 挑拣某个commit到当前分支 
  git cherry-pick e43a6fd3e94888d76779ad79fb568ed180e5fcdf
  
  # 生成内部版本号
  git describe master
  
  # 打包
  git archive master --prefix='project/' | gzip > `git describe master`.tar.gz
  git archive master --prefix='project/' --format=zip > `git describe master`.zip
  
  # 制作简报，发送邮件告知他人做了哪些变更
  # git shortlog命令方便快捷的制作一份修改日志
  git shortlog --no-merges master --not v1.0.1
  ```

### Git&SVN

- Git & SVN

  ```sh
  # 克隆svn的仓库本地用git操作，借助于git svn命令
  git svn clone file:///tmp/test-svn -s    # 克隆svn的仓库代码
  git branch -a
  git show-ref              # 所有指向远程服务的引用不加区分的保存 
  git commit -am 'Adding git-svn instructions to the README'
  git svn dcommit          # 提交到svn
  git svn rebase           # 解决冲突，拉取服务器上所有最新的改变，在此基础上衍合你的修改
  
  # 总结
  # 1. 保持一个不包含由 git merge 生成的 commit 的线性提交历史
  # 2. 不要单独建立和使用一个 Git 服务来搞合作
  ```

- SVN迁移Git

  自定义脚本：创建 Git 对象比运行纯 Git 命令或者手动写对象要简单

  ```sh
  # 方案一 ：git svn克隆，推送到新的git服务器
  
  # 方案二 ：git svn导入，清理工作，推送
  # 获取作者信息列表，生存users.txt
  svn log --xml | grep author | sort -u | perl -pe 's/.>(.?)<./$1 = /' 
  
  # 为 git svn 提供该文件可以然它更精确的映射作者数据
  # --no-metadate来阻止 git svn 包含那些 Subversion 的附加信息
  git-svn clone http://my-project.googlecode.com/svn/ --authors-file=users.txt --no-metadata -s my_project       
  
  # 清理工作，删除不必要的索引结构
  cp -Rf .git/refs/remotes/tags/* .git/refs/tags/
  rm -Rf .git/refs/remotes/tags
  cp -Rf .git/refs/remotes/* .git/refs/heads/ 
  rm -Rf .git/refs/remotes
  
  # 所有的旧分支都变成真正的 Git 分支，所有的旧标签也变成真正的 Git 标签，推送到git服务器
  git push origin --all
  ```

### 内部原理

- 本质 ：内容寻址系统文件系统

- 目录结构

  ```sh
  $ ls  .git
  HEAD             # 文件指向当前分支  ref: refs/heads/master
  branches/ 
  config           # 文件包含了项目特有的配置选项
  description 
  hooks/           # 客户端或服务端钩子脚本  .git/hooks/pre-push.sample
  index            # 文件保存了暂存区域信息
  info/            # 目录保存了一份不希望在 .gitignore 文件中管理的忽略 模式 
  objects/         # 目录存储所有数据内容
  refs/            # 目录存储指向数据 (分支) 的提交对象的指针
  ```

- blob对象

  ```sh
  # blob对象： 具体的内容
  echo 'test content' | git hash-object -w --stdin   # 存储数据对象，通过标准输入
  echo 'version 1' > test.txt
  git hash-object -w test.txt            # 通过文件方式
  git cat-file -t d670460b4b4aece5915caf5c68d12f560a9fe3e4   # 查看对象类型blob、commit、tree
  git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4   # 查看对象内容
  ```

- tree对象

  ```sh
  # 创建tree对象条件
  #    可通过暂存区域、index文件、已经存在的tree对象
  
  # masterˆtree 表示 branch 分支上最新提交指向的 tree 对象
  # git cat-file -p master^{tree}
  100644 blob 91c45d2d90753402c8023518558a39192745df33	a.txt
  040000 tree 3ac46b52a3debf2bbf74e4e20f5d30fd27098ec0	tmp
  # git cat-file -p 3ac46b52a3debf2bbf74e4e20f5d30fd27098ec0
  100644 blob e61ef7b965e17c62ca23b6ff5f0aaf09586e10e9	b.txt
  ```

- commit提交对象

  ```sh
  # 保存是谁、何时以及为何保存了这些快照的信息，为tree对象服务
  # 通过tree对象创建commit对象
  echo 'first commit' | git commit-tree d8329f
  fdf4fc3344e67ab068f836878b6c4951e3b15f3d
  
  # 通过tree对象创建commit对象，同时指向前一个commit对象
  echo 'second commit' | git commit-tree 0155eb -p fdf4fc3 cac0cab538b970a37ea1e769cbbde608743bc96d
  echo 'third commit' | git commit-tree 3c4e9c -p cac0cab 1a410efbd13591db07496601ebc7a059dd55cfe9
  ```

- 对象存储思路

  ```sh
  # 当存储数据内容时，同时会有存储一个文件头
  # blob换成tree、commit对象一样
  
  # 数据内容和文件头
  # 文件头格式： blob添加一个空格，接着是数据内容的长度，最后是一个空字节 (null byte):
  content = "文件内容"
  head = "blob #{content.length}\0"
  
  # 计算sha1值
  store = content + head
  SHA = sha1(store)
  
  # 压缩后存储
  # SHA-1 值的头两个字符作为子目录名称，剩余 38 个字符作为文件名
  ZLIB = zlib（store）
  echo ZLIB > .git/objects/ + SHA[0,2] + '/' + SHA[2,38]
  ```

- refs

  ```sh
  # 执行git branch的本质
  # 基本上 Git 中的一个分支其实就是一个指向某个工作版本一条 HEAD 记录的指针或引用
  git update-ref refs/heads/master 1a410efbd13591db07496601ebc7a059dd55cfe9
  
  # 更新master指向的对象
  git update-ref refs/heads/master 1a410efbd13591db07496601ebc7a059dd55cfe9
  ```

- 真正删除提交过的大文件

  ```sh
  # 恢复数据
  git fsck --full
  
  # 移除对象
  curl http://kernel.org/pub/software/scm/git/git-1.6.3.1.tar.bz2 > git.tbz2
  git add git.tbz2
  git commit -am 'added git tarball'
  
  git rm git.tbz2
  git commit -m 'oops - removed large tarball'
  git gc
  # 运行 count-objects 以查看使用了多少空间
  git count-objects -v
  
  # 在这次提交时删除文件并没有真正将其从历史记录中删除
  # 以识别出大对象
  git verify-pack -v .git/objects/pack/pack-3f8c0...bb.idx | sort -k 3 -n | tail -3
  # 查看具体文件名
  git rev-list --objects --all | grep 7a9eb2fb
  # 该文件从历史记录的所有 tree 中移除
  git log --pretty=oneline -- git.tbz2
  # 重写从 6df76 开始的所有 commit 才能将文件从 Git 历史中完全移除
  git filter-branch --index-filter 'git rm --cached --ignore-unmatch git.tbz2' -- 6df7640^..
  # 删除本地文件
  rm -Rf .git/refs/original 
  rm -Rf .git/logs/
  
  git gc
  git count-objects -v
  ```
