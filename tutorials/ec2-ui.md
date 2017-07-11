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
  - id: createL3publicNetwork
    title: Create L3 Public Network
  - id: createInstanceOffering
    title: Create Router Image
  - id: createVirtualRouterOffering
    title: Create Virtual Router Offering
  - id: createPN
    title: Create Private Network 
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
click 'Create Image' button again to add the virtual router image:

1. name the image as 'VRouter'
2. choose media type 'ISO'
3. choose platform 'Linux'
4.  input URL {{site.vr_en}}
5.  choose BackupStorage 'BS1'
8. click button 'OK'

<div class="bs-callout bs-callout-success">
  <h4>Fast link for users of Mainland China</h4>
  .................................
  
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

click 'Network' in left sidebar and click 'L2Network' to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

click button 'Create L2Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. name the L2 network as 'L2Network-public'
2. choose type 'L2NoVlanNetwork'
3. input physical interface as 'eth0'
4. select cluster 'CLUSTER1'
5. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network3.png">

<hr>

click 'Create L2Network' again to create the private L2 network:

1. name the L2 network as 'L2Network-private'
2. **choose type 'L2VlanNetwork'**
3. **input vlan as '100'**
4. input physical interface as 'eth0'
5. select cluster(CLUSTER1) to attach 
6. click button 'OK':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network5.png">

<hr>

<h4 id="createL3Network">11. Create L3 Network</h4>

click 'L3Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

click 'Public Network' in sidebar to enter L3 public network page:

<img class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network1.png">

click button 'Create Public Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network2.png">

<hr>

Name the L3 network as 'L3Neywork-public' and select L2Network 'L2Network-private'

<img  class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network3.png">

<hr>

1. choose method 'IP Range'
2. input start IP as '10.121.9.20'
3. input end IP as '10.121.9.200'
4. input netmask as '255.0.0.0'
5. input gateway as '10.0.0.1'

<img  class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network4.png">

<hr>
Input DNS as '8.8.8.8' and click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createpublicL3Network5.png">

<hr>

<div class="bs-callout bs-callout-info">
  <h4>No network services needed for PUBLIC-MANAGEMENT-L3'</h4>
  No user VMs will be created on the public L3 network in this tutorial, so we don't specify any network services for it.
</div>

<hr>
<h4 id="createInstanceOffering">12. Create Router Image</h4>

click 'Virtual Router' in left sidebar and click 'Virtual Router Image' to enter virtual router image page:

<img  class="img-responsive"  src="/images/tutorials/t1/ createrouterimage1.png">

<hr>

click button 'Add Virtual Router Image' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createrouterimage2.png">

<hr>

1. name the virtual router image as 'Virtualrouterimage1'
2. input URL where  latest cloud route mirroring is
3. seclect  BackupStorage 'BS1'
4. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createrouterimage3.png">

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

Choose management L3 network 'L3Network-public' ,  choose public L3 network 'L3Network-public' and click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering4.png">

<hr>

<h4 id="createPN">14. Create Private Network </h4>

<hr>

click 'Network' in the left sidebar, click 'L3Network' and click 'Private Network' to enter L3Network  private network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createPN1.png">

<hr>

click 'Create Private Network' button again to create the private L3 network:

1.  name the L3 network as 'L3Network-private'
2.  choose L2Network 'L2Network-private'
3.  choose type 'V Router'

<img  class="img-responsive"  src="/images/tutorials/t1/createPN2.png">

<hr>

1. choose Virtual Router Offering  'VR-offering1'
2. choose method 'CIDR'
3. input network CIDR as '192.168.1.0/24'
4. input DNS as '8.8.8.8'
5. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createPN3.png">

<hr>

<h4 id="createIO">15. Create Instance Offering</h4>

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


<h4 id="createVM">16. Create Virtual Machine</h4>

click 'Resource Pool' in the left sidebar and click 'VmInstance' to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'Create VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose Type  'Single'
2. input name as 'VM1'
3. choose instance offering 'IO1'
4.  choose  network 'L3Network-private'
6. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createVM3.png">

<hr>

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

once the VM is created successfully, click button 'VM1' and then click button 'VMInstance Actions',finnally click item 'Console' to open VM's console:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM5.png">

<hr>

in the popup window, login the VM by *username: root* and ping google.com, it should ping successfully:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM6.png">

<hr>

and by the 'ifconfig' command, you should see the private IP address:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM7.png">

<hr>

<h4 id="createEIP">17. Create EIP</h4>

click 'Network' in the left sidebar, click 'Network Service' and then click 'EIP' to enter the EIP page:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP1.png">

<hr>

click button 'Create EIP' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP2.png">

<hr>

1. name EIP as 'EIP1'
2. choose VIP method 'Create New VIP'
3. choose Network 'L3Network-public'
4. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP3.png">

<hr>

1. choose VMInstance 'VM1'
2. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP4.png">

<hr>

once it finishes, you should be able to see the result in EIP page; in our case, the EIP is '10.121.9.98':

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP5.png">

<hr>

use on machine that can reach subnet 192.168.1.0/24 to SSH the IP '10.121.9.98', you should be able to login the VM:

<img  class="img-responsive"  src="/images/tutorials/t1/createEIP6.png">

<hr>

<h4 id="rebindEIP">18. Rebind The EIP To Another VM</h4>

follow instructions in section <a href="#createVM">11. Create Virtual Machine</a> to create another VM(VM2) on the private
L3 network:

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP1.png">

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

<img  class="img-responsive"  src="/images/tutorials/t1/rebindEIP7.png">

SSH login to the EIP '10.121.9.98' again and run command 'hostname', you should see the hostname 'vm2', which proves the EIP has been
successfully rebound to VM2.


  [1]: ./images/1499498065018.jpg

