---
layout: post.cn
title:  "【免安装】ZStack v0.9三层网络VMWare镜像 "
date:   2015-9-24
categories: blog
author: Yongkang You
category: cn_blog
---

zstack.tw社区最近制作了ZStack 0.9 VMware Workstation镜像并上传到百度云盘。感兴趣试用的同学可以按照下面的介绍下载试用。

本次镜像里按照了ZStack 0.9，并且配置了复杂的三层网络模式 (Three Tiered Network模式)

**ovf档案百度云盘下载位置**

http://pan.baidu.com/s/1pJmqR8n

配置说明：

1.操作系统centos7，预设帐号root，默认密码zstack

2.网络模式是NAT模式，默认ip位置是192.168.230.140

3.开机后记得启动zstack node服务与ui ｀zstack-ctl start_node;zstack-ctl start_ui｀

4.已经下载安装了两个VM的qcow2文件： ttylinux.qcow2， zstack-virtualrouter-0.9.0.qcow2

 镜像所在目录：

 /var/www/html/qcow2

 url位置：

 http://192.168.230.140/qcow2

5.Linux安装ISO的文件也已下载，共有两个ISO档案，练习安装虚拟机会用到：

 CentOS-7-x86_64-Minimal-1503-01.iso

 ubuntu-14.04.3-server-amd64.iso

 文件位置：

 /var/www/html/iso

 url位置：

 http://192.168.230.140/iso

如果遇到安装使用的问题，大家可以到ZStack QQ群：410185063里需求帮助。
