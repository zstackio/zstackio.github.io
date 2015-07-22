---
title: ZStack 一键安装
layout: installationPage.cn
---

<h1 id="quickInstallation">一键安装</h1>

对于新用户来说，ZStack提供的一键安装可以把IaaS云环境快速部署到一个Linux主机上。

我们推荐您的硬件环境最好能有如下配置(虽然可以在一个打开了 nested virtualization 的虚拟机中来安装ZStack，但是特殊的nested virtualization配置以及受限的虚拟机资源会降低你的试用体验过程)：

<table class="table table-striped table-bordered">
  <tr>
    <td><b>CPU</b></td>
    <td>>= 4 核支持VT-x或者SVM的 Intel/AMD CPUs</td>
  </tr>
  <tr>
    <td><b>物理内存</b></td>
    <td>>= 8G</td>
  </tr>
  <tr>
    <td><b>磁盘剩余空间</b></td>
    <td>>= 250G</td>
  </tr>
  <tr>
    <td><b>操作系统</b></td>
    <td>
      <p>CentOS6.x/CentOS7/Ubuntu14.04</p>
      <div class="bs-callout bs-callout-info">
        <h4>这是我们测试过的系统</h4>
        虽然我们测试了这三个操作系统，但是从理论上来说其他支持KVM的Linux操作系统也应该可以工作。
        另外为了避免不必要的软件冲突，我们推荐您在一个全新安装的系统中安装ZStack。
      </div>
    </td>
  </tr>
</table>

<div class="bs-callout bs-callout-info">
  <h4>配置root用户的ssh登录能力</h4>
  管理节点需要root用户的SSH权限来调用Ansible安装系统包和consoleproxy。您需要提前配置root用户的SSH访问能力。
  
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

<div class="bs-callout bs-callout-warning">
<h4>注意配置YUM或者APT的镜像</h4>
在安装的过程中，脚本会从Linux发行商的repo里面安装需要的包。国内访问例如CentOS/RedHat/Ubuntu的repo通常会比较慢，如果你有常用的镜像repo，在执行脚本前
先设置好镜像repo可以大大加快安装速度。
</div>
      
由于国内用户在访问我们美国服务器速度较慢，请使用以下链接：
      
<h4 style="margin-bottom:15px; margin-top:15px">Use <i>curl</i>:</h4>
<pre><code>curl -L http://download.zstack.org/releases/0.7/zstack-install-0.7.1.sh -o install-zstack.sh
sudo bash install-zstack.sh -a -f http://7xi3lj.com1.z0.glb.clouddn.com/releases/0.7/zstack-all-in-one-0.7.1.tgz</code></pre>
      
<h4 style="margin-bottom:15px">Use <i>wget</i>:</h4>
<pre><code>wget -O install-zstack.sh http://download.zstack.org/releases/0.7/zstack-install-0.7.1.sh
sudo bash install-zstack.sh -a -f http://7xi3lj.com1.z0.glb.clouddn.com/releases/0.7/zstack-all-in-one-0.7.1.tgz</code></pre>
      
<div class="bs-callout bs-callout-danger">
<h4>注意DNS劫持</h4>
        
        由于国内所有不能解析的域名都会被送到某DNS解析，造成在安装系统时随意设置的hostname也会被解析成IP，但该IP并不代表你本机。这会造成RabbitMQ在启动时出错，
        并可能导致登录MySQL时出错。我们的安装脚本会在安装时检测DNS劫持，如果发现错误解析的hostname会报错并停止安装。我们建议国内用户在安装前先检查你的hostname:
        
        <pre><code>ping `hostname`</code></pre>
        
        如果可以解析，但看到的IP不是127.x.x.x或者不是本机IP，则可能是DNS劫持，可以执行以下命令将hostname映射至本机：
        
        <pre><code>sudo echo "127.0.1.1 `hostname`" >> /etc/hosts</code></pre>
      </div>

<div class="bs-callout bs-callout-warning">
  <h4>请您耐心等待一会，安装程序会帮您安装所需要的所有软件</h4> 
  不论您之前的操作系统采用的是最小安装还是完整安装，安装程序都会正确安装并配置你系统所需要的全部资源。
  取决与当前系统中已安装包的数量和网络连接速度，通常一次自动化安装过程会需要5～15分钟的时间。您可以在这段时间放松一下。
</div>


ZStack的安装程序会在您的系统中安装如下软件：    

* Apache Tomcat 7 以及 zstack.war
* ZStack web图形界面
* ZStack 命令行工具 zstack-cli
* ZStack 管控工具 zstack-ctl
* MySQL 数据库
* RabbitMQ server 消息总线
* NFS 服务器 （作为之后演示使用）
* Apache HTTP 服务器 （作为之后演示使用）

<div class="bs-callout bs-callout-info">
  <h4>默认的用户名和密码</h4>
  
  ZStack图形用户界面默认的用户名和密码是： admin/password.
</div>

现在你的第一个ZStack已经安装成功。请访问[快速使用ZStack](../documentation/getstart-quick.html) 来获取后续的ZStack图形界面和命令行的使用方法。
