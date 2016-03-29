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
  - id: attachPrimaryStorage
    title: Attach Primary Storage
  - id: addBackupStorage
    title: Add Backup Storage
  - id: attachBackupStorage
    title: Attach Backup Storage
  - id: addImage
    title: Add Image
  - id: createL2Network
    title: Create L2 Network
  - id: createL3Network
    title: Create L3 Network
  - id: createInstanceOffering
    title: Create Instance Offering
  - id: createVirtualRouterOffering
    title: Create Virtual Router Offering
  - id: createVM
    title: Create Virtual Machine
  - id: createVIP
    title: Create VIP
  - id: createPortForwarding
    title: Create Port Forwarding
  - id: rebindPortForwarding
    title: Rebind The PortForwarding To Another VM 
  - id: createPortForwarding2
    title: Create 2nd Port Forwarding
---

### Elastic Port Forwarding

<h4 id="overview">1. Overview</h4>
<img class="img-responsive" src="/images/port_forwarding.png">

While EIP can be used to bind a public IP to a VM that is on a private network, it opens all ports of that EIP to the world;
to achieve decent security, users may need to use security group along with EIP. Elastic port forwarding provides another way
to this problem; users can selectively bind one or several ports of an public IP to a VM on the private network, and restrict
what traffic can access these ports.

In this example, we will initially create a port forwarding rule for one VM, and later rebind it to another VM.
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

Based on those requirements, we assume below setup information (you should change the IP address and other configurations to align with your local environment.):

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

add Primary Storagei 'PRIMAYR-STORAGE1' with NFS URI '10.0.101.20:/usr/local/zstack/nfs_root' under zone 'ZONE1':

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
<h4 id="attachPrimaryStorage">8. Attach Primary Storage to Cluster</h4>

attach 'PRIMARY-STORAGE1' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#7_1">Find UUID</button>

<div id="7_1" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryPrimaryStorage fields=uuid, name=PRIMARY-STORAGE1</code></pre>
</div>

	>>> AttachPrimaryStorageToCluster primaryStorageUuid=35405cbbb25d497c94b8484e487f2496 clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t1/cliAttachPrimaryStorageToCluster.png">

<hr>

<h4 id="addBackupStorage">9. Add Backup Storage</h4>

add sftp Backup Storage 'BACKUP-STORAGE1' with backup storage host IP address('10.0.101.20'), root username('root'), password('password') and sftp folder path('/home/sftpBackupStorage'):

	>>> AddSftpBackupStorage name=BACKUP-STORAGE1 hostname=10.0.101.20 username=root password=password url=/home/sftpBackupStorage

<img class="img-responsive" src="/images/tutorials/t1/cliAddBackupStorage.png">

<hr>

<h4 id="attachBackupStorage">10. Attach Backup Storage</h4>

attach new created Backup Storage('BACKUP-STORAGE1') to zone('ZONE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#8">Find UUID</button>

<div id="8" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AttachBackupStorageToZone backupStorageUuid=e5dfe0824d8a4503bbc1b6b51782b5a3 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliAttachBackupStorageToZone.png">

<div class="bs-callout bs-callout-warning">
  It may take a few minutes to complete because Ansible will install necessary packages and deploy ZStack SFTP backup storage agent.
</div>

<hr>

<h4 id="addImage">11. Add Image</h4>

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
  to storage it and images created by yourself.
</div>

<hr>

<h4 id="createL2Network">12. Create L2 Network</h4>

create No Vlan L2 Network 'PUBLIC-MANAGEMENT-L2' with physical interface as 'eth1' under 'ZONE1':

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

create new private Vlan L2 network 'PRIVATE-L2' with physical interface as 'eth0' and vlan '100' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_3">Find UUID</button>

<div id="10_3" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2VlanNetwork name=PRIVATE-L2 physicalInterface=eth0 vlan=100 zoneUuid=69b5be02a15742a08c1b7518e32f442a

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL2Vlan.png">

<hr>

attach 'PRIVATE-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_4">Find UUID</button>

<div id="10_4" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=PRIVATE-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=426017fa734d435bbf3fb99ad5f1b807 clusterUuid=2e88755b7dd0411f9dfc5362fc752b88

<img class="img-responsive" src="/images/tutorials/t1/cliAttachVlanL2toCluster.png">

<hr>

<h4 id="createL3Network">13. Create L3 Network</h4>

on L2 'PUBLIC-MANAGEMENT-L2', create Public Management L3 'PUBLIC-MANAGEMENT-L3' and set system to 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_1">Find UUID</button>

<div id="11_1" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=PUBLIC-MANAGEMENT-L2</code></pre>
</div>

	>>> CreateL3Network name=PUBLIC-MANAGEMENT-L3 l2NetworkUuid=fb76e28e60844dfca1fb71caff37baf2

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL3NoVlan.png">

<hr>

create IP Range for 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_2">Find UUID</button>

<div id="11_2" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	>>> AddIpRange name=PUBLIC-IP-RANGE l3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 startIp=10.0.101.100 endIp=10.0.101.150 netmask=255.255.255.0 gateway=10.0.101.1

<img class="img-responsive" src="/images/tutorials/t1/cliAddIpRange1.png">

<hr>

on L2 network 'PRIVATE-L2', create a new guest VM L3 'PRIVATE-L3' with domain 'tutorials.zstack.org':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_3">Find UUID</button>

<div id="11_3" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=PRIVATE-L2</code></pre>
</div>

	>>> CreateL3Network name=PRIVATE-L3 l2NetworkUuid=426017fa734d435bbf3fb99ad5f1b807 dnsDomain=tutorials.zstack.org

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL3Vlan.png">

<hr>

create IP Range for 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_4">Find UUID</button>

<div id="11_4" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
</div>

	>>> AddIpRange name=PRIVATE-RANGE l3NetworkUuid=ca17c4f3425e44ff9d77b9817b76aa7d startIp=10.0.0.2 endIp=10.0.0.254 netmask=255.255.255.0 gateway=10.0.0.1

<img class="img-responsive" src="/images/tutorials/t1/cliAddIpRange2.png">

<hr>

add DNS for 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_5">Find UUID</button>

<div id="11_5" class="collapse">
<pre><code>QueryL3Network fields=uuid name=PRIVATE-L3</code></pre>
</div>

	>>> AddDnsToL3Network l3NetworkUuid=ca17c4f3425e44ff9d77b9817b76aa7d dns=8.8.8.8

<img class="img-responsive" src="/images/tutorials/t1/cliAddDns.png">

<hr>

we need to get available network service provider UUID, before add any virtual router service to L3 network:

	>>> QueryNetworkServiceProvider

<img class="img-responsive" src="/images/tutorials/t1/cliQueryNetworkServiceProvider.png">

there are 2 available network service providers. In this tutorial, we just need the Virtual Router, which could provide 'DHCP', 'SNAT', 'DNS', 'PortForwarding' and 'Eip'.

<hr>

attach VirtualRouter services 'DHCP', 'SNAT', 'DNS' and 'PortForwarding' to 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_6">Find UUID</button>

<div id="11_6" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid, name=VirtualRouter</code></pre>
</div>

<div class="bs-callout bs-callout-info">
  <h4>Structure of parameter networkServices</h4>
  It's a JSON object of map that key is UUID of network service provider and value is a list of network service types.
</div>

	>>> AttachNetworkServiceToL3Network networkServices="{'96c5fbe222ad4b6586d35086b67ec07a':['DHCP','DNS','SNAT','PortForwarding']}" l3NetworkUuid=ca17c4f3425e44ff9d77b9817b76aa7d 

<img class="img-responsive" src="/images/tutorials/t5/cliAttachNetworkServiceToL3.png">

<hr>

<h4 id="createInstanceOffering">14. Create Instance Offering</h4>

create a guest VM instance offering 'small-instance' with 1 512Mhz CPU and 128MB memory:

	>>> CreateInstanceOffering name=small-instance cpuNum=1 cpuSpeed=512 memorySize=134217728

<img class="img-responsive" src="/images/tutorials/t1/cliCreateInstanceOffering.png">

<hr>

<h4 id="createVirtualRouterOffering">15. Create Virtual Router Offering</h4>

create a Virtual Router VM instance offering 'VR-OFFERING' with 1 512Mhz CPU, 512MB memory, management L3 network 'PUBLIC-MANAGEMENT-L3', public L3 network 'PUBLIC-MANAGEMENT-L3' and isDefault 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13">Find UUID</button>

<div id="13" class="collapse">
<pre><code>QueryImage fields=uuid, name=VIRTUAL-ROUTER</code></pre>
<pre><code>QueryL3Network fields=uuid name=PUBLIC-MANAGEMENT-L3</code></pre>
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateVirtualRouterOffering name=VR-OFFERING cpuNum=1 cpuSpeed=512 memorySize=536870912 imageUuid=854801a869e149b092281e0ef65585f9 managementNetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 publicNetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9 isDefault=True zoneUuid=69b5be02a15742a08c1b7518e32f442a	

<img class="img-responsive" src="/images/tutorials/t1/cliCreateVirtualRouterOffering.png">

<hr>

<h4 id="createVM">16. Create Virtual Machine</h4>

create a new guest VM instance with configuration:

1. instance offering 'small-instance'
2. image 'zs-sample-image'
3. L3 network 'PRIVATE-L3'
4. name 'VM1'

<hr>

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#16">Find UUID</button>

<div id="16" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
</div>

	>>> CreateVmInstance name=VM1 instanceOfferingUuid=328d52eae4ff4ba0a685101c3116020a imageUuid=62cf76d08c944288a92de98af1405289 l3NetworkUuids=ca17c4f3425e44ff9d77b9817b76aa7d systemTags=hostname::vm1

<img class="img-responsive" src="/images/tutorials/t1/cliVmCreation.png">

the new VM has 1 NIC ('585bb3322f444f2296eb12f3f06e4f89') and assigned IP address: 10.0.0.210

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="createVIP">17. Create VIP</h4>

create a new VIP 'VIP1' on 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#17">Find UUID</button>

<div id="17" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	>>> CreateVip name=VIP1 l3NetworkUuid=4f38ba9a57a44efa8f3f575c08dce3d9

<img class="img-responsive" src="/images/tutorials/t1/cliCreateVip.png">

once it finishes, you should be able to see the new IP address, which will be used in Port Forwarding; in our case, the VIP is '10.0.101.138'.

<hr>

<h4 id="createPortForwarding">18. Create Port Forwarding</h4>

create a new Port Forwarding 'PORT-FORWARDING1' with 'VIP1' for 'VM1' NIC UUID '585bb3322f444f2296eb12f3f06e4f89' to bind VM1's 22 port with VIP1's 22 port: 

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18">Find UUID</button>

<div id="18" class="collapse">
<pre><code>QueryVip fields=uuid name=VIP1</code></pre>
<pre><code>QueryVmNic fields=uuid vmInstance.name=VM1</code></pre>
</div>

	>>> CreatePortForwardingRule name=PORT-FORWARDING1 vipUuid=2bad3299657544418d1cb776cac4493b vmNicUuid=585bb3322f444f2296eb12f3f06e4f89 protocolType=TCP privatePortStart=22 privatePortEnd=22 vipPortStart=22 vipPortEnd=22

<img class="img-responsive" src="/images/tutorials/t5/cliCreatePF1.png">

<hr>

use a machine that can reach subnet 10.0.101.0/24 to SSH the IP '10.0.101.138', you should be able to login the VM and see its internal IP address:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_1">Find VIP of the port forwarding rule</button>

<div id="18_1" class="collapse">
<pre><code>QueryVip fields=ip portForwarding.vipPortStart=22</code></pre>
</div>

	# ssh 10.0.101.138 /sbin/ifconfig

<img class="img-responsive" src="/images/tutorials/t1/cliSshEip.png">

<hr>

<h4 id="rebindPortForwarding">19. Rebind The Port Forwarding To Another VM</h4>

follow instructions in section <a href="#createVM">16. Create Virtual Machine</a> to create another VM(VM2) on the private
L3 network:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#19_1">Find UUID</button>

<div id="19_1" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
</div>

	>>> CreateVmInstance name=VM2 instanceOfferingUuid=328d52eae4ff4ba0a685101c3116020a imageUuid=62cf76d08c944288a92de98af1405289 l3NetworkUuids=ca17c4f3425e44ff9d77b9817b76aa7d systemTags=hostname::vm2

<img class="img-responsive" src="/images/tutorials/t1/cliVmCreation2.png">

<hr>

then detach 'PORT-FORWARDING1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#19_2">Find UUID</button>

<div id="19_2" class="collapse">
<pre><code>QueryPortForwardingRule fields=uuid name=PORT-FORWARDING1</code></pre>
</div>

	>>> DetachPortForwardingRule uuid=42f4646b75fc43db9431728fd033e813

<img class="img-responsive" src="/images/tutorials/t5/cliDetachPF.png">

<hr>

after detaching, attach the 'PORT-FORWARDING1' to VM2 NIC:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#19_3">Find UUID</button>

<div id="19_3" class="collapse">
<pre><code>QueryPortForwardingRule fields=uuid name=PORT-FORWARDING1</code></pre>
<pre><code>QueryVmNic fields=uuid vmInstance.name=VM2</code></pre>
</div>

	>>> AttachPortForwardingRule ruleUuid=42f4646b75fc43db9431728fd033e813 vmNicUuid=8faf3fcf62f34c33b67d4f03f1a2ea7d

<img class="img-responsive" src="/images/tutorials/t5/cliAttachPF.png">

SSH login to the '10.0.101.138' again and run command 'hostname; ifconfig', you should see 'VM2' hostname internal network information:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_2">Find VIP of the port forwarding rule</button>

<div id="18_2" class="collapse">
<pre><code>QueryVip fields=ip portForwarding.vipPortStart=22</code></pre>
</div>

	# ssh 10.0.101.138

<img class="img-responsive" src="/images/tutorials/t1/cliSshEip2.png">

<hr>

<h4 id="createPortForwarding2">20. Create the 2nd Port Forwarding</h4>

create a new Port Forwarding 'PORT-FORWARDING2' with 'VIP1' for 'VM1' NIC UUID '585bb3322f444f2296eb12f3f06e4f89' to bind VM1's 22 port to VIP1's 2222 port:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#20">Find UUID</button>

<div id="20" class="collapse">
<pre><code>QueryVip fields=uuid name=VIP1</code></pre>
<pre><code>QueryVmNic fields=uuid vmInstance.name=VM1</code></pre>
</div>

	>>> CreatePortForwardingRule name=PORT-FORWARDING2 vipUuid=2bad3299657544418d1cb776cac4493b vmNicUuid=585bb3322f444f2296eb12f3f06e4f89 protocolType=TCP privatePortStart=22 privatePortEnd=22 vipPortStart=2222 vipPortEnd=2222

<img class="img-responsive" src="/images/tutorials/t5/cliCreatePF2.png">

<hr>

then PORT-FORWARDING1 and PORT-FORWARDING2 are sharing same VIP1 10.0.101.138 but mapping different ports to different VMs.

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_3">Find VIP of the port forwarding rule</button>

<div id="18_3" class="collapse">
<pre><code>QueryVip fields=ip name=VIP1</code></pre>
</div>

When ssh 22 port, it will be routed to VM2:

	# ssh root@10.0.101.138

<img class="img-responsive" src="/images/tutorials/t1/cliSshEip2.png">

 when ssh 2222 port, it will be routed to VM1:

	# ssh root@10.0.101.138 -p 2222

<img class="img-responsive" src="/images/tutorials/t5/cliSshPF2.png">

### Summary

In this tutorial, we showed you how to create port forwarding rules that allow public traffic to reach
specific ports of VMs on the private L3 network. For more details, please visit
[Elastic Port Forwarding in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/portForwarding.html).
