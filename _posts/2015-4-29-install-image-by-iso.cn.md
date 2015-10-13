---
layout: post.cn
title:  "在ZStack用ISO文件安装虚拟机模板"
date:   2015-4-29
categories: blog
author: Yongkang You
category: cn_blog
---
IaaS的快速启动虚拟机的奥秘之一，就是把操作系统预先装到一个公共的模板之中。当用户创建一个新的虚拟机的时候，IaaS就会复制该模板作为新虚拟机的根分区，从而省掉了安装部署等操作。基于KVM，ZStack目前支持qcow2和raw两种格式的模板。在ZStack官网上，可以下载到两个虚拟机的模板：virtual-router和ttylinux。其中virtual-router是一个特殊的模板，它用于ZStack的基本网络服务（DHCP，DNS，SNAT，EIP，PortForwarding）使用的；而ttylinux是一个超小的Linux模板，文件大小只有十几兆（最小启动内存可以低至24MB），具有最基本的网络功能，不过只用于演示用途。如果用户需要定制自己的虚拟机模板，通常需要自己先去用virt-manager这样的系统自带工具手动安装，然后再上传到一个http的服务器，略显麻烦。

ZStack解决了这个麻烦，提供了非常便捷的安装方式。如果用户有系统安装ISO文件，用户就可以通过ZStack的UI来安装一个全新的虚拟机，在进行各种系统配置之后，就可以把该虚拟机的根Volume保存成一个通用的模板文件。今天我们就要来看看，用户怎么利用ZStack安装和生成一个Ubuntu14.04的虚拟机模板。

初始条件，用户已经安装完ZStack，并且根据任何一个ZStack的用户手册（例如EIP，或者Flat Network），完成所有云环境的部署（可以成功创建一个虚拟机）。

第一，用户需要把系统安装ISO，通过Image菜单添加到ZStack的备份存储中。（ZStack all in one 安装的时候如果选择了-a参数，会把/usr/local/zstack/http_root作为httpd的目录，用户可以把ISO文件放在这个目录里，访问的方法是http://localhost/image/YOUR_ISO_NAME。）**不过我们还是强烈建议用户自己创建一个httpd的服务器，把自己用于安装的ISO放到这个服务器里面，以后可以长期使用。**

需要注意的是，在添加ISO的时候，如果添加的是Windows的ISO，那么在Platform的地方请选择Windows。
否则你的Windows安装程序会因为缺少virtio driver而找不到磁盘。当你你可以在安装好Windows后，添加VirtIO driver，
[并让你的数据磁盘运行在高速的VirtIO驱动上](http://zstack.org/cn_blog/install-virtio-for-windows.html)

另外在MediaType和Format两个域，均需要选择为**ISO**格式。

<img  class="img-responsive"  src="/images/tutorials/iso/add-iso.png">

<hr>

第二，用户需要添加一个存储模板（Disk Offering），这个存储模板的大小需要略大，例如10G，这个大小也就是未来虚拟机的根Volume的大小。这里我们先假定为RootVolumeOffering。

<img  class="img-responsive"  src="/images/tutorials/iso/add-disk-offering.png">
<hr>

第三，由于ZStack用户手册里面案例的虚拟机实例模板中内存和CPU分配的较小，可能会影响系统安装的速度。我们就再创建一个2个CPU和1G内存的虚拟机实例模板，这里我们先假定为InstallationOffering

<img  class="img-responsive"  src="/images/tutorials/iso/add-instance-offering.png">

<hr>
第四，现在我们可以创建一个新的虚拟机来用作Installation。这个创建虚拟机实例的选项和普通的创建过程略有不同。当在IMAGE一栏里选择刚刚添加的ubuntu image之后，会出现一个ROOT VOLUME DISK OFFERING让用户选择。选择RootVolumeOffering和L3network之后，就可以创建虚拟机了。

<img  class="img-responsive"  src="/images/tutorials/iso/create-install-vm.png">
<hr>

第五，虚拟机启动后就可以安装操作系统。在系统安装完毕后，还可以做一些其他必要的系统设置，或者软件安装。

<img  class="img-responsive"  src="/images/tutorials/iso/vm-installation.png">

	**安装好系统后，请不要让虚拟机自己reboot，否则虚拟机启动后可能会无法启动刚刚安装好的系统，而是又进入了安装的界面。这个时候只需要通过ZStack UI界面把虚拟机做一次Stop和Start的操作即可。**

<hr>
第六，将已经安装完毕配置完成的虚拟机stop（需要通过ZStack UI界面来stop 虚拟机）。

<img  class="img-responsive"  src="/images/tutorials/iso/vm-installation-stop-vm.png">

<hr>

第七，点击该虚拟机详情，并点击Volume选项，选择Root Volume，点击Action，选择Create Template。

<img  class="img-responsive"  src="/images/tutorials/iso/create-root-template-action.png">

输入新的Image的名字：new-ubuntu-14.04

<img  class="img-responsive"  src="/images/tutorials/iso/create-root-template.png">

Action成功之后，我们就会在Image的section里面看到刚刚添加的Root Volume Template了。

<img  class="img-responsive"  src="/images/tutorials/iso/create-root-template2.png">

    如果使用的是CentOS操作系统，为了让使用该虚拟机的模板的云主机在启动后自动获得IP地址，那么需要在保存模板前，在安装好的虚拟机上做如下操作：

        1. edit /etc/sysconfig/network-scripts/ifcfg-eth0:
```
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=dhcp
```

        2. rm -f /etc/udev/rules.d/70-persistent-net.rules

<hr>
第八，用户就可以在Instance界面选择刚刚创建的new-ubuntu的image来创建新的VM了：

<img  class="img-responsive"  src="/images/tutorials/iso/create-new-ubuntu-img.png">

<hr>
Okay，打完收工。是不是觉得用ZStack安装新的虚拟机模板会很容易呢？如果你还想了解更多的试用场景，请关注ZStack的官方微信。如果你有特别的场景需求，可以把你的需求发送到ZStack中国社区的QQ群：410185063。你会得到及时的解答和帮助。
