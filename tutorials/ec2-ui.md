---
title: ZStack EC2 Tutorials
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
  - id: createInstanceOffering
    title: Create Instance Offering
  - id: createVirtualRouterOffering
    title: Create Virtual Router Offering
  - id: createVM
    title: Create Virtual Machine
  - id: createEIP
    title: Create EIP
  - id: rebindEIP
    title: Rebind The EIP To Another VM 
---

### Amazon EC2 classic EIP zone

<h4 id="overview">1. Overview</h4>
<img  class="img-responsive"  src="/images/eip.png">

Amazon EC2 is the well-known and maybe the most popular public cloud in the world; in EC2 classic, users can create a VM instance
with a private IP address, and acquire an elastic IP(EIP) that is usually a public IP and can be dynamically bound to the VM.
If there are more than one VMs, users can unbind and bind the EIP to VMs on demand.

In this example, we will create a deployment that has a public network a private network, and that allows users to bind an EIP created
from the public network to VM nics that are on the private network.

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

<h4 id="createL2Network">10. Create L2 Network</h4>

click 'L2 Network' in left sidebar to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

click button 'New L2 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. select zone(ZONE1)
2. name the L2 network as 'PUBLIC-MANAGEMENT-L2'
3. choose type 'L2NoVlanNetwork'
4. input physical interface as 'eth0'
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network4.png">

<hr>

click 'New L2 Network' again to create the private L2 network:

1. select zone(ZONE1)
2. name the L2 network as 'PRIVATE-L2'
3. **choose type 'L2VlanNetwork'**
4. **input vlan as '100'**
5. input physical interface as 'eth0'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network5.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network6.png">

<hr>

<h4 id="createL3Network">11. Create L3 Network</h4>

click 'L3 Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

click button 'New L3 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network2.png">

<hr>

1. select zone(ZONE1)
2. select L2 network(PUBLIC-MANAGEMENT-L2)
3. name the L3 network as 'PUBLIC-MANAGEMENT-L3'
4. choose type 'L3BasicNetwork'
5. check 'system network' checkbox
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network3.png">

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

click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network5.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network6.png">

<div class="bs-callout bs-callout-info">
  <h4>No network services needed for PUBLIC-MANAGEMENT-L3'</h4>
  No user VMs will be created on the public L3 network in this tutorial, so we don't specify any network services for it.
</div>

<hr>

click 'New L3 Network' button again to create the private L3 network:

1. select zone(ZONE1)
2. select L2 network(PRIVATE-L2)
3. name the L3 network as 'PRIVATE-L3'
4. choose type 'L3BasicNetwork'
5. input domain as 'tutorials.zstack.org'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network7.png">

<hr>

1. name the IP range as 'PRIVATE-IP-RANGE'
2. choose method 'Add BY CIDR'
3. input network CIDR '10.0.0.0/24'
4. click button 'Add' to add the IP range
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network8.png">

<hr>

input DNS as '8.8.8.8' then click button 'Add' to add the DNS, then click button 'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network9.png">

<hr>

1. choose provider 'VirtualRouter'
2. choose service 'DHCP'
3. click button 'Add' to add the network service

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network10.png">

<hr>

repeat the above three steps to add network services: DNS, SNAT, EIP, then click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network11.png">

<hr>

<h4 id="createInstanceOffering">12. Create Instance Offering</h4>

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

<h4 id="createVirtualRouterOffering">13. Create Virtual Router Offering</h4>

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

<h4 id="createVM">14. Create Virtual Machine</h4>

click 'Instance' in the left sidebar to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'New VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'PRIVATE-L3' and **click 'Add'**
4. input name as 'VM1'
5. input host name as 'vm1'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createVM3.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createVM4.png">

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

once the VM is created successfully, click button 'Action' then click item 'Console' to open VM's console:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM5.png">

<hr>

in the popup window, login the VM by *username: root, password: password* and ping google.com, it should ping successfully:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM6.png">

<hr>

and by the 'ifconfig' command, you should see the private IP address:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM7.png">

<hr>

<h4 id="createEIP">15. Create EIP</h4>

click 'EIP' in the left sidebar to enter the EIP page:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP1.png">

<hr>

click button 'New EIP' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP2.png">

<hr>

1. choose VIP method 'Create New VIP'
2. choose L3 Network 'PUBLIC-MANAGEMENT-L3'
3. click button 'Create VIP' to create the VIP
4. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP3.png">

<hr>

1. select VM instance 'VM1'
2. name the EIP as 'EIP1'
3. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP4.png">

<hr>

once it finishes, you should be able to see the result in EIP page; in our case, the EIP is '192.168.0.240':

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP5.png">

<hr>

use on machine that can reach subnet 192.168.0.0/24 to SSH the IP '192.168.0.240', you should be able to login the VM:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP6.png">

<hr>

<h4 id="rebindEIP">16. Rebind The EIP To Another VM</h4>

follow instructions in section <a href="#createVM">11. Create Virtual Machine</a> to create another VM(VM2) on the private
L3 network:

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP1.png">

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP2.png">

<div class="bs-callout bs-callout-info">
  <h4>Subsequent VMs are created extremely fast</h4>
  As the image has been downloaded to the image cache of the primary storage and the virtual router VM has been created,
  new VMs will be created extremely fast, usually less than 3 seconds. 
</div>

<hr>

go to EIP page, select the EIP1 and click button 'Action'; then in the dropdown box, click item 'Detach' and confirm:

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP3.png">

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP4.png">

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP5.png">

<hr>

after detaching, click button 'Action' again and select item 'Attach', in the dialog, choose VM2 this time and click button 'Attach':

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP6.png">

SSH login to the EIP '192.168.0.240' again and run command 'hostname', you should see the hostname 'vm2', which proves the EIP has been
successfully rebound to VM2.


