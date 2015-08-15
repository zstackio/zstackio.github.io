---
layout: post.cn
title:  "ZStack 编译手册"
date:   2015-8-15
categories: blog
author: yongkang
category: cn_blog
---
##前言
最近越来越多的云端开发者开始阅读[ZStack API手册](http://zstackdoc.readthedocs.org/en/latest/)和[ZStack在GitHub上的源代码](https://github.com/zstackorg/zstack)。
其中部分开发者尝试基于ZStack进行二次开发（例如把传输云主机图像的VNC协议换成Spice协议，需要让ZStack创建的云主机拥有嵌套虚拟化，
给ZStack加上特别的监控程序，让ZStack管理非硬件虚拟化支持的Qemu虚拟机，更改UI界面等等）。
这些工作可能需要在ZStack中添加新的代码，并重新编译安装包。本文将会介绍标准的ZStack的编译打包方法。
使用该方法，开发人员可以快速的添加新的功能，并生成自己新的ZStack安装包。

***

##下载ZStack源代码
目前ZStack的源代码由三个软件仓库构成：

1.  [zstack](https://github.com/zstackorg/zstack)使用Java编写，是ZStack的核心，负责IaaS各种资源管理调度和消息通讯；
2.  [zstack-utility](https://github.com/zstackorg/zstack-utility)目前主要使用Python编写，包含ZStack的各种终端代理和其他工具。
    这些终端代理负责接收来自ZStack核心的消息并执行对应的操作，例如和Libvirt通讯来管理VM的生命周期、各种存储（例如Ceph，iSCSI，SFTP）的管理、
    虚拟路由器里管理VM的IP地址等等。除了终端代理工具外，这个软件仓库还包含了ZStack其他的工具，例如ZStack的编辑打包工具、
    ZStack安装程序、ZStack命令行工具、ZStack管控工具等等。
3.  [zstack-dashboard](https://github.com/zstackorg/zstack-dashboard)使用JavaScript编写，是ZStack的图形界面。

编译ZStack All In One Package，你需要先从github上下载上面三个源代码。

<pre><code>
mkdir /root/zstack-repos
cd zstack-repos
git clone https://github.com/zstackorg/zstack.git
git clone https://github.com/zstackorg/zstack-utility.git
git clone https://github.com/zstackorg/zstack-dashboard.git 
</code></pre>

***
## 下载安装编译依赖
编译OS最好是在CentOS6.6或者CentOS7.1里进行。在编译之前，需要确保系统上已经安装了ant，maven，java-1.7.0-openjdk-devel，bzip2，gzip等工具。
另外由于ZStack核心是Java代码，里面需要很多maven的依赖库，但是很多maven的依赖库的第一选择都是放在google管理的软件仓库。
由于总所周知的原因，会导致第一次编译ZStack的时候异常缓慢，甚至是无法通过。不过maven的.m2/库是可以在不同机器上共享的。
我们在百度云盘里放置了一份编译的依赖包：http://pan.baidu.com/s/1eQvUmWU。
大家下载之后，可以根据说明，把依赖库的内容放到/root/.m2 的目录里即可（随着ZStack的开发，ZStack可能会引入一些新的库文件，
有可能在编译新的ZStack的时候，还是会遇到动态下载少量的依赖包，不过由于新的依赖包数量不多，所以下载速度应该可以接收）。

另外如果有条件，大家也可以使用http代理服务器加速maven依赖包的下载，设置的方法可以参考：https://maven.apache.org/guides/mini/guide-proxies.html

***
## 预编译ZStack的Java代码
验证一下Java和Maven相关的依赖是不是已经解决正常，我们先来编译一下ZStack的Java源码：
<pre><code>
cd zstack
mvn -DskipTests clean install
</code></pre>
如果一切顺利，我们大概只需要等待5分钟。

***
## 编译ZStack All In One安装包
如果ZStack的Java源码已经编译通过，我们就可以开始尝试编译ZStack All In One安装包了：
<pre><code>
cd ~/zstack-repos/
wget -c http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.35/bin/apache-tomcat-7.0.35.zip
cd zstack-utility/zstackbuild
ant -Dzstack_build_root=/root/zstack-repos all-in-one
</code></pre>

编译完成，安装包会放在zstack-utility/zstackbuild/target/目录中，例如：
zstack-utility/zstackbuild/target/zstack-all-in-one-0.8.0-qa.tgz
All In One安装包包含了ZStack核心功能，ZStack终端代理，ZStack管控工具和ZStack Web界面。

如果用户只是改变了Java代码，其实只需要更新ZStack核心功能即可。ZStack的核心代码是编译打包到zstack.war中，
该文件会放在 zstack-utility/zstackbuild/target/zstack.war

有了新编译完成的ZStack包，用户便可以参考我们的[安装升级手册](http://zstack.org/cn_blog/v0.8-release.html)来安装自己编译的ZStack安装包了。

***
## ZStack 集成测试用例
在开发新功能的时候，不要忘记添加自己的集成测试用例。ZStack的集成测试用例都是放在zstack/test/ 目录下的。
开发者可以学习之前的集成测试用例来创建自己的测试用例。在成功完成**预编译ZStack的Java代码**之后，
我们可以使用如下的方法来运行集成测试用例：

运行一个测试用例：
<pre><code>
cd zstack/test/
mvn test -Dtest=test_case_name 
#for example: for TestChangeHostState.java, the name is TestChangeHostState
mvn test -Dtest=TestChangeHostState
</code></pre>

运行一组测试用例：
<pre><code>
cd zstack/test/
mvn test -Dtest=UnitTestSuite -Dconfig=unitTestSuiteXml/AccountManager.xml 
#all group test configures are in zstack_source/test/src/test/resources/unitTestSuiteXml/
</code></pre>

运行全部的测试用例：
<pre><code>
cd zstack/test/
mvn test -Dtest=UnitTestSuite
</code></pre>
