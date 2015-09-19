---
layout: post.cn
title:  "ZStack 虚拟路由器工作流程"
date:   2015-9-14
categories: blog
author: Yongkang You
category: cn_blog
---

Virtual Router（VR，虚拟路由器）是ZStack中一个特别的网络组件。目前ZStack里大部分的网络服务都是由VR提供的。
VR实际上是一个用于提供服务的特殊虚拟机，
它只在用户虚拟机需要网络服务的时候，由ZStack自动创建和管理。今天我们介绍一下ZStack网络服务里VR的工作流程。
当了解该工作流程后，用户可以更好的规划云环境里的网络服务。一旦出现VR创建失败的情况，也可以更快的定位和解决问题。

<img  class="img-responsive"  src="/images/blogs/misc/zstack-create-vm-process.png">

首先来看一下上图，这个网络环境是ZStack教程里典型内外网分离的网络模型，可用于EIP，Port Forwarding，Security Group，Load Balancer等。
在这个模型里，我们有两台物理机器，左边一台是计算节点，用于创建各种虚拟机；右边一台用于安装ZStack管控节点（Management Node）。
计算节点有两块物理网卡eth0和eth1（如果用户只有一个网卡eth0，可以通过vlan创建一个eth0.x的网卡替代eth1）。
计算节点的eth0和管控节点的网卡相连，这个网络在ZStack里面被称为管理网络（Management-l2）。该网络可以直接连接到公网（Internet或者公司内网）。
在该模型中，公有网络（Public-l2）和Management-l2公用一个eth0。当然为了更好的网络隔离，用户也可以再增加一个独立等网卡eth2，
用于Public-l2（由于管控节点控制计算节点不需要走公有网络，通过网络分离，也可以保护管控节点的安全）。
在我们的例子中，我们需要确保ZStack管控节点可以正确的连接计算节点的eth0（图中的10.0.0.1/24网段，我们需要给网卡配置上正确的IP地址）。
这样在添加计算节点的时候，ZStack就可以通过计算节点eth0上的IP地址部署对应的Agent。
由于Public-l2和Management-l2共享了一个L2，所以在配置网络环境的时候，我们只需要添加Public-l2和Public-l3。
随后在创建VR的时候，管控节点会和VR上的eth0进行通讯，VR的eth0的IP地址将会从用户设置的Public-l3中的IP Range取出一个。
在本例子里面，Publice-l3的IP Range一定是在10.0.0.1/24中的某一段。用户在设置Public-l3的IP Range的时候必须确保设置的IP地址段
不和已有网络中的网络设备冲突，Gateway和NetMask也需要设置正确。

**注意：当用户只使用了单台物理机做ZStack部署，并且单台物理机的eth0是从DHCP拿到的IP地址的时候，
如果把eth0作为Public-l2的网卡设备，需要特别关注ZStack给VR分配的IP地址不能和网络中的其他IP冲突。
如果使用没有连接任何网络的ethX作为单节点的Public-l2的网络设备，那么需要在添加L2 Network之前，给ethX设置上相应的IP地址，否则之后无法连通VR的eth0。**

在我们的模型里，计算节点上还有一个eth1用于用户VM的私有网络。该eth1可以通过交换机和同一个Cluster内的其他计算节点的eth1相连。
当ZStack添加计算节点的时候，会通过Ansible把KVM Agent安装到计算节点上。当ZStack添加Publice-L2和Private-L2的时候，
会在计算节点上给eth0和eth1创建对应的网桥br_eth0和br_eth1。根据网桥工作原理，ZStack还会把eth0和eth1上的IP地址转移到br_eth0和br_eth1上。

添加完成所有的资源，用户在创建第一个VM的时候，如果用户VM使用了VR的任何一种网络服务（DHCP、DNS、SNAT、Port Forwarding、EIP、Load Balancer），
ZStack会自动创建一个VR VM。这也是创建第一个VM的时候速度比较慢的原因之一。

ZStack创建VR VM的过程如下：

 1. ZStack 根据 VR 模版创建一个VR VM，该VM有两个网卡，一个连接到br_eth0负责连接管控节点和公网（如果有独立的Public-l2，会多创建一个网卡），另一个连接到br_eth1负责连接用户VM。
 2. ZStack 给VR指定两个特定的IP地址并注入VR VM中。
 3. VR 启动的最后会调用一个初始化的脚本把注入的IP地址设置到eth0和eth1上面
 4. ZStack管控程序在创建VR之后就会轮询的用ssh尝试连接VR
 5. 如果ssh连接成功，ZStack管控程序就会通过Ansible 安装和部署VR的管控程序
 6. VR Agent启动后，ZStack管控程序就会通过HTTP post命令给VR，例如设置即将启动的用户VM的IP地址，DNS之类。

VR启动成功后，ZStack就会创建用户VM。用户VM的eth0通过br_eth1的网桥连接到VR的eth1上，并且可以和未来的用户VM通讯。
用户VM访问公网的时候，通过VR的SNAT服务中转。用户VM需要EIP、Port Forwarding还有Load Balancer等服务的时候，也都是在VR上进行对应的配置。

用户在使用ZStack的时候，有时候会遇到VR创建失败的情况。经过分析，其中大多数失败原因都是因为网络配置导致的。具体来看，VR启动失败的故障可能有：

 1. 创建VR VM失败：找不到合适的Host。可能是没有处于Connected状态的Host，或者Host上的空闲资源（CPU，内存）不足以启动VR。
 2. VR 操作系统启动失败：虚拟化软件错误或者硬盘连接错误（NFS网络不稳定）
 3. ** ZStack ssh VR 失败：ZStack管控节点无法连接VR。通常原因有：IP地址配置不对；交换机没有允许对应的IP连接；使用了特别的vlan，但是交换机没有设置Truck模式。**
 4. ZStack Ansible部署VR Agent失败：部署VR的时候可能会连接Internet下载VR需要的系统库，但是这步在0.9之后就不需要从互联网上下载系统库了，所以通常不会出错。
 5. VR Agent 启动失败：可能是使用了不匹配的VR Image。例如ZStack 0.9 需要使用 VR 0.9版本的Image，如果用户没有更新VR Image的话，会导致HTTP 404的错误。

上述错误中，最常见的错误是3。大家可以对照解决。

在VR启动后，用户再启动同一Private L3上的VM的时候ZStack通常不会再次创建VR（除非是使用了独立的负载均衡功能）。
如果在用户VM运行的过程中，发生了VR连接错误，它的影响会是什么？我们该如何恢复呢？下表例举了在多计算节点和不同存储类型的情况下如何恢复失联VR的方法。

<table class="table table-striped table-bordered">
  <tr>
    <td><b>VR失效原因</b></td>
    <td><b>VR失效影响</b></td>
    <td><b>恢复VR方法</b></td>
  </tr>
  <tr>
    <td>VR VM网络失联，但是virsh list还可以看到VR 是running状态</td>
    <td>扁平网络：外网通讯中断、无法创建新VM、内网连接不影响；扁平网络：无法创建新VM，网络连接不影响</td>
    <td>从ZStack UI中的Virtual Router中delete VR VM， 再去Instance的界面重新创建一个用户VM</td>
  </tr>
  <tr>
    <td>VR VM 所在Host挂掉，之后手动重启Host</td>
    <td>非扁平网络：外网通讯中断、无法创建新VM；扁平网络：无法创建新VM，网络不影响</td>
    <td>从ZStack UI中的Virtual Router中再次Start VR VM</td>
  </tr>
  <tr>
    <td>VR VM 所在Host挂掉，之后Host无法重启，使用网络共享主存储</td>
    <td>非扁平网络：外网通讯中断、无法创建新VM、内网不影响；扁平网络：无法创建新VM，网络连接不影响</td>
    <td>使用zstack-cli UpdateVmInstance 把VR VM的状态改成 Stopped，再从ZStack UI中的Virtual Router中再次Start VR VM</td>
  </tr>
  <tr>
    <td>VR VM 所在Host挂掉，之后Host无法重启，使用本地主存储</td>
    <td>非扁平网络：外网通讯中断、无法创建新VM；扁平网络：无法创建新VM，网络连接不影响</td>
    <td>使用zstack-cli UpdateVmInstance 把VR VM的状态改成 Stopped，从ZStack UI中的Virtual Router中delete VR VM，然后再去Instance的界面创建一个新的用户VM</td>
  </tr>
</table>

未来ZStack的VR还会提供HA的功能，当一个VR失效的时候，会自动启动一个VR接管之前VR的网络服务。
通常虚拟路由已经可以满足大多数用户正常的网络要求，但是如果用户对网络性能有更高的要求，ZStack也可以集成商业虚拟机交换机，甚至是物理交换机的网络服务。
用户可以在创建L3网络的时候，选择不同网络服务的提供方。
