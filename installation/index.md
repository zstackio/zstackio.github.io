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
      <p>CentOS 7.2+</p>
    </td>
  </tr>
</table>

<div class="bs-callout bs-callout-success">
  <h4 class="hand" data-toggle="collapse" data-target="#china">Fast link for users of Mainland China (国内用户请点击展开)</h4>
  <div id="china" class="collapse">
      国内用户在访问我们美国服务器速度较慢，请使用以下链接：
      
      <h4 style="margin-bottom:15px; margin-top:15px">Use <i>curl</i>:</h4>
      <pre><code>curl -L {{site.all_in_one_ch}} -o zstack-installer.bin
sudo bash zstack-installer.bin -o</code></pre>
      
      <h4 style="margin-bottom:15px">Use <i>wget</i>:</h4>
      <pre><code>wget -O zstack-installer.bin {{site.all_in_one_ch}}
sudo bash zstack-installer.bin -o</code></pre>
      
      
      
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

    curl -L {{site.all_in_one_en}} -o zstack-installer.bin
    sudo bash zstack-installer.bin -o
    
#### Use *wget*:

    wget -O zstack-installer.bin {{site.all_in_one_en}}
    sudo bash zstack-installer.bin -o
    
The md5sum of ztack-installer.bin is:

{{site.all_in_one_md5}}

<div class="bs-callout bs-callout-warning">
  <h4>Please be patient, the installation will install all software needed</h4>
  The installation script will install and configure your system no matter it's a minimal or a regular Linux distribution.
  Depending on the completeness of the distribution and the networking speed, the process may take 5 ~ 15 minutes. 
</div>

    
The script will install in machine with:

* Apache Tomcat 7 with zstack.war deployed
* ZStack web UI
* ZStack command line tool (zstack-cli)
* ZStack control tool (zstack-ctl)
* MySQL(will set MySQL root password, if it is empty.)
* RabbitMQ server
* NFS server
* Apache HTTP server

<div class="bs-callout bs-callout-warning">
  <h4>MySQL is installed and root password is set</h4>
  User could install MySQL before installing ZStack. If MySQL root user password is set, please send the password
to zstack-installer by parameter: '-P MYSQL_ROOT_PASSWORD', e.g.:

    `sudo bash zstack-installer.bin -a -P MYSQL_ROOT_PASSWORD`

</div>

<div class="bs-callout bs-callout-info">
  <h4>Default Credential</h4>
  
  The default credential for UI login is admin/password.
</div>

Now your ZStack is successfully installed, visit [Getting started with quick installation](../documentation/getstart-quick.html) see how to access web UI and command line tool.
