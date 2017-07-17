yout: tutorialDetailPage
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

<hr

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
3. input start IP as '10.121.9.20'
4. input end IP as '10.121.9.200'
5. input netmask as '255.0.0.0'
6. input gateway as '10.0.0.1'

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


<h4 id="createSecurityGroup">15. Create Security Group</h4>

click 'Network Services' in left sidebar and click 'Security Group' to enter security group page:

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup1.png">

<hr>

click button 'Create Security Group' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup2.png">

<hr>

Input name as 'SECURITY-GROUP-1' and select Network as 'L3Network-private':

<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup3.png">

<hr>
Select rule to open setting rules page:
1. select type 'Ingress'
2. select protocol as 'TCP'
3. input start port as 23
4. input end port as 200
5. click button 'OK'

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


Click button 'OK':
<img  class="img-responsive"  src="/images/tutorials/t4/createSecurityGroup5.png">

<hr>


<h4 id="createInstanceOffering">13. Create Instance Offering</h4>

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


<h4 id="createInnerVM">14. Create INNER-VM</h4>

click 'Resource Pool' in the left sidebar and click 'VmInstance' to enter VM instance page:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

click button 'Create VmInstance' to open the dialog:

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. choose Type  'Single'
2. input name as 'INNER-VM'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5.  choose  network 'L3Network-private'
6. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t4/createInnerVM3.png">

<hr>


<div class="bs-callout bs-callout-warning">
  <h4>The first user VM takes more time to create</h4>
  For the first user VM, ZStack needs to download the image from the backup storage to the primary storage and create a virtual router VM on
  the private L3 network, so it takes about 1 ~ 2 minutes to finish.
</div>

<hr>

<h4 id="joinInnerVM">16. Join INNER-VM Into Security Group</h4>

In security group page, select 'SECURITY-GROUP-1', then click button 
'VmInstance Nic',click button 'Action' and select item 'Add Vm Nic':

<img  class="img-responsive"  src="/images/tutorials/t4/joinSecurityGroup1.png">

<img  class="img-responsive"  src="/images/tutorials/t4/joinSecurityGroup2.png">

<hr>

1. select the only nic of INNER-VM
2. click button 'OK'

<img  class="img-responsive"  src="/images/tutorials/t4/joinSecurityGroup3.png">

<hr>

<h4 id="createOuterVM">17. Create OUTER-VM</h4>

go to vm instance page and click button 'Create VmInstance' again to create OUTER-VM:

1. choose Type  'Single'
2. input name as 'OUTER-VM'
3. choose instance offering 'IO1'
4. choose image 'Image1'
5. choose  network 'L3Network-private'
6. click button 'OK'


<img  class="img-responsive"  src="/images/tutorials/t4/createOuterVM1.png">

<div class="bs-callout bs-callout-info">
  <h4>Subsequent VMs are created extremely fast</h4>
  As the image has been downloaded to the image cache of the primary storage and the virtual router VM has been created,
  new VMs will be created extremely fast, usually less than 3 seconds. 
</div>

<hr>

<h4 id="sshLogin">18. SSH Login INNER-VM From OUTER-VM</h4>

go to vm instance page:

Click 'INNER-VM' and you can see IP address of INNER-VM: 192.168.1.222

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin1.png">

<hr>

Select OUTER-VM and  click button 'Action':

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin2.png">

<hr>

Select item 'Console' to open VNC console

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin3.png">

<hr>

in the popup window, login the VM by *username: root.password:password*.

1. ping INNER-VM(192.168.1.222),it should failed
2. ssh INNER-VM(192.168.1.222), it should failed
3. run 'ip r', you should see IP (192.168.1.219) that is of OUTER-VM


<div class="bs-callout bs-callout-info">
  <h4>Using your IP to test</h4>
  The IP address may be different in your environment, please use the IP showed in your nic page of INNER-VM.
</div>

<img  class="img-responsive"  src="/images/tutorials/t4/sshLogin4.png">

<hr>

<h4 id="deleteSecurityGroupRule">19. Delete Security Group Rule</h4>

go to security group page:

Select 'SECURITY-GROUP-1' and click button 'More Action'

<img  class="img-responsive"  src="/images/tutorials/t4/deleteSecurityGroupRule1.png">

<hr>

Click button 'Delete'

<img  class="img-responsive"  src="/images/tutorials/t4/deleteSecurityGroupRule2.png">

<hr>

<h4 id="sshLoginFailure">20. Confirm Unable to SSH Login INNER-VM From OUTER-VM</h4>

go back to VNC console of OUTER-VM; ping INNER-VM and ssh INNER-VM, it should ssuccess.

<img  class="img-responsive"  src="/images/tutorials/t4/sshLoginFailure1.png">

### Summary

In this tutorial, we showed you the basics of using security group. Though we only show one security group with
one L3 network and one VM; you can actually create many security groups and attach them to different L3 networks;
you can also put many VMs in the same security group. For more details,
please visit [Security Group in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/securityGroup.html).

