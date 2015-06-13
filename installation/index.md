---
title: ZStack Download
layout: installationPage
---

<h1 id="quickInstallation">Quick Installation</h1>

For people wanting to try out ZStack quickly, the best way is to install all software including KVM on a single machine so
you can build your first cloud with only one machine. Because of this, we recommend below hardware specification:

<table class="table table-striped table-bordered">
  <tr>
    <td><b>CPU</b></td>
    <td>>= 4 Cores Intel/AMD CPUs supporting VT-x or SVM</td>
  </tr>
  <tr>
    <td><b>Memory</b></td>
    <td>>= 8G</td>
  </tr>
  <tr>
    <td><b>Free Disk</b></td>
    <td>>= 250G</td>
  </tr>
  <tr>
    <td><b>OS</b></td>
    <td>
      <p>CentOS6.x/CentOS7/Ubuntu14.04</p>
      <div class="bs-callout bs-callout-info">
        <h4>We have tested those OS</h4>
        Those OS have been tested while other Linux OS should work as well.
        We recommend you to use a fresh installed OS, to avoid unnecessary software conflicts. 
      </div>
    </td>
  </tr>
</table>

<div class="bs-callout bs-callout-success">
  <h4 class="hand" data-toggle="collapse" data-target="#china">Fast link for users of Mainland China (国内用户请点击展开)</h4>
  <div id="china" class="collapse">
      国内用户在访问我们美国服务器以及<a href="https://pypi.python.org/pypi">Pypi</a>网站时速度较慢，请使用以下链接：
      
      <h4 style="margin-bottom:15px; margin-top:15px">Use <i>curl</i>:</h4>
      <pre><code>curl -L http://download.zstack.org/install.sh -o install-zstack.sh
sudo bash install-zstack.sh -a -R https://pypi.mirrors.ustc.edu.cn/simple -f http://7xi3lj.com1.z0.glb.clouddn.com/zstack-all-in-one-0.6.2.tgz</code></pre>
      
      <h4 style="margin-bottom:15px">Use <i>wget</i>:</h4>
      <pre><code>wget -O install-zstack.sh http://download.zstack.org/install.sh
sudo bash install-zstack.sh -a -R https://pypi.mirrors.ustc.edu.cn/simple -f http://7xi3lj.com1.z0.glb.clouddn.com/zstack-all-in-one-0.6.2.tgz</code></pre>
      
      在安装的过程中，脚本会从Linux发行商的repo里面安装需要的包。国内访问例如CentOS/RedHat/Ubuntu的repo通常会比较慢，如果你有常用的镜像repo，在执行脚本前
      先设置好镜像repo可以大大加快安装速度。
      
      
      <div class="bs-callout bs-callout-danger">
        <h4>注意DNS劫持</h4>
        
        由于国内所有不能解析的域名都会被送到某DNS解析，造成在安装系统时随意设置的hostname也会被解析成IP，但该IP并不代表你本机。这会造成RabbitMQ在启动时出错，
        并可能导致登录MySQL时出错。我们的安装脚本会在安装时检测DNS劫持，如果发现错误解析的hostname会报错并停止安装。我们建议国内用户在安装前先检查你的hostname:
        
        <pre><code>ping `hostname`</code></pre>
        
        如果可以解析，但看到的IP不是127.x.x.x或者不是本机IP，则可能是DNS劫持，可以执行以下命令将hostname映射至本机：
        
        <pre><code>sudo echo "127.0.1.1 `hostname`" >> /etc/hosts</code></pre>
      </div>
  </div>
</div>

#### Use *curl*:

    curl -L http://download.zstack.org/install.sh -o install-zstack.sh
    sudo bash install-zstack.sh -a
    
#### Use *wget*:

    wget -O install-zstack.sh http://download.zstack.org/install.sh 
    sudo bash install-zstack.sh -a

    
<div class="bs-callout bs-callout-warning">
  <h4>Please be patient, the installation will install all software needed</h4>
  The installation script will install and configure your system no matter it's a minimal or a regular Linux distribution.
  Depending on the completeness of the distribution and the networking speed, the process may take 5 ~ 15 minutes. 
</div>


    
The script will install the machine with:

* Apache Tomcat 7 with zstack.war deployed
* ZStack web UI
* ZStack command line tool (zstack-cli)
* ZStack control tool (zstack-ctl)
* MySQL
* RabbitMQ server
* NFS server
* Apache HTTP server

<div class="bs-callout bs-callout-info">
  <h4>Default Credential</h4>
  
  The default credential for UI login is admin/password.
</div>

Now your ZStack is successfully installed, visit [Getting started with quick installation](../documentation/getstart-quick.html) see how to access web UI and command line tool.
