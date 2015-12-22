---
layout: post
title:  "ZStack开发分享－－给Qemu增加Cache Mode"
date:   2015-12-22
categories: blog
author: Matts Yan 
category: cn_blog
---
## 前言

笔者一直以来都持续关心着各种云相关的软件发展的情形和趋势, 但始终没有真正的去折腾它。
直到今年五月份在 Ceph 群组里听到了一个名为 ZStack的 IaaS 开源软件, 于是在自己的好奇心驱使下加入了 ZStack中国社区QQ群组。
在群里潜水了几个月后发现安装似乎很容易, 所以开始试著依照
http://ZStack.org/cn/installation/ 上的一键安装来安装 ZStack, 果然是非常容易安装

接着按照[扁平网络的教程](http://ZStack.org/cn/tutorials/flat-network-ui.html), 正准备继续折腾，却发生VM 无法启动的问题, 顿时觉得有点小失望。


详细的错误讯息请见
https://github.com/ZStackorg/ZStack/issues/146

后来通过Google搜索发现原来是 Qemu 的 Cache Option 和文件系统兼容性所引起的问题。
这个问题的起源是因为我的机器里用的文件系统是ZFS (操作系统是 Ubuntu 14.04), 但是ZFS 不支持 O_DIRECT 所造成的。 
因为 ZStack 0.9中在创建 VM 时都是使用 'cache=none', 但是在 ZFS 作为 VM 主存储时 cache 必须为 writethrough 或者 writeback 才行。
去群里向原开发者请教之后发现可以通过在 GlobalConfig中增加一个配置来实现Qemu cache 模式的切换，来解决这个问题。
看起来这个方法实现起来也不会太困难, 于是开始着手解决这个问题。

##实际动手
先参考一些官方的文件来了解 ZStack 源代码
(以下些许内容取自 ZStack 官网 http://ZStack.org/cn )
目前ZStack的源代码由三个软件仓库构成：

 1. ZStack使用Java编写，是ZStack的核心，负责IaaS各种资源管理调度和消息通讯；
 2. ZStack-utility目前主要使用Python编写，包含ZStack的各种终端代理和其他工具。 这些终端代理负责接收来自ZStack核心的消息并执行对应的操作，例如和Libvirt通讯来管理VM的生命周期、各种存储（例如Ceph，iSCSI，SFTP）的管理、 虚拟路由器里管理VM的IP地址等等。除了终端代理工具外，这个软件仓库还包含了ZStack其他的工具，例如ZStack的编辑打包工具、 ZStack安装程序、ZStack命令行工具、ZStack管控工具等等。
 3. ZStack-dashboard使用JavaScript编写，是ZStack的图形界面。

(为免篇幅太长, 关于怎么从 Github 取出源码的部分在此省略了)

基本上修改的思路为三个步骤：
 1. 新增一个全局的变量叫 CacheMode （Java编写）
 2. 将此新的全局变量传给 ZStack-utility 里的 agent (Python 编写的)
 3. 在 Python编写的 agent 里, 依照此全局变量的值做出对应的设置

###步骤一
首先修改 ZStack 的部分, 
在 conf/globalConfig/kvm.xml新增一个element

<img src="/images/blogs/cache_mode/1.png" class="center-img img-responsive">

在 plugin/kvm/src/main/java/org/ZStack/kvm/KVMGlobalConfig.java 新增全局的变量

<img src="/images/blogs/cache_mode/2.png" class="center-img img-responsive">

到此基本上已经在 Web UI 的 Global Configure 新增一个配置 vm.CacheMode (见下图)

<img src="/images/blogs/cache_mode/3.png" class="center-img img-responsive">


###步骤二
修改 ZStack 的部分,
在plugin/kvm/src/main/java/org/ZStack/kvm/KVMAgentCommands.java 中
public static class VolumeTO 中新增私有的变量及公有的方法

<img src="/images/blogs/cache_mode/4.png" class="center-img img-responsive">

接著修改 plugin/kvm/src/main/java/org/ZStack/kvm/KVMHost.java
在 startVm 方法里透过 VolumeTO 类新增的方法将新增的 Global Config 配置传给 ZStack-utility agent

<img src="/images/blogs/cache_mode/5.png" class="center-img img-responsive">

到这边 ZStack 部分算是修改完成

###依照官方说明的方法来编译ZStack Java 源码
http://ZStack.org/cn_blog/build-ZStack.html

`cd ZStack`
`mvn -DskipTests clean install`

<img src="/images/blogs/cache_mode/6.png" class="center-img img-responsive">

如果过程顺利应该会看到如下的输出

<img src="/images/blogs/cache_mode/7.png" class="center-img img-responsive">


### 步骤三
最后我们还要修改 ZStack-utility agent在收到我们新增的全局配置后做出对应的修改
kvmagent/kvmagent/plugins/vm_plugin.py

<img src="/images/blogs/cache_mode/8.png" class="center-img img-responsive">

<img src="/images/blogs/cache_mode/9.png" class="center-img img-responsive">

### 步骤四
依照官方说明的方法来编译ZStack All In One 安装包
http://ZStack.org/cn_blog/build-ZStack.html

### 编译ZStack All In One安装包
如果ZStack的Java源码已经编译通过，我们就可以开始尝试编译ZStack All In One安装包了：
`cd ~/ZStack-repos/`
`wget -c http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.35/bin/apache-tomcat-7.0.35.zip`
`cd ZStack-utility/ZStackbuild`
`ant -DZStack_build_root=/root/ZStack-repos all-in-one`

因为default git 都会去 checkout master 分支来编译  ZStack All In One包,下面是我使用的方式

`ant 	-DZStack.build_version=0.9fix 
-DZStackutility.build_version=0.9fix 
-DZStackdashboard.build_version=0.9 
-Dbuild_name=qa 
-DZStack_build_root=/home/matt/ZStack-github all-in-one`

(关于 –D 相关的选项, 可以看 ZStack-utility/ZStackbuild/build.properties)
如果过程顺利应该会看到如下的输出

<img src="/images/blogs/cache_mode/10.png" class="center-img img-responsive">

###后话

对于新增全局配置的修改大致上就是这样, 唯一要特别注意的地方是, 修改 ZStack Java代码的部分, 关于新增全局配置的变量和方法该摆放在哪一个类, 为了以后代码的维护以及可读性, 最好还是可以跟原始开发者讨论讨论, 本范例会修改在 VolumeTO 类 里, 不代表著所有新增的全局配置都需要修改在那边（意思是有经过些许判断的）, 主要还是得依照新增的配置去找出比较相关的类去修改会比较适当, 以上为个人一点小小的心得。

