---
title: ZStack搭建扁平网络教程
layout: tutorialDetailPage.cn
sections:
  - id: overview 
    title: 介绍
  - id: prerequisites 
    title: 前提
  - id: login 
    title: 登录
  - id: createZone 
    title: 创建Zone
  - id: createCluster 
    title: 创建Cluster
  - id: addHost 
    title: 添加主机Host
  - id: addPrimaryStorage
    title: 添加主存储
  - id: addBackupStorage
    title: 添加备份存储
  - id: addImage
    title: 添加云主机磁盘镜像
  - id: createL2Network
    title: 创建二层网络
  - id: createL3Network
    title: 创建三层网络
  - id: createInstanceOffering
    title: 添加云主机配置
  - id: createVirtualRouterOffering
    title: 添加虚拟路由器配置
  - id: createVM
    title: 创建云主机
---

### 扁平网络 Flat Network

<h4 id="overview">1. 介绍</h4>
<img  class="img-responsive"  src="/images/flat_network.png">

扁平网络在私有云网络环境中非常的流行。它的网络拓扑很简单，所有的云主机都是直接接在公司内部的一个大二层的网络上。
扁平网络也非常容易搭建。由于所有的云主机和物理主机都在一个二层广播域，在这个二层网络上的云主机可以
通过数据中心的核心路由器链接到Internet。在这个教程里，我们假定您拥有一个可以访问Internet的IP网络。

<hr>

<h4 id="prerequisites">2. 前提</h4>

我们假定您已经根据[安装手册](../installation/index.html)里的方法成功的安装并且启动了ZStack。
您可以在Chrome浏览器或者FireFox浏览器（IE浏览器可能会遇到使用问题）上打开如下地址来登录ZStack管理界面：

    http://your_machine_ip:5000/
    
我们假定您的这台Linux服务器只有一个网卡，并且它可以链接到互联网。除此之外，我们还需要如下的要求：

+ 至少20G可用的硬盘剩余空间用于基本的主存储和备份存储
+ 有几个可以使用的公网的IP地址
+ 有一个启动的NFS服务器NFS (如果在安装ZStack的时候使用了-a或者-n的参数，ZStack安装程序会在本机启动一个NFS服务，默认是在/usr/local/zstack/nfs_root/。但是我们还是建议用户自己可以配置一个单独的NFS服务，例如/my_nfs_folder)
+ 可以使用root用户 ssh到本机

<div class="bs-callout bs-callout-info">
  <h4>配置root用户的ssh登录能力</h4>
  KVM节点需要root用户的SSH权限来使用Ansible安装系统包和控制KVM Agent。本教程里面只使用了单一的Linux
  服务器作为操作对象，您需要提前配置root用户的SSH访问能力。
  
  <h5>CentOS:</h5>
  <pre><code>sudo su
passwd root</code></pre>

  <h5>Ubuntu:</h5>
  您需要修改SSHD的配置文件：
  <pre><code>1. sudo su
2. passwd root
3. 编辑/etc/ssh/sshd_config
4. 注释掉 'PermitRootLogin without-password'
5. 添加'PermitRootLogin yes'
6. 重启 SSHD: 'service ssh restart'</code></pre>
</div>

基于以上的环境要求，我们假设有如下的配置信息：

+ 网卡设备： eth0
+ eth0 IP: 192.168.0.212 
+ 其他空闲的IP地址范围: 192.168.0.230 ~ 192.168.0.240
+ 主存储目录: /usr/local/zstack/nfs_root
+ 备份存储目录: /backupStorage

<div class="bs-callout bs-callout-warning">
  <h4>停止云主机可能会等1分钟，如果云主机镜像里没有配置ACPID:</h4>
    尽管我们的教程里不会演示停止云主机的功能，但是您可能自己在尝试的时候会发现启动一个云主机只需要1秒钟，
    但是停止一个云主机可能会需要1分钟时间。这是因为您的云主机模板中没有ACPID相关的服务。
    ZStack发出Stop指令后，云主机的操作系统并不会接收这样的指令。ZStack在等待1分钟后会强行的停止这个云主机。
    如果用户自己的云主机模板也存在类似的问题，那么最好求助于操作系统提供商解决相关的问题。
</div>
    
<hr>

<h4 id="login">3. 登录</h4>

在Chrome浏览器或者FireFox浏览器（IE浏览器可能会遇到使用问题）上登录ZStack管理界面：
默认的用户名和密码分别为admin/password:

<img  class="img-responsive"  src="/images/tutorials/t1/login.png">

<hr>

<h4 id="createZone">4. 创建Zone</h4>

点击左侧面板的'Zone':

<img  class="img-responsive"  src="/images/tutorials/t1/createZone1.png">

<hr>

点击按钮'New Zone'来打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/createZone2.png">

<hr>

给第一个Zone取一个名字：'ZONE1'，然后点击按钮'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createZone3.png">

<hr>

<h4 id="createCluster">5. 创建Cluster</h4>

点击左侧面板的'Cluster':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster1.png">

<hr>

点击按钮'New Cluster'来打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster2.png">

<hr>

选择刚刚创建的zone(ZONE1); 给cluster取个名字：'CLUSTER1'; 然后选择hypervisor 'KVM'；接着点击按钮'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster3.png">

<hr>

我们现在还没有任何的主存储，让我们继续点击'Next':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster4.png">

<hr>

我们现在还没有任何的L2网络，让我们直接点击'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createCluster5.png">

<hr>

<h4 id="addHost">6. 添加计算节点Host</h4>

点击左侧面板的'Host':

<img  class="img-responsive"  src="/images/tutorials/t1/addHost1.png">

<hr>

点击按钮'New Host'打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/addHost2.png">

<hr>

1. 选择zone(ZONE1)和cluster(CLUSTER1)
2. 给host取个名字：'HOST1'
3. 输入host的IP地址(192.168.0.212)
4. 最重要的是输入host root用户的用户名和密码
5. 点击'add'

<img  class="img-responsive"  src="/images/tutorials/t1/addHost3.png">

<div class="bs-callout bs-callout-warning">
  <h4>第一次添加Host可能会较慢</h4>
  基于用户的网络环境，第一次添加Host可能需要等待几分钟的时间。ZStack会安装好所有的依赖包和完成自动化的配置。
</div>

<hr>

<h4 id="addPrimaryStorage">7. 添加主存储</h4>

点击左侧面板的'Primary Storage':

<img  class="img-responsive"  src="/images/tutorials/t1/addPS1.png">

<hr>

点击按钮'New Primary Storage'来打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/addPS2.png">

<hr>

1. 选择zone(ZONE1)
2. 给主存储取个名字:'PRIMARY-STORAGE1'
3. 选择类型'NFS' 
4. 输入NFS url(例如192.168.0.212:/usr/local/zstack/nfs_root)
5. 点击'Next'

<div class="bs-callout bs-callout-info">
  <h4>NFS URL的格式</h4>
  NFS URL的格式和在Linux中使用<i>mount</i>命令非常的相似.
</div>

<img  class="img-responsive"  src="/images/tutorials/t1/addPS3.png">

<hr>

选择cluster(CLUSTER1)作为挂载对象, 然后点击按钮'Add':

<img  class="img-responsive"  src="/images/tutorials/t1/addPS4.png">

<div class="bs-callout bs-callout-info">
  <h4>Add会执行多条实际的ZStack APIs</h4>
  如果一切顺利，您会看到两个APIs完成的通知：addPrimaryStorage和attachPrimaryStorageToCluster.
</div>

<hr>

<h4 id="addBackupStorage">8. 添加备份存储</h4>

点击左侧面板的'Backup Storage':

<img  class="img-responsive"  src="/images/tutorials/t1/addBS1.png">

<hr>

点击按钮'New Backup Storage'来打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/addBS2.png">

<hr>

1. 给备份存储取名为：'BACKUP-STORAGE1'
2. 选择类型'SftpBackupStorage'
3. 输入URL '/backupStorage' (如果该目录不存在，ZStack会负责创建该目录)
4. 输入本机IP地址(192.168.0.212)
5. 输入root用户的ssh密码
6. 点击'Next'

<img  class="img-responsive"  src="/images/tutorials/t1/addBS3.png">

<hr>

选择zone(ZONE1)作为挂载对象，然后点击'Add':

<img  class="img-responsive"  src="/images/tutorials/t1/addBS4.png">

<hr>

<h4 id="addImage">9. 添加云主机磁盘镜像</h4>

点击左侧面板的'Image':

<img  class="img-responsive"  src="/images/tutorials/t1/addImage1.png">

<hr>

点击'New Image'来打开对话框:

<img  class="img-responsive"  src="/images/tutorials/t1/addImage2.png">

<hr>

1. 选择备份存储(BACKUP-STORAGE1)
2. 给磁盘镜像取名为'zs-sample-image'
3. 选择格式'qcow2'
4. 选择媒体类型为'RootVolumeTemplate'
5. 选择平台'Linux'
6. 输入下载地址 {{site.zstack_image}}
7. 点击'Add' （不能选择'System'）

该镜像文件将会用于用户云主机的模板。

<img  class="img-responsive"  src="/images/tutorials/t1/addImage3.png">

<hr>

再次点击'New Image'来添加一个用于虚拟路由器的磁盘镜像:

1. 选择备份存储(BACKUP-STORAGE1)
2. 给磁盘镜像取名为'VIRTUAL-ROUTER'
3. 选择格式'qcow2'
4. 选择媒体类型为'RootVolumeTemplate'
5. 选择平台'Linux'
6. 输入下载地址 {{site.vr_ch}}
7. **勾选'System'（非虚拟路由器的普通Image不能选择System，否则该Image无法用于创建虚拟机）**
8. 点击'Add'

<img  class="img-responsive"  src="/images/tutorials/t1/addImage4.png">

<div class="bs-callout bs-callout-info">
  <h4>预先下载磁盘镜像文件在本地的HTTP服务器</h4>
  ZStack的虚拟路由器镜像文件超过了400MB的大小。如果您的网络下载速度较慢，我们建议您提前用其他的办法下载该模板，
  并存储在本地搭建的HTTP服务器上。如果未来需要添加其他的更大的云主机模板，您最好也把它存放在本地的HTTP服务器上。
  默认情况下，添加Image的时间超过30分钟，ZStack会自动中断添加的过程并报告超时。
</div>

<hr>

<h4 id="createL2Network">10. 创建二层网络</h4>

点击左侧面板的'L2 Network':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network1.png">

<hr>

点击按钮'New L2 Network':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network2.png">

<hr>

1. 选择zone(ZONE1)
2. 给二层网络取个名字'FLAT-L2'
3. 选择类型'L2NoVlanNetwork'
4. 输入物理网卡的名字'eth0'
5. 点击'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL2Network3.png">

<hr>

选择cluster(CLUSTER1)作为挂载对象，然后点击'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createL2Network4.png">

<hr>

<h4 id="createL3Network">11. 创建三层网络</h4>

点击左侧面板的'L3 Network':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network1.png">

<hr>

点击'New L3 Network':

<img  class="img-responsive"  src="/images/tutorials/t1/createL3Network2.png">

<hr>

1. 选择zone(ZONE1)
2. 选择二层网络(FLAT-L2)
3. 给三层网络取名为'FLAT-L3'
4. 选择类型'L3BasicNetwork'
5. 输入域名：'tutorials.zstack.org'
6. 点击'Next' (不要选择System)

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network3.png">

<hr>

1. 命名IP range：'FLAT-IP-RANGE'
2. 选择添加方法：'Add By IP Range'
3. 输入起始IP地址 '192.168.0.230'
4. 输入结束IP地址'192.168.0.240'
5. 输入子网掩码 '255.255.255.0'
6. 输入网关 '192.168.0.1'
7. 点击 'Add' 来添加一个 IP range
8. 点击 'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network4.png">

<hr>

输入'8.8.8.8'(您也可以输入国内的DNS，例如114.114.114.114)，然后点击'Add'来添加一个DNS服务器，接着点击'Next':

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network5.png">

<hr>

1. 选择provider'VirtualRouter'
2. 选择'DHCP'
3. 点击'Add'增加一个网络服务
重复上面这步来添加DNS, 最后点击'Create':

<img  class="img-responsive"  src="/images/tutorials/t2/createL3Network6.png">

<hr>

<h4 id="createInstanceOffering">12. 创建云主机模板</h4>

点击左边面板的'Instance Offering':

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering1.png">

<hr>

点击'New Instance Offering':

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering2.png">

<hr>

1. 给模板取个名字'512M-512HZ'
2. 输入CPU个数为1
3. 输入CPU速度512
4. 输入内存大小512M
5. 点击'create'

<img  class="img-responsive"  src="/images/tutorials/t1/createInstanceOffering3.png">

如果使用zs-sample-image的磁盘镜像来创建虚拟机，该虚拟机的最低内存需求量仅需要64MB。用户可以只创建一个64MB的模板。

<hr>

<h4 id="createVirtualRouterOffering">13. 创建虚拟机路由器模板</h4>

点击左边面板的'Virtual Router Offering':

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering1.png">

<hr>

点击'New Virtual Router Offering':

<img  class="img-responsive"  src="/images/tutorials/t1/createVirtualRouterOffering2.png">

<hr>

1. 选择zone(ZONE1)
2. 取个名字'VR-OFFERING'
3. 输入CPU数量'1'
4. 输入CPU主频'512'
5. 输入内存大小'512M'
6. 选择磁盘镜像'VIRTUAL-ROUTER"
7. 选择management L3 network 'FLAT-L3'
8. 选择public L3 network 'FLAT-L3'
9. 勾选'DEFAULT OFFERING'
10. 点击'Create'

<img  class="img-responsive"  src="/images/tutorials/t2/createVirtualRouterOffering3.png">

<hr>

<h4 id="createVM">14. 创建云主机</h4>

点击左边面板的'Instance':

<img  class="img-responsive"  src="/images/tutorials/t1/createVM1.png">

<hr>

点击'New VmInstance':

<img  class="img-responsive"  src="/images/tutorials/t1/createVM2.png">

<hr>

1. 选择模板'512M-512HZ'
2. 选择磁盘镜像'zs-sample-image'
3. 选择三层网络'FLAT-L3'，**并且点击'Add'**
4. 输入云主机的名字'VM1'
5. 输入云主机的网络名字： 'vm1'
6. 点击'Next'

<img  class="img-responsive"  src="/images/tutorials/t2/createVM2.png">

<hr>

点击 'Create':

<img  class="img-responsive"  src="/images/tutorials/t1/createVM4.png">

<div class="bs-callout bs-callout-warning">
  <h4>启动第一个云主机会花费较长的时间</h4>
  当第一次创建云主机的时候，ZStack需要把云主机的磁盘镜像从备份存储下载到主存储中来，根据不同磁盘镜像的大小，
    它可能需要一段时间。另外ZStack也会为云主机创建虚拟路由器，这个也需要消耗1分钟的时间。
    当第一个云主机创建好后，再次创建云主机将会非常快速。
</div>

<hr>

当云主机创建完成，点击'Action'，再点击'Console'来打开云主机的终端(需要在浏览器上允许弹出窗口):

<img  class="img-responsive"  src="/images/tutorials/t1/createVM5.png">

在弹出的窗口中，用root用户的password密码来登录zs-sample-image。登录后，您可以用'hostname'来查看主机名，
用'ifconfig'来检查IP地址是不是属于扁平网络的地址。

<img  class="img-responsive"  src="/images/tutorials/t2/createVM6.png">

<hr>

您应该可以成功的ping www.baidu.com:

<img  class="img-responsive"  src="/images/tutorials/t2/createVM7.png">

<hr>

重复以上步骤来创建更多的VM2和VM3。他们应该都可以获得IP地址并且顺利访问Internet。

<img  class="img-responsive"  src="/images/tutorials/t2/createVM8.png">

<div class="bs-callout bs-callout-info">
  <h4>后续的云主机创建过程会非常的快</h4>
  由于第一次创建云主机时，ZStack已经把云主机的磁盘放到了缓存中，虚拟路由器也成功创建，所以后续的云主机添加的过程通常不会超过2秒。
</div>

### 总结

在这个教程里，我们展示了如何快速的使用ZStack来搭建一个扁平网络环境。关于ZStack更多的三层网络的介绍，
您可以登录[L3 Network in user manual](http://zstackdoc.readthedocs.org/en/latest/userManual/l3Network.html)来查阅。








