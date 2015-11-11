---
layout: post.cn
title: ZStack 助力PaaS／SaaS 高效集成IaaS －－ ZStack云环境的快速备份和还原
date:   2015-11-11
categories: blog
author: Yongkang You
category: cn_blog
---

ZStack的快速安装能力解决了传统基础架构即服务软件部署过程过于繁琐的问题。不过安装IaaS软件本身只是第一步。
安装ZStack之后，用户还需要在ZStack上添加计算、存储、网络等相关资源，才能创建云主机。如果用户需要反复的测试部署云环境的过程，例如：

1，给不同的客户演示ZStack的环境的使用过程
2，PaaS和SaaS产品，需要集成ZStack作为IaaS管控层。在搭建PaaS／SaaS私有云的过程中，快速搭建ZStack云环境。

ZStack已经充分的考虑了PaaS／SaaS用户的快速集成，以及需要经常的搭建演示相同的ZStack环境的需求。
对此，ZStack提供了备份和还原云的能力。用户只需要把当前搭建好的云环境备份到一个xml文件中，
之后就可以在一个新装的ZStack环境里使用该xml文件快速还原云环境。'''这一切都要归功于ZStack的全API交付能力'''。
所谓IaaS API的全交付能力，就是指通过API便可以创建IaaS所需要的全部资源。

下面我们就来看一看ZStack的备份和还原云是怎么操作的。

假设我们已经搭建了ZStack，并且配置了一个可以创建虚拟机的云环境。那么备份当前云环境的命令非常简单：

1. 首先你需要用zstack-cli登录zstack环境（如果没有更改过密码，密码就是password）：

zstack-cli LogInByAccount accountName=admin password=password

2. 如果IaaS已经部署（或者部署了一部分，例如你可以只部署到下载完Image Template和添加完主存储和备份存储的相关操作。
那么下次还原的时候，也可以是恢复一个IaaS云环境的中间状态），就可以用下面的命令来备份云环境到一个xml文件中去，
备份的参数是 '-D' （切勿和还原的小 '-d' 搞混淆，每次执行命令前也可以使用'-h'查看）：

zstack-cli -D /tmp/ec2-cloud.xml

dump好的xml文件的内容是这样的：

<img class="img-responsive" src="/images/blogs/dump-zstack/dump-xml.png">

---

需要注意的是zstack-cli在备份云环境的时候，调用的是Query相关的API。由于Query API无法取到两个重要信息的：
'''Host的用户名和密码，SftpBackupStorage的用户名和密码'''，所以这两个信息需要用户手动添加，不过手动编辑一下还是非常简单的：

<img class="img-responsive" src="/images/blogs/dump-zstack/dump-xml2.png">

---

3. 还原IaaS环境前，为了保证一个干净的环境，请务必停止ZStack server，重新初始化数据库，和再重启ZStack server
(如果是全新安装的ZStack，可以跳过这步。)：

`zstack-ctl stop_node`

zstack-ctl deploydb --host=YOUR_DB_IP_ADDRESS --drop

`zstack-ctl start_node`

4. 使用下面这条命令来还原IaaS环境：

zstack-cli -d /tmp/ec2-cloud.xml

如果用户的image是放在本地的，整个还原过程会非常快速（例如小于1分钟）。

有了云环境的快速备份和还原，ZStack是不是非常适合我们的PaaS和SaaS软件集成呢？ZStack欢迎和各种PaaS和SaaS的应用服务公司合作。

