---
title: ZStack Volume Snapshot Tutourials
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

<h4 id="createSnapshotTree1">13. Create Volume Snapshot</h4>

first of all, we are going to create a flag file in VM1, so later on we can use this file to confirm that we revert
to the correct snapshot. go to vm instance page:

1. select VM1
2. click button 'VmInstance Actions'
3. select item 'Console'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot5.png">

<hr>

in the popup window, login the VM by *username: root, password: password*; then create a file 'flag' as below:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot6.png">

<hr>

go to vm instance page: 

1. select VM1 to enter details page
2. select item 'Configure'
3. click 'ROOT-for-VM1'


<img class="img-responsive" src="/images/tutorials/t6/createSnapshot1.png">

1. click the button 'Volume Actions'
2. select item 'Create Snapshot'
<img class="img-responsive" src="/images/tutorials/t6/createSnapshot2.png">

<hr>

1. input name as 'sp1'
2. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot4.png">

<hr>

repeat above two steps to create two more snapshots: sp2 and sp3:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot7.png">

<hr>

click tab 'Snapshot' and expand the tree, you should see three snapshots:

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot9.png">

<hr>
use instructions in the beginning of this section to enter VM1's console, and delete the flag file 'flag1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot10.png">

<hr>

to revert the root volume to a prior snapshot, we need to stop the VM1 first; go to the VM instance page:

1. select VM1
2. click button 'VmInstance Actions'
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
3. in the dropdown, select item 'Snapshot Actions'
4. select 'Recover'


<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot11.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot13.png">

<hr>

now start the VM again:

1. select VM1
2. click button 'VmInstance Actions'
3. select item 'Start'

<hr>

open the VNC console again and check the flag file 'flag1', you should see the file we deleted before now comes back,
which confirms we have successfully reverted the root volume to the snapshot 'sp1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot15.png">

<hr>

use former instructions to create two more snapshots: 'sp1.1' and 'sp1.2':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot16.png">
<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot17.png">

<hr>

expand the snapshot tree, now you should see two branches that are both derived from snapshot 'sp1':

<img  class="img-responsive"  src="/images/tutorials/t6/createSnapshot18.png">


### Summary

In this tutorial, we showed you how to create volume snapshot in ZStack. Besides reverting a volume to
an old snapshot, you can also create image template and volumes from snapshots. For details, please visit
[Volume Snapshot in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/volumeSnapshot.html).
