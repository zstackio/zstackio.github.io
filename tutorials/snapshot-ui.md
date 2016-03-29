---
title: ZStack Volume Snapshot Tutorials
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
  - id: createSnapshotTree1
    title: Create Volume Snapshot
---

### Volume Snapshot

<h4 id="overview">1. Overview</h4>
<img  class="img-responsive"  src="/images/snapshot.png">

ZStack allows user to create snapshots from VM's root volume and data volumes. Unlike majority of IaaS software only allowing users
to create at most one snapshot chain, ZStack allows users to create a snapshot tree that each branch is a snapshot chain.

In this example, we will create a snapshot tree with two branches from a VM's root volume.

<div class="bs-callout bs-callout-warning">
  <h4>Only Ubuntu14.04 supports live snapshot, CentOS doesn't</h4>
  For Linux distributions (CentOS6.x, CentOS7, and Ubuntu14.04) we have tested, only Ubuntu14.04 supports live
  snapshot. If you use a Linux other than Ubuntu14.04, you have to stop the VM before taking every snapshot. 
  Assuming you use Ubuntu14.04, this tutorial doesn't contain instructions to stop VM before taking snapshot. However, reverting snapshot
  always requires to stop VM no matter what Linux distributions in use.
</div>

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

<h4 id="createL2Network">10. Create Flat L2 Network</h4>

click 'L2 Network' in left sidebar to enter L2 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

click button 'New L2 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. select zone(ZONE1)
2. name the L2 network as 'FLAT-L2'
3. choose type 'L2NoVlanNetwork'
4. input physical interface as 'eth0'
5. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL2Network3.png">

<hr>

select cluster(CLUSTER1) to attach, and click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network4.png">

<hr>

<h4 id="createL3Network">11. Create L3 Network</h4>

click 'L3 Network' in left sidebar to enter L3 network page:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

click button 'New L3 Network' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network2.png">

<hr>

1. select zone(ZONE1)
2. select L2 network(FLAT-L2)
3. name the L3 network as FLAT-L3
4. input domain as 'tutorials.zstack.org'
5. choose type 'L3BasicNetwork'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network3.png">

<hr>

1. name the IP range as 'FLAT-IP-RANGE'
2. choose method 'Add By IP Range'
3. input start IP '192.168.0.230'
4. input end IP '192.168.0.240'
5. input netmask '255.255.255.0'
6. input gateway '192.168.0.1'
7. click button 'Add' to add the IP range
8. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network4.png">

<hr>

1. input DNS '8.8.8.8'
2. click button 'Add' to add the DNS
3. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network5.png">

<hr>

1. select provider 'VirtualRouter'
2. select service 'DHCP'
3. click button 'Add' to add DHCP service
4. repeat step 2~3 to add DNS service
5. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network6.png">

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
7. choose management L3 network 'FLAT-L3'
8. choose public L3 network 'PLAT-L3'
9. check 'DEFAULT OFFERING' checkbox
10. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t2/createVirtualRouterOffering3.png">

<h4 id="createVM">14. Create Virtual Machine</h4>

click 'Instance' in the left sidebar to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'New VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t2/createVM2.png">

<hr>

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'FLAT-L3'
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

<h4 id="createSnapshotTree1">15. Create Volume Snapshot</h4>

first of all, we are going to create a flag file in VM1, so later on we can use this file to confirm that we revert
to the correct snapshot. go to vm instance page:

1. select VM1
2. click button 'Action'
3. select item 'Console'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot5.png">

<hr>

in the popup window, login the VM by *username: root, password: password*; then create a file 'flag' as below:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot6.png">

<hr>

go to vm instance page: 

1. double click VM1 to enter details page
2. select tab 'Volume':
3. click device ID 0 to enter VM1's root volume page

<img class="img-responsive" src="/images/tutorials/t6/createSnapshot1.png">
<img class="img-responsive" src="/images/tutorials/t6/createSnapshot2.png">

<hr>

1. click button 'Action'
2. select item 'Take Snapshot'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot3.png">

<hr>

1. input name as 'sp1'
2. click button 'click'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot4.png">

<hr>

repeat above two steps to create two more snapshots: sp2 and sp3:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot7.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot8.png">

<hr>

click tab 'Snapshot' and expand the tree, you should see three snapshots:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot9.png">

<hr>

use instructions in the beginning of this section to enter VM1's console, and delete the flag file 'flag1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot10.png">

<hr>

to revert the root volume to a prior snapshot, we need to stop the VM1 first; go to the VM instance page:

1. select VM1
2. click button 'Action'
3. select item 'Stop'

<div class="bs-callout bs-callout-warning">
  <h4>Again it's slow only because the zs-sample-image doesn't support ACPID</h4>
   Because the image zs-sample-image doesn't support ACPID, the VM cannot be gracefully stopped.
   ZStack has to wait 60s stopping timeout then kill it, you won't encounter this problem in regular Linux
   distributions.
</div>

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot12.png">

<hr>

use former instructions to go to snapshot page:

1. expand the snapshot tree
2. select snapshot 'sp1'
3. in the dropdown, select item 'Revert volume to this snapshot'
4. click button 'Revert'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot11.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot13.png">

<hr>

now start the VM again:

1. select VM1
2. click button 'Action'
3. select item 'Start'

<img class="img-responsive" src="/images/tutorials/t6/createSnapshot14.png">

<hr>

open the VNC console again and check the flag file 'flag1', you should see the file we deleted before now comes back,
which confirms we have successfully reverted the root volume to the snapshot 'sp1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot15.png">

<hr>

use former instructions to create two more snapshots: 'sp1.1' and 'sp1.2':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot16.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot17.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot18.png">

<hr>

expand the snapshot tree, now you should see two branches that are both derived from snapshot 'sp1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot19.png">


### Summary

In this tutorial, we showed you how to create volume snapshot in ZStack. Besides reverting a volume to
an old snapshot, you can also create image template and volumes from snapshots. For details, please visit
[Volume Snapshot in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/volumeSnapshot.html).

























