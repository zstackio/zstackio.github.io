---
title: ZStack FAQ
layout: tutorialDetailPage.cn 
sections:
  - id: q1
    title: Q1. 管理节点重启后，如何重新启动ZStack Management Node
  - id: q2
    title: Q2. 管理节点IP地址变化了該怎么办?
  - id: q3
    title: Q3. 如何更改UI的Admin密码?
  - id: q4
    title: Q4. 如何手动启动ZStack管理节点
  - id: q5
    title: Q5. 如何手动延长ZStack管理节点启动时间
  - id: q6
    title: Q6. 手动启动ZStack UI管理界面
  - id: q7
    title: Q7. Vmware ESXi設定嵌套虚拟化的虚拟机
  - id: q8
    title: Q8. 如何重新安装ZStack
  - id: q9
    title: Q9. VMWare的嵌套虚拟化的虚拟机里创建ZStack的VR VM失败
  - id: q10
    title: Q10. 计算节点的IP是内网IP，管理节点IP有公网和内网，怎么通过管理节点连接VM的console
  - id: q11
    title: Q11. Windows VM 怎么设置使用VirtIO
  - id: q12
    title: Q12. ZStack 报告主、备份存储容量和物理机上看到的容量不一致
  - id: q13
    title: Q13. 计算节点是内网IP，如何通过管理节点上的公网IP连接虚拟机的console 
  - id: q14
    title: Q14. 修改 zstack-dashboard 默认使用的5000端口
  - id: q15
    title: Q15. 管理节点上有多个IP地址，如何让ZStck启动在某个非default路由的IP地址上？
  - id: q16
    title: Q16. 增加ZStack UI用户和zstack-cli的session过期时间
  - id: q17
    title: Q17. 从IP Range中保留一个IP地址,不让ZStack分配给云主机
  - id: q18
    title: Q18. 如何批量修改一批云主机的计算规格
  - id: q19
    title: Q19. 如何解决qemu版本不匹配问题
  - id: q20
    title: Q20. 如何释放Flat Network Service Provider DHCP占用的IP
---

<h2 id='q1'> Q1. 管理节点重启后，如何重新启动ZStack Management Node </h2>

管理节点重启后，用户只需要做三步：

1, ｀zstack-ctl start_node｀

2, ｀zstack-ctl start_ui｀

3, 进入UI界面 找到VirtualRouter 点击 action->start

从ZStack 1.0开始，用户也可直接使用如下一条命令，自动启动管理节点和Web管理界面（ZStack会根据系统当前安装的环境来启动对应的服务）：

    `zstack-ctl start`

用户可以将这条命令添加到系统的/etc/rc.local 文件中，并给该文件添加可执行权限：

    `chmod a+x /etc/rc.local`
    
---

<h2 id='q2'> Q2.管理节点IP地址变化了该怎么办? </h2>

编辑zstack.properties里所有老IP的IP地址，換成新IP地址。 zstack.properties的安装路径通常在：
/usr/local/zstack/apache-tomcat-7.0.35/webapps/zstack/WEB-INF/classes/zstack.properties

修改完毕后，重启ZStack管理节点：

｀ zstack-ctl stop_node; zstack-ctl start_node｀

从ZStack 1.0开始，用户也可直接使用如下一条命令:

` zstack-ctl stop; zstack-ctl start`

---

<h2 id='q3'>Q3.如何更改UI的Admin密码? </h2>

在管理节点上运行如下命令(如果password已经更改，请用改过的密码替換password):

｀zstack-cli LogInByAccount accountName=admin password=password｀

然后运行如下命令（NEW_PASSWORD 就是新要使用的密码）：
｀zstack-cli UpdateAccount uuid=36c27e8ff05c4780bf6d2fa65700f22e password=NEW_PASSWORD｀

---

<h2 id='q4'>Q4.如何手动启动ZStack管理节点</h2>

zstack-ctl start_node

---

<h2 id='q5'>Q5.如何手动延长ZStack管理节点启动时间</h2>

如果用户在虚拟机中运行ZStack，很可能会遇到启动超时失败，例如系统提示：

no management-node-ready message received within 120 seconds, please check error in log file /tmp/zstack_installation.log

如果之后运行 ｀zstack-ctl status｀ 又显示ZStack为Running的状态，那么可以试用如下的参数直接增加timeout的时间：

zstack-ctl start_node --timeout 300

---

<h2 id='q6'>Q6.手动启动ZStack UI管理界面</h2>

`zstack-ctl start_ui`

---

<h2 id='q7'>Q7.Vmware ESXi設定嵌套虚拟化的虚拟机</h2>

有两个方法：

一，登陆 VMware ESXi 控制台打开 VMware ESXi 5.0 的 SSH 服务（默认 SSH 服务是关闭的），然后用 ssh 登陆 VMware ESXi 后在 config 文件 （vi /etc/vmware/config）中最后加入 vhv.enable = “TRUE” 一行。

这个做掉后需要重启 ESXi，之后启动的虚拟机都会支持。

二，如果不能重启整改ESXi，就通过vphere 下载想要设置嵌套虚拟化的虚拟机的 config文件（xxx.vmx) 然后在这个文件的最后加上 vhv.enable = "TRUE" 一行。做这个操作前，需要停止这个虚拟机。加上设置后，再把修改的config，拷贝覆盖原有配置文件，重新启动虚拟机。

資料來源:http://www.oschina.net/question/54100_43989

---

<h2 id='q8'>Q8.如何重新安装ZStack</h2>
 
删除千万小心，如果需要彻底重装ZStack，只需要两步：

`rm -rf /usr/local/zstack`

ALL_IN_ONE.tgz是用户预先下载的ZStack All In One Package。

`bash zstack-install.sh -a -D -f ALL_IN_ONE.tgz`

---

<h2 id='q9'>Q9.在VMWare的嵌套虚拟化的虚拟机里创建ZStack的VR VM失败</h2>

需要在VMware的VSwitch设备上打开混杂模式，以及Vlan号。

---

<h2 id='q10'> Q10.计算节点的IP是内网IP，管理节点IP有公网和内网，怎么通过管理节点连接VM的console</h2>

如果管理节点上有公网IP地址和私网IP地址，但是Host的IP地址为私网IP地址。这个时候需要在管理节点上做个设置，才可以访问实例（Instance）的控制台（console）。
我们假设管理节点公网IP地址是'150.20.150.21'

`zstack-ctl configure consoleProxyOverriddenIp=150.20.150.21`

然后重启ZStack：

`zstack-ctl stop_node`

`zstack-ctl start_node`

---

<h2 id='q11'> Q11.Windows VM 怎么设置使用VirtIO </h2>

ZStack 默认创建Windows虚拟机的根磁盘使用IDE，而数据磁盘使用VirtIO。当用户给Windows虚拟机安装了VirtIO驱动后，
也可以让Windows虚拟机的根磁盘使用VirtIO设备。方法是给该虚拟机添加一条系统标签：

`zstack-cli CreateSystemTag resourceType=VmInstanceVO resourceUuid=TARGET_VM_UUID tag=windows::virtioVolume`

关于如何给Windows VM 安装 VirtIO driver，请看[博客](/cn_blog/install-virtio-for-windows.html)

---

<h2 id='q12'> Q12. ZStack 报告主、备份存储容量和物理机上看到的容量不一致</h2>

ZStack使用的是 thin clone 模式（copy on write技术），所以VM可以很快的被创建。
在KVM环境下，不论VM的镜像文件是10G还是100G，VM创建的时候只有一个很小的qcow2的独立文件被创建出来。
这个qcow2文件和原始的镜像文件一起共同组成了新的VM的硬盘。当有新的数据产生的时候，该qcow2文件的大小会不断增加。
文件大小的上限为原始VM的镜像文件的配置上限（例如10G，20G），也同VM的操作系统启动后看到的硬盘的实际大小相一致。
由于ZStack默认不支持资源超分（超卖），所以ZStack在计算空间的时候，会按照VM使用空间的上限来扣除可用空间的数量。
于是用户在系统上用df命令看到的可用空间可能还有很大，但是ZStack已经把VM未来可能会占用的所有空间都已经计算在内了。
于是，就会导致用户可能看到硬盘上还有很多空间，但是不能创建虚拟机的错误。

关于资源超分的支持，请联系ZStack社区获取帮助。

---

<h2 id='q13'> Q13. 计算节点是内网IP，如何通过管理节点上的公网IP连接虚拟机的console </h2>

用户需要进行如下设置：

`zstack-ctl configure consoleProxyOverriddenIp=MANAGEMENT_NODE_PUBLIC_IP_ADDRESS`

并重启zstack：

`zstack-ctl stop_node`

`zstack-ctl start_node`

---

<h2 id='q14'> Q14. 修改 zstack-dashboard 默认的5000端口</h2>

例如要修改端口号为5888，让dashboard的访问URL变为 http://本地IP地址:5888
vim /var/lib/zstack/virtualenv/zstack-dashboard/lib/python2.7/site-packages/zstack_dashboard/web.py

修改：
app.run(host="0.0.0.0", port="5888", threaded=True)

---

<h2 id='q15'> Q15. 管理节点上有多个IP地址，如何让ZStck启动在某个非default路由的IP地址上？</h2>

先用下面的命令设置管理节点的ip地址：
`zstack-ctl configure management.server.ip=YOUR_EXPECTED_IP_ADDRESS`

然后重启zstack即可：
`zstack-ctl stop_node; zstack-ctl start_node`

---
<h2 id='q16'> Q16. 增加ZStack UI用户和zstack-cli的session过期时间</h2>

在zstack-dashboard界面Global Configure下找到 session 对应的timeout设置,双击设置可以更高过期时间

也可以通过zstack-cli的命令修改,例如下例会把zstack account登陆的过期时间改成200个小时:

zstack-cli LogInByAccount accountName=admin password=password
zstack-cli UpdateGlobalConfig name=session.timeout category=identity value=720000
zstack-cli LogOut

---
<h2 id='q17'> Q17. 从IP Range中保留一个IP地址,不让ZStack分配给云主机</h2>

目前ZStack还没有提供 ReserverIpRange的API,如果我们希望ZStack从已经设置的IP Range中保留几个特定的
IP地址,我们可以用CreateVip这个API.

例如下面的命令将会把a.b.c.d的IP地址从指定的L3 网络上用创建VIP的方法保留住.
zstack-cli LogInByAccount accountName=admin password=password
zstack-cli CreateVip l3NetworkUuid=YOU_L3_NETWORK_UUID name=for_reserver requiredIp=a.b.c.d
zstack-cli LogOut

---
<h2 id='q18'> Q18. 如何批量修改一批云主机的计算规格</h2>
在本例里,我们将会使用shell脚本配合zstack-cli命令来把一批名字里包含Win7的云主机的计算规格全部修改为
名字是Win7-Instance-Offering的计算规格.

which jq || (echo "you need to install jq" && exit 1)

zstack-cli LogInByAccount accountName=admin password=password
instance_offering_uuid=`zstack-cli QueryInstanceOffering name=Win7-Instance-Offering |jq '.["inventories"][0].uuid'`
target_vms=`zstack-cli zstack-cli QueryVmInstance name~=Win7|jq '.["inventories"][].uuid'`
for vm in $target_vms; do
    zstack-cli ChangeInstanceOffering instanceOfferingUuid=$instance_offering_uuid vmInstanceUuid=$vm
    echo "change vm: $vm instance offering to $instance_offering_uuid"
    zstack-cli StopVmInstance uuid=$vm
    zstack-cli StartVmInstance uuid=$vm
done
zstack-cli LogOut

---
<h2 id='q19'> Q19. 如何解决qemu版本不匹配问题</h2>

在使用过程中，启动虚拟机时，可能遇到类似的错误信息uses a qcow2 feature which is not supported by this qemu version: QCOW version 3

主要原因：QCOW 版本不一致，原始的qcow2创建版本使用的qemu-img为较新版本，现在创建时使用的为较旧版本，旧版本的不支持新版本的。

解决办法：在拥有较新版本的qemu-img里面进行兼容性转换，例如执行以下命令进行转换，转换完毕后，再重新添加镜像

qemu-img  convert -o compat=0.10 -f qcow2 -O qcow2 centos6-cloud-init.qcow2  centos-st-ssh-key.qcow2

---
<h2 id='q20'> Q20. 如何释放Flat Network Service Provider 占用的IP</h2>

Flat Network Service Provider 因为提供DHCP服务,所以会占用一个IP地址.
当用户不想使用该服务的时候,可以删除对应L3 network.
但是该provider所占用的IP地址并不会被主动释放.用户可以用下面的方法回收该IP地址,并消除对应的影响.

在所有的物理节点上执行:
1. ip netns
2. 然后对所有输出的namespace 执行 ip netns delete xxxx, xxxx是步骤一输出的对应的namespace
3. 执行 ebtables -F
4. pkill dnsmasq, 把所有DHCP server 杀死

---
