---
layout: post.cn
title:  "ZStack本地存储使用手册"
date:   2015-7-27
categories: blog
author: Yongkang You
category: cn_blog
---

##介绍##
本地存储（Local Storage）是继NFS主存储、iSCSI主存储之后ZStack支持的第三类主存储。
本地存储相比网络共享存储而言，更轻量、更方便（甚至在网络速度和网络存储性能不佳的情况下，本地存储的性能也更高）
，所以也有很多客户采用本地存储方案来搭建云系统。ZStack自v0.8.0开始支持本地存储。本教程仅会介绍如何添加本地存储来做云环境的主存储。

ZStack对于本地存储的使用有如下定义：
1. 一个Cluster内的所有计算节点应该有相同的目录放本地存储。
2. 如果一个Cluster既拥有本地主存储也挂载了NFS或者其他网络共享存储，那么云主机的根磁盘将会存放在本地存储，
而数据磁盘将会存放在网络共享存储。
3. 在使用网络共享存储的时候，当原始云主机磁盘被删除后，备份过的**磁盘快照**依然可以用于创建磁盘镜像模板和恢复磁盘；
但是这个操作在本地存储上无法进行。用户需要在原始磁盘删除前，使用磁盘快照功能创建磁盘镜像模板。

### 通过UI添加本地存储

用户关于如何添加Zone，Cluster，Host等其他资源的方法请访问[创建扁平网络环境](../cn/tutorials/flat-network-ui.html)

在[创建主存储](../cn/tutorials/flat-network-ui.html#addPrimaryStorage)的时候：
1. 选择类型'LocalStorage'
2. 输入计算节点上云主据磁盘要存放的目录

<img src="/images/0.8/localstorage.png" class="center-img img-responsive">

<hr>

### 通过zstack-cli添加本地存储

用户关于如何添加Zone，Cluster，Host等其他资源的方法请访问[创建扁平网络环境](../cn/tutorials/flat-network-cli.html)。
在[创建主存储](../cn/tutorials/flat-network-cli.html#addPrimaryStorage)的时候：

    >>>AddLocalPrimaryStorage zoneUuid=15d546efe84a499caa36b2f6a95d6b81 name=local url=/home/volumes


<div class="bs-callout bs-callout-default">
  <h4>URL</h4>
  本地主存储使用本地的一个目录来存放云主机的磁盘。当主存储挂载到Cluster上时，该目录会在Cluster内的所有计算节点上创建出来。
</div>

<div class="bs-callout bs-callout-default">
  <h4>关于本地存储的容量</h4>
  
  一个cluster里面本地存储的总容量是每一个计算节点上存储容量的总和。不像网络共享存储（例如NFS主存储），
  即使您发现ZStack系统显示的可用容量大于你所申请的磁盘空间，您可能还是会遇到空间不足（not enough capacity）的错误。
  这是因为该Cluster内找不到任何一个单个的计算节点能够独立满足空间分配的需求。例如，您有两个计算节点，
  每个节点上都有10GB的剩余空间，ZStack会显示当前Cluster有20GB的可用空间。当您试图去创建一个15GB的云主机磁盘的时候，
  ZStack会告诉你找不到足够的空间。
</div>

<div class="bs-callout bs-callout-warning">
  <h4>本地储存不支持云主机漂移和有限的跨云主机数据盘挂载</h4>
  
  由于本地存储不具备网络共享存储中，每个计算节点都可以访问该存储的能力。所以在存储漂移功能支持前，
  使用本地存储的云主机将不会具有漂移的功能。用户需要对可能发生的数据丢失或者长时间无法恢复云主机的运行做好准备。
  例如，需要考虑如何在应用层做到跨云主机的高可用。

  对于系统中可以挂载（状态为Ready）的数据磁盘，该磁盘仅能挂载到和该磁盘在同一计算节点的云主机上。
</div>
