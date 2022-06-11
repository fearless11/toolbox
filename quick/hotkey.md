[toc]

### Google

 - [扩展 chrome://extensions](chrome://extensions) 
    - Vimium
    - [有道云网页剪](报http://note.youdao.com/web-clipper-chrome.html)
    
- 标签页&窗口

| 操作                               | 快捷键         |
| ---------------------------------- | -------------- |
| 打开新窗口                         | ⌘ + n          |
| 在无痕模式下打开新窗口             | ⌘ + Shift + n  |
| 打开新的标签页                     | ⌘ + t          |
| 重新打开最后关闭的标签页           | ⌘ + Shift + t  |
| 在当前标签页中打开主页             | ⌘ + Shift + h  |
| 跳转到特定标签页                   | ⌘ + 1 到 ⌘ + 8 |
| 跳转到最后一个标签页               | ⌘ + 9          |
| 关闭当前标签页                     | ⌘ + w          |
| 关闭当前窗口                       | ⌘ + Shift + w  |
| 最小化窗口                         | ⌘ + m          |
| 隐藏 Google Chrome                 | ⌘ + h          |
| 重新加载当前网页                   | ⌘ + r          |
| 重新加载当前网页（忽略缓存的内容） | ⌘ + Shift + r  |
| 停止加载网页                       | Esc            |
| 打印当前网页                       | ⌘ + p          |
| 保存当前网页                       | ⌘ + s          |
| 通过电子邮件发送当前网页           | ⌘ + Shift + i  |

-  查看&搜索

| 操作                                       | 快捷键         |
| ------------------------------------------ | -------------- |
| 开启或关闭全屏模式                         | ⌘ + Ctrl + f   |
| 放大网页上的所有内容                       | ⌘ 和 +         |
| 缩小网页上的所有内容                       | ⌘ 和 -         |
| 将网页上的所有内容恢复到默认大小           | ⌘ + 0          |
| 向下滚动网页，一次一个屏幕                 | 空格键         |
| 向上滚动网页，一次一个屏幕                 | Shift + 空格键 |
| 跳转到地址栏                               | ⌘ + L          |
| 当前页搜索                                 | ⌘ + f          |
| 跳转到与查找栏中搜索字词相匹配的下一条内容 | ⌘ + g          |
| 跳转到与查找栏中搜索字词相匹配的上一条内容 | ⌘ + Shift + g  |
| 网络搜索                                   | ⌘ + Option + f |

- 功能键

| 操作                                           | 快捷键             |
| ---------------------------------------------- | ------------------ |
| 显示或隐藏书签栏                               | ⌘ + Shift + b      |
| 将当前网页保存为书签                           | ⌘ + d              |
| 将所有打开的标签页以书签的形式保存在新文件夹中 | ⌘ + Shift + d      |
| 打开书签管理器                                 | ⌘ + Option + b     |
| 在新标签页中打开“设置”页                       | ⌘ + ,              |
| 在新标签页中打开“历史记录”页                   | ⌘ + y              |
| 在新标签页中打开“下载内容”页                   | ⌘ + Shift + j      |
| 打开“清除浏览数据”选项                         | ⌘ + Shift + Delete |
| 使用其他帐号登录或以访客身份浏览               | ⌘ + Shift + m      |
| 打开“开发者工具”                               | ⌘ + Option + i     |
| 显示当前网页的 HTML 源代码（不可修改）         | ⌘ + Option + u     |
| 打开 JavaScript 控制台                         | ⌘ + Option + j     |

###  终端

`终端的Keyboard设置中有“Use Option as Meta key”选项 即可使用 option == alt 键`

| 移动    | a e xx b f     |
| ------- | -------------- |
| ctrl+a  | 移动行首       |
| ctrl+e  | 移动行尾       |
| ctrl+xx | 行首行尾间移动 |
| ctrl+b  | 左移一个字符   |
| ctrl+f  | 右移一个字符   |
| alt +b  | 左移一个单词   |
| alt +f  | 右移一个单词   |

| 搜索     | r g p n                              |
| -------- | ------------------------------------ |
| ctrl + r | 搜索历史命令,Enter执行 ESC显示不执行 |
| ctrl+g   | 退出历史搜索                         |
| ctrl + p | 显示上一条命令                       |
| ctrl+n   | 显示下一条命令                       |

| 删除   | h w d u k _                        |
| ------ | ---------------------------------- |
| ctl+h  | 删除左边的字符                     |
| ctrl+d | 删除右边的字符，无自符退出系统     |
| ctrl+u | 删除光标左方所有的字符             |
| ctrl+k | 删除光标右方所有的字符             |
| alt+d  | 删除右边的单词                     |
| ctrl+w | 删除左边单词                       |
| ctrl+_ | 撤销操作                           |
| Ctrl+l | 清屏                               |
| Ctrl+r | 搜索历史命令                       |
| Ctrl+z | 当前进程后台运行 fg恢复 disown后台 |
| Ctrl+d | 无命令时退出当前shell              |

```bash
# 设置终端提示PS1
# 用户 目录（分支）
function git_br() {
	local git_branch
	ls .git &> /dev/null
	if [ $? == 0 ];then
		git_branch=$(git branch | grep ^* | awk '{print $2}')
                git_branch="($git_branch)"
	else
		git_branch=''
	fi
        echo $git_branch
}

# h主机 u用户 W目录 $默认提示符（root为#）
#PS1='\h:\u \W\$ '
export PS1='\u \W$(git_br)\$ '
export CLICOLOR=1
# 深蓝色
export LSCOLORS=gxfxcxdxbxegedabagacad

# alias
alias gitee='cd /data/go/src/gitee.com/feareless11'
alias github='cd /data/go/src/github.com'
```

### Mac

| 操作                                        | 说明         |
| ------------------------------------------- | ------------ |
| Ctrl + Command + Q                          | 锁屏         |
| Cmd + Shift + 4                             | Mac截屏      |
| 回车键                                      | 重命名       |
| 右侧的Command键                             | Windows键    |
| sudo scutil --set HostName newName          | 设置主机名   |
| open /                                      | 快速打开目录 |
| 开机长按cmd＋shift＋r，进入终端 resetpasswd | 重置密码     |

### vscode

- 插件：启动耗内存，不用可禁
  - Markdown-toc、sftp、draw.io、Restclient

```bash
 # centos
 sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
 sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=ht    tps://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
 
 yum check-update
 sudo yum install code
```

| 说明                                  | 操作                     |
| ------------------------------------- | ------------------------ |
| 创建文件                              | ctrl+n  、 ⌘N            |
| 关闭文件                              | ctrl+w                   |
| 保存文件                              | ctrl+s                   |
| 创建vscode窗口                        | ctrl+shift+n             |
| 关闭vscode窗口                        | ctrl+shift+w             |
| 主命令                                | ctrl+shift+p             |
| 直接跳转到文件                        | ctrl+p 后输入文件名      |
| 列出当前可执行动作                    | ctrl+p 后输入?           |
| 跳到指定行数                          | ctrl+p 后输入:           |
| 跳转到指定函数或变量                  | ctrl+p 后输入@           |
| 文件切换                              | crtl+tab 或 alt+左右箭头 |
| 查看函数定义                          | alt+F12                  |
| mac回退                               | ctrl+-                   |
| mac前进                               | ctrl+shift+-             |
| 快速打开浏览器                        | alt+shfit+b              |
| 格式化代码                            | shift+alt+f              |
| 显示左侧                              | ctrl+B                   |
| 打开终端                              | ctrl+`                   |
| 快速生成html文档                      | !+回车                   |
| gitbash进入目录快速调用vscode打开目录 | code .                   |
| 运行代码调试                          | F5双击                   |
| 设置断点                              | F9                       |
| 跳到函数定义                          | F12                      |

- 插件配置

  ```json
  #  插件: F1或ctrl+shift+p， 输入命令Extensions:Install Extension —> 输入插件名
  #  配置: 菜单File — Preferences — User - Extensions - Go - Edit in settings.json
  {
    "window.zoomLevel": 0,
    "files.autoSave": "off",
    "files.eol": "\n",
    "editor.columnSelection": false,
    "editor.fontSize": 20,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    },
    "editor.renderWhitespace": "all",
    "editor.minimap.enabled": true,
    "breadcrumbs.enabled": true,
    "debug.allowBreakpointsEverywhere": true,
    "git.path": "D:\\Program Files (x86)\\Git\\cmd\\git.exe",
    "go.gopath": "D:\\gohome",
    "go.goroot": "D:\\Program Files (x86)\\go",
    "go.buildOnSave": "package",
    "go.lintOnSave": "package",
    "go.formatTool": "goimports",
    "go.useCodeSnippetsOnFunctionSuggest": true,
    "go.useLanguageServer": false,
    "go.useGoProxyToCheckForToolUpdates": true,
    "eslint.validate": [
      "javascript",
      "javascriptreact",
      "html",
    ],
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "yapf",
    "python.linting.flake8Args": [
      "--max-line-length=248"
    ],
    "python.linting.pylintEnabled": false,
  }
  ```

- 插件 sftp

  ```json
  # 安装插件 sftp 后左侧扩展图标下新增一个远程目录图标
  # 工作空间 .vscode/sftp.json
  {   
      # 远程目录的别名
      "name": "vue",
      "host": "192.168.56.101",
      "protocol": "sftp",
      "port": 22,
      "username": "root",
      "password": "root123456",
      # 默认vscode的工作区目录，设置要同步的目录
      "context": "D:\\gohome\\src\\github.com\\didi\\nightingale",
      # 同步到远程机器的目录
      "remotePath": "/data/vue",
      # 保存上传
      "uploadOnSave": true,
      # 忽略的文件不上传
      "ignore": [
          ".vscode",
          ".git",
          ".DS_Store"
      ],
      # 监听，重命名文件或删除同步更新
      "watcher": {
          "files": "**/*",
          "autoUpload": true,
          "autoDelete": true
      },
      # 支持不同git分支同步到不同主机
      "profiles": {
          "dev": {
              "host": "192.168.56.101",
              "remotePath": "/data/vue",
              "uploadOnSave": true
          },
          "master": {
              "host": "192.168.56.101",
              "remotePath": "/data/vue2"
          }
      },
      "defaultProfile": "master"
  }
  ```

- 插件 [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)

  ```json
  # 类似postman，支持 cURL 和 RFC 2616两种标准来调用REST API
  
  注释符 #
  请求发送分隔符 ###
  
  ### cURL GET
  # 自动生成代码: ctrl+alt+c 后选择语言即可生产对应语言的代码
  curl -X GET "http://alert.zhenaioa.com/api/v1/users"
  
  ### Basic Auth
  GET https://httpbin.org/basic-auth/user/passwd HTTP/1.1
  Authorization: Basic user:passwd
  
  ### RFC 2016 POST
  POST http://alert.oa.com/api/v1/alert HTTP/1.1
  User-Agent: rest-client
  Content-Type: application/json
  Authorization: token xxx
  
  {
      "alertname": "vscode-REST-client",    
      "from": "Test",
      "level" : "I",                        
      "txt": "ok"
  }
  
  ### custom Environment variables
  # 根据不同分支环境区分变量
  # 在settings.json中rest-client.environmentVariables设置
  GET http://{{host}}/api/{{version}}/users HTTP/1.1
  Authorization: {{token}}
  
  ### file variables
  @hostname = alert.oa.com
  @port = 8080
  ### 
  @name = hello
  GET https://{{hostname}}:{{port}}/authors/{{name}} HTTP/1.1
  
  ### Request Variables
  # 根据请求返回的结果值来判断
  # 发送请求前先声明 // @name requestName or # @name requestName
  @baseUrl = https://example.com/api
  
  # @name login
  POST {{baseUrl}}/api/login HTTP/1.1
  Content-Type: application/x-www-form-urlencoded
  
  name=foo&password=bar
  
  ###
  @authToken = {{login.response.headers.X-AuthToken}}
  
  # @name createComment
  POST {{baseUrl}}/comments HTTP/1.1
  Authorization: {{authToken}}
  Content-Type: application/json
  
  {
      "content": "fake content"
  }
  
  ### system variables
  # {{$processEnv [%]envVarName}}: local machine environment variable
  # {{$dotenv [%]variableName}}: the .env file value 
  # {{$timestamp [offset option]}}: Add UTC timestamp of now. 
  # {{$datetime rfc1123|iso8601|"custom format"|'custom format' [offset option]}}: Add a datetime string in either ISO8601, RFC1123 or a custom display format. 
  # {{$localDatetime rfc1123|iso8601|"custom format"|'custom format' [offset option]}}: Similar to $datetime except that $localDatetime returns a time string in your local time zone.
  
  # {{$timestamp -3 h}} : 3 hours ago
  # {{$timestamp 2 d}} : tthe day after tomorrow
  POST https://api.example.com/comments HTTP/1.1
  Content-Type: application/xml
  Date: {{$datetime rfc1123}}
  
  {  
      "SECRET": "{{$processEnv SECRET}}",
      "user_name": "{{$dotenv USERNAME}}",
      "request_id": "{{$guid}}",
      "updated_at": "{{$timestamp}}",
      "created_at": "{{$timestamp -1 d}}",
      "review_count": "{{$randomInt 5 200}}",
      "custom_date": "{{$datetime 'YYYY-MM-DD'}}",
      "local_custom_date": "{{$localDatetime 'YYYY-MM-DD'}}"
  }
  ```