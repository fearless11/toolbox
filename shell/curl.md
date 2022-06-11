[toc]

# curl

## 配置

- ENV
  
  ```bash
  http_proxy, HTTPS_PROXY, FTP_PROXY
  ALL_PROXY
  NO_PROXY
  ```

## 用例

- GET

    ```bash
    # 默认80的http
    curl https://www.example.com

    # 指定8000的http
    curl http://www.example.com:8000

    # ftp请求
    curl ftp://ftp.funet.fi

    # 多个请求
    curl ftp://ftp.funet.fi/ http://www.example.    com:8000/

    # scp请求
    curl -u username: --key ~/.ssh/id_rsa scp://    example.com/~/file.txt
    curl -u username: --key ~/.ssh/id_rsa --pass    private_key_password
    scp://example.com/~/file.txt

    # ipv6的http
    curl "http://[2001:1890:1112:1::20]/"
    ```

- 认证

   ```bash
   # ftp方式一
   curl ftp://name:passwd@machine.domain:port/full/path/to/file

   # ftp方式二
   curl -u name:passwd ftp://machine.domain:port/full/path/to/file

   # http方式一
   curl http://name:passwd@machine.domain/full/path/to/file

   # http方式二
   curl -u name:passwd http://machine.domain/full/path/to/file
   ```

- 上传

   ```bash
   # 所有的stdin到ftp
   curl -T - ftp://ftp.upload.com/myfile

   # 指定文件并重命名
   curl -T uploadfile -u user:passwd ftp://ftp.upload.com/myfile

    # 指定文件
   curl -T uploadfile -u user:passwd ftp://ftp.upload.com/
   
   # 追加
   curl -T localfile -a ftp://ftp.upload.com/remotefile

   # 所有的stdin到http
   curl -T - http://127.0.0.1:8090/myfile
   ```

- 下载

    ```bash
    # 另存为
    curl -o thatpage.html http://www.example.com/

    # 保存
    curl -O http://www.example.com/index.html

    # 多个文件
    curl -O www.haxx.se/index.html -O curl.se/download.html
    ```

- 指定HTTP或SOCKS代理

  ```bash
  # http代理
  curl -x my-proxy:888 ftp://ftp.leachsite.com/README

  # http代理，网站认证
  curl -u user:passwd -x my-proxy:888 http://www.get.this/

  # http代理认证
  curl -U user:passwd -x my-proxy:888 http://www.get.this/
  ```

- 指定获取字节数

   ```bash
   # 开始的100 bytes
   curl -r 0-99 http://www.get.this/

   # 最后的500 bytes
   curl -r -500 http://www.get.this/
   ```

- 调试

  ```bash
  # 请求详情
  curl -v ftp://ftp.upload.com/

  # 请求追踪
  curl --trace trace.txt www.haxx.se
  ```

- POST

    ```bash
    # 简单
    curl -d "name=Rafael%20Sagula&phone=3320780" http://127.0.0.1:8090

    #  multipart/form-data的方式，文件用@区分，没指定type的时候默认application/octet-stream
    curl -F "coolfiles=@fil1.gif;type=image/gif,fil2.txt,fil3.html"
  http://www.post.com/postit.cgi

    # post form
    curl -F "file=@cooltext.txt" -F "yourname=Daniel" -F "filedescription=Cool text file with cool text inside" http://127.0.0.1:8090
    ```

- 头部

   ```bash
   # referrer
   curl -e www.coolsite.com http://127.0.0.1:8090

   # User Agent
   curl -A 'Mozilla/3.0 (Win95; I)' http://127.0.0.1:8090

   # 指定Cookie: name=Daniel
   curl -b "name=Daniel" 127.0.0.1:8090 

   # 指定上一个请求的cookie
   curl --dump-header headers www.example.com
   curl -b headers www.example.com

   # 额外头部
   curl -H "X-you-and-me: yes" 127.0.0.1:8090 
   ```

- 进度
    
   ```bash
    # 不显示进度
    curl -s www.example.com

    # 不显示进度，但如果curl出错显示
    curl -sS www.example.com

    # 显示进度字段说明
    % - percentage completed of the whole transfer
    Total - total size of the whole expected transfer
    % - percentage completed of the download
    Received - currently downloaded amount of bytes
    % - percentage completed of the upload
    Xferd - currently uploaded amount of bytes
    Average Speed Dload - the average transfer speed of the download
    Average Speed Upload - the average transfer speed of the upload
    Time Total - expected time to complete the operation
    Time Current - time passed since the invoke
    Time Left - expected time left to completion
    Curr.Speed - the average transfer speed the last 5 seconds (the first 5 seconds of a transfer is based on less time of course.)
  ```

- 限速
 
  ```bash
  # 如果速度小于1分钟3000bytes则中止运行
  curl -Y 3000 -y 60 www.far-away-site.com

  # 限制必须30分钟完成，每分钟速度不低于3000bytes
  curl -m 1800 -Y 3000 -y 60 www.far-away-site.com

  # 限制最大传输速度不超过10K
  curl --limit-rate 10K www.far-away-site.com

  # 限制最大上传速度不超过1M
  curl -T upload --limit-rate 1M ftp://uploadshereplease.com
  ```

- 指定网卡

  ```bash
  # 网卡
  curl --interface eth0:1 http://www.example.com/

  # 出口
  curl --interface 192.168.1.10 http://www.example.com/
  ```

- 重连

  ```bash
  # -C - 表示curl自动处理在哪里怎样重传
  # -C <offset>

  # 不中断下载
  curl -C - -o file ftp://ftp.server.com/path/file

  # 不中断上传
  curl -C - -T file ftp://ftp.server.com/path/file
  ```

- 自定义输出

  ```bash
  # -w <format>
  http_code
  http_version
  local_ip
  local_port
  method
  referer
  remote_ip
  remote_port
  response_code
  size_download
  size_header
  size_request
  size_upload
  speed_download 
  speed_upload
  time_appconnect : ssh握手
  time_connect : tcp建立
  time_namelookup
  time_pretransfer
  time_starttransfer 
  time_total

  # 请求大小 byte
  curl -w '%{size_download} bytes\n' www.example.com

  # 请求状态
  curl -sS -o /tmp/a -w ' http_code %{http_code}\n response_code %{response_code}\n' www.example.com

  # 耗时
  curl -sS -o /tmp/a -w ' time_appconnect: %{time_appconnect}\n time_connect: %{time_connect}\n time_namelookup: %{time_namelookup}\n time_pretransfer: %{time_pretransfer} \n time_starttransfer: %{time_starttransfer}\n time_total: %{time_total}\n' www.example.com

  time_appconnect: 0.000
  time_connect: 0.004
  time_namelookup: 0.004
  time_pretransfer: 0.004 
  time_starttransfer: 0.332
  time_total: 0.332
  ```

## 资料

[tutorial-https://curl.se/docs/manual.html](https://curl.se/docs/manual.html)
[usage-https://curl.se/docs/manpage.html](https://curl.se/docs/manpage.html)