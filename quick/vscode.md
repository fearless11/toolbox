---
title: vscode插件
date: 2020-06-25 06:47:00
tags: vscode
description: vscode插件
toc: true
---

## vscode plugin
   [https://code.visualstudio.com/docs](https://code.visualstudio.com/docs)

### Remote Development 远程开发调试 
[简书](https://www.jianshu.com/p/0f2fb935a9a1)

- 远程主机 [install ssh_server](https://code.visualstudio.com/docs/remote/troubleshooting#_installing-a-supported-ssh-server)
  
  ```bash
  # 安装ssh_server
  # Debian 8+ / Ubuntu 16.04+
  sudo apt-get install openssh-server	

  # RHEL / CentOS 7+	
  sudo yum install openssh-server && sudo systemctl start sshd.service && sudo systemctl enable sshd.service
  ```
- 本地主机 [install ssh_client](https://code.visualstudio.com/docs/remote/troubleshooting#_installing-a-supported-ssh-client)

- 免密登陆 
  ```bash
  # 本地主机生成id_rsa.pub 
  ssk-keygen    # 回车
  cat ~/.ssh/id_rsa.pub 
  #ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC63//hcCLABAdyA4u1 haha@vera

  # 远程主机保存id_rsa.pub到authorized_keys 
  cat  ~/.ssh/authorized_keys 
  #ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC63//hcCLABAdyA4u1 haha@vera
  chmod 600 ~/.ssh/authorized_keys 
  ```

- vscode配置
  
  - 安装插件: Remote Development
  - 配置终端：ctrl+shift+p —> Remote-SSH-Settings -> 勾选Show Login Terminal
  - 配置主机：ctrl+shift+p —> Remote-SSH：Connect to Host -> Configure SSH Hosts->选择一个config
    ```bash
    Host VM-centos7
        HostName 192.168.57.5
        User root
    ```
  - vscode左侧边框出现远程图标Remote Expoler： 选择配置好的VM-centos7右键登陆即可



  


