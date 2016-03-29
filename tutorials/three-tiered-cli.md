---
title: ZStack Tutorials
layout: tutorialDetailPage
sections:
  - id: overview 
    title: Overview
  - id: prerequisites 
    title: Prerequisites
  - id: login 
    title: LogIn
  - id: createZone 
    title: Create Zone
  - id: createCluster 
    title: Create Cluster
  - id: addHost 
    title: Add Host
  - id: addPrimaryStorage
    title: Add Primary Storage
  - id: addBackupStorage
    title: Add Backup Storage
  - id: addImage
    title: Add Image
  - id: createPublicL2Network
    title: Create Public L2 Network
  - id: createPublicL3Network
    title: Create Public L3 Network
  - id: createApplicationL2Network
    title: Create Application L2 Network
  - id: createApplicationL3Network
    title: Create Application L3 Network
  - id: createDatabaseL2Network
    title: Create Database L2 Network
  - id: createDatabaseL3Network
    title: Create Database L3 Network
  - id: createInstanceOffering
    title: Create Instance Offering
  - id: createVirtualRouterOffering
    title: Create Virtual Router Offering
  - id: createWebVM
    title: Create Web VM
  - id: createApplicationVM
    title: Create Application VM
  - id: createDatabaseVM
    title: Create Database VM
  - id: createTestVM
    title: Confirm VM Connectivity
---

<h4 id="overview">1. Overview</h4>
<img class="img-responsive" src="/images/tier_3_networks.png">

Three tiered network gets its popularity because users can deploy presentation layer, application layer, and database layer
into separate networks, in order to get better isolation and security.

In this example, we will create a deployment that consists of three L3 networks: web network, application network, and database
network. The web network connecting to internet can be reached by public traffic, application network and database network
are private but can reach internet through source NAT. For the sake of demonstration, we will create 3 VMs: web-vm, application-vm,
and database-vm; web-vm will have two nics that one is on web network and another is on application network; application-vm will
have two nics too that one is on application network and another is on database network; database-vm will have only one nic that is
on database network.

<hr>

<h4 id="prerequisites">2. Prerequisites</h4>

We assume you have followed [Quick Installation Guide](../installation/index.html) to install ZStack on a single Linux machine, and
the ZStack management node is up and running. To use the command line tool, type below command in your shell terminal:

    #zstack-cli
    
<img class="img-responsive" src="/images/tutorials/t1/zstackCli.png">

<div class="bs-callout bs-callout-info">
  <h4>Connect to a remote management node</h4>
  By default, zstack-cli connects to the ZStack management node on the local machine. To connect
  to a remote node, using option '-H ZSTACK_NODE_HOST_IP'; for example: zstack-cli -H 192.168.0.224
</div>

To make things simple, we assume you have only one Linux machine with one network card that can access the internet; besides, there are
some other requirements:

+ At least 20G free disk that can be used as primary storage and backup storage
+ Several free IPs that can access the internet
+ NFS server is enabled on the machine (done in [Quick Installation Guide](../installation/index.html))
+ SSH credentials for user root (done in [Quick Installation Guide](../installation/index.html))

<div class="bs-callout bs-callout-info">
  <h4>Configure root user</h4>
  The KVM host will need root user credentials of SSH, to allow Ansible to install necessary packages and to give the KVM agent full control
  of the host. As this tutorial use a single machine for both ZStack management node and KVM host, you will need to configure credentials for
  the root user.
  
  <h5>CentOS:</h5>
  <pre><code>sudo su
passwd root</code></pre>

  <h5>Ubuntu:</h5>
  You need to also enable root user in SSHD configuration.
  <pre><code>1. sudo su
2. passwd root
3. edit /etc/ssh/sshd_config
4. comment out 'PermitRootLogin without-password'
5. add 'PermitRootLogin yes'
6. restart SSH: 'service ssh restart'</code></pre>
</div>

Based on those requirements, we assume below setup information:

+ ethernet device names: eth0
+ eth0 IP: 10.0.101.20
+ free IP range: 10.0.101.100 ~ 10.0.101.150 (these IPs can access the internet)
+ primary storage folder: 10.0.101.1:/home/nfs
+ backup storage folder: /home/sftpBackupStorage

<div class="bs-callout bs-callout-warning">
  <h4>Slow VM stopping due to lack of ACPID:</h4>
    Though we don't show the example of stopping VM, you may find stopping a VM takes more than 60s. That's 
    because the VM image doesn't support ACPID that receives KVM's shutdown event, ZStack has to
    wait for 60 seconds timeout then destroy it. It's not a problem for regular Linux distributions which have ACPID installed.
</div>
    
<hr>

<h4 id="login">3. LogIn</h4>

open zstack-cli and login with admin/password:

	>>> LogInByAccount accountName=admin password=password	

<img class="img-responsive" src="/images/tutorials/t1/cliLogin.png">

<hr>

<h4 id="createZone">4. Create Zone</h4>

create a zone with name 'ZONE1' and description 'zone 1':

	>>> CreateZone name=ZONE1 description='zone 1'

<img class="img-responsive" src="/images/tutorials/t1/cliCreateZone.png">

<div class="bs-callout bs-callout-info">
  <h4>Substitute your UUIDs for those in this tutorial</h4>
  Resources are all referred by UUIDs in CLI tutorials. The UUIDs are generated by ZStack when you create a resource, so they
  may vary from what you see in tutorials. UUIDs of resources will be printed out in a JSON object to the screen after resources
  are created; however, it's inconvenient to scroll up screen to find UUIDs of resources that are created very early. We add
  buttons <img src="/images/tutorials/find-uuid.png" style="border:none"> to sections, which will show you commands of retrieving UUIDs of resources,
  so please make sure you replace UUIDs in tutorials with yours.
</div>

<hr>

<h4 id="createCluster">5. Create Cluster</h4>

create a cluster with name 'CLUSTER1' and hypervisorType 'KVM' under zone 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#5">Find UUID</button>

<div id="5" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateCluster name=CLUSTER1 hypervisorType=KVM zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliCreateCluster.png">

<hr>

<h4 id="addHost">6. Create Host</h4>

add KVM Host 'HOST1' under 'CLUSTER1' with correct host IP address and root username and password:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#6">Find UUID</button>

<div id="6" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
</div>

	>>> AddKVMHost name=HOST1 managementIp=10.0.101.20 username=root password=password clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t1/cliCreateHost.png">

<div class="bs-callout bs-callout-warning">
  <h4>A little slow when first time adding a host</h4>
  It may take a few minutes to add a host because Ansible will install all dependent packages, for example, KVM, on the host.
</div>

<hr>

<h4 id="addPrimaryStorage">7. Add Primary Storage</h4>

add Primary Storage 'PRIMAYR-STORAGE1' with NFS URI '10.0.101.20:/usr/local/zstack/nfs_root' under zone 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#7">Find UUID</button>

<div id="7" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> AddNfsPrimaryStorage name=PRIMARY-STORAGE1 url=10.0.101.20:/usr/local/zstack/nfs_root zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliAddPrimaryStorage.png">

<div class="bs-callout bs-callout-info">
  <h4>Format of NFS URL</h4>
  The format of URL is exactly the same to the one used by Linux <i>mount</i> command.
</div>

<hr>

attach 'PRIMARY-STORAGE1' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#7_1">Find UUID</button>

<div id="7_1" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryPrimaryStorage fields=uuid, name=PRIMARY-STORAGE1</code></pre>
</div>

	>>> AttachPrimaryStorageToCluster primaryStorageUuid=35405cbbb25d497c94b8484e487f2496 clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t1/cliAttachPrimaryStorageToCluster.png">

<hr>

<h4 id="addBackupStorage">8. Add Backup Storage</h4>

add sftp Backup Storage 'BACKUP-STORAGE1' with backup storage host IP address('10.0.101.20'), root username('root'), password('password') and sftp folder path('/home/sftpBackupStorage'):

	>>> AddSftpBackupStorage name=BACKUP-STORAGE1 hostname=10.0.101.20 username=root password=password url=/home/sftpBackupStorage

<img class="img-responsive" src="/images/tutorials/t1/cliAddBackupStorage.png">

<hr>

attach new created Backup Storage('BACKUP-STORAGE1') to zone('ZONE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#8">Find UUID</button>

<div id="8" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AttachBackupStorageToZone backupStorageUuid=e5dfe0824d8a4503bbc1b6b51782b5a3 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliAttachBackupStorageToZone.png">

<hr>

<h4 id="addImage">9. Add Image</h4>

add Image('zs-sample-image') with format 'qcow2', 'RootVolumeTemplate' type, 'Linux' platform and image URL('{{site.zstack_image}}') to backup storage ('BACKUP-STORAGE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#9_1">Find UUID</button>

<div id="9_1" class="collapse">
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AddImage name=zs-sample-image format=qcow2 mediaType=RootVolumeTemplate platform=Linux url={{site.zstack_image}} backupStorageUuids=e5dfe0824d8a4503bbc1b6b51782b5a3

<img class="img-responsive" src="/images/tutorials/t1/cliAddImage.png">

this image will be used as user VM image.

<hr>

add another Image('VIRTUAL-ROUTER') with format 'qcow2', 'RootVolumeTemplate' type, 'Linux' platform and image URL({{site.vr_en}}) to backup storage ('BACKUP-STORAGE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#9_2">Find UUID</button>

<div id="9_2" class="collapse">
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

<div class="bs-callout bs-callout-success">
  <h4>Fast link for users of Mainland China</h4>
  由于国内访问我们位于美国的服务器速度较慢，国内用户请使用以下链接：
  
  <pre><code>{{site.vr_ch}}</code></pre>
</div>

	>>> AddImage name=VIRTUAL-ROUTER format=qcow2 mediaType=RootVolumeTemplate platform=Linux url={{site.vr_en}} backupStorageUuids=e5dfe0824d8a4503bbc1b6b51782b5a3


<img class="img-responsive" src="/images/tutorials/t1/cliAddVRImage.png">

this image will be used as Virtual Router VM image.

<div class="bs-callout bs-callout-info">
  <h4>Cache images in your local HTTP server</h4>
  The virtual router image is about 432M that takes a little of time to download. We suggest you use a local HTTP server
  to store it and images created by yourself.
</div>

<hr>

<h4 id="createPublicL2Network">10. Create Public L2 Network</h4>

create No Vlan Public L2 Network 'PUBLIC-MANAGEMENT-L2' with physical interface as 'eth0' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_1">Find UUID</button>

<div id="10_1" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2NoVlanNetwork name=PUBLIC-MANAGEMENT-L2 physicalInterface=eth0 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL2NoVlan.png">

<hr>

attach 'PUBLIC-MANAGEMENT-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_2">Find UUID</button>

<div id="10_2" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=PUBLIC-MANAGEMENT-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=fb76e28e60844dfca1fb71caff37baf2 clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t1/cliAttachNoVlanL2toCluster.png">

<hr>

<h4 id="createPublicL3Network">11. Create Public L3 Network</h4>

on L2 'PUBLIC-MANAGEMENT-L2', create Public Management L3 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_1">Find UUID</button>

<div id="11_1" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=PUBLIC-MANAGEMENT-L2</code></pre>
</div>

	>>> CreateL3Network name=PUBLIC-MANAGEMENT-L3 l2NetworkUuid=fb76e28e60844dfca1fb71caff37baf2

<img class="img-responsive" src="/images/tutorials/t3/cliCreateL3NoVlan.png">

<hr>

create IP Range for 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_2">Find UUID</button>

<div id="11_2" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	>>> AddIpRange name=PUBLIC-IP-RANGE l3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 startIp=10.0.101.100 endIp=10.0.101.150 netmask=255.255.255.0 gateway=10.0.101.1

<img class="img-responsive" src="/images/tutorials/t1/cliAddIpRange1.png">

<hr>

add DNS for 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_4">Find UUID</button>

<div id="11_4" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	>>> AddDnsToL3Network l3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 dns=8.8.8.8

<img class="img-responsive" src="/images/tutorials/t3/cliAddDns1.png">

<hr>

we need to get UUIDS of available network service providers, before attaching any virtual router services to the L3 network:

	>>> QueryNetworkServiceProvider

<img class="img-responsive" src="/images/tutorials/t3/cliQueryNetworkServiceProvider.png">

there are 2 available network service providers. In this tutorial, we just need the Virtual Router, which could provide 'DHCP', 'SNAT', 'DNS', 'PortForwarding' and 'Eip'.

<hr>

attach VirtualRouter services 'DHCP' and 'DNS' to 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_6">Find UUID</button>

<div id="11_6" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid, name=VirtualRouter</code></pre>
</div>

<div class="bs-callout bs-callout-info">
  <h4>Structure of parameter networkServices</h4>
  It's a JSON object of map that key is UUID of network service provider and value is a list of network service types.
</div>

	>>> AttachNetworkServiceToL3Network networkServices="{'4d2e4116a680421ea731a4f128c417f2':['DHCP','DNS']}" l3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 

<img class="img-responsive" src="/images/tutorials/t3/cliAttachNetworkService1.png">

<hr>

<h4 id="createApplicationL2Network">12. Create Application L2 Network</h4>

create Vlan L2 Network 'APPLICATION-L2' with physical interface as 'eth0' and vlan '100' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#12_1">Find UUID</button>

<div id="12_1" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2VlanNetwork name=APPLICATION-L2 physicalInterface=eth0 vlan=100 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t3/cliCreateAppL2.png">

<hr>

attach 'APPLICATION-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#12_2">Find UUID</button>

<div id="12_2" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=APPLICATION-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=b8132ea7bfa54946a312d9811478d420 clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t3/cliAttachL2-1.png">

<hr>

<h4 id="createApplicationL3Network">13. Create Application L3 Network</h4>

on L2 'APPLICATION-L2', create Application L3 'APPLICATION-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13_1">Find UUID</button>

<div id="13_1" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=APPLICATION-L2</code></pre>
</div>

	>>> CreateL3Network name=APPLICATION-L3 l2NetworkUuid=b8132ea7bfa54946a312d9811478d420

<img class="img-responsive" src="/images/tutorials/t3/cliCreateAppL3.png">

<hr>

create IP Range for 'APPLICATION-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13_2">Find UUID</button>

<div id="13_2" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=APPLICATION-L3</code></pre>
</div>

	>>> AddIpRange name=APPLICATION-IP-RANGE l3NetworkUuid=12e3b797f903436cb7a13f33b6cc561e startIp=192.168.0.2 endIp=192.168.0.254 netmask=255.255.255.0 gateway=192.168.0.1

<img class="img-responsive" src="/images/tutorials/t3/cliAddIpRange1.png">

<hr>

add DNS for 'APPLICATION-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13_3">Find UUID</button>

<div id="13_3" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=APPLICATION-L3</code></pre>
</div>

	>>> AddDnsToL3Network l3NetworkUuid=12e3b797f903436cb7a13f33b6cc561e dns=8.8.8.8

<img class="img-responsive" src="/images/tutorials/t3/cliAddDns2.png">

<hr>

attach VirtualRouter services 'DHCP', 'DNS' and 'SNAT' to 'APPLICATION-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13_4">Find UUID</button>

<div id="13_4" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=APPLICATION-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid, name=VirtualRouter</code></pre>
</div>

	>>> AttachNetworkServiceToL3Network networkServices="{'4d2e4116a680421ea731a4f128c417f2':['DHCP','DNS','SNAT']}" l3NetworkUuid=12e3b797f903436cb7a13f33b6cc561e

<img class="img-responsive" src="/images/tutorials/t3/cliAttachNetworkService2.png">

<hr>

<h4 id="createDatabaseL2Network">14. Create Database L2 Network</h4>

create Vlan L2 Network 'DATABASE-L2' with physical interface as 'eth0' and vlan '101' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#14_1">Find UUID</button>

<div id="14_1" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2VlanNetwork name=DATABASE-L2 physicalInterface=eth0 vlan=101 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t3/cliCreateDBL2.png">

<hr>

attach 'DATABASE-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#14_2">Find UUID</button>

<div id="14_2" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=DATABASE-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=864bfddcac3d429c8b32002ad9d1e79b clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t3/cliAttachL2-2.png">

<hr>

<h4 id="createDatabaseL3Network">15. Create Database L3 Network</h4>

on L2 'DATABASE-L2', create Database L3 'DATABASE-L3' with domain name 'database.zstack.org':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#15_1">Find UUID</button>

<div id="15_1" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=DATABASE-L2</code></pre>
</div>

	>>> CreateL3Network name=DATABASE-L3 l2NetworkUuid=b8132ea7bfa54946a312d9811478d420 dnsDomain=database.zstack.org

<img class="img-responsive" src="/images/tutorials/t3/cliCreateDBL3.png">

<hr>

create IP Range for 'DATABASE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#15_2">Find UUID</button>

<div id="15_2" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=DATABASE-L3</code></pre>
</div>

	>>> AddIpRange name=DATABASE-IP-RANGE l3NetworkUuid=ca289521b7e0443abfb42cd1b669f548 startIp=192.168.10.2 endIp=192.168.10.254 netmask=255.255.255.0 gateway=192.168.10.1

<img class="img-responsive" src="/images/tutorials/t3/cliAddIpRange2.png">

<hr>

add DNS for 'DATABASE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#15_3">Find UUID</button>

<div id="15_3" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=DATABASE-L3</code></pre>
</div>

	>>> AddDnsToL3Network l3NetworkUuid=ca289521b7e0443abfb42cd1b669f548 dns=8.8.8.8

<img class="img-responsive" src="/images/tutorials/t3/cliAddDns3.png">

<hr>

attach VirtualRouter services 'DHCP', 'DNS' and 'SNAT' to 'DATABASE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#15_4">Find UUID</button>

<div id="15_4" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=DATABASE-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid, name=VirtualRouter</code></pre>
</div>

	>>> AttachNetworkServiceToL3Network networkServices="{'4d2e4116a680421ea731a4f128c417f2':['DHCP','DNS','SNAT']}" l3NetworkUuid=ca289521b7e0443abfb42cd1b669f548

<img class="img-responsive" src="/images/tutorials/t3/cliAttachNetworkService3.png">

<hr>

<h4 id="createInstanceOffering">16. Create Instance Offering</h4>

create a guest VM instance offering 'small-instance' with 1 512Mhz CPU and 128MB memory:

	>>> CreateInstanceOffering name=small-instance cpuNum=1 cpuSpeed=512 memorySize=134217728

<img class="img-responsive" src="/images/tutorials/t1/cliCreateInstanceOffering.png">

<hr>

<h4 id="createVirtualRouterOffering">17. Create Virtual Router Offering</h4>

create a Virtual Router VM instance offering 'VR-OFFERING' with 1 512Mhz CPU, 512MB memory, management L3 network 'PUBLIC-MANAGEMENT-L3', public L3 network 'PUBLIC-MANAGEMENT-L3' and isDefault 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13">Find UUID</button>

<div id="13" class="collapse">
<pre><code>QueryImage fields=uuid, name=VIRTUAL-ROUTER</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name=PUBLIC-MANAGEMENT-L3</code></pre>
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateVirtualRouterOffering name=VR-OFFERING cpuNum=1 cpuSpeed=512 memorySize=536870912 imageUuid=854801a869e149b092281e0ef65585f9 managementNetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 publicNetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 isDefault=True zoneUuid=69b5be02a15742a08c1b7518e32f442a	
<img class="img-responsive" src="/images/tutorials/t1/cliCreateVirtualRouterOffering.png">

<hr>

<h4 id="createWebVM">18. Create WEB VM</h4>

create a new WEB VM instance with configuration:

1. instance offering 'small-instance'
2. image 'zs-sample-image'
3. L3 network 'PUBLIC-MANAGEMENT-L3'(default L3) and 'APPLICATION-L3'
4. name 'WEB-VM1'
5. hostname 'web'

<hr>
<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_1">Find UUID</button>

<div id="18_1" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name?=PUBLIC-MANAGEMENT-L3,APPLICATION-L3</code></pre>
</div>

	>>> CreateVmInstance name=WEB-VM1 instanceOfferingUuid=328d52eae4ff4ba0a685101c3116020a imageUuid=62cf76d08c944288a92de98af1405289 l3NetworkUuids=12e3b797f903436cb7a13f33b6cc561e,4f38ba9a57a44efa8f3f575c08dce3d9 defaultL3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 systemTags=hostname::web

<img src="/images/tutorials/t3/cliWebVM1.png">

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="createApplicationVM">19. Create Application VM</h4>

create a new Application VM instance with configuration:

1. instance offering 'small-instance'
2. image 'zs-sample-image'
3. L3 network 'APPLICATION-L3'(default L3) and 'DATABASE-L3'
4. name 'APPLICATION-VM1'
5. hostname 'application'

<hr>
<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#19_1">Find UUID</button>

<div id="19_1" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name?=APPLICATION-L3,DATABASE-L3</code></pre>
</div>

	>>> CreateVmInstance name=APPLICATION-VM1 instanceOfferingUuid=328d52eae4ff4ba0a685101c3116020a imageUuid=62cf76d08c944288a92de98af1405289 l3NetworkUuids=12e3b797f903436cb7a13f33b6cc561e,ca289521b7e0443abfb42cd1b669f548 defaultL3NetworkUuid=12e3b797f903436cb7a13f33b6cc561e systemTags=hostname::application

<img src="/images/tutorials/t3/cliAppVM1.png">

<div class="bs-callout bs-callout-warning">
  <h4>Again, slow because of creating the virtual router VM</h4>
  Because it's the first VM on DATABASE-L3 network, ZStack will start the virtual router VM before creating APPLICATION-VM,
  it will takes about 1 minute to finish. Future VMs creation on the DATABASE-L3 will be extremely fast. 
</div>

<hr>

<h4 id="createDatabaseVM">20. Create Database VM</h4>

create a new Application VM instance with configuration:

1. instance offering 'small-instance'
2. image 'zs-sample-image'
3. L3 network 'DATABASE-L3'
4. input name as 'DATABASE-VM'
5. input host name as 'database'

<hr>
<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#20_1">Find UUID</button>

<div id="20_1" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name=DATABASE-L3</code></pre>
</div>

	>>> CreateVmInstance name=DATABASE-VM1 instanceOfferingUuid=328d52eae4ff4ba0a685101c3116020a imageUuid=62cf76d08c944288a92de98af1405289 l3NetworkUuids=ca289521b7e0443abfb42cd1b669f548 systemTags=hostname::database

<img src="/images/tutorials/t3/cliDBVM1.png">

<hr>

<h4 id="testVM">21. Confirm Network Connectivity</h4>

use a machine that can reach subnet 10.0.101.0/24 to SSH IP '10.0.101.147', you should be able to login the WEB-VM1(username:root, password:password) and see 2 IP addresses:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#21_1">Find IP</button>

<div id="21_1" class="collapse">
<pre><code>QueryVmNic fields=ip vmInstance.name=WEB-VM1 l3Network.name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	# ssh root@10.0.101.147

<img src="/images/tutorials/t3/cliSshVM1.png">

<hr>

after login into WEB-VM1, you could ping 'www.w3.org', then ssh IP '192.168.0.244', which is APPLICATION-VM1:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#21_2">Find IP</button>

<div id="21_2" class="collapse">
<pre><code>QueryVmNic fields=ip vmInstance.name=APPLICATION-VM1 l3Network.name=APPLICATION-L3</code></pre>
</div>

	# ssh root@192.168.0.244

<img src="/images/tutorials/t3/cliSshVM2.png">

<hr>

through APPLICATION-VM1, you can also ping 'www.w3.org', then ssh IP '192.168.10.208', which is DATABASE-VM1:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#21_3">Find IP</button>

<div id="21_3" class="collapse">
<pre><code>QueryVmNic fields=ip vmInstance.name=DATABASE-VM1 l3Network.name=DATABASE-L3</code></pre>
</div>

	# ssh root@192.168.10.208

<img src="/images/tutorials/t3/cliSshVM4.png">

<hr>

in DATABASE-VM1, you can reach 'www.w3.org', WEB-VM1 ('10.0.101.147') and APPLICATION-VM1 ('192.168.10.208'):

<img src="/images/tutorials/t3/cliSshVM5.png">

<hr>

### Summary

In this example, we showed you how to create a three tiered network in ZStack. For the sake of demonstration, we don't
apply any firewall. You can use security group combining with this example to create a more secure deployment. For
more details, please visit [L3 Network in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/l3Network.html).
