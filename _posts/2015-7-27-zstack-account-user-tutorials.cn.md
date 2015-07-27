---
layout: post.cn
title:  "可与AWS媲美的ZStack账号用户系统"
date:   2015-7-27
categories: blog
author: Yongkang You
category: cn_blog
---

##介绍##
在v0.8.0之前，ZStack只支持管理员账号来使用整个云环境。自v0.8.0开始，ZStack支持了完善的用户账号系统。
ZStack用户账号系统设计与经典的亚马逊AWS相似，都定义了Account（账号）和User（用户）。账号可以分为系统管理员账号（SystemAdmin）
和普通账号（Normal）。其中系统管理员就是我们之前熟悉的名为 **admin** 的账号。用户是某个账号下的成员，
一个账号下可以有多个不同的用户。账号可以通过策略来限制不同用户所拥有的权限。默认情况下新创建的普通账号的用户
只拥有该普通账号所有只读API的权限。账号所有者可以通过添加或者删除权限来限制用户的API执行能力。

**ZStack v0.8.0系统里创建和管理账户只能通过 zstack-cli 来完成。目前还无法通过UI界面来完成账户管理任务**

一般来说，在一个复杂应用中，一个账号可以对应一个部门或者公司。同一个账号下的用户可以对应于公司里的不同角色。

对于通常的私有云用户来说，我们建议只需要给普通的使用者创建不同的账号来限制系统级别的操作即可，而无需在每个账号下再创建用户。
对于共有云用户来说，您可能会有自己的账号和计费系统。您可以根据需求来对接ZStack的账号用户系统，选择是否使用用户。

##登录##
当首次安装和部署完ZStack系统，admin账号即已经添加完毕。admin用户拥有全部API的执行能力，包括构建整个云系统。
admin用户的默认密码是：**password**，用户可以通过Account API登录ZStack系统，例如：

<pre><code># zstack-cli LogInByAccount accountName=admin password=password </code></pre>

##修改密码##
登录ZStack系统后，可以通过**UpdateAccountPassword**来修改自身的登录密码，例如：

<pre><code># zstack-cli UpdateAccount password=password </code></pre>

另外，用户也可以直接输入 **zstack-cli** 命令后，进入命令行交互模式来输入ZStack API命令：

<img class="img-responsive" src="/images/tutorials/account/zstackCli.png">

<hr>

##退出登录##
退出当前账号的登录方法是通过zstack-cli的LogOut命令，或者在ZStack UI界面里点击右上角的用户选择**Sign Out**

##查询资源##
云系统环境的搭建，可以通过**admin**用户进入ZStack UI或者ZStack CLI来完成，具体的搭建过程可以参考：[用户教程](../tutorials)

云环境部署好后，系统管理员可以通过添加普通账号和普通用户来限制云环境的使用者的权限，例如普通用户只能在制定
的环境里创建和查询（有限的）云主机，而不能更改整个云环境的配置。创建云主机需要至少知道三个要素：L3 Network，Image和InstanceOffering。

在使用**admin** 账号登录后，可以查询之前部署云系统的各种资源，例如查询三层网络（L3 Network）:

<pre><code># zstack-cli QueryL3Network
{
    "inventories": [
        {
            "createDate": "Jul 27, 2015 1:41:31 PM",
            "description": "Test",
            "ipRanges": [
                {
                    "createDate": "Jul 27, 2015 1:41:31 PM",
                    "description": "Test",
                    "endIp": "10.0.101.250",
                    "gateway": "10.0.101.1",
                    "l3NetworkUuid": "8f5006aac7874a20a0c2cfcb095ce6d2",
                    "lastOpDate": "Jul 27, 2015 1:41:31 PM",
                    "name": "host IP range",
                    "netmask": "255.255.255.0",
                    "startIp": "10.0.101.150",
                    "uuid": "52414f42081b4e8eb5b3daa3ed96f685"
                }
            ],
            "l2NetworkUuid": "523de2369a7845c18c6ea44263b53be3",
            "lastOpDate": "Jul 27, 2015 1:41:31 PM",
            "name": "public network",
            "networkServices": [],
            "state": "Enabled",
            "system": false,
            "type": "L3BasicNetwork",
            "uuid": "8f5006aac7874a20a0c2cfcb095ce6d2",
            "zoneUuid": "f3515d3bfb8649d9837c7681a528b736"
        }
    ],
    "success": true
}
</code></pre>

<hr>

也可以查询云主机镜像（Image）和云主机模板（InstanceOffering）：

<pre><code># zstack-cli QueryImage
{
    "inventories": [
        {
            "backupStorageRefs": [
                {
                    "backupStorageUuid": "ce26eab0a5114bcb81f2c5c7ce3384ae",
                    "createDate": "Jul 27, 2015 1:41:35 PM",
                    "imageUuid": "0ac93029ede142849a1355d8e7be8974",
                    "installPath": "/home/sftpBackupStorage/rootVolumeTemplates/acct-36c27e8ff05c4780bf6d2fa65700f22e/0ac93029ede142849a1355d8e7be8974/f18_200m.template",
                    "lastOpDate": "Jul 27, 2015 1:41:35 PM"
                }
            ],
            "createDate": "Jul 27, 2015 1:41:33 PM",
            "description": "Test",
            "format": "raw",
            "guestOsType": "unknown",
            "lastOpDate": "Jul 27, 2015 1:41:33 PM",
            "md5Sum": "not calculated",
            "mediaType": "RootVolumeTemplate",
            "name": "ttylinux",
            "platform": "Linux",
            "size": 209715200,
            "state": "Enabled",
            "status": "Ready",
            "system": false,
            "type": "zstack",
            "url": "http://zstack.yyk.net/image/f18_200m.img",
            "uuid": "0ac93029ede142849a1355d8e7be8974"
        }
    ],
    "success": true
}
</code></pre>

<pre><code># zstack-cli QueryInstanceOffering
{
    "inventories": [
        {
            "allocatorStrategy": "DefaultHostAllocatorStrategy",
            "cpuNum": 1,
            "cpuSpeed": 512,
            "createDate": "Jul 27, 2015 1:41:37 PM",
            "description": "small install offering",
            "lastOpDate": "Jul 27, 2015 1:41:37 PM",
            "memorySize": 134217728,
            "name": "small-vm",
            "sortKey": 0,
            "state": "Enabled",
            "type": "UserVm",
            "uuid": "ea8d1e412df54f23aa8f2372e3547929"
        }
    ],
    "success": true
}
</code></pre>

<hr>
当然我们也可以通过ZStack的UI界面取获取各种资源的详细信息。

##添加账号##
添加普通账号的命令是 **CreateAccount**, 使用方法例如：

<pre><code># zstack-cli CreateAccount name=frank password=123456
{
    "inventory": {
        "createDate": "Jul 27, 2015 2:02:36 PM",
        "lastOpDate": "Jul 27, 2015 2:02:36 PM",
        "name": "frank",
        "type": "Normal",
        "uuid": "a20609798cd949d297eb82becfe61983"
    },
    "success": true
}
</code></pre>

添加完普通帐号，可以用新的添加的帐号登录试试

<pre><code># zstack-cli LogInByAccount accountName=frank password=123456
{
    "inventory": {
        "accountUuid": "a20609798cd949d297eb82becfe61983",
        "createDate": "Jul 27, 2015 2:03:04 PM",
        "expiredDate": "Jul 27, 2015 4:03:04 PM",
        "userUuid": "a20609798cd949d297eb82becfe61983",
        "uuid": "6985fef9518f417296d2d9ed317d0281"
    },
    "success": true
}
</code></pre>

##共享资源##
新添加的普通用户是没有办法读取**admin**账户创建的各种资源，例如L3 Network, Image和Instance Offering:

<pre><code># zstack-cli QueryL3Network
{
    "inventories": [],
    "success": true
}
</code></pre>

如果需要让普通用户使用管理员账户创建的各种资源来创建云主机的化，我们需要把相关的资源的共享给普通用户。
共享资源的API是 **ShareResource**。使用这个API的时候，如果需要共享账户A的资源给B，那么我们首先需要用A登录系统，
再使用ShareResource API来共享相关资源。例如我们想要把admin用户的L3 Network，Image和InstanceOffering共享给frank：

###1. 先进入zstack-cli的交互模式：###
<pre><code>
# zstack-cli 
  ZStack command line tool

  Type "help" for more information

  Type Tab key for auto-completion
</code></pre>

###2. 登录admin账户：###
<pre><code>
>>>LogInByAccount accountName=admin password=password
{
    "inventory": {
        "accountUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "createDate": "Jul 27, 2015 2:06:19 PM",
        "expiredDate": "Jul 27, 2015 4:06:19 PM",
        "userUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "uuid": "e69fdd16edbd416ab09c17e9ffe94c75"
    },
    "success": true
}
</code></pre>

###3. 共享L3 Network，Image和InstanceOffering 给账户frank。这里的uuid，都是前面在创建账户以及Query资源的时候返回的uuid。###
共享多个资源的时候，uuid之间是用逗号分割的。另外，我们可以用一条命令把相同的资源共享给多个账户，同样账户uuid之间用逗号分割。
如果需要把资源共享给所有的账户，我们可以使用参数**toPublic=true**:
<pre><code>
>>>ShareResource accountUuids=a20609798cd949d297eb82becfe61983 resourceUuids=8f5006aac7874a20a0c2cfcb095ce6d2,0ac93029ede142849a1355d8e7be8974,ea8d1e412df54f23aa8f2372e3547929
{
    "success": true
}
</code></pre>

###4. 然后我们可以登录到frank账户检查一下是不是已经可以查询到各个资源：###
<pre><code>
>>>LogOut 
{
    "success": true
}

>>>LogInByAccount accountName=frank password=123456
{
    "inventory": {
        "accountUuid": "a20609798cd949d297eb82becfe61983",
        "createDate": "Jul 27, 2015 2:15:01 PM",
        "expiredDate": "Jul 27, 2015 4:15:01 PM",
        "userUuid": "a20609798cd949d297eb82becfe61983",
        "uuid": "4472cdcb583a42219b8fff24b9a903aa"
    },
    "success": true
}

>>>QueryL3Network fields=name,uuid
{
    "inventories": [
        {
            "name": "public network",
            "uuid": "8f5006aac7874a20a0c2cfcb095ce6d2"
        }
    ],
    "success": true
}

>>>QueryImage fields=name,uuid
{
    "inventories": [
        {
            "name": "ttylinux",
            "uuid": "0ac93029ede142849a1355d8e7be8974"
        }
    ],
    "success": true
}

>>>QueryInstanceOffering  fields=name,uuid
{
    "inventories": [
        {
            "name": "small-vm",
            "uuid": "ea8d1e412df54f23aa8f2372e3547929"
        }
    ],
    "success": true
}
</code></pre>

###当账户frank拥有了相关资源的访问能力后，就可以用他们创建自己的虚拟机了：###
<pre><code>
>>>CreateVmInstance name=frank-vm1 description="frnak 1st vm" l3NetworkUuids=8f5006aac7874a20a0c2cfcb095ce6d2 imageUuid=0ac93029ede142849a1355d8e7be8974 instanceOfferingUuid=ea8d1e412df54f23aa8f2372e3547929
{
    "inventory": {
        "allVolumes": [
            {
                "createDate": "Jul 27, 2015 2:21:46 PM",
                "description": "Root volume for VM[uuid:801bb9b7664e4a16a06d36a894a8ef1e]",
                "deviceId": 0,
                "format": "qcow2",
                "installPath": "/opt/zstack/nfsprimarystorage/prim-fbc3536389e641ceaef120f10ea5db83/rootVolumes/acct-a20609798cd949d297eb82becfe61983/vol-df3977d719774d0ab3faf2c3b70aeea4/df3977d719774d0ab3faf2c3b70aeea4.qcow2",
                "lastOpDate": "Jul 27, 2015 2:21:46 PM",
                "name": "ROOT-for-frank-vm1",
                "primaryStorageUuid": "fbc3536389e641ceaef120f10ea5db83",
                "rootImageUuid": "0ac93029ede142849a1355d8e7be8974",
                "size": 209715200,
                "state": "Enabled",
                "status": "Ready",
                "type": "Root",
                "uuid": "df3977d719774d0ab3faf2c3b70aeea4",
                "vmInstanceUuid": "801bb9b7664e4a16a06d36a894a8ef1e"
            }
        ],
        "allocatorStrategy": "DefaultHostAllocatorStrategy",
        "clusterUuid": "6ce598a2e2684845a6656c83038b6fa3",
        "cpuNum": 1,
        "cpuSpeed": 512,
        "createDate": "Jul 27, 2015 2:21:46 PM",
        "defaultL3NetworkUuid": "8f5006aac7874a20a0c2cfcb095ce6d2",
        "description": "frnak 1st vm",
        "hostUuid": "af661086268041ea9bb07a181d1371e1",
        "hypervisorType": "KVM",
        "imageUuid": "0ac93029ede142849a1355d8e7be8974",
        "instanceOfferingUuid": "ea8d1e412df54f23aa8f2372e3547929",
        "lastHostUuid": "af661086268041ea9bb07a181d1371e1",
        "lastOpDate": "Jul 27, 2015 2:21:46 PM",
        "memorySize": 134217728,
        "name": "frank-vm1",
        "platform": "Linux",
        "rootVolumeUuid": "df3977d719774d0ab3faf2c3b70aeea4",
        "state": "Running",
        "type": "UserVm",
        "uuid": "801bb9b7664e4a16a06d36a894a8ef1e",
        "vmNics": [
            {
                "createDate": "Jul 27, 2015 2:21:46 PM",
                "deviceId": 0,
                "gateway": "10.0.101.1",
                "ip": "10.0.101.232",
                "l3NetworkUuid": "8f5006aac7874a20a0c2cfcb095ce6d2",
                "lastOpDate": "Jul 27, 2015 2:21:46 PM",
                "mac": "fa:f8:f4:b0:89:00",
                "netmask": "255.255.255.0",
                "uuid": "4587e8b851e84b159fa0622cda354fed",
                "vmInstanceUuid": "801bb9b7664e4a16a06d36a894a8ef1e"
            }
        ],
        "zoneUuid": "f3515d3bfb8649d9837c7681a528b736"
    },
    "success": true
}
</code></pre>

<div class="bs-callout bs-callout-warning">
<h4>注意退出账户登录</h4>
zstack-cli默认会记录最近一次用户登录的<b>session_uuid</b>用于之后API命令的操作。ZStack系统会根据session_uuid
来获取当前用户以及用户的权限。用户session默认超时时间是120分钟（当然也可以修改全局参数改变）。如果用户在操作了API命令
后没有及时的LogOut，zstack-cli依然会使用之前的session_uuid来进行后续的操作。这可能对你的系统产生不必要的安全问题。
另外ZStack系统还会限制当前活跃的session数量（默认是500个，可以修改全局参数改变。过度的登录新的session而不登出的化，
有可能因为到达session登录的上线，会导致系统拒绝新账号的登录。
</div>

##限制账号创建资源的数量##
ZStack默认限制了普通账号创建资源的数量，例如普通账号最多只能创建20个云主机（更多账号限制可以访问：
[默认账号资源数量限制](http://zstackdoc.readthedocs.org/en/latest/userManual/identity.html#default-quotas)）

如果需要修改账号可使用的资源数量，需要利用**UpdateQuota** API，例如（需要使用**admin**用户登录后操作）:
<pre><code>
>>>UpdateQuota identityUuid=a20609798cd949d297eb82becfe61983 name=vm.num value=100
{
    "inventory": {
        "createDate": "Jul 27, 2015 2:02:36 PM",
        "identityType": "AccountVO",
        "identityUuid": "a20609798cd949d297eb82becfe61983",
        "lastOpDate": "Jul 27, 2015 2:02:36 PM",
        "name": "vm.num",
        "value": 100
    },
    "success": true
}
</code></pre>

用户也可以使用**QueryQuota** 命令来获取某个账户的所有资源限制：
<pre><code>
>>>QueryQuota identityUuid=a20609798cd949d297eb82becfe61983 fields=name,value
{
    "inventories": [
        {
            "name": "vm.memorySize",
            "value": 85899345920
        },
        {
            "name": "eip.num",
            "value": 20
        },
        {
            "name": "volume.data.num",
            "value": 40
        },
        {
            "name": "l3.num",
            "value": 20
        },
        {
            "name": "vip.num",
            "value": 20
        },
        {
            "name": "portForwarding.num",
            "value": 20
        },
        {
            "name": "vm.num",
            "value": 100
        },
        {
            "name": "vm.cpuNum",
            "value": 80
        },
        {
            "name": "volume.capacity",
            "value": 10995116277760
        },
        {
            "name": "securityGroup.num",
            "value": 20
        }
    ],
    "success": true
}</code></pre>

##给一个账号创建多用户，并设置不同的用户权限##
在一个大型的云环境中，可能会同时使用账号和用户，并且给同一账号下的不同用户设置不同的权限。
接下来我们来看一个可能的案例，在这个案例中我们将会创建如下图所示的用户登录环境：

<img class="img-responsive" src="/images/tutorials/account/multiUser.png">

在这个部门里，你会有一个三人架构团队（David，Tony和Frank），他们负责创建和管理云主机；
另外有一个三人的运营团队（Lucy，Arhbi和Jeff），他们不能创建云主机，但是能够打开并且操作云主机的终端。
除此之外，这两个团队有一个共同的项目经理，他拥有全部团队的所有能力。我们来看看该如何创建一个这样的使用场景：

###1. 使用**admin**用户登录后，创建一个新的账号：ops-team###

<pre><code>
>>>CreateAccount name=ops-team password=password</code></pre>

###2. 登录ops-team账号###
<pre><code>
>>>LogOut
>>>LogInByAccount accountName=ops-team password=password
</code></pre>

###3. 创建用户###
<pre><code>
>>>CreateUser name=david password=password
</code></pre>

重复这步来创建其他的用户：tony, frank, lucy, arhbi, jeff, mgr

###4. 创建用户组###
<pre><code>
>>>CreateUserGroup name=infra
</code></pre>

重复这步来创建一个新的用户组 ops

###5. 添加用户到用户组###
<pre><code>
>>>AddUserToGroup userUuid=d7646ae8af2140c0a3ccef2ad8da816d groupUuid=92c523a43651442489f8d2d598c7c3da
</code></pre>

**注意:**userUuid 和 groupUuid 都是之前在创建的时候，系统返回的uuid。
重复这步把david, tony, frank加到infra组, 把lucy, arhbi, jeff加到ops组

###6. 创建权限策略 ###
创建第一条策略，可以允许执行所有云主机相关的操作：
<pre><code>
>>>CreatePolicy name=vm-management statements='[{"actions":["instance:.*"], "effect":"Allow"}]'
</code></pre>

创建第二条策略，可以允许访问云主机的console：
<pre><code>
>>>CreatePolicy name=vm-console statements='[{"actions":["instance:APIRequestConsoleAccessMsg"], "effect":"Allow"}]'
</code></pre>

创建第三条策略，允许所有本账户可以执行的操作：
<pre><code>
>>>CreatePolicy name=all statements='[{"actions":[".*"], "effect":"Allow"}]'
</code></pre>

<div class="bs-callout bs-callout-warning">
<h4>特殊的JSON字符串</h4>
需要注意的是这里的statements是一个JSON的字符串，最外面是一个单引号，里面的每一个字符串需要用双引号包裹起来。
如果写错，会导致策略添加失败。
</div>

###7. 把策略一添加到 infra小组###
<pre><code>
>>>AttachPolicyToUserGroup groupUuid=92c523a43651442489f8d2d598c7c3da policyUuid=afb3bfbb911a42e0a662286728e49891
</code></pre>

**注意**：这里的policyUuid和groupUuid都是之前创建策略和用户组的时候，系统返回的uuid。用户需要把他们修改成自己创建的uuid。

###8. 把策略二添加到 ops小组###
<pre><code>
>>>AttachPolicyToUserGroup groupUuid=0939fc6f772d44d6a8f9d45c89c2a716 policyUuid=3bddf41e2ba6469881a65287879e5d58
</code></pre>

###9. 把策略三添加给mgr用户###
<pre><code>
>>>AttachPolicyToUser userUuid=d55c5fba4d1b4533961db9952dc15b00 policyUuid=36c27e8ff05c4780bf6d2fa65700f22e
</code></pre>

现在一个拥有三种不同权限用户组，7个用户名的架构就已经创建完毕了

**更多关于账号和用户相关的介绍和API请访问[ZStack账号系统](http://zstackdoc.readthedocs.org/en/latest/userManual/identity.html)**
