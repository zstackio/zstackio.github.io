---
layout: post.cn
title:  "在Windows VM中使用data volume"
date:   2015-7-25
categories: blog
author: Yongkang You
category: cn_blog
---

##适用版本：##
**ZStack v0.8.0 + **

##介绍##
由于KVM不提供Windows SCSI驱动，ZStack只能使用 IDE和virtio两种模式提供硬盘驱动。其中IDE由于无法支持硬盘hotplug，这导致使用IDE硬盘来添加数据磁盘的时候必须要重启虚拟机。所以想要实现动态的数据磁盘添加和删除操作，需要使用virtio类型的磁盘。由于Windows系统中没有包含virtio的驱动，所以用在创建Windows虚拟机模版的时候，需要额外安装virtio的驱动程序，否则在0.8以后的系统中，无论是否重启虚拟机，用户都无法直接使用新添加的数据磁盘。

<div class="bs-callout bs-callout-info">
  <h4>RedHat VirtIO 下载地址</h4>
完整的virtio驱动下载页面在
https://fedoraproject.org/wiki/Windows_Virtio_Drivers
此外，Redhat提供了一个教程安装virtio驱动，但该教材讲述的是安装ballon驱动，并且对磁盘驱动的描述是不准确的。
我们下面提供的教程已在Windows7上成功实验过
</div>

要使用virtio驱动，用户需要先通过ISO安装好一个windows VM，然后根据以下步骤进行：
1. 下载virtio驱动到windows VM，地址：https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso，下载完成后可以用WinRAR等工具解压
2. attach一个data volume到windows VM。
3. 在设备管理器中，可以看到一个未知的SCSI controller

<img  class="img-responsive"  src="/images/blogs/windows-virtio/add-device1.png">

4. 如下图所示选中PCI BUS，右键点击，弹出菜单后选择"Update Driver Software..."
<img  class="img-responsive"  src="/images/blogs/windows-virtio/add-device2.png">

5. 选着从本地安装驱动，把路径指向解压的virtio驱动。使用的驱动文件夹为viostor (不要选择vioscsi，这个是virtio-scsi设备的驱动，用于ISCSI设备，viostor是块设备的磁盘驱动）

<img  class="img-responsive"  src="/images/blogs/windows-virtio/add-device3.png">

6. 右键点击未知的SCSI Controller，同样使用"Update Driver Software..."，安装viostor驱动（如果不执行步骤5更新PCI驱动，SCSI controller右键点击不会出现更新驱动的菜单）

<img  class="img-responsive"  src="/images/blogs/windows-virtio/add-device4.png">

<img  class="img-responsive"  src="/images/blogs/windows-virtio/add-device5.png">
7. 安装完驱动后，就可以使用windows自带的磁盘管理工具发现新硬盘并格式化。

<div class="bs-callout bs-callout-info">
  <h4>动态卸载磁盘</h4>
Widnows virtio驱动对detach volume支持不好，我们发现在volume detach后在windows里仍可以看到该磁盘，但操作的时候会导致系统挂起。
建议用户在detach volume后重启windows。
</div>
