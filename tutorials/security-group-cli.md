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
  - id: createL2Network
    title: Create L2 Network
  - id: createL3Network
    title: Create L3 Network
  - id: createSecurityGroup
    title: Create Security Group
  - id: createInstanceOffering
    title: Create Instance Offering
  - id: createVirtualRouterOffering
    title: Create Virtual Router Offering
  - id: createInnerVM
    title: Create INNER-VM
  - id: joinInnerVM
    title: Join INNER-VM Into Security Group
  - id: createOuterVM
    title: Create OUTER-VM
  - id: sshLogin
    title: SSH Login INNER-VM From OUTER-VM
  - id: deleteSecurityGroupRule
    title: Delete Security Group Rule
  - id: sshLoginFailure
    title: Confirm Unable to SSH Login INNER-VM From OUTER-VM
---

### Security Group

<h4 id="overview">1. Overview</h4>
<img src="/images/flat_network_with_security_group.png">

Security group is a virtual firewall that can control the traffic for a group of VMs. In this example, we will
create a flat network with a security group, then create one VM(INNER-VM) in the security group and another VM(OUTER-VM) out of
the security group. The security group will initially contain a rule opening port 22 to the OUTER-VM; we will confirm OUTER-VM
can SSH login the INNER-VM; later on, we will remove the only rule and confirm OUTER-VM cannot SSH login INNER-VM anymore.

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

</div>

Based on those requirements, we assume below setup information:

+ ethernet device names: eth0
+ eth0 IP: 172.20.11.34
+ free IP range: 10.121.9.40 ~ 10.121.9.200 (these IPs can access the internet)
+ primary storage folder: /zstack_ps
+ backup storage folder: /zstack_bs

<div class="bs-callout bs-callout-warning">
  <h4>Slow VM stopping due to lack of ACPID:</h4>
    Though we don't show the example of stopping VM, you may find stopping a VM takes more than 60s. That's 
    because the VM image doesn't support ACPID that receives KVM's shutdown event, ZStack has to
    wait for 60 seconds timeout then destroy it. It's not a problem for regular Linux distributions which have ACPID installed.
</div>

<div class="bs-callout bs-callout-warning">
  <h4>Avoid DHCP conflict</h4>
  Please make sure you don't have a DHCP server in the network because ZStack will spawn its own DHCP server; if you have a
  DHCP server in the network and cannot remove it, please use an IP range that is unlikely used by your DHCP server, otherwise the VM 
  may not receive an IP from ZStack's DHCP server but from yours.
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

	>>> CreateCluster name=CLUSTER1 hypervisorType=KVM zoneUuid=b5ba18197f7843308cd26f87eab933c5

<img class="img-responsive" src="/images/tutorials/t1/cliCreateCluster.png">

<hr>

<h4 id="addHost">6. Create Host</h4>

add KVM Host 'HOST1' under 'CLUSTER1' with correct host IP address and root username and password:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#6">Find UUID</button>

<div id="6" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
</div>

	>>> AddKVMHost name=HOST1 managementIp=172.20.11.34 username=root password=password clusterUuid=e630ebdb5f7742f3818fd998e91d35a8

<img class="img-responsive" src="/images/tutorials/t1/cliCreateHost.png">

<div class="bs-callout bs-callout-warning">
  <h4>A little slow when first time adding a host</h4>
  It may take a few minutes to add a host because Ansible will install all dependent packages, for example, KVM, on the host.
</div>

<hr>

<h4 id="addPrimaryStorage">7. Add Primary Storage</h4>

add Primary Storage 'PRIMAYR-STORAGE1' with URL '/zstack_ps' under zone 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#7">Find UUID</button>

<div id="7" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> AddLocalPrimaryStorage name=PRIMARY-STORAGE1 url=/zstack_ps zoneUuid=b5ba18197f7843308cd26f87eab933c5

<img class="img-responsive" src="/images/tutorials/t1/cliAddPrimaryStorage.png">

<div class="bs-callout bs-callout-info">
  <h4>Format of URL</h4>
  The format of URL is exactly the same to the one used by Linux <i>mount</i> command.
</div>

<hr>

attach 'PRIMARY-STORAGE1' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#7_1">Find UUID</button>

<div id="7_1" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryPrimaryStorage fields=uuid, name=PRIMARY-STORAGE1</code></pre>
</div>

	>>> AttachPrimaryStorageToCluster primaryStorageUuid=1b952f1e74a747dfb89ef3bdb9e8a821 clusterUuid=e630ebdb5f7742f3818fd998e91d35a8

<img class="img-responsive" src="/images/tutorials/t1/cliAttachPrimaryStorageToCluster.png">

<hr>

<h4 id="addBackupStorage">8. Add Backup Storage</h4>

add sftp Backup Storage 'BACKUP-STORAGE1' with backup storage host IP address('172.20.11.34'), root username('root'), password('password') and sftp folder path('/zstack_bs'):

	>>> AddSftpBackupStorage name=BACKUP-STORAGE1 hostname=172.20.11.34 username=root password=password url=/zstack_bs


<img class="img-responsive" src="/images/tutorials/t1/cliAddBackupStorage.png">

<hr>

attach new created Backup Storage('BACKUP-STORAGE1') to zone('ZONE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#8">Find UUID</button>

<div id="8" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AttachBackupStorageToZone backupStorageUuid=ccc8214bfc2344e5a58c2ec23de3b348 zoneUuid=b5ba18197f7843308cd26f87eab933c5

<img class="img-responsive" src="/images/tutorials/t1/cliAttachBackupStorageToZone.png">

<hr>

<h4 id="addImage">9. Add Image</h4>

add Image('image') with format 'qcow2', 'RootVolumeTemplate' type, 'Linux' platform and image URL('{{site.zstack_image}}') to backup storage ('BACKUP-STORAGE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#9_1">Find UUID</button>

<div id="9_1" class="collapse">
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AddImage name=image mediaType=RootVolumeTemplate platform=Linux url=http://192.168.200.100/mirror/diskimages/zstack-image-1.4.qcow2 backupStorageUuids=ccc8214bfc2344e5a58c2ec23de3b348 format=qcow2

<img class="img-responsive" src="/images/tutorials/t1/cliAddImage.png">

this image will be used as user VM image.

<hr>

<h4 id="createL2Network">10. Create L2 Network</h4>

create No Vlan L2 Network 'PUBLIC-MANAGEMENT-L2' with physical interface as 'eth0' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_1">Find UUID</button>

<div id="10_1" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2NoVlanNetwork name=PUBLIC-MANAGEMENT-L2 physicalInterface=eth0 zoneUuid=b5ba18197f7843308cd26f87eab933c5

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL2NoVlan.png">

<hr>

attach 'PUBLIC-MANAGEMENT-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_2">Find UUID</button>

<div id="10_2" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=PUBLIC-MANAGEMENT-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=b4b611280afe4d289c8e3f66aee0393d clusterUuid=e630ebdb5f7742f3818fd998e91d35a8

<img class="img-responsive" src="/images/tutorials/t1/cliAttachNoVlanL2toCluster.png">

<hr>

create new private Vlan L2 network 'PRIVATE-L2' with physical interface as 'eth0' and vlan '100' under 'ZONE1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_3">Find UUID</button>

<div id="10_3" class="collapse">
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateL2VlanNetwork name=PRIVATE-L2 physicalInterface=eth0 vlan=100 zoneUuid=b5ba18197f7843308cd26f87eab933c5

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL2Vlan.png">

<hr>

attach 'PRIVATE-L2' to 'CLUSTER1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#10_4">Find UUID</button>

<div id="10_4" class="collapse">
<pre><code>QueryCluster fields=uuid, name=CLUSTER1</code></pre>
<pre><code>QueryL2Network fields=uuid, name=PRIVATE-L2</code></pre>
</div>

	>>> AttachL2NetworkToCluster l2NetworkUuid=b052b4e080c840f6984c29581b167644 clusterUuid=e630ebdb5f7742f3818fd998e91d35a8

<img class="img-responsive" src="/images/tutorials/t1/cliAttachVlanL2toCluster.png">

<hr>

<h4 id="createL3Network">11. Create L3 Network</h4>

on L2 'PUBLIC-MANAGEMENT-L2', create a Public Management L3 'PUBLIC-MANAGEMENT-L3' with system set to 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_1">Find UUID</button>

<div id="11_1" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=PUBLIC-MANAGEMENT-L2</code></pre>
</div>

	>>> CreateL3Network name=PUBLIC-MANAGEMENT-L3 l2NetworkUuid=b4b611280afe4d289c8e3f66aee0393d system=true

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL3NoVlan.png">

<hr>

create IP Range for 'PUBLIC-MANAGEMENT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_2">Find UUID</button>

<div id="11_2" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PUBLIC-MANAGEMENT-L3</code></pre>
</div>

	>>> AddIpRange name=PUBLIC-IP-RANGE l3NetworkUuid=5bda71a3ebbd48a5947e325dd24665e5 startIp=10.121.9.40 endIp=10.121.9.100 netmask=255.0.0.0 gateway=10.0.0.1

<img class="img-responsive" src="/images/tutorials/t1/cliAddIpRange1.png">

<div class="bs-callout bs-callout-info">
  <h4>No network services needed for PUBLIC-MANAGEMENT-L3'</h4>
  No user VMs will be created on the public L3 network in this tutorial, so we don't specify any network services for it.
</div>

<hr>

<h4 id="createInstanceOffering">12. Create Router Image</h4>


add Image('VRImage') with format 'qcow2' and image URL('{{site.zstack_image}}') to backup storage ('BACKUP-STORAGE1'):

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#9_1">Find UUID</button>

<div id="9_1" class="collapse">
<pre><code>QueryBackupStorage fields=uuid, name=BACKUP-STORAGE1</code></pre>
</div>

	>>> AddImage name=VRImage url=http://192.168.200.100/mirror/diskimages/zstack-vrouter-latest.qcow2 backupStorageUuids=ccc8214bfc2344e5a58c2ec23de3b348 format=qcow2


<div class="bs-callout bs-callout-success">
  <h4>Fast link for users of Mainland China</h4>
  .................................
  
  <pre><code>{{site.vr_ch}}</code></pre>
</div>

<img class="img-responsive" src="/images/tutorials/t1/cliAddVRouterImage.png">

this image will be used as Virtual Router VM image.

<div class="bs-callout bs-callout-info">
  <h4>Cache images in your local HTTP server</h4>
  The virtual router image is about 432M that takes a little of time to download. We suggest you use a local HTTP server
  to storage it and images created by yourself.
</div>

<hr>

<h4 id="createVirtualRouterOffering">13. Create Virtual Router Offering</h4>

create a Virtual Router VM instance offering 'VR-OFFERING' with 1 CPU, 512MB memory, management L3 network 'PUBLIC-MANAGEMENT-L3', public L3 network 'PUBLIC-MANAGEMENT-L3' and isDefault 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13">Find UUID</button>

<div id="13" class="collapse">
<pre><code>QueryImage fields=uuid, name=VIRTUAL-ROUTER</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name?=PUBLIC-MANAGEMENT-L3,PRIVATE-L3</code></pre>
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateVirtualRouterOffering name=VR-OFFERING cpuNum=1 imageUuid=090906b0e7de4bf890c677b3bc8f680b managementNetworkUuid=5bda71a3ebbd48a5947e325dd24665e5 publicNetworkUuid=5bda71a3ebbd48a5947e325dd24665e5 zoneUuid=b5ba18197f7843308cd26f87eab933c5 memorySize=536870912


<img class="img-responsive" src="/images/tutorials/t1/cliCreateVirtualRouterOffering.png">

<hr>

<h4 id="createPN">14. Create Private Network </h4>

<hr>

on L2 network 'PRIVATE-L2', create a new guest VM L3 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_3">Find UUID</button>

<div id="11_3" class="collapse">
<pre><code>QueryL2Network fields=uuid, name=PRIVATE-L2</code></pre>
</div>

	>>> CreateL3Network name=PRIVATE-L3 l2NetworkUuid=b052b4e080c840f6984c29581b167644

<img class="img-responsive" src="/images/tutorials/t1/cliCreateL3Vlan.png">

<hr>

create an IP Range for 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_4">Find UUID</button>

<div id="11_4" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
</div>

	>>>AddIpRange name=PRIVATE-RANGE l3NetworkUuid=6a73fdfffb104c79919179af28cba3e3 startIp=192.168.2.2 endIp=192.168.2.254 netmask=255.255.255.0 gateway=192.168.2.1

<img class="img-responsive" src="/images/tutorials/t1/cliAddIpRange2.png">

<hr>

add DNS for 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_5">Find UUID</button>

<div id="11_5" class="collapse">
<pre><code>QueryL3Network fields=uuid name=PRIVATE-L3</code></pre>
</div>

	>>> AddDnsToL3Network l3NetworkUuid=6a73fdfffb104c79919179af28cba3e3 dns=8.8.8.8

<img class="img-responsive" src="/images/tutorials/t1/cliAddDns.png">

<hr>

we need to get available network service provider UUID, before add any virtual router service to L3 network:

	>>> QueryNetworkServiceProvider

<img class="img-responsive" src="/images/tutorials/t1/cliQueryNetworkServiceProvider.png">


<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_6">Find UUID</button>

<div id="11_6" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid, name=VirtualRouter</code></pre>
</div>

attach  SecurityGroup services to 'FLAT-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#11_6">Find UUID</button>

<div id="11_6" class="collapse">
<pre><code>QueryL3Network fields=uuid, name=FLAT-L3</code></pre>
<pre><code>QueryNetworkServiceProvider fields=uuid,name name?=VirtualRouter,SecurityGroup</code></pre>
</div>

<div class="bs-callout bs-callout-info">
  <h4>Structure of parameter networkServices</h4>
  It's a JSON object of map that key is UUID of network service provider and value is a list of network service types.
</div>

	>>> AttachNetworkServiceToL3Network networkServices="{'90df78d13d8d4f7a99b2b0465b3ea1ba':['SecurityGroup']}" l3NetworkUuid=6a73fdfffb104c79919179af28cba3e3

<img class="img-responsive" src="/images/tutorials/t4/cliAttachNetworkService.png">

<hr>

<h4 id="createSecurityGroup">12. Create Security Group</h4>

create Security Group 'SECURITY-GROUP-1':

	>>> CreateSecurityGroup name=SECURITY-GROUP-1

<img src="/images/tutorials/t4/cliCreateSG.png">

<hr>

create Security Group Rule for 'SECURITY-GROUP-1':

1. type: 'Ingress'
2. start port: as 23
3. end port: 25
4. protocol: 'TCP'
5. CIDR: 0.0.0.0/0

<hr>

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#12_1">Find UUID</button>

<div id="12_1" class="collapse">
<pre><code>QuerySecurityGroup fields=uuid, name=SECURITY-GROUP-1</code></pre>
</div>

	>>> AddSecurityGroupRule securityGroupUuid=72f3e24f0b7c4d588810c25075524954 rules="[{'type':'Ingress','protocol':'TCP','startPort':'25','endPort':'22'}]"

<img src="/images/tutorials/t4/cliCreateSGRule1.png">

<hr>

attach 'SECURITY-GROUP-1' to 'PRIVATE-L3':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#12_2">Find UUID</button>

<div id="12_2" class="collapse">
<pre><code>QuerySecurityGroup fields=uuid, name=SECURITY-GROUP-1</code></pre>
<pre><code>QueryL3Network fields=uuid, name=PRIVATE-L3</code></pre>
</div>

	>>> AttachSecurityGroupToL3Network securityGroupUuid=72f3e24f0b7c4d588810c25075524954 l3NetworkUuid=6a73fdfffb104c79919179af28cba3e3

<img src="/images/tutorials/t4/cliAttachSG.png">

<hr>

<h4 id="createInstanceOffering">13. Create Instance Offering</h4>

create a guest VM instance offering 'small-instance' with 1 512Mhz CPU and 128MB memory:

	>>> CreateInstanceOffering name=small-instance cpuNum=1 cpuSpeed=512 memorySize=134217728

<img class="img-responsive" src="/images/tutorials/t1/cliCreateInstanceOffering.png">

<hr>

<h4 id="createVirtualRouterOffering">14. Create Virtual Router Offering</h4>

create a Virtual Router VM instance offering 'VR-OFFERING' with 1 CPU, 512MB memory, management L3 network 'PUBLIC-MANAGEMENT-L3', public L3 network 'PUBLIC-MANAGEMENT-L3' and isDefault 'True':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#13">Find UUID</button>

<div id="13" class="collapse">
<pre><code>QueryImage fields=uuid, name=VIRTUAL-ROUTER</code></pre>
<pre><code>QueryL3Network fields=uuid,name, name?=PUBLIC-MANAGEMENT-L3,PRIVATE-L3</code></pre>
<pre><code>QueryZone fields=uuid, name=ZONE1</code></pre>
</div>

	>>> CreateVirtualRouterOffering name=VR-OFFERING cpuNum=1 imageUuid=090906b0e7de4bf890c677b3bc8f680b managementNetworkUuid=5bda71a3ebbd48a5947e325dd24665e5 publicNetworkUuid=5bda71a3ebbd48a5947e325dd24665e5 zoneUuid=b5ba18197f7843308cd26f87eab933c5 memorySize=536870912


<img class="img-responsive" src="/images/tutorials/t1/cliCreateVirtualRouterOffering.png">

<hr>

<h4 id="createInnerVM">15. Create INNER-VM</h4>

create a new guest VM instance with instance offering 'small-instance', image 'zs-sample-image', L3 network 'PRIVATE-L3', name 'INNER-VM' and hostname 'inner'

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#15">Find UUID</button>

<div id="15" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=image</code></pre>
<pre><code>QueryL3Network fields=uuid, name=FLAT-L3</code></pre>
</div>

	>>> CreateVmInstance name=INNER-VM instanceOfferingUuid=025d33f751e241a5b89862e3da2dac47 imageUuid=6874474809df4d2292d3503884e0096e l3NetworkUuids=6a73fdfffb104c79919179af28cba3e3

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<img class="img-responsive" src="/images/tutorials/t4/cliCreateVm1.png">

from VM creation result, you can get the new created VM IP address is 192.168.2.199

<hr>

<h4 id="joinInnerVM">16. Join INNER-VM Into Security Group</h4>

add 'INNER-VM' NIC to 'SECURITY-GROUP-1':

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#16">Find UUID</button>

<div id="16" class="collapse">
<pre><code>QuerySecurityGroup fields=uuid name=SECURITY-GROUP-1</code></pre>
<pre><code>QueryVmNic fields=uuid vmInstance.name=INNER-VM</code></pre>
</div>

	>>> AddVmNicToSecurityGroup vmNicUuids=715b1051e8dc4bc69302865179c31d4b securityGroupUuid=72f3e24f0b7c4d588810c25075524954

<img src="/images/tutorials/t4/cliAddNicToSG.png">

<hr>

<h4 id="createOuterVM">17. Create OUTER-VM</h4>

create a new guest VM instance with instance offering 'small-instance', image 'zs-sample-image', L3 network 'PRIVATE-L3', name 'OUTER-VM' and hostname 'outer'

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#17">Find UUID</button>

<div id="17" class="collapse">
<pre><code>QueryInstanceOffering fields=uuid, name=small-instance</code></pre>
<pre><code>QueryImage fields=uuid, name=zs-sample-image</code></pre>
<pre><code>QueryL3Network fields=uuid, name=FLAT-L3</code></pre>
</div>

	>>> CreateVmInstance name=OUTER-VM instanceOfferingUuid=025d33f751e241a5b89862e3da2dac47 imageUuid=6874474809df4d2292d3503884e0096e l3NetworkUuids=6a73fdfffb104c79919179af28cba3e3

<img class="img-responsive" src="/images/tutorials/t4/cliCreateVm2.png">

from VM creation result, you can get the new created VM IP address is 192.168.2.241

<hr>

<h4 id="sshLogin">18. SSH Login INNER-VM From OUTER-VM</h4>

use a machine that can reach subnet 192.168.2.0/24 to SSH the OUTER-VM's IP '192.168.2.241'

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_1">Find IP of OUTER-VM</button>

<div id="18_1" class="collapse">
<pre><code>QueryVmNic fields=ip vmInstance.name=OUTER-VM</code></pre>
</div>

	#ssh root@192.168.2.241

<img src="/images/tutorials/t4/cliSshVM1.png">

<hr>

in OUTER-VM, ssh INNER-VM's IP '192.168.2.199', it should failed:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#18_2">Find IP of INNER-VM</button>

<div id="18_2" class="collapse">
<pre><code>QueryVmNic fields=ip vmInstance.name=INNER-VM</code></pre>
</div>

	#ssh root@192.168.2.199

<img src="/images/tutorials/t4/cliSshVM2.png">


<hr>


<h4 id="deleteSecurityGroupRule">19. Delete Security Group Rule</h4>

delete 'SECURITY-GROUP-1' rule:

<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#19">Find UUID</button>

<div id="19" class="collapse">
<pre><code>QuerySecurityGroupRule fields=uuid startPort=22 endPort=22</code></pre>
</div>

	>>> DeleteSecurityGroupRule ruleUuids=5d1ebed51795467b894ca2f77f9293cd

<img src="/images/tutorials/t4/cliDeleteSGRule.png">

<hr>

<h4 id="sshLoginFailure">20. Confirm Unable to SSH Login INNER-VM From OUTER-VM</h4>

go back to OUTER-VM and ssh INNER-VM again, it should success.

<img src="/images/tutorials/t4/cliSshVM4.png">

### Summary

In this tutorial, we showed you the basics of using security group. Though we only show one security group with
one L3 network and one VM; you can actually create many security groups and attach them to different L3 networks;
you can also put many VMs in the same security group. For more details,
please visit [Security Group in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/securityGroup.html).

