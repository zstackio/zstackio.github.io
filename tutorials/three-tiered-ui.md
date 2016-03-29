---
title: ZStack Three Ties Network Tutorials
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

We assume you have followed [installation guide](../installation/index.html) to install ZStack on a single Linux machine, and
the ZStack management node is up and running. To access the web UI, type below URL in your browser (Please use latest Chrome or Firefox browser.):

    http://your_machine_ip:5000/
    
To make things simple, we assume you have only one Linux machine with one network card that can access the internet; besides, there are
some other requirements:

+ At least 20G free disk that can be used as primary storage and backup storage
+ Several free IPs that can access the internet
+ NFS server is enabled on the machine (see end of this section for automatically setup NFS)
+ SSH credentials for user root

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

+ ethernet device name: eth0
+ eth0 IP: 192.168.0.212 
+ free IP range: 192.168.0.230 ~ 192.168.0.240
+ primary storage folder: /usr/local/zstack/nfs_root
+ backup storage folder: /backupStorage

<div class="bs-callout bs-callout-warning">
  <h4>Slow VM stopping due to lack of ACPID:</h4>
    Though we don't show the example of stopping VM, you may find stopping a VM takes more than 60s. That's 
    because the VM image doesn't support ACPID that receives KVM's shutdown event, ZStack has to
    wait for 60 seconds timeout then destroy it. It's not a problem for regular Linux distributions which have ACPID installed.
</div>

<hr>

<h4 id="login">3. LogIn</h4>

open browser with URL(http://your_machine_ip:5000/) and login with admin/password:

<img  class="img-responsive"  src="/images/tutorials/t1/login.png">

<hr>

<h4 id="createZone">4. Create Zone</h4>

click 'Zone' in the left sidebar to enter the zone page:

<img  class="img-responsive"  src="/images/tutorials/t1/createZone1.png">

<hr>

click button 'New Zone' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createZone2.png">

<hr>

name your first zone as 'ZONE1' and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createZone3.png">

<hr>

<h4 id="createCluster">5. Create Cluster</h4>

click 'Cluster' in the left sidebar to enter the cluster page:

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster1.png">

<hr>

click button 'New Cluster' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster2.png">

<hr>

select the zone(ZONE1) you just created; name the cluster as 'CLUSTER1'; select hypervisor 'KVM' then click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster3.png">

<hr>

for now you don't have any primary storage to attach, click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster4.png">

<hr>

you don't have L2 network to attach either, click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster5.png">

<hr>

<h4 id="addHost">6. Add Host</h4>

click 'Host' in the left sidebar to enter host page:

<img  class="img-responsive"  src="/images/tutorials/t1/addHost1.png">

<hr>

click 'New Host' button to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addHost2.png">

<hr>

1. select zone(ZONE1) and cluster(CLUSTER1) you just created
2. name the host as 'HOST1'
3. input the host IP(192.168.0.212)
4. the most important thing: give **SSH credentials for user root**
5. click 'add' button

<img  class="img-responsive"  src="/images/tutorials/t1/addHost3.png">

<div class="bs-callout bs-callout-warning">
  <h4>A little slow when first time adding a host</h4>
  It may take a few minutes to add a host because Ansible will install all dependent packages, for example, KVM, on the host.
</div>

<hr>

<h4 id="addPrimaryStorage">7. Add Primary Storage</h4>

click 'Primary Storage' in the left slider to enter primary storage page:

<img  class="img-responsive"  src="/images/tutorials/t1/addPS1.png">

<hr>

click button 'New Primary Storage' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addPS2.png">

<hr>

1. select zone(ZONE1)
2. name the primary storage as 'PRIMARY-STORAGE1'
3. select type 'NFS'
4. input NFS url(192.168.0.212:/usr/local/zstack/nfs_root)
5. click button 'Next'

<div class="bs-callout bs-callout-info">
  <h4>Format of NFS URL</h4>
  The format of URL is exactly the same to the one used by Linux <i>mount</i> command.
</div>

<img  class="img-responsive"  src="/images/tutorials/t1/addPS3.png">

<hr>

select cluster(CLUSTER1) to attach, then click button 'Add':

<img  class="img-responsive"  src="/images/tutorials/t1/addPS4.png">

<div class="bs-callout bs-callout-info">
  <h4>It's actually multiple API calls</h4>
  You will see two API finishing notification because it actually calls two APIs: addPrimaryStorage and attachPrimaryStorageToCluster.
</div>

<hr>

<h4 id="addBackupStorage">8. Add Backup Storage</h4>

click 'Backup Storage' in left sidebar to enter backup storage page:

<img  class="img-responsive"  src="/images/tutorials/t1/addBS1.png">

<hr>

click button 'New Backup Storage' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addBS2.png">

<hr>

1. name the backup storage as 'BACKUP-STORAGE1'
2. choose type 'SftpBackupStorage'
3. input URL '/backupStorage' which is the folder that will store images
4. input IP(192.168.0.212) in hostname
5. input SSH credentials for user root
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/addBS3.png">

<hr>

select zone(ZONE1) to attach, and click button 'Add':

<img  class="img-responsive"  src="/images/tutorials/t1/addBS4.png">

<hr>

<h4 id="addImage">9. Add Image</h4>

click 'Image' in left sidebar to enter image page:

<img  class="img-responsive"  src="/images/tutorials/t1/addImage1.png">

<hr>

click button 'New Image' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addImage2.png">

<hr>

1. select backup storage(BACKUP-STORAGE1)
2. name the image as 'zs-sample-image'
3. choose format 'qcow2'
4. choose media type 'RootVolumeTemplate'
5. choose platform 'Linux'
6. input URL {{site.zstack_image}}
7. click button 'Add'

this image will be used as user VM image.

<img  class="img-responsive"  src="/images/tutorials/t1/addImage3.png">

<hr>

click 'New Image' button again to add the virtual router image:

1. select backup storage(BACKUP-STORAGE1)
2. name the image as 'VIRTUAL-ROUTER'
3. choose format 'qcow2'
4. choose media type 'RootVolumeTemplate'
5. choose platform 'Linux'
6. input URL {{site.vr_en}}
7. **check 'System' checkbox**
8. click button 'Add'

<div class="bs-callout bs-callout-success">
  <h4>Fast link for users of Mainland China</h4>
  由于国内访问我们位于美国的服务器速度较慢，国内用户请使用以下链接：
  
  <pre><code>{{site.vr_ch}}</code></pre>
</div>

<img  class="img-responsive"  src="/images/tutorials/t1/addImage4.png">

<div class="bs-callout bs-callout-info">
  <h4>Cache images in your local HTTP server</h4>
  The virtual router image is about 432M that takes a little of time to download. We suggest you use a local HTTP server
  to storage it and images created by yourself.
</div>

<hr>

<h4 id="createPublicL2Network">10. Create Public L2 Network</h4>

click 'L2 Network' in left sidebar to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL2Network1.png">

<hr>

click button 'New L2 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL2Network2.png">

<hr>

1. select zone(ZONE1)
2. name the L2 network as 'PUBLIC-MANAGEMENT-L2'
3. choose type 'L2NoVlanNetwork'
4. input physical interface as 'eth0'
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL2Network4.png">

<hr>

<h4 id="createPublicL3Network">11. Create Public L3 Network</h4>

click 'L3 Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network1.png">

<hr>

click button 'New L3 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network2.png">

<hr>

1. select zone(ZONE1)
2. select L2 network(PUBLIC-MANAGEMENT-L2)
3. name the L3 network as 'PUBLIC-MANAGEMENT-L3'
4. choose type 'L3BasicNetwork'
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network3.png">

<hr>

1. name the IP range as 'PUBLIC-IP-RANGE'
2. choose method 'Add By Range'
3. input start IP as '192.168.0.230'
4. input end IP as '192.168.0.240'
5. input netmask as '255.255.255.0'
6. input gateway as '192.168.0.1'
7. click button 'Add' to add the IP range
8. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network4.png">

<hr>

input DNS as '8.8.8.8' then click button 'Add' to add the DNS, then click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network3.png">
<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network4.png">

<hr>

1. choose provider 'VirtualRouter'
2. choose service 'DHCP'
3. click button 'Add' to add the network service

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network6.png">

<hr>

repeat the above three steps to add 'DNS' service, then click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network7.png">

<hr>

<h4 id="createApplicationL2Network">12. Create Application L2 Network</h4>

click button 'New L2 Network' again to create the application L2 network:

1. select zone(ZONE1)
2. name the L2 network as 'APPLICATION-L2'
3. choose type 'L2VlanNetwork'
4. input vlan as '100'
5. input physical interface as 'eth0'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL2Network4.png">

<hr>

<h4 id="createApplicationL3Network">13. Create Application L3 Network</h4>

click 'New L3 Network' button again to create the application L3 network:

1. select zone(ZONE1)
2. select L2 network(APPLICATION-L2)
3. name the L3 network as 'APPLICATION-L3'
4. choose type 'L3BasicNetwork'
5. input domain as 'application.zstack.org'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network1.png">

<hr>

1. name the IP range as 'APPLICATION-IP-RANGE'
2. choose method 'Add BY CIDR'
3. input network CIDR '10.0.0.0/24'
4. click button 'Add' to add the IP range
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network2.png">
<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network3.png">

<hr>

input DNS as '8.8.8.8' then click button 'Add' to add the DNS, then click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network4.png">
<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network5.png">

<hr>

1. choose provider 'VirtualRouter'
2. choose service 'DHCP'
3. click button 'Add' to add the network service

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network6.png">

<hr>

repeat the above three steps to add network services: DNS, SNAT, then click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network7.png">

<hr>

<h4 id="createDatabaseL2Network">14. Create Database L2 Network</h4>

click button 'New L2 Network' again to create database L2 network:

1. select zone(ZONE1)
2. name the L2 network as 'DATABASE-L2'
3. choose type 'L2VlanNetwork'
4. input vlan as '101'
5. input physical interface as 'eth0'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL2Network4.png">

<hr>

<h4 id="createDatabaseL3Network">15. Create Database L3 Network</h4>

click 'New L3 Network' button again to create the database L3 network:

1. select zone(ZONE1)
2. select L2 network(DATABASE-L2)
3. name the L3 network as 'DATABASE-L3'
4. choose type 'L3BasicNetwork'
5. input domain as 'database.zstack.org'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network1.png">

<hr>

1. name the IP range as 'DATABASE-IP-RANGE'
2. choose method 'Add BY CIDR'
3. input network CIDR '172.16.1.0/24'
4. click button 'Add' to add the IP range
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network2.png">
<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network3.png">

<hr>

input DNS as '8.8.8.8' then click button 'Add' to add the DNS, then click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network4.png">
<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network5.png">

<hr>

1. choose provider 'VirtualRouter'
2. choose service 'DHCP'
3. click button 'Add' to add the network service

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network6.png">

<hr>

repeat the above three steps to add network services: DNS, SNAT, then click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network7.png">

<hr>

<h4 id="createInstanceOffering">16. Create Instance Offering</h4>

click 'Instance Offering' in left sidebar to enter instance offering page:

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering1.png">

<hr>

click button 'New Instance Offering' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering2.png">

<hr>

1. name the instance offering as '512M-512HZ'
2. input CPU NUM as 1
3. input CPU speed as 512
4. input memory as 512M
5. click button 'create'

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering3.png">

<hr>

<h4 id="createVirtualRouterOffering">17. Create Virtual Router Offering</h4>

click 'Virtual Router Offering' in the left sidebar to enter virtual router offering page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering1.png">

<hr>

click 'New Virtual Router Offering' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering2.png">

<hr>

1. select zone(ZONE1)
2. name the virtual router offering as 'VR-OFFERING'
3. input CPU NUM as '1'
4. input CPU speed as '512'
5. input memory as '512M'
6. choose image 'VIRTUAL-ROUTER"
7. choose management L3 network 'PUBLIC-MANAGEMENT-L3'
8. choose public L3 network 'PUBLIC-MANAGEMENT-L3'
9. check 'DEFAULT OFFERING' checkbox
10. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering3.png">

<hr>

<h4 id="createWebVM">18. Create WEB VM</h4>

click 'Instance' in the left sidebar to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t3/createWebVM1.png">

<hr>

click button 'New VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t3/createWebVM2.png">

<hr>

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'PUBLIC-MANAGEMENT-L3'
4. choose L3 network 'APPLICATION-L3'
5. select default L3 network as 'PUBLIC-MANAGEMENT-L3'
6. input name as 'WEB-VM'
7. input host name as 'web'
8. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createWebVM3.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createWebVM4.png">

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="createApplicationVM">19. Create Application VM</h4>

click button 'New VmInstance' to open the dialog again:

<hr>

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'APPLICATION-L3'
4. choose L3 network 'DATABASE-L3'
5. select default L3 network as 'APPLICATION-L3'
6. input name as 'APPLICATION-VM'
7. input host name as 'application'
8. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationVM1.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationVM2.png">

<div class="bs-callout bs-callout-warning">
  <h4>Again, slow because of creating the virtual router VM</h4>
  Because it's the first VM on DATABASE-L3 network, ZStack will start the virtual router VM before creating APPLICATION-VM,
  it will takes about 1 minute to finish. Future VMs creation on the DATABASE-L3 will be extremely fast. 
</div>

<hr>

<h4 id="createDatabaseVM">20. Create Database VM</h4>

click button 'New VmInstance' to open the dialog again:

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'DATABASE-L3'
4. input name as 'DATABASE-VM'
5. input host name as 'database'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseVM1.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationVM2.png">

<hr>

<h4 id="testVM">21. Confirm Network Connectivity</h4>

select WEB-VM, click button 'Action' then click item 'Console' to open VM's console:

<img  class="img-responsive"  src="/images/tutorials/t3/webVMConsole1.png">

<hr>

in the popup window, login the VM by *username: root, password: password*.

1. ping google.com, it should succeed.
2. ping APPLICATION-VM, it should succeed.
3. ping DATABASE-VM, it should fail.

<img  class="img-responsive"  src="/images/tutorials/t3/webVMConsole2.png">

<hr>

select APPLICATION-VM, click button 'Action' then click item 'Console' to open VM's console:

in the popup window, login the VM by *username: root, password: password*.

1. ping google.com, it should succeed.
2. ping DATABASE-VM, it should succeed.
3. ping WEB-VM, it should succeed.

<img  class="img-responsive"  src="/images/tutorials/t3/applicationVMConsole1.png">

<hr>

select DATABASE-VM, click button 'Action' then click item 'Console' to open VM's console:

in the popup window, login the VM by *username: root, password: password*.

1. ping google.com, it should succeed.
2. ping APPLICATION-VM, it should succeed.
3. ping WEB-VM, it should fail.

<img  class="img-responsive"  src="/images/tutorials/t3/databaseVMConsole1.png">

### Summary

In this example, we showed you how to create a three tiered network in ZStack. For the sake of demonstration, we don't
apply any firewall. You can use security group combining with this example to create a more secure deployment. For
more details, please visit [L3 Network in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/l3Network.html).
