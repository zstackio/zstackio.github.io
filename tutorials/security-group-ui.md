---
title: ZStack Security Group Tutorials
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
<img  class="img-responsive"  src="/images/flat_network_with_security_group.png">

Security group is a virtual firewall that can control the traffic for a group of VMs. In this example, we will
create a flat network with a security group, then create one VM(INNER-VM) in the security group while another VM(OUTER-VM) out of
the security group. The security group will initially contain a rule opening port 22 to the OUTER-VM; we will confirm OUTER-VM
can SSH login the INNER-VM; later on, we will remove the only rule and confirm OUTER-VM cannot SSH login INNER-VM anymore.

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

<h4 id="createL2Network">10. Create L2 Network</h4>

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

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network6.png">

<hr>

1. select provider 'SecurityGroup'
2. select service 'SecurityGroup'
3. click button 'Add' to add security group service
4. now you should have network services: DHCP, DNS, and SecurityGroup added
5. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t4/createL3Network7.png">
<img  class="img-responsive"  src="/images/tutorials/t4/createL3Network8.png">

<hr>

<h4 id="createSecurityGroup">12. Create Security Group</h4>

click 'Security Group' in left sidebar to enter security group page:

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup1.png">

<hr>

click button 'New Security Group' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup2.png">

<hr>

1. input name as 'SECURITY-GROUP-1'
2. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup3.png">

<hr>

1. select type 'Ingress'
2. input start port as 22
3. input end port as 22
4. select protocol as 'TCP'
5. click button 'Add'
6. click button 'Next' 

<div class="bs-callout bs-callout-info">
  <h4>This rule is world open</h4>
  Here we ignore field 'ALLOWED CIDR', the default CIDR will be 0.0.0.0/0 that makes the port 22 world open.
  You can specify a CIDR(e.g. 16.16.16.0/24, 16.16.16.16/32) to restrict what traffics can access the port.
</div>

<div class="bs-callout bs-callout-info">
  <h4>ICMP start port & end port</h4>
  If select ICMP, the start port and end port mean ICMP type. To use '-1' for all ICMP types. 
  For details port definition, please visit [ZStack API Doc](http://zstackdoc.readthedocs.org/en/latest/userManual/securityGroup.html#security-group-rule-inventory)
</div>

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup4.png">
<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup5.png">

<hr>

1. select L3 network 'FLAT-L3'
2. click button 'Create'

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup6.png">

<hr>

<h4 id="createInstanceOffering">13. Create Instance Offering</h4>

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

<h4 id="createVirtualRouterOffering">14. Create Virtual Router Offering</h4>

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

<hr>

<h4 id="createInnerVM">15. Create INNER-VM</h4>

click 'Instance' in the left sidebar to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'New VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'FLAT-L3'
4. input name as 'INNER-VM'
5. input host name as 'inner'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t4/createInnerVM3.png">

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createVM4.png">

<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="joinInnerVM">16. Join INNER-VM Into Security Group</h4>

In security group page, select 'SECURITY-GROUP-1', then click button 'Action' and select item 'Add Vm Nic'.

<img  class="img-responsive"  src="/images/tutorials/t4/joinSecurityGroup1.png">

<hr>

1. select the only nic of INNER-VM
2. click button 'Add'

<img  class="img-responsive"  src="/images/tutorials/t4/joinSecurityGroup2.png">

<hr>

<h4 id="createOuterVM">17. Create OUTER-VM</h4>

go to vm instance page and click button 'New VmInstance' again to create OUTER-VM:

1. choose instance offering '512M-512HZ'
2. choose image 'zs-sample-image'
3. choose L3 network 'FLAT-L3'
4. input name as 'OUTER-VM'
5. input host name as 'outer'
6. click button 'Next'

<img  class="img-responsive"  src="/images/tutorials/t4/createOuterVM1.png">

<div class="bs-callout bs-callout-info">
  <h4>Subsequent VMs are created extremely fast</h4>
  As the image has been downloaded to the image cache of the primary storage and the virtual router VM has been created,
  new VMs will be created extremely fast, usually less than 3 seconds. 
</div>

<hr>

click button 'Create':

<img  class="img-responsive"  src="/images/tutorials/t4/createOuterVM2.png">

<hr>

<h4 id="sshLogin">18. SSH Login INNER-VM From OUTER-VM</h4>

go to vm instance page:

1. double click 'INNER-VM'
2. click tab 'Nic'
3. you can see IP address of INNER-VM: 192.168.0.236

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin1.png">

<hr>

click breadcrumb 'VM INSTANCE' on top of title bar 'INNER-VM' to go back vm instance page:

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin2.png">

<hr>

1. select OUTER-VM
2. click button 'Action'
3. select item 'Console' to open VNC console

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin3.png">

<hr>

in the popup window, login the VM by *username: root, password: password*.

1. ping INNER-VM (192.168.0.236), it should fail because we don't open ICMP rule in the security group 
2. ssh INNER-VM, it should succeed
3. after SSH login, run 'ifconfig', you should see IP (192.168.0.236) that is of INNER-VM
4. type 'logout' then click enter to SSH logout

<div class="bs-callout bs-callout-info">
  <h4>Using your IP to test</h4>
  The IP address may be different in your environment, please use the IP showed in your nic page of INNER-VM.
</div>

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin4.png">

<hr>

<h4 id="deleteSecurityGroupRule">19. Delete Security Group Rule</h4>

go to security group page:

1. select 'SECURITY-GROUP-1'
2. click button 'Action'
3. select item 'Delete Rule'

<img  class="img-responsive"  src="/images/tutorials/t4/deleteSecurityGroupRule1.png">

<hr>

1. select checkbox of rule 22
2. click button 'Delete'

<img  class="img-responsive"  src="/images/tutorials/t4/deleteSecurityGroupRule2.png">

<hr>

<h4 id="sshLoginFailure">20. Confirm Unable to SSH Login INNER-VM From OUTER-VM</h4>

go back to VNC console of OUTER-VM; ssh INNER-VM, it should fail.

<img  class="img-responsive"  src="/images/tutorials/t4/sshLoginFailure1.png">

### Summary

In this tutorial, we showed you the basics of using security group. Though we only show one security group with
one L3 network and one VM; you can actually create many security groups and attach them to different L3 networks;
you can also put many VMs in the same security group. For more details,
please visit [Security Group in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/securityGroup.html).

