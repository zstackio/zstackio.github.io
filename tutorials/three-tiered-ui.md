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
</div>

Based on those requirements, we assume below setup information:

+ ethernet device name: eth0
+ eth0 IP: 172.20.11.34 
+ free IP range: 10.121.10.20 ~ 10.121.10.200
+ primary storage folder: /zstack_ps
+ backup storage folder: /zstack_bs

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

click 'Hardware' in the left sidebar and then click 'Zone'to enter the zone page:

<img  class="img-responsive"  src="/images/tutorials/t1/createZone1.png">

<hr>

click button 'Create Zone' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createZone2.png">

<hr>

name your first zone as 'ZONE1' and click button 'OK':

<img  class="img-responsive"  src="/images/tutorials/t1/createZone3.png">

<hr>

<h4 id="createCluster">5. Create Cluster</h4>

click 'Cluster' in the left sidebar to enter the cluster page:

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster1.png">

<hr>

click button 'Create Cluster' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster2.png">

<hr>

name the cluster as 'CLUSTER1' then click button 'OK':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster3.png">

<hr>

<h4 id="addHost">6. Add Host</h4>

click 'Host' in the left sidebar to enter host page:

<img  class="img-responsive"  src="/images/tutorials/t1/addHost1.png">

<hr>

click 'Create Host' button to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addHost2.png">

<hr>

1. name the host as 'HOST1'
2. select cluster(CLUSTER1) you just created
3. input the host IP(172.20.11.45)
4. input the ssh port(22)
5. the most important thing: give **SSH credentials for user root**
6. click 'OK' button

<img  class="img-responsive"  src="/images/tutorials/t1/addHost3.png">

<div class="bs-callout bs-callout-warning">
  <h4>A little slow when first time adding a host</h4>
  It may take a few minutes to add a host because Ansible will install all dependent packages, for example, KVM, on the host.
</div>

<hr>

<h4 id="addPrimaryStorage">7. Add Primary Storage</h4>

click 'PrimaryStorage' in the left slider to enter primary storage page:

<img  class="img-responsive"  src="/images/tutorials/t1/addPS1.png">

<hr>

click button 'Add PrimaryStorage' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addPS2.png">

<hr>

1. name the primary storage as 'PS1'
3. select type 'LocalStorge'
4. input url(/zstack_ps)
5. select cluster 'CLUSTER1' 
6. click button 'OK'

<div class="bs-callout bs-callout-info">
  <h4>Format of URL</h4>
  The format of URL is exactly the same to the one used by Linux <i>mount</i> command.
</div>

<img  class="img-responsive"  src="/images/tutorials/t1/addPS3.png">

<hr>

<div class="bs-callout bs-callout-info">
  <h4>It's actually multiple API calls</h4>
  You will see two API finishing notification because it actually calls two APIs: addPrimaryStorage and attachPrimaryStorageToCluster.
</div>

<hr>

<h4 id="addBackupStorage">8. Add Backup Storage</h4>

click 'BackupStorage' in left sidebar to enter backup storage page:

<img  class="img-responsive"  src="/images/tutorials/t1/addBS1.png">

<hr>

click button 'Add BackupStorage' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addBS2.png">

<hr>

1. name the backup storage as 'BS1'
2. choose type 'Sftp'
3. input IP(172.20.11.45) in host IP
4. input URL '/zstack_bs' which is the folder that will store images

<img  class="img-responsive"  src="/images/tutorials/t1/addBS3.png">

<hr>


Input ssh port(22), input SSH credentials for user root, and click button 'OK':

<img  class="img-responsive"  src="/images/tutorials/t1/addBS4.png">

<hr>

<h4 id="addImage">9. Add Image</h4>

click 'Resource Pool' in left sidebar and click 'Image' to enter image page:

<img  class="img-responsive"  src="/images/tutorials/t1/addImage1.png">

<hr>

click button 'Add Image' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/addImage2.png">

<hr>

1. name the image as 'Image1'
2. select media type 'Image'
3. select platform 'Linux'
4. input URL {{site.zstack_image}}
5. select BackupStorage 'BS1'
7. click button 'OK'

this image will be used as user VM image.

<img  class="img-responsive"  src="/images/tutorials/t1/addImage3.png">

<hr>

<h4 id="createPublicL2Network">10. Create  Public L2 Network</h4>

click 'Network' in left sidebar and click 'L2Network' to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

click button 'Create L2Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. name the L2 network as 'PUBLIC-MANAGEMENT-L2'
2. choose type 'L2NoVlanNetwork'
3. input physical interface as 'eth0'
4. select cluster 'CLUSTER1'
5. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t3/createL2Network3.png">

<hr>


<h4 id="createPublicL3Network">11. Create Public L3 Network</h4>


click 'L3 Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

click 'Public Network' in sidebar to enter L3 public network page:

<img class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network1.png">

click button 'Create Public Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network2.png">

<hr>

Name the L3 network as 'PUBLIC-MANAGEMENT-L3' and select L2Network 'PUBLIC-MANAGEMENT-L2'

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network2.png">

<hr>

1. choose method 'IP Range'
2. input start IP as '10.121.10.20'
3. input end IP as '10.121.10.200'
4. input netmask as '255.0.0.0'
5. input gateway as '10.0.0.1'
6. click the button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t3/createL3Network4.png">

<hr>

<h4 id="createInstanceOffering">12. Create Virtual Router Image</h4>

click 'Virtual Router' in left sidebar and click 'Virtual Router Image' to enter virtual router image page:

<img  class="img-responsive"  src="/images/tutorials/t1/createrouterimage1.png">

<hr>
click button 'Add Virtual Router Image' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createrouterimage2.png">

<hr>

1. name the virtual router image as 'Virtualrouterimage1'
2. input URL where  latest cloud route mirroring is
3. seclect  BackupStorage 'BS1'
4. click button 'OK'

<div class="bs-callout bs-callout-success">
  <h4>Fast link for users of Mainland China</h4>
  .................................
  
  <pre><code>{{site.vr_ch}}</code></pre>
</div>

<img  class="img-responsive"  src="/images/tutorials/t1/createrouterimage3.png">

<hr>

<div class="bs-callout bs-callout-info">
  <h4>Cache images in your local HTTP server</h4>
  The virtual router image is about 432M that takes a little of time to download. We suggest you use a local HTTP server
  to storage it and images created by yourself.
</div>

<hr>

<h4 id="createVirtualRouterOffering">13. Create Virtual Router Offering</h4>

click 'Virtual Router Offering' in the left sidebar to enter virtual router offering page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering1.png">

<hr>

click 'Create Virtual Router Offering' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering2.png">

<hr>

1. name the virtual router offering as 'VR-offering1'
2. input CPU NUM as '2'
3. input CPU speed as '2'
4. choose image 'Virtualrouterimage1'

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering3.png">

<hr>

Choose management L3 network 'PUBLIC-MANAGEMENT-L3' ,  choose public L3 network 'PUBLIC-MANAGEMENT-L3' and click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t3/createVirtualRouterOffering4.png">

<hr>



<h4 id="createApplicationL2Network">14. Create  Application L2 Network</h4>

click button 'New L2 Network' again to create the application L2 network:

1. name the L2 network as 'APPLICATION-L2'
2. choose type 'L2VlanNetwork'
3. input vlan as '2017'
4. input physical interface as 'eth0'


<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL2Network3.png">

choose cluster 'CLUSTER1' and click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL2Network4.png">

<hr>

<h4 id="createApplicationL3Network">15. Create Application L3 Network</h4>


click 'Network' in the left sidebar, click 'L3Network' and click 'Private Network' to enter L3Network  private network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createPN1.png">

<hr>

click 'Create Private Network' button again to create the private L3 network:

1.  name the L3 network as  'APPLICATION-L3'
2.  choose L2Network 'APPLICATION-L2'
3.  choose type 'V Router'

<img  class="img-responsive"  src="/images/tutorials/t3/createPublicL3Network2.png">

<hr>

1. choose Virtual Router Offering  'VR-offering1'
2. choose method 'CIDR'
3. input network CIDR as '192.0.0.0/24'
4. input DNS as '8.8.8.8'
5. click button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationL3Network3.png">

<hr>

<h4 id="createDatabaseL2Network">16. Create Database L2 Network</h4>

click button 'New L2 Network' again to create the database L2 network:

1. name the L2 network as 'DATABASE-L2'
2. choose type 'L2VlanNetwork'
3. input vlan as '2018'
4. input physical interface as 'eth0'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'OK':

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL2Network4.png">

<hr>

<h4 id="createDatabaseL3Network">17. Create Database L3 Network</h4>

click 'Network' in the left sidebar, click 'L3Network' and click 'Private Network' to enter L3Network  private network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createPN1.png">

<hr>

click 'Create Private Network' button again to create the private L3 network:

1.  name the L3 network as  'DATABASE-L3'
2.  choose L2Network 'DATABASE-L2'
3.  choose type 'V Router'

<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network1.png">

<hr>

1. choose Virtual Router Offering  'VR-offering1'
2. choose method 'CIDR'
3. input network CIDR as '172.16.1.0/24'
4. input DNS as '8.8.8.8'
5. click button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t3/createDatabaseL3Network2.png">


<h4 id="createInstanceOffering">18. Create Instance Offering</h4>

click 'Resource Pool' in the left sidebar and click 'InstanceOffering' to enter instance offering page:

<img  class="img-responsive"  src="/images/tutorials/t1/createIO1.png">

<hr>

click button 'Create InstanceOffering' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createIO2.png">

<hr>

1. input name as 'IO1'
2. input CPU as '1'
3. input Memory as '1'
6. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createIO3.png">

<hr>

<h4 id="createWebVM">18. Create WEB VM</h4>

click 'Resource Pool' in the left sidebar and click 'VmInstance' to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'Create VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose Type  'Single'
2. input name as 'WEB-VM'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5. choose L3 network 'WEB-L3' and set it as default web
7. choose L3 network 'APPLICATION-L3' 
8. click button 'OK'



<img  class="img-responsive"  src="/images/tutorials/t3/createWebVM3.png">

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="createApplicationVM">19. Create Application VM</h4>

click button 'Create VmInstance' to open the dialog:

<hr>

1. choose Type  'Single'
2. input name as 'APPLICATION-VM'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5. choose L3 network 'WEB-L3'
7. choose L3 network 'APPLICATION-L3' and set it as default web
8. click button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t3/createApplicationVM1.png">


<div class="bs-callout bs-callout-warning">
  <h4>Again, slow because of creating the virtual router VM</h4>
  Because it's the first VM on DATABASE-L3 network, ZStack will start the virtual router VM before creating APPLICATION-VM,
  it will takes about 1 minute to finish. Future VMs creation on the DATABASE-L3 will be extremely fast. 
</div>

<hr>

<h4 id="createDatabaseVM">20. Create Database VM</h4>

click button 'Create VmInstance' to open the dialog again:

1. choose Type  'Single'
2. input name as 'DATABASE-VM'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5. choose L3 network 'Database-L3'
6. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t3/creationDatabasevm.png">

<hr>


<h4 id="testVM">21. Confirm Network Connectivity</h4>

select WEB-VM, click button 'VmInstance Actions' then click item 'Console' to open VM's console:

<img  class="img-responsive"  src="/images/tutorials/t3/webVMConsole1.png">

<hr>

in the popup window, login the VM by *username: root, password: password*.

1. ping google.com, it should succeed.
2. ping DATABASE-VM, it should succeed.
3. ping APPLICATION-VM, it should failed.

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
2. ping WEB-VM, it should succeed.
3. ping APPLICATION-VM, it should fail.

<img  class="img-responsive"  src="/images/tutorials/t3/databaseVMConsole1.png">

### Summary

In this example, we showed you how to create a three tiered network in ZStack. For the sake of demonstration, we don't
apply any firewall. You can use security group combining with this example to create a more secure deployment. For
more details, please visit [L3 Network in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/l3Network.html).
