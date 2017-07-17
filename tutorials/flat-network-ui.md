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
  - id: createVM
    title: Create Virtual Machine
---

### Flat Network

<h4 id="overview">1. Overview</h4>
<img  class="img-responsive"  src="/images/flat_network.png">

Flat networks are very popular for small businesses and internal networks which cannot be accessed by traffics out of data center.
A flat network is very easy to deploy, usually has only one L2 broadcast domain, and machines on it can
access the internet through the core router of the data center. In this example, we assume you already have a subnet that has been routed to the internet;
we will create a few VMs and assign them IPs from that subnet.

<hr>

<h4 id="prerequisites">2. Prerequisites</h4>

We assume you have followed [Quick Installation Guide](../installation/index.html) to install ZStack on a single Linux machine, and
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
+ eth0 IP: 172.20.11.45
+ free IP range: 192.168.0.230 ~ 192.168.0.240
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

<h4 id="createL2Network">10. Create Flat L2 Network</h4>

click 'Network' in left sidebar and click 'L2Network' to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

click button 'Create L2Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. name the L2 network as 'FLAT-L2'
2. choose type 'L2NoVlanNetwork'
3. input physical interface as 'eth0'
4. select cluster 'CLUSTER1'
5. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t2/createL2Network3.png">

<hr>

<h4 id="createL3Network">11. Create L3 Network</h4>

click 'L3 Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

click button 'Private Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createPN1.png">

<hr>

Name the L3 network as 'FLAT-L3' , select L2 network(FLAT-L2) and choose  'Flat Network ':

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network3.png">

<hr>

1. choose method 'IP Range'
2. input start IP '192.168.0.230'
3. input end IP '192.168.0.240'
4. input netmask '255.255.255.0'
5. input gateway '192.168.0.1'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network4.png">

<hr>

input DNS '8.8.8.8' and click button 'OK' to add the IP range:

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network5.png">

<hr>

<h4 id="createVM">12. Create Virtual Machine</h4>

click 'Resource Pool' in the left sidebar and click 'VmInstance' to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'Create VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose Type  'Single'
2. input name as 'VM1'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5. choose  network 'FLAT-L3'
6. click button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t2/createVM2.png">

<hr>


<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

once the VM is created successfully, click button 'Action' then click item 'Console' to open VM's console:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM5.png">

in the popup window, login the VM by *username: root*; run command 'hostname', you should see the hostname
'zstack''; and command 'ifconfig' should show the IP address which is in the flat network.

<img  class="img-responsive"  src="/images/tutorials/t2/createVM6.png">

<hr>

ping google.com, it should succeed:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM6.png">

<hr>

repeat above steps to create vm2 and vm3. They should all get IP address and should be able to reach the internet.

<img  class="img-responsive"  src="/images/tutorials/t2/createVM8.png">

<div class="bs-callout bs-callout-info">
  <h4>Subsequent VMs are created extremely fast</h4>
  As the image has been downloaded to the image cache of the primary storage and the virtual router VM has been created,
  new VMs will be created extremely fast, usually less than 3 seconds. 
</div>

### Summary

In this tutorial, we showed you how to create a flat network in ZStack. For more details about ZStack's L3 network, visit
[L3 Network in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/l3Network.html).
