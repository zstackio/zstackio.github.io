---
layout: post.cn
title:  "给不同L3网络设置不同的 VirtualRouter Offering"
date:   2015-12-31
categories: blog
author: Yongkang You
category: cn_blog
---
## 前言
当用户的网络环境中有多套公有L3网络并且使用了 VirtualRouter(VR) 的网络服务的时候，就需要给创建虚拟机的L3网络配置不同的VR Offering。

由于每个VR Offering会设置特定的管理网络L3和公有网络L3，所以不同公有网络的L3网络应该配备不同的VR Offering，
否则会导致使用其中某个L3网络的虚拟机无法获得正常的网络连接能力。

## 网络场景描述

让我们先来看三种网络场景。第一张图描述了在一个典型的EIP网络模型下，有两个用户的私有网络，整个环境共用了相同的管理网络和公有网络。
在这个场景中，不同的用户网络进行了隔离。用户网络内的虚拟机通讯只发生在私有网络上。当需要访问外网环境时，
VM会通过不同的VR连接相同的公有网络。在这里，我们只需要设置一个默认的VR Offering即可，因为两个VR都是使用相同的公有网络。也就是说VR的配置相同。

<img src="/images/blogs/vroffering/zstack_1_pub_l3-2_pri_l3.png" class="center-img img-responsive">

有时候，由于一些特殊的原因（例如需要分摊流量、需要设置不同的公网出口等），我们会配置类似于第二张图的场景。
这个场景和第一张图唯一的不同是在于，两个私有网络访问公网的时候并不是通过相同的共有网络。
这个时候我们就需要给两个私有网络（private l3）配置不同的VR Offering。让其中一个VR走 Public L3-1 访问公网，
而另外一个走 Public L3-2 访问公网。

<img src="/images/blogs/vroffering/zstack_2_pub_l3_2_pri_l3.png" class="center-img img-responsive">

在扁平网络（Flat Network）模式中，我们更可能遇到多个公有网络的场景。每个公有网络有独立的网关。
例如下图所示，两个VR只负责给各自的L3网络做DHCP和DNS服务，
虚拟机VM1和VM3分别通过不同的公有网络进行网络通讯。这个时候我们也需要给两个公有网络（public l3）配置不同的 VR Offering。
VM会根据所在的不同的L3网络连接公有网络。

<img src="/images/blogs/vroffering/zstack_2_pub_l3.png" class="center-img img-responsive">

## 给不同的L3网络设置不同的VR Offering

首先我们要根据公有网络的数量创建相同数量VR Offering，我们可以把最常用L3的VR Offering设置成默认的。

接着我们就可以给不同L3网络配置不同VR Offering。具体的方法是通过设置系统标签（System Tag）的方式来完成的。
设置系统标签的zstack-cli命令是：

`CreateSystemTag resourceType=InstanceOfferingVO resourceUuid=YOUR_VR_OFFERING_UUID tag=guestL3Network::YOUR_L3_NETWORK_UUID`

这里的YOUR_VR_OFFERING_UUID需要替换成目标VR Offering的UUID
YOUR_L3_NETWORK_UUID替换为用于创建VM的L3网络的UUID。EIP模式下（图二），该网络是Private L3。
扁平模式下（图三），该网络是Public L3的UUID。千万留意该L3 网络UUID不可以指定错误。

如果还不熟悉zstack-cli命令，可以参考ZStack的用户教程里各种[命令行版本](http://zstack.org/cn/tutorials/flat-network-cli.html)的操作方法。

设置完后，ZStack就可以正确识别不同L3网络的VR Offering，并为不同VM使用不同的网络服务。

更多关于网络服务和VR的信息可以参考：[ZStack API文档](http://zstackdoc.readthedocs.org/en/latest/userManual/virtualRouter.html)
