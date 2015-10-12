---
title: ZStack功能列表
layout: docPage.cn
---

## ZStack 功能列表

在目前的版本中（0.9），ZStack支持如下功能：


<table class="table black-table">
  <thead>
    <th>分类</th>
    <th>功能</th>
    <th>备注</th>
  </thead>
  
  <tbody>
    <tr>
      <td rowspan=3>计算</td>
      <td>区域</td>
      <td>由一些集群组成的一个逻辑资源组。类似于Amazon EC2 availability zone</td>
    </tr>
    <tr>
      <td>集群</td>
      <td>由一些主机组成的逻辑组</td>
    </tr>
    <tr>
      <td>主机</td>
      <td>目前仅支持KVM</td>
    </tr>
    
    <tr>
      <td rowspan=5>存储</td>
      <td>主存储</td>
      <td>用于放置虚拟机磁盘卷的块存储设备。类似于 OpenStack的Cinder。 支持NFS, Local Storage, iSCSI 和 Ceph </td>
    </tr>
    <tr>
      <td>备份存储</td>
      <td>用于存放虚拟机镜像文件的存储。如果加上镜像文件，就相当于OpenStack的Glance。 支持Sftp 和 Ceph</td>
    </tr>
    <tr>
      <td>镜像</td>
      <td>用于创建虚拟机磁盘卷的模板文件。如果加上备份存储，就像当于OpenStack的Glance。支持raw, Qcow2 和 ISO.</td>
    </tr>
    <tr>
      <td>磁盘卷</td>
      <td>虚拟机磁盘卷</td>
    </tr>
    <tr>
      <td>磁盘卷快照</td>
      <td>虚拟机的磁盘卷快照</td>
    </tr>
    
    <tr>
      <td rowspan=2>网络</td>
      <td>二层网络</td>
      <td>二层广播域，用于隔离网络通讯。支持VLAN和非VLAN</td>
    </tr>
    <tr>
      <td>三层网络</td>
      <td>子网以及各种网络服务</td>
    </tr>
    
    <tr>
      <td rowspan=7>网络服务</td>
      <td>DHCP</td>
      <td></td>
    </tr>
    <tr>
      <td>DNS</td>
      <td></td>
    </tr>
    <tr>
      <td>SNAT</td>
      <td>源地址转换</td>
    </tr>
    <tr>
      <td>动态端口转发</td>
      <td>设置端口转发规则可以把网络包动态转发给不同的虚拟机的不同端口</td>
    </tr>
    <tr>
      <td>EIP</td>
      <td>类似于 Amazon EC2 elastic IP</td>
    </tr>
    <tr>
      <td>安全组</td>
      <td>分布式防火墙。类似于Amazon EC2 security group</td>
    </tr>
    <tr>
      <td>动态负载均衡</td>
      <td>类似于Amazon EC2 Elastic Load Balancer</td>
    </tr>
    
    <tr>
      <td>账号系统</td>
      <td>账号管理</td>
      <td>针对账户、用户的资源权限管理系统。类似于Amazon IAM</td>
    </tr>

    <tr>
      <td rowspan=2>配置</td>
      <td>实例方案</td>
      <td>虚拟机的资配置清单。类似于OpenStack flavor</td>
    </tr>
    <tr>
      <td>磁盘卷方案</td>
      <td>虚拟机磁盘卷的大小配置</td>
    </tr>
  </tbody>
</table>
