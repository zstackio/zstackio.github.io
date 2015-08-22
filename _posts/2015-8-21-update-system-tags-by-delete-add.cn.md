---
layout: post.cn
title:  "更改VM hostname和静态IP地址"
date:   2015-8-22
categories: blog
author: yongkang
category: cn_blog
published: true
---
##简介
ZStack在创建VM Instance的时候可以设定VM的hostname和静态IP地址。那么我们怎么在创建VM Instance之后修改这个云主机的hostname和IP地址呢？

答案要从ZStack是如何支持云主机的hostname和静态IP地址说起。ZStack是通过特有的System Tags（系统标签）来支持这两个功能的。
[System Tags](http://zstackdoc.readthedocs.org/en/latest/userManual/tag.html#system-tags)是ZStack特有的标签。
它的出现主要是为了解决IaaS架构稳定性的问题，保证ZStack在添加新功能的时候不必修改原有的代码。
用户在创建特定hostname和静态IP地址的云主机的时候，ZStack会创建两个特别的系统标签。ZStack对应的模块在创建云主机的过程中，
通过读取系统标签里的内容就可以把所需的内容设置上。所以，如果用户需要修改云主机的hostname和静态ip地址，
只需要修改之前的系统标签，再通过ZStack重启（不能在VM里面用reboot命令重启）云主机即可。

目前ZStack的版本（0.8）里，还不支持UpdateSystemTags的API，只能通过Delete原有System Tages，再增加一个新的System Tags的方式。
ZStack 0.9版本会添加UpdateSystemTags的API。

##查询System Tags
首先我们假定用户已经通过ZStack的UI界面或者zstack-cli创建了一台指定hostname和静态IP地址的云主机。

例如创建了一台云主机，该云主机的hostname为vm1，静态IP地址是10.11.0.100：

<pre>
<code>
>>>QueryVmInstance name~=vm1 
{
    "inventories": [
        {
            "allVolumes": [
                {
                    "createDate": "Aug 20, 2015 5:46:16 PM",
                    "description": "Root volume for VM[uuid:beda91e5c2474ab9bc5e15ce7c83de91]",
                    "deviceId": 0,
                    "format": "qcow2",
                    "installPath": "/opt/zstack/nfsprimarystorage/prim-5b4d7483ba3b4d109c8d35c971fd2c24/rootVolumes/acct-36c27e8ff05c4780bf6d2fa65700f22e/vol-38d9adae6422474786d14d66672bcc9a/38d9adae6422474786d14d66672bcc9a.qcow2",
                    "lastOpDate": "Aug 20, 2015 5:46:16 PM",
                    "name": "ROOT-for-vm1",
                    "primaryStorageUuid": "5b4d7483ba3b4d109c8d35c971fd2c24",
                    "rootImageUuid": "589c8795fbdf45549be1c7a9ebdda70b",
                    "size": 209715200,
                    "state": "Enabled",
                    "status": "Ready",
                    "type": "Root",
                    "uuid": "38d9adae6422474786d14d66672bcc9a",
                    "vmInstanceUuid": "beda91e5c2474ab9bc5e15ce7c83de91"
                }
            ],
            "allocatorStrategy": "DefaultHostAllocatorStrategy",
            "clusterUuid": "1fae9d050a60441eac7e15d09d7a57e0",
            "cpuNum": 1,
            "cpuSpeed": 512,
            "createDate": "Aug 20, 2015 5:46:16 PM",
            "defaultL3NetworkUuid": "31fd0dba47ee472481ee4edc9ab9d6ee",
            "hostUuid": "15d0f76c5989472e83d264a1bc408355",
            "hypervisorType": "KVM",
            "imageUuid": "589c8795fbdf45549be1c7a9ebdda70b",
            "instanceOfferingUuid": "db2320b776ca4365962870f371db7c5c",
            "lastHostUuid": "15d0f76c5989472e83d264a1bc408355",
            "lastOpDate": "Aug 20, 2015 5:46:16 PM",
            "memorySize": 134217728,
            "name": "vm1",
            "platform": "Linux",
            "rootVolumeUuid": "38d9adae6422474786d14d66672bcc9a",
            "state": "Running",
            "type": "UserVm",
            "uuid": "beda91e5c2474ab9bc5e15ce7c83de91",
            "vmNics": [
                {
                    "createDate": "Aug 20, 2015 5:46:16 PM",
                    "deviceId": 0,
                    "gateway": "10.11.0.1",
                    "ip": "10.11.0.100",
                    "l3NetworkUuid": "31fd0dba47ee472481ee4edc9ab9d6ee",
                    "lastOpDate": "Aug 20, 2015 5:46:16 PM",
                    "mac": "fa:1f:45:81:f4:00",
                    "netmask": "255.255.0.0",
                    "uuid": "c9ba9bc674084ac39a02a680ba6752fa",
                    "vmInstanceUuid": "beda91e5c2474ab9bc5e15ce7c83de91"
                }
            ],
            "zoneUuid": "fb92b33a29bc42a8990f5db0356493b8"
        }
    ],
    "success": true
}
</code>
</pre>

如果还没有登录，请用下面的方法登录系统：
<pre>
<code>
>>>LogInByAccount accountName=admin password=password
{
    "inventory": {
        "accountUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "createDate": "Aug 20, 2015 7:29:33 PM",
        "expiredDate": "Aug 20, 2015 9:29:33 PM",
        "userUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "uuid": "84ec1c14f1574806afe2ae2b1c963ab3"
    },
    "success": true
}
</code>
</pre>

我们可以通过查询系统标签来，得到该VM的hostname和静态IP的设置。查询vm1的System Tags，也就是查询resourceUuid为vm1的UUID的系统标签：

<pre>
<code>
>>>QuerySystemTag resourceUuid=beda91e5c2474ab9bc5e15ce7c83de91
{
    "inventories": [
        {
            "createDate": "Aug 20, 2015 5:46:16 PM",
            "inherent": false,
            "lastOpDate": "Aug 20, 2015 5:46:16 PM",
            "resourceType": "VmInstanceVO",
            "resourceUuid": "beda91e5c2474ab9bc5e15ce7c83de91",
            "tag": "staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.100",
            "type": "System",
            "uuid": "0dc36ae8dad24409bfca5c8d307dc8d9"
        },
        {
            "createDate": "Aug 20, 2015 5:46:16 PM",
            "inherent": false,
            "lastOpDate": "Aug 20, 2015 5:46:16 PM",
            "resourceType": "VmInstanceVO",
            "resourceUuid": "beda91e5c2474ab9bc5e15ce7c83de91",
            "tag": "hostname::vm1",
            "type": "System",
            "uuid": "bde1ac5f07e04e5d93849c07875ea1ff"
        }
    ],
    "success": true
}
</code>
</pre>

##删除hostname和静态IP地址

删除hostname和静态IP地址的方法就是删除设定的系统标签。删除系统标签和删除用户普通标签（资源别名）的方法一样都是使用DeleteTag API：

<pre>
<code>
>>>DeleteTag uuid=0dc36ae8dad24409bfca5c8d307dc8d9
{
    "success": true
}

>>>DeleteTag uuid=bde1ac5f07e04e5d93849c07875ea1ff
{
    "success": true
}
</code>
</pre>

删除标签之后，我们将不会查询到和云主机vm1相关的标签:

<pre>
<code>
>>>QuerySystemTag resourceUuid=beda91e5c2474ab9bc5e15ce7c83de91
{
    "inventories": [],
    "success": true
}
</code>
</pre>

## 设置新的hostname和静态IP地址

创建系统标签的API是CreateSystemTag，这个API需要输入几个参数：

 1. resourceUuid： 这里就是云主机vm1的UUID
 2. resourceType: 这里的类型是VmInstanceVO , 更多类型可以访问[系统标签介绍](http://zstackdoc.readthedocs.org/en/latest/userManual/tag.html#resource-type)
 3. tag: 就是具体的标签。每个系统标签的定义是不同的，这个需要根据System的定义来指定。我们稍后还会看到两个不同的系统标签。

先来创建新的hostname为newVm1：

<pre>
<code>
>>>CreateSystemTag resourceUuid=beda91e5c2474ab9bc5e15ce7c83de91 resourceType=VmInstanceVO tag=hostname::newVm1
{
    "inventory": {
        "createDate": "Aug 20, 2015 7:29:34 PM",
        "inherent": false,
        "lastOpDate": "Aug 20, 2015 7:29:34 PM",
        "resourceType": "VmInstanceVO",
        "resourceUuid": "beda91e5c2474ab9bc5e15ce7c83de91",
        "tag": "hostname::newVm1",
        "type": "System",
        "uuid": "775f6655e6604c46ad6509c0270e4249"
    },
    "success": true
}
</code>
</pre>

再来创建新的静态IP地址为10.11.0.101（需要在对应的L3的IP地址范围内）：

<pre>
<code>
>>>CreateSystemTag resourceUuid=beda91e5c2474ab9bc5e15ce7c83de91 resourceType=VmInstanceVO tag=staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.101
{
    "inventory": {
        "createDate": "Aug 20, 2015 7:36:18 PM",
        "inherent": false,
        "lastOpDate": "Aug 20, 2015 7:36:18 PM",
        "resourceType": "VmInstanceVO",
        "resourceUuid": "beda91e5c2474ab9bc5e15ce7c83de91",
        "tag": "staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.101",
        "type": "System",
        "uuid": "85d75b94b78f4fccb4c5ca8ab95a5e3f"
    },
    "success": true
}
</code>
</pre>

这里的31fd0dba47ee472481ee4edc9ab9d6ee是VM所在L3网络的UUID。然后让我们来重启vm1。需要注意的是，
我们需要使用StopVmInstacne 和StartVmInstance来重启VM，而不是RebootVmInstacne。

<pre>
<code>
StopVmInstance uuid=beda91e5c2474ab9bc5e15ce7c83de91
StartVmInstance uuid=beda91e5c2474ab9bc5e15ce7c83de91
</code>
</pre>

待vm1重新启动后，我们就会发现vm1的hostname变成了newVm1，IP地址也变成了10.11.0.101。如果是通过
UI面板重启的VM，还需要刷新一下UI面板，vm1的IP地址就会显示正常。

**0.8版本中有一个bug会导致云主机在重启后，不能更改的静态IP地址。这个Bug会在0.9版本中修复**

## 更新系统标签
在0.9版本之后，我们还会支持直接更新系统标签，这样可以节省更改云主机信息的步骤。更改hostname
系统标签的方法是：
<pre>
<code>
UpdateSystemTag tag=hostname::newVm1 uuid=bde1ac5f07e04e5d93849c07875ea1ff
</code>
</pre>

这里的UUID是之前通过QuerySystemTag 查到的hostname的Tag的UUID。

更改静态IP地址系统标签的方法是：
<code>
UpdateSystemTag tag=staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.101 uuid=0dc36ae8dad24409bfca5c8d307dc8d9
</code>
</pre>

需要注意的是，这里有两个UUID。其中31fd0dba47ee472481ee4edc9ab9d6ee，
是云主机网卡所在的L3 Network的UUID。而0dc36ae8dad24409bfca5c8d307dc8d9
是之前通过QuerySystemTag API查询到的静态IP地址Tag的UUID。

## 添加新的网络并设置静态IP地址
在0.8版本之后，ZStack支持给云主机动态的添加网卡。通常动态添加的网卡也是一个动态的IP地址，
如果需要给动态添加的网卡提前配置一个静态的IP地址，那么我们也需要依赖静态IP地址的系统标签。

我们假设需要添加的网卡所属的L3网络的UUID是：31fd0dba47ee472481ee4edc9ab9d6ee

云主机的UUID是：beda91e5c2474ab9bc5e15ce7c83de91

需要设定的静态IP地址是：10.11.0.102

那么我们添加的系统标签的方法是：
<pre>
<code>
>>>CreateSystemTag resourceUuid=beda91e5c2474ab9bc5e15ce7c83de91 resourceType=VmInstanceVO tag=staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.102
{
    "inventory": {
        "createDate": "Aug 20, 2015 7:36:18 PM",
        "inherent": false,
        "lastOpDate": "Aug 20, 2015 7:36:18 PM",
        "resourceType": "VmInstanceVO",
        "resourceUuid": "beda91e5c2474ab9bc5e15ce7c83de91",
        "tag": "staticIp::31fd0dba47ee472481ee4edc9ab9d6ee::10.11.0.102",
        "type": "System",
        "uuid": "85d75b94b78f4fccb4c5ca8ab95a5e3f"
    },
    "success": true
}
</code>
</pre>

在添加完系统标签后，我们再添加网卡的时候，ZStack就会使用刚刚设置的静态IP地址了。

**参考：**

 1. [系统标签手册](http://zstackdoc.readthedocs.org/en/latest/userManual/tag.html#system-tags)
 2. [静态IP地址功能介绍](./v0.7.html)
 3. [给云主机动态的添加删除网卡](./attach-detach-l3-tutorials.html)

