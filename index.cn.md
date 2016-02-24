---
title: ZStack 项目首页
layout: homePage.cn
---
<div class="home-slogan-background">
  <div class="homepage-intro">
    <div class="container">
      <div class="row">
        <div class="col-xs-10 col-xs-offset-1" style="padding-top: 50px">
            <h1 class="homepage-slogan">ZStack是你一直在寻找的IaaS</h1>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1" style="padding-top: 10px">
        <h1>什么是ZStack</h1>
        <p>
          ZStack是下一代开源的云计算IaaS（基础架构即服务）软件。它主要面向的是未来的智能数据中心，
          通过提供全完善的APIs来管理包括计算、存储和网络在内的数据中心的各种资源。
          用户可以基于ZStack构建自己的智能数据中心，也可以在稳定的ZStack之上搭建灵活的云应用场景，
          例如VDI（虚拟桌面基础架构），PaaS（平台即服务），SaaS（软件即服务）等等。
          只需要5分钟，用户就可以在一台Linux机器上轻松完成下载和安装ZStack云环境。
          跟着ZStack的用户教程，只需要30分钟就可以部署一个简单的云计算环境，完成云主机的创建。
        </p>
      </div>
    </div>
  </div>
</div>


<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1" style="padding-top: 10px">
        <h3><i class="fa fa-sitemap">&nbsp; 弹性计算</i></h3>
        <p>单ZStack管理节点即可胜任管理<b>数十万的</b>物理服务器和<b>数百万的</b>虚拟云主机。
          单ZStack管理节点可以轻松处理<b>数万条</b> 并发的API请求</p>

        <p>ZStack弹性计算的奥秘:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/asynchronous-architecture.html">ZStack's Scalability Secrets Part 1: Asynchronous Architecture (英文)</a></li>
            <li><a href="blog/stateless-clustering.html">ZStack's Scalability Secrets Part 2: Stateless Services (英文)</a></li>
            <li><a href="blog/lock-free.html">ZStack's Scalability Secrets Part 3: Lock-free Architecture (英文)</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-bolt">&nbsp; 闪电性能</i></h3>
        <p>各种云操作在ZStack之中都具有<b>急速性能</b>, 看看下表中关于ZStack并发创建虚拟机的性能指标吧。一万个云主机，创建只需要23分钟。
        <table class="table table-bordered home-table" style="margin-bottom: 0;">
          <tr>
            <th>云主机数量</td>
            <th>总耗时&nbsp;&nbsp;
                <i class='fa fa-info-circle' style='cursor:help' title="受限于测试硬件，本数据是在一个普通的PC台式机上，采用混合的嵌套虚拟化技术，利用仿真虚拟机采集的。整个测试采用了100个并发的线程来创建虚拟机。如果在一个高性能的物理机集群中测试，我们有100%的信心去拿到更好的结果。"></i>
            </td>
          </tr>
          <tr>
            <td>1</td>
            <td>0.51 秒</td>
          </tr>
          <tr>
            <td>10</td>
            <td>1.55 秒</td>
          </tr>
          <tr>
            <td>100</td>
            <td>11.33 秒</td>
          </tr>
          <tr>
            <td>1000</td>
            <td>103 秒</td>
          </tr>
          <tr>
            <td>10000</td>
            <td>23 分钟</td>
          </tr>
        </table>
      </div>
    </div>
 </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">

      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-share-alt">&nbsp; 网络功能虚拟化 NFV</i></h3>
        <p>
          作为云产品，网络功能必不可少。ZStack提供了非常完善的<b>网络功能虚拟化 NFV(network functions virtualization)</b>。
          通过一个虚拟应用的虚拟机，它提供给每一个租户一个专属的网络环境。整个网络模型都是自包含和自管理的。
          网络管理员无需购买额外的硬件就可以提供完善的网络服务（例如DHCP，DNS，SNAT，EIP，Port Forwarding，Security Group等等）。
        </p>
        <p>详细的ZStack网络能力:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/network-l2.html">Networking Model 1: L2 and L3 Network (英文)</a></li>
            <li><a href="blog/virtual-router.html">Networking Model 2: Virtual Router Network Service Provider (英文)</a></li>
          </ul>
        </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">

      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-search">&nbsp; 包罗万象的查询APIs</i></h3>
        <p>
           IaaS管理了海量的基层硬件信息和云主机信息，能否有效的获取各种资源的信息决定了IaaS是否是用户友好的系统。ZStack提供了超过<b>4,000,000</b>种单项查询条件（如果进行条件组合，那就是不计其数了）来获取IaaS里各种资源和信息。
           用户无需手动添加任何的ad-hoc脚本，也无需手动查询数据库。获取信息的方式就是调用ZStack的查询APIs。
        <pre id="pre-code"><code>>> QueryVmInstance vmNics.eip.guestIp=16.16.16.16 zone.name=west-coast</code></pre>
        <pre id="pre-code"><code>>> QueryHost fields=name,uuid,managementIp hypervisorType=KVM vmInstance.allVolumes.size>=549755813888000 vmInstance.state=Running start=0 limit=10</code></pre>
        <p>详细的API介绍:</p>
          <div class="home-links">
            <ul>
              <li><a href="blog/query.html">The Query API</a></li>
            </ul>
          </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-leaf">&nbsp; 一键安装、无缝升级 </i></h3>

        <p>
          ZStack安装和升级其实就好比拷贝和复制一个Java的WAR文件一样的简单。一个ZStack的POC演示环境，
          可以用一个安装程序在<b>5分钟</b>内搞定；一个多节点的生产环境的搭建也可以在<b>30分钟</b>内完成
          <i class='fa fa-info-circle' style='cursor:help' title="因为ZStack的安装程序会从互联网上下载安装系统需要的资源，如果您的网络环境稍慢，实际的安装时间可能会略长。另外我们提醒国内的用户提前配置自己的yum或者apt的镜像地址，这样可以节省大量的安装时间。"></i>
          升级时，用户只需要升级一个或者两个管理节点，所有的节点都会随之自动无缝升级。升级管理节点的操作简单到运行几条升级命令即可。
        </p>

        <pre id="pre-code"><code>[root@localhost ~]# curl {{site.all_in_one_ch}} |  bash -s -- -a</code></pre>
        <p>详细的安装手册：</p>
          <div class="home-links">
            <ul>
              <li><a href="installation/index.html">快速安装手册</a></li>
              <li><a href="installation/manual.html">手动安装手册</a></li>
              <li><a href="installation/multi-node.html">多节点安装手册</a></li>
            </ul>
          </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-wrench">&nbsp; 全自动部署和配置</i></h3>
        <p>
          <b>一切都是由APIs来管理</b>。用户无需手动的去编辑各种各样复杂的配置文件。绝大部分配置都是透明而无缝的。
          ZStack利用<a href="http://www.ansible.com/home"><b>Ansible</b></a>库实现全自动的部署和升级，
          把用户从管理海量服务器硬件的功能中解放出来。
        </p>
        <p>ZStack全自动的奥秘:</p>
          <div class="home-links">
            <ul>
              <li><a href="blog/ansible.html">Full Automation By Ansible (英文)</a></li>
            </ul>
          </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-random">&nbsp; VERSATILE PLUGIN SYSTEM</i></h3>
        <p>
          云世界瞬息万变，功能叠出。想要拥抱未来的功能，灵活稳定的扩展能力必必可少。ZStack的整个核心架构
          都是基于类似于<a href="https://eclipse.org/">Eclipse</a>和
          <a href="http://www.osgi.org/Main/HomePage">OSGI</a>一样的<b>插件系统</b> ，所有的模块都是以插件的形式存在。
          辅以创新的系统标签能力，可以让ZStack在添加新功能时真正的做到无需修改核心代码，以保证核心代码的稳定高效。
        </p>

        <p>ZStack创新插件系统的奥秘:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/microservices.html">The In-Process Microservices Architecture (英文)</a></li>
            <li><a href="blog/plugin.html">The Versatile Plugin System (英文)</a></li>
            <li><a href="blog/workflow.html">The Workflow Engine (英文)</a></li>
            <li><a href="blog/tag.html">The Tag System (英文)</a></li>
            <li><a href="blog/cascade.html">The Cascade Framework (英文)</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-cubes">&nbsp; 严格的测试系统</i></h3>
        <p>
          <b>三级全自动的测试系统</b>严格测试每一个功能，确保ZStack的核心代码像CPU一样的安全可靠。
        </p>

        <p>ZStack自动化测试的奥秘:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/integration-testing.html">The Automation Testing System 1: Integration Testing (英文)</a></li>
            <li><a href="blog/system-testing.html">The Automation Testing System 2: System Testing (英文)</a></li>
            <li><a href="blog/model-based-testing.html">The Automation Testing System 3: Model-based Testing (英文)</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
