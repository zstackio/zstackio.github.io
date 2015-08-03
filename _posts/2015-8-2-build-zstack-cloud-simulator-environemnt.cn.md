---
layout: post.cn
title:  "ZStack 云环境模拟器"
date:   2015-8-2
categories: blog
author: Yongkang You 
category: cn_blog
---
### 介绍

熟悉OpenStack的同学应该知道OpenStack可以用[devstack](https://ask.openstack.org/en/question/28/openstack-api-mocker-or-simulator/)来搭建一个虚拟云环境，
使用CloudStack的同学也知道CloudStack也有一个[虚拟云环境](https://cwiki.apache.org/confluence/display/CLOUDSTACK/Simulator+integration)。
在虚拟云环境中，云主机不会在物理设备上真正创建出来，一切的云场景都是构建在一个虚无的世界中，唯有IaaS的数据库和消息总线还在真实的工作。
由于云模拟器的这种特性，我们可以用它来熟悉各种云操作和进行底层和虚拟机无关的集成测试，例如测试消息总线，测试数据库，测试IaaS的基本功能。
ZStack的模拟器是ZStack开发伊始就存在的，并随着ZStack功能的开发而不断增强。ZStack的数百个集成测试用例就是
跑在ZStack的模拟器之上的。ZStack首页上例举的很多大规模并发性能测试也是基于模拟器来进行的
（不过ZStack在用户的真实物理环境中已经拿到比在PC模拟器上还要好的数据了，平均云主机的创建时间可以低于0.08s）。在频繁的各种VM的操作之中，
我们可以稳定的获得ZStack仅仅用一个管理节点就可以高效的模拟管理数十万的计算节点和上百万的云主机的常规并发操作。
从而验证了Rabbitmq完全可以胜任大规模并发环境的IaaS操作（只要调度方法正确）。
ZStack模拟器是和ZStack天然集成的，用户不需要进行额外的配置。只要正常启动ZStack管理程序后，就可以部署虚拟云环境。

<img  class="img-responsive"  src="/images/blogs/simulator/simulator.png">

今天我们就要给大家展示一下ZStack的虚拟云环境如何创建。另外我们还要给大家展示一下如何一步部署ZStack模拟云环境。
ZStack模拟器和ZStack天然集成，最早的时候ZStack的Dashboard也是可以在UI界面上添加和部署虚拟云环境。但是后来为了避免用户的误操作，
ZStack开发团队把UI界面上添加云环境的功能给禁止了。目前虚拟云环境需要通过zstack-cli来操作。
如果您只是想快速部署一个虚拟的云环境，而不在乎部署的过程，可以直接跳转到本文的最后，使用一键部署。
用户可以在半分钟内完成虚拟云环境的部署，并用其创建虚拟云主机。

### 前提
已经根据[ZStack快速安装手册](/cn/installation/index.html)，完成ZStack的快速安装和启动。

### 登录zstack控制终端
<pre><code>
[zstack@localhost ~]$ sudo zstack-cli

  ZStack command line tool
  Type "help" for more information
  Type Tab key for auto-completion
  Type "quit" or "exit" or Ctrl-d to exit

>>>LogInByAccount accountName=admin password=password
{
    "inventory": {
        "accountUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "createDate": "Aug 3, 2015 7:59:59 AM",
        "expiredDate": "Aug 3, 2015 9:59:59 AM",
        "userUuid": "36c27e8ff05c4780bf6d2fa65700f22e",
        "uuid": "d45bdd89b8984d65b35dd97f83387e4c"
    },
    "success": true
}
</code></pre>

### 创建Zone
<pre><code>
>>>CreateZone name=simulator-zone
{
    "inventory": {
        "createDate": "Aug 3, 2015 8:00:25 AM",
        "lastOpDate": "Aug 3, 2015 8:00:25 AM",
        "name": "simulator-zone",
        "state": "Enabled",
        "type": "zstack",
        "uuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 创建Cluster
需要大家把zoneUuid换成自己刚刚创建的Zone的UUID，并且把hypervisor的类型指定为“Simulator”：
<pre><code>
>>>CreateCluster name=simulator-cluster zoneUuid=22331c109ef64f88a5826bcf96793941 hypervisorType=Simulator
{
    "inventory": {
        "createDate": "Aug 3, 2015 8:02:19 AM",
        "hypervisorType": "Simulator",
        "lastOpDate": "Aug 3, 2015 8:02:19 AM",
        "name": "simulator-cluster",
        "state": "Enabled",
        "type": "zstack",
        "uuid": "c237767682d947f58efaf5e485b713e7",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 添加虚拟的计算节点
添加虚拟计算节点的时候，需要使用一个特别的API：**AddSimulatorHost**。（添加物理KVM计算节点的API是：AddKVMHost）。
由于是虚拟的计算节点，我们还需要给一个假设的CPU容量和内存容量（为了测试方便，该容量可以给的随意大）：
<pre><code>
>>>AddSimulatorHost name=simulator-host clusterUuid=c237767682d947f58efaf5e485b713e7 cpuCapacity=200000 memoryCapacity=1000000000000 managementIp=10.10.10.10
{
    "inventory": {
        "availableCpuCapacity": 200000,
        "availableMemoryCapacity": 1000000000000,
        "clusterUuid": "c237767682d947f58efaf5e485b713e7",
        "createDate": "Aug 3, 2015 8:05:08 AM",
        "hypervisorType": "Simulator",
        "lastOpDate": "Aug 3, 2015 8:05:08 AM",
        "managementIp": "10.10.10.10",
        "name": "simulator-host",
        "state": "Enabled",
        "status": "Connected",
        "totalCpuCapacity": 200000,
        "totalMemoryCapacity": 1000000000000,
        "uuid": "b879af2114794044a6ce2f8902da3e38",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 添加虚拟主存储
同虚拟计算节点一样，我们需要使用一个特别的API（**AddSimulatorPrimaryStorage**）来添加虚拟主存储，
另外我们还需要给一个虚拟的可用空间以及设置类型为**SimulatorPrimaryStorage**:
<pre><code>
>>>AddSimulatorPrimaryStorage name=simulator-ps zoneUuid=22331c109ef64f88a5826bcf96793941 availableCapacity=10000000000000 totalCapacity=10000000000000 url=nfs://fake_url/fake_folder type=SimulatorPrimaryStorage
{
    "inventory": {
        "attachedClusterUuids": [],
        "availableCapacity": 10000000000000,
        "availablePhysicalCapacity": 0,
        "createDate": "Aug 3, 2015 8:12:31 AM",
        "lastOpDate": "Aug 3, 2015 8:12:31 AM",
        "mountPath": "/primarystoragesimulator/c6c019a5b6dc494aaacbedfb5d3beb8e",
        "name": "simulator-ps",
        "state": "Enabled",
        "status": "Connected",
        "totalCapacity": 10000000000000,
        "totalPhysicalCapacity": 0,
        "type": "SimulatorPrimaryStorage",
        "url": "nfs://fake_url/fake_folder",
        "uuid": "c6c019a5b6dc494aaacbedfb5d3beb8e",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

然后把刚创建的主存储挂载到虚拟cluster上去：
<pre><code>
>>>AttachPrimaryStorageToCluster primaryStorageUuid=c6c019a5b6dc494aaacbedfb5d3beb8e clusterUuid=c237767682d947f58efaf5e485b713e7
{
    "inventory": {
        "attachedClusterUuids": [
            "c237767682d947f58efaf5e485b713e7"
        ],
        "availableCapacity": 10000000000000,
        "availablePhysicalCapacity": 0,
        "createDate": "Aug 3, 2015 8:12:31 AM",
        "lastOpDate": "Aug 3, 2015 8:12:31 AM",
        "mountPath": "/primarystoragesimulator/c6c019a5b6dc494aaacbedfb5d3beb8e",
        "name": "simulator-ps",
        "state": "Enabled",
        "status": "Connected",
        "totalCapacity": 10000000000000,
        "totalPhysicalCapacity": 0,
        "type": "SimulatorPrimaryStorage",
        "url": "nfs://fake_url/fake_folder",
        "uuid": "c6c019a5b6dc494aaacbedfb5d3beb8e",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 添加虚拟备份存储
同添加虚拟主存储类似，我们也需要用到特殊的**AddSimulatorBackupStorage**，除了设定虚拟的可用空间外，
我们还需要指定存储类型为SimulatorBackupStorage。创建完成后，在把它挂载到zone上：
<pre><code>
>>>AddSimulatorBackupStorage name=simulator-bs url=/fake_url totalCapacity=1000000000000 availableCapacity=1000000000000 type=SimulatorBackupStorage
{
    "inventory": {
        "attachedZoneUuids": [],
        "availableCapacity": 1000000000000,
        "createDate": "Aug 3, 2015 8:22:00 AM",
        "lastOpDate": "Aug 3, 2015 8:22:00 AM",
        "name": "simulator-bs",
        "state": "Enabled",
        "status": "Connected",
        "totalCapacity": 1000000000000,
        "type": "SimulatorBackupStorage",
        "url": "/fake_url",
        "uuid": "7bde50df528b45ffb1689229c3de105b"
    },
    "success": true
}

>>>AttachBackupStorageToZone backupStorageUuid=7bde50df528b45ffb1689229c3de105b zoneUuid=22331c109ef64f88a5826bcf96793941
{
    "inventory": {
        "attachedZoneUuids": [
            "22331c109ef64f88a5826bcf96793941"
        ],
        "availableCapacity": 1000000000000,
        "createDate": "Aug 3, 2015 8:22:00 AM",
        "lastOpDate": "Aug 3, 2015 8:22:00 AM",
        "name": "simulator-bs",
        "state": "Enabled",
        "status": "Connected",
        "totalCapacity": 1000000000000,
        "type": "SimulatorBackupStorage",
        "url": "/fake_url",
        "uuid": "7bde50df528b45ffb1689229c3de105b"
    },
    "success": true
}
</code></pre>

### 添加虚拟云主机模版
由于我们指定了备份存储为一个虚拟备份存储，添加Image的时候不需要使用真实的url。但是我们需要在Image的format上指定为**simulator**，而不是qcow2或者raw。
<pre><code>
>>>AddImage name=simulator-image backupStorageUuids=7bde50df528b45ffb1689229c3de105b format=simulator mediaType=RootVolumeTemplate url=http://fake_url
{
    "inventory": {
        "backupStorageRefs": [
            {
                "backupStorageUuid": "7bde50df528b45ffb1689229c3de105b",
                "createDate": "Aug 3, 2015 8:46:40 AM",
                "imageUuid": "5e40b7d5fed442848830716bfe71ec2e",
                "installPath": "/fake_url/simulator-image",
                "lastOpDate": "Aug 3, 2015 8:46:40 AM"
            }
        ],
        "createDate": "Aug 3, 2015 8:46:40 AM",
        "format": "simulator",
        "lastOpDate": "Aug 3, 2015 8:46:40 AM",
        "md5Sum": "528068b1699f4495bcd90f1b901e6ee9",
        "mediaType": "RootVolumeTemplate",
        "name": "simulator-image",
        "platform": "Linux",
        "size": 100,
        "state": "Enabled",
        "status": "Ready",
        "system": false,
        "type": "zstack",
        "url": "http://fake_url",
        "uuid": "5e40b7d5fed442848830716bfe71ec2e"
    },
    "success": true
}
</code></pre>

### 创建虚拟L2
添加一个虚拟的L2设备，当挂载给一个虚拟的Cluster的时候，ZStack不会检查该L2设备是否真实存在。
<pre><code>
>>>CreateL2NoVlanNetwork name=simulator-l2 physicalInterface=eth0 zoneUuid=22331c109ef64f88a5826bcf96793941
{
    "inventory": {
        "attachedClusterUuids": [],
        "createDate": "Aug 3, 2015 8:26:46 AM",
        "lastOpDate": "Aug 3, 2015 8:26:46 AM",
        "name": "simulator-l2",
        "physicalInterface": "eth0",
        "type": "L2NoVlanNetwork",
        "uuid": "66d4801c02154daeb361bf0a703bd14b",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}

>>>AttachL2NetworkToCluster l2NetworkUuid=66d4801c02154daeb361bf0a703bd14b clusterUuid=c237767682d947f58efaf5e485b713e7
{
    "inventory": {
        "attachedClusterUuids": [
            "c237767682d947f58efaf5e485b713e7"
        ],
        "createDate": "Aug 3, 2015 8:26:46 AM",
        "lastOpDate": "Aug 3, 2015 8:26:46 AM",
        "name": "simulator-l2",
        "physicalInterface": "eth0",
        "type": "L2NoVlanNetwork",
        "uuid": "66d4801c02154daeb361bf0a703bd14b",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 添加一个L3网络
<pre><code>
>>>CreateL3Network name=simulator-l3 l2NetworkUuid=66d4801c02154daeb361bf0a703bd14b
{
    "inventory": {
        "createDate": "Aug 3, 2015 8:29:23 AM",
        "ipRanges": [],
        "l2NetworkUuid": "66d4801c02154daeb361bf0a703bd14b",
        "lastOpDate": "Aug 3, 2015 8:29:23 AM",
        "name": "simulator-l3",
        "networkServices": [],
        "state": "Enabled",
        "system": false,
        "type": "L3BasicNetwork",
        "uuid": "af0c2a51dd954207af9f61e43bfee757",
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
>>>AddIpRange name=simulator-ip-range l3NetworkUuid=af0c2a51dd954207af9f61e43bfee757 startIp=172.16.0.2 endIp=172.16.255.254 netmask=255.255.0.0 gateway=172.16.0.1
{
    "inventory": {
        "createDate": "Aug 3, 2015 8:30:44 AM",
        "endIp": "172.16.255.254",
        "gateway": "172.16.0.1",
        "l3NetworkUuid": "af0c2a51dd954207af9f61e43bfee757",
        "lastOpDate": "Aug 3, 2015 8:30:44 AM",
        "name": "simulator-ip-range",
        "netmask": "255.255.0.0",
        "startIp": "172.16.0.2",
        "uuid": "24607ef0fa0b4b3fa6965e4c3c331abe"
    },
    "success": true
}
</code></pre>

### 添加云主机模版
<pre><code>
>>>CreateInstanceOffering name=simulator-vm-offering cpuNum=2 cpuSpeed=128 memorySize=256000000
{
    "inventory": {
        "allocatorStrategy": "DefaultHostAllocatorStrategy",
        "cpuNum": 2,
        "cpuSpeed": 128,
        "createDate": "Aug 3, 2015 8:33:14 AM",
        "lastOpDate": "Aug 3, 2015 8:33:14 AM",
        "memorySize": 256000000,
        "name": "simulator-vm-offering",
        "sortKey": 0,
        "state": "Enabled",
        "type": "UserVm",
        "uuid": "3ea91a8e7d3a4cd7b87eaf2f516aa827"
    },
    "success": true
}
</code></pre>

### 创建一个虚拟的云主机
创建一个虚拟的云主机我们需要指定L3，Image和InstanceOffering的UUID。它们的UUID都可以在之前的命令结果中找到：
<pre><code>
CreateVmInstance name=sim-vm1 l3NetworkUuids=af0c2a51dd954207af9f61e43bfee757 imageUuid=5e40b7d5fed442848830716bfe71ec2e instanceOfferingUuid=3ea91a8e7d3a4cd7b87eaf2f516aa827
{
    "inventory": {
        "allVolumes": [
            {
                "createDate": "Aug 3, 2015 8:48:27 AM",
                "description": "Root volume for VM[uuid:63becebd92894c108a4c268d7a722ed9]",
                "deviceId": 0,
                "format": "simulator",
                "installPath": "nfs:/fake_url/fake_folder/vm/8657fb16029444bfb62e96eed0867cc0.qcow2",
                "lastOpDate": "Aug 3, 2015 8:48:27 AM",
                "name": "ROOT-for-sim-vm1",
                "primaryStorageUuid": "c6c019a5b6dc494aaacbedfb5d3beb8e",
                "rootImageUuid": "5e40b7d5fed442848830716bfe71ec2e",
                "size": 100,
                "state": "Enabled",
                "status": "Ready",
                "type": "Root",
                "uuid": "8657fb16029444bfb62e96eed0867cc0",
                "vmInstanceUuid": "63becebd92894c108a4c268d7a722ed9"
            }
        ],
        "allocatorStrategy": "DefaultHostAllocatorStrategy",
        "clusterUuid": "c237767682d947f58efaf5e485b713e7",
        "cpuNum": 2,
        "cpuSpeed": 128,
        "createDate": "Aug 3, 2015 8:48:27 AM",
        "defaultL3NetworkUuid": "af0c2a51dd954207af9f61e43bfee757",
        "hostUuid": "b879af2114794044a6ce2f8902da3e38",
        "hypervisorType": "Simulator",
        "imageUuid": "5e40b7d5fed442848830716bfe71ec2e",
        "instanceOfferingUuid": "3ea91a8e7d3a4cd7b87eaf2f516aa827",
        "lastHostUuid": "b879af2114794044a6ce2f8902da3e38",
        "lastOpDate": "Aug 3, 2015 8:48:27 AM",
        "memorySize": 256000000,
        "name": "sim-vm1",
        "platform": "Linux",
        "rootVolumeUuid": "8657fb16029444bfb62e96eed0867cc0",
        "state": "Running",
        "type": "UserVm",
        "uuid": "63becebd92894c108a4c268d7a722ed9",
        "vmNics": [
            {
                "createDate": "Aug 3, 2015 8:48:27 AM",
                "deviceId": 0,
                "gateway": "172.16.0.1",
                "ip": "172.16.199.179",
                "l3NetworkUuid": "af0c2a51dd954207af9f61e43bfee757",
                "lastOpDate": "Aug 3, 2015 8:48:27 AM",
                "mac": "fa:f1:91:9a:a7:00",
                "netmask": "255.255.0.0",
                "uuid": "888fdf0816714cdfa16a5797d6e2c8dc",
                "vmInstanceUuid": "63becebd92894c108a4c268d7a722ed9"
            }
        ],
        "zoneUuid": "22331c109ef64f88a5826bcf96793941"
    },
    "success": true
}
</code></pre>

### 保存当前云环境
如果觉得每次创建一个虚拟云环境还是需要花费一些时间来一步步添加各种资源。我们可以利用zstack-cli的dump云环境的功能，
把当前的云环境给dump下来，然后在以后的测试中，直接还原。

使用zstack-cli -h 来获取相关的参数信息
<pre><code>
[zstack@localhost ~]$ sudo zstack-cli -h
Usage: -c [options]

Options:
  -h, --help            show this help message and exit
  -H HOST, --host=HOST  [Optional] IP address or DNS name of a ZStack
                        management node. Default value: localhost
  -p PORT, --port=PORT  [Optional] Port that the ZStack management node is
                        listening on. Default value: 8080
  -d DEPLOY_CONFIG_FILE, --deploy=DEPLOY_CONFIG_FILE
                        [Optional] deploy a cloud from a XML file.
  -t DEPLOY_CONFIG_TEMPLATE_FILE, --tempate=DEPLOY_CONFIG_TEMPLATE_FILE
                        [Optional] variable template file for XML file
                        spcified in option '-d'
  -D ZSTACK_CONFIG_DUMP_FILE, --dump=ZSTACK_CONFIG_DUMP_FILE
                        [Optional] dump a cloud to a XML file
</code></pre>

然后使用 -D 来dump刚刚部署好的虚拟云环境
<pre><code>
[zstack@localhost ~]$ sudo zstack-cli -D /tmp/simulator-zstack-cloud.xml
</code></pre>
**如果还没有登录zstack-cli或者session已经超时，请使用zstack-cli LogInByAccount accountName=admin password=password**来登录系统。

### Dump好的xml文件内容
{% highlight xml %}
<?xml version="1.0" ?>

<deployerConfig>

  <nodes>
    <node hostName="10.10.3.230" uuid="8ff3c1babe0d44c0a75ab3a93eb7c867"/>
  </nodes>

  <instanceOfferings>
    <instanceOffering allocatorStrategy="DefaultHostAllocatorStrategy"
      cpuNum="2"
      cpuSpeed="128"
      memorySize="256000000"
      name="simulator-vm-offering"
      sortKey="0"
      state="Enabled"
      type="UserVm"
      uuid="3ea91a8e7d3a4cd7b87eaf2f516aa827"/>
  </instanceOfferings>

  <backupStorages>
    <simulatorBackupStorage availableCapacity="1000000000000"
      name="simulator-bs"
      state="Enabled"
      status="Connected"
      totalCapacity="1000000000000"
      type="SimulatorBackupStorage"
      url="/fake_url"
      uuid="7bde50df528b45ffb1689229c3de105b"/>
  </backupStorages>

  <images>
    <image format="simulator"
      mediaType="RootVolumeTemplate"
      name="simulator-image"
      platform="Linux"
      state="Enabled"
      status="Ready"
      system="False"
      type="zstack"
      url="http://fake_url"
      uuid="5e40b7d5fed442848830716bfe71ec2e">

      <backupStorageRef>
        simulator-bs
      </backupStorageRef>
    </image>
  </images>

  <zones>
    <zone name="simulator-zone"
      state="Enabled"
      type="zstack"
      uuid="22331c109ef64f88a5826bcf96793941">

      <backupStorageRef>
        simulator-bs
      </backupStorageRef>

      <primaryStorages>
        <simulatorPrimaryStorage availableCapacity="9999999999900"
          availablePhysicalCapacity="0"
          name="simulator-ps"
          state="Enabled"
          status="Connected"
          totalCapacity="10000000000000"
          totalPhysicalCapacity="0"
          url="nfs://fake_url/fake_folder"
          uuid="c6c019a5b6dc494aaacbedfb5d3beb8e"/>
      </primaryStorages>

      <clusters>
        <cluster hypervisorType="Simulator"
          name="simulator-cluster"
          state="Enabled"
          type="zstack"
          uuid="c237767682d947f58efaf5e485b713e7"
          zoneUuid="22331c109ef64f88a5826bcf96793941">

          <hosts>
            <host managementIp="10.10.10.10"
              name="simulator-host"
              state="Enabled"
              status="Connected"
              uuid="b879af2114794044a6ce2f8902da3e38"/>
          </hosts>

          <primaryStorageRef>
            simulator-ps
          </primaryStorageRef>

          <l2NetworkRef>
            simulator-l2
          </l2NetworkRef>
        </cluster>
      </clusters>

      <l2Networks>
        <l2NoVlanNetwork name="simulator-l2"
          physicalInterface="eth0"
          description="l2"
          uuid="66d4801c02154daeb361bf0a703bd14b">

          <l3Networks>
            <l3BasicNetwork name="simulator-l3"
              state="Enabled"
              system="False"
              uuid="af0c2a51dd954207af9f61e43bfee757">
              <ipRange endIp="172.16.255.254"
                gateway="172.16.0.1"
                name="simulator-ip-range"
                netmask="255.255.0.0"
                startIp="172.16.0.2"
                uuid="24607ef0fa0b4b3fa6965e4c3c331abe"/>
            </l3BasicNetwork>
          </l3Networks>
        </l2NoVlanNetwork>
      </l2Networks>
    </zone>
  </zones>
</deployerConfig>
{% endhighlight %}

### 还原虚拟云环境

当进行了一些测试后，希望快速还原初始化的虚拟云环境，我们就可以使用上一节的xml内容进行恢复。我们假设xml的文件为：/tmp/simulator-zstack-cloud.xml

#### 停止zstack管理节点
<pre><code>
zstack-ctl stop_node
</code></pre>

#### 初始化数据库
**注意：该操作会清空整个数据库中的数据**
<pre><code>
zstack-ctl deploydb --drop
</code></pre>

如果设置了mysql的root密码，还需要添加 --root-password=MY_MYSQL_ROOT_PASSWORD 的参数。

#### 启动zstack管理节点
<pre><code>
zstack-ctl start_node
</code></pre>

#### 一键恢复zstack云环境
**如果还没有登录zstack-cli或者session已经超时，请使用zstack-cli LogInByAccount accountName=admin password=password**来登录系统。
<pre><code>
zstack-cli -d /tmp/simulator-zstack-cloud.xml
</code></pre>

### 创建一个虚拟云主机试试
<pre><code>
sudo zstack-cli CreateVmInstance name=sim-vm1 l3NetworkUuids=af0c2a51dd954207af9f61e43bfee757 imageUuid=5e40b7d5fed442848830716bfe71ec2e instanceOfferingUuid=3ea91a8e7d3a4cd7b87eaf2f516aa827
</code></pre>

### 总结
在本文中，我们介绍了如何使用zstack-cli 命令来搭建一个模拟的zstack 云环境。也介绍了如何把搭建好的云环境备份下来，然后之后可以一键还原。
欢迎ZStack的用户使用模拟器来熟悉ZStack云环境，以及进行各种性能和压力测试，看看ZStack系统是否可以相应数万的并发API请求。
