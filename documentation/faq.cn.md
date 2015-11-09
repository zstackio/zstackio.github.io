---
title: ZStack FAQ
layout: tutorialDetailPage.cn 
sections:
  - id: q1
    title: Q1. 管理节点重启后，如何重新启动ZStack Management Node
  - id: q2
    title: Q2.管理节点IP地址变化了該怎麼辦?
  - id: q3
    title: Q3.如何更改UI的Admin密码?
  - id: q4
    title: Q4.如何手动启动ZStack管理节点
  - id: q5
    title: Q5.如何手动延长ZStack管理节点启动时间
  - id: q6
    title: Q6.手動ZStack UI管理界面
  - id: q7
    title: Q7.Vmware ESXi設定嵌套虚拟化的虚拟机
  - id: q8
    title: Q8.如何重新安装ZStack
  - id: q9
    title: Q9.VMWare的嵌套虚拟化的虚拟机里创建ZStack的VR VM失败
  - id: q10
    title: Q10.计算节点的IP是内网IP，管理节点IP有公网和内网，怎么通过管理节点连接VM的console
  - id: q11
    title: Q11.Windows VM 怎么设置使用VirtIO



---

<h2 id='q1'> Q1. 管理节点重启后，如何重新启动ZStack Management Node </h2>

管理节点重启后，用户只需要做三步：

1, ｀zstack-ctl start_node｀

2, ｀zstack-ctl start_ui｀

3, 进入UI界面 找到VirtualRouter 点击 action->start

---

<h2 id='q2'> Q2.管理节点IP地址变化了该怎么办? </h2>

到管理节点上运行｀zstack-ctl status｀ 就知道zstack.properties在哪個路徑。

编辑zstack.properties里所有老IP的IP地址，換成新IP地址。

修改完毕后，重启ZStack管理节点：

｀ zstack-ctl stop_node; zstack-ctl start_node｀

---

<h2 id='q3'>Q3.如何更改UI的Admin密码? </h2>

在管理节点上运行如下命令(如果password已經更改，請用改過的密碼替換password):

｀zstack-cli LogInByAccount accountName=admin password=password｀

然后运行如下命令（NEW_PASSWORD 就是新要使用的密码）：
｀zstacl-cli UpdateAccount uuid=36c27e8ff05c4780bf6d2fa65700f22e password=NEW_PASSWORD｀

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

<h2 id='q6'>Q6.手動ZStack UI管理界面</h2>

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

