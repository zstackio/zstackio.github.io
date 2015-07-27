---
layout: post.cn
title:  "ZStack云主机动态添加和删除网卡教程"
date:   2015-7-27
categories: blog
author: Yongkang You
category: cn_blog
---

##介绍##
动态添加和删除网卡是IaaS里的基本功能，ZStack自v0.8.0开始支持云主机运行态或停止态动态的添加和删除网卡（更准确的称为三层网络）。
动态添加的网卡要求该网卡的三层网络不能是该云主机中已有的三层网络。

### 通过UI给云主机挂载三层网络

在VM Instance的界面
<img src="/images/0.8/2.png" class="center-img img-responsive">

1. 选择需要添加三层网络的云主机并点击'Action'
2. 点击 'Attach L3 Network'

<img src="/images/0.8/3.png" class="center-img img-responsive">

1. 选择你希望挂载的三层网络
2. 点击挂载

### 通过zstack-cli给云主机挂载三层网络

你可以使用** AttachL3NetworkToVm **命令来挂载一个三层网络，例如；

    >>>AttachL3NetworkToVm l3NetworkUuid=d791a3f662ac48a99b9e998136eed2a1 vmInstanceUuid=15d546efe84a499caa36b2f6a95d6b81
    
### 通过UI删除一个云主机的三层网络

<img src="/images/0.8/4.png" class="center-img img-responsive">

1. 选择云主机并点击'Action'
2. 点击 'Detach L3 Network'

<img src="/images/0.8/5.png" class="center-img img-responsive">

1. 选择您想卸载的三层网络
2. 点击 'Detach'

### 通过zstack-cli给云主机卸载一个三层网络

你可以使用** DetachL3NetworkToVm **命令来卸载一个三层网络，例如；

    >>>DetachL3NetworkFromVm vmNicUuid=d791a3f662ac48a99b9e998136eed2a1
    
<div class="bs-callout bs-callout-info">
  <h4>云主机网卡的UUID</h4>
  
  在卸载三层网络的时候，ZStack使用了云主机的网卡UUID，而不是三层网络的UUID。这是因为一个网卡的UUID，隐含着关联了云主机的UUID和三层网络的UUID。
</div>
