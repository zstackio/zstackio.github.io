---
layout: post.cn
title:  "给ZStack添加SPice协议的支持（一）"
date:   2016-1-10
categories: blog
author: Nan Su 
category: cn_blog
---
## 前言
读研时方向选定云计算虚拟化，之前一直在摸索学习各种IaaS软件，因老板项目需要找一款合适的开源软件做私有云，无奈实力所限OpenStack这样重量级的实在玩不动。在CloudStack群里有大牛推荐用ZStack简单好用，遂依照 http://ZStack.org/cn/installation/上的一键安装来安装 ZStack, 我这样的小白用all in one和扁平网络的方式，一个小时居然能跑起了VM，兴奋不已。

后来老板要做VDI，了解相关信息之后发现可用的开源协议只有SPICE了，于是很自然的将Zstack和SPCIE结合起来。有朋友可能会问zs自身的conslo就有VNC啊，也可以接虚拟机图像。但是VNC主要用于linux的服务器的管理，由于无声音和usb传输，不满足于虚拟桌面的使用。而SPICE几乎全面超过VNC，尤其在图像质量和重定向这两部分，几乎是开源的不二选择。
#实践操作
桌面虚拟化与服务器虚拟化的本质区别就是在协议优化，当然这里只讲怎么连上去。Zstack本身拥有VNC协议的Console，SPICE-client连接到VM的方式与VNC相同——都是通过套接字识别VM。在询问群主意见后，决定加一个开关ConsoleMode让其能在SPICE和VNC间自由切换。那么问题来了，具体怎么做呢？

正好看到ZStack开发分享http://zstack.org/cn_blog/add-qemu-mode-to-zstack.html，作为一只小白，照葫芦画瓢的事情当然最好不过了。思路立马清晰了：1. 新增一个全局的变量叫 ConsoleMode（Java编写） 2. 将此新的全局变量传给 ZStack-utility 里的 agent (Python 编写的) 3. 在 Python编写的 agent 里, 依照此全局变量的值做出对应的设置（哈哈，写到这里我自己都笑了）。
##步骤一
首先修改 ZStack 的部分, 在 conf/globalConfig/kvm.xml新增一个element
<img src="/images/blogs/spice/1.jpg" class="center-img img-responsive">

    <config>
         <category>kvm</category>
         <name>consoleMode</name>
       <description>You can choose a transport protocol for consolemode,when set to spice, enable the spice protocol connection virtual machine.options:[vnc,spice]</description>
         <type>java.lang.String</type>
         <defaultValue>vnc</defaultValue>
    </config>

在 plugin/kvm/src/main/java/org/zstack/kvm/KVMGlobalConfig.java 新增全局的变量
<img src="/images/blogs/spice/2.jpg" class="center-img img-responsive">
  
    @GlobalConfigValidation(validValues = {"vnc","spice"})
    public static GlobalConfig VM_CONSOLE_MODE = new GlobalConfi(CATEGORY, "consoleMode");

 到此基本上已经在 Web UI 的 Global Configure 新增一个配置 ConsoleMode (见下图)，等到我们修改完成后，将该值从vnc修改为spice即可（默认为vnc）。注意：如果已经running的VM需要重启，才会生效。
<img src="/images/blogs/spice/3.jpg" class="center-img img-responsive">

##步骤二
修改 ZStack 的部分, 在plugin/kvm/src/main/java/org/zstack/kvm/KVMAgentCommands.java 中 public static class StartVmCmd 中新增私有的变量及公有的方法
<img src="/images/blogs/spice/4.jpg" class="center-img img-responsive">

    private String consoleMode;

    public String getConsoleMode() {
             return consoleMode;
         }
         public void setConsoleMode(String consoleMode) {
             this.consoleMode = consoleMode;
         }
接著修改 plugin/kvm/src/main/java/org/zstack/kvm/KVMHost.java 在 startVm 方法里透过 VolumeTO 类新增的方法将新增的 Global Config 配置传给 zstack-utility agent
<img src="/images/blogs/spice/6.jpg" class="center-img img-responsive">
##步骤三
最后我们还要修改 zstack-utility agent在收到我们新增的全局配置后做出对应的修改 kvmagent/kvmagent/plugins/vm_plugin.py
<img src="/images/blogs/spice/5.jpg" class="center-img img-responsive">

    def get_console_port(self)
    if (g.type_ =='vnc')or(g.type_=='spice'):

    def make_console():
    if cmd.consoleMode == 'spice':
                make_spice()
            else:
                make_vnc()
                 
    def make_spice():
            devices = elements['devices']
            spice = e(devices, 'graphics', None, {'type':'spice', 'port':'5900', 'autoport':'yes'})
            e(spice, "listen", None, {'type':'address', 'address':'0.0.0.0'})
##步骤四
依照官方说明的方法来编译ZStack All In One 安装包http://zstack.org/cn_blog/build-zstack.html

#总结
限于本人能力所限，只是加了个切换协议开关，如果想在web上直接显示SPICE链接的远程桌面，还需要添加web-spice-client的代码。所以想体验的同学暂时还需要使用官方的virt-viewer软件才能连接哦，附效果图一张~最后严重感谢惯C哥的帮助^_^
<img src="/images/blogs/spice/7.jpg" class="center-img img-responsive">
