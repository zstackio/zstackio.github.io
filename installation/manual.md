---
title: ZStack Installation
layout: installationPage
---

# Manual Installation

### 1. Install ZStack management node, MySQL and RabbitMQ on separate machines

For users wanting to setup a production ZStack environment, the recommended way is to install ZStack management node,
MySQL, and RabbitMQ message broker on separate machines:

<img src="../images/install-manual1.png" class="center-img img-responsive">

For machine to install ZStack management node, we recommend below hardware specification:

<table class="table table-striped table-bordered">
  <tr>
    <td><b>CPU</b></td>
    <td>>= 4 Cores Intel/AMD CPUs supporting VT-x or SVM</td>
  </tr>
  <tr>
    <td><b>Memory</b></td>
    <td>
    <p>>= 8G</p>
    </td>
  </tr>
  <tr>
    <td><b>Free Disk</b></td>
    <td>
      <p>>= 250G</p>
    </td>
  </tr>
  <tr>
    <td><b>OS</b></td>
    <td>
      <p>ZStack customized ISO</p>
    </td>
  </tr>
</table>

For machines to install MySQL and RabbitMQ message broker, please refer to their official web sites.

<div class="bs-callout bs-callout-warning">
  <h4>Low disk capacity can cause RabbitMQ hang</h4>
  Please make sure your RabbitMQ machine has enough memory and free disk.
  When encountering low memory or disk capacity, RabbitMQ will enter <i>flow control mode</i> which will throttle
  message delivery and lead to slow or paused ZStack management node.
</div>

#### Installing ZStack must use the ZStack customized ISO

<div class="bs-callout bs-callout-info">
  <h4>The Introduction of ZStack customized ISO</h4>
    <ul>
      <li>Based on CentOS-7-x86_64-Minimal-1511.ISO, friendly TUI management support a variety of system configuration.</li>
      <li>Install ZStack don't need to connect to the external network and configure yum source, you can achieve to install ZStack offline.</li>
      <li>Provide four installation modes: Enterprise management node mode, community management node mode, computing node mode, expert mode. The user can choose according to the demand. </li>
      <li>Cancel the eth setting. Using the system default NIC naming rules. </li>
    </ul>
</div>

#### The Introduction of Four Installation Modes

<table class="table table-striped table-bordered">
  <tr>
    <td><b>ZStack Enterprise management node</b></td>
    <td>Install ZStack customized CentOS7.2 and ZStack Enterprise Management Node.</td>
  </tr>
  <tr>
    <td><b>ZStack Community Management Node</b></td>
    <td>Install ZStack customized CentOS7.2 and ZStack Community Management Node.</td>
  </tr>
  <tr>
    <td><b>ZStack Computer Node</b></td>
    <td>Install ZStack customized CentOS7.2 and the Compute Node essential package.</td>
  </tr>
  <tr>
    <td><b>ZStack Expert Node</b></td>
    <td>Install ZStack customized CentOS7.2 and config the local yum. The user can customize system applications.</td>
  </tr>
</table>

<div class="bs-callout bs-callout-info">
<h4>Burn ISO to USB:</h4>

In the hard drive list select the USB to burn.
</div>

#### 1.1 Install ZStack management node:
 
<div class="bs-callout bs-callout-warning">
  
  <h4>Download ZStack ISO</h4>
  
  ZStack user should download the ZStack customized ISO {{site.zstack_iso_name}} and ZStack-installer package {{site.all_in_one_en_name}}.<br>
  
  <h4>Download link :</h4>
    <ul>
      <li><b>ZStack ISO:</b>{{site.zstack_iso}}</li>
      <li><b>ZStack-installer package:</b>{{site.all_in_one_en}}</li>
    </ul>
    
    The md5sum of ZStack ISO is:{{site.zstack_iso_md5}}<br>
	The md5sum of ZStack-installer package is:{{site.all_in_one_md5}}<br>
</div>

#### System Installation

The system has been pre-configured default options: DATE & TIME for the East Asia Area, LANGUAGE is English, KEYBOARD is English (US).
The administrator can change the configuration.

<img src="../images/Quick_Installation1.png" class="center-img img-responsive">

#### Mode selection

If you use Manual Installation, please choose `ZStack Expert Mode`.

<img src="../images/install-manual3.png" class="center-img img-responsive">

<div class="bs-callout bs-callout-success">
  Please be patient, the installation will cost a moment. You can click the <i>root password</i> to set the password.<br>
  Depending on the completeness of the distribution and the networking speed, the process may take 15 ~ 20 minutes.
</div>

#### Use *wget*:

    wget {{site.all_in_one_en}} 
    
    bash {{site.all_in_one_en_name}} -i


<img src="../images/install-manual2.png" class="center-img img-responsive">

#### 1.2 Install MySQL

You can use ZStack control tool `zstack-ctl`, which is automatically installed along with ZStack in step 1.1, to install MySQL.

    sudo zstack-ctl install_db --host=ip_of_machine_to_install_mysql
    
    Example: sudo zstack-ctl install_db --host=192.168.0.224
    
`zstack-ctl` leverages [Ansible](http://www.ansible.com/home) to do the installation; it will ask you for SSH root password, if the SSH key is not set on the remote machine.

#### 1.3 Install RabbitMQ

You can use `zstack-ctl` to install RabbitMQ message broker:

    sudo zstack-ctl install_rabbitmq --host=ip_of_machine_to_install_mysql
    
    Example: sudo zstack-ctl install_rabbitmq --host=192.168.0.224
    
<div class="bs-callout bs-callout-info">
  <h4>The command will update zstack.properties</h4>
  After installing, <code>zstack-ctl</code> will automatically update IP of RabbitMQ to zstack.properties file.
</div>

#### 1.4 Install Web UI

You can use `zstack-ctl` to install web UI:

##### 1.4.1 Install to local

    sudo zstack-ctl install_ui
    
##### 1.4.2 Install to separate machine

    sudo zstack-ctl install_ui --host=ip_of_machine_to_install_ui
    
    Example: sudo zstack-ctl install_ui --host=192.168.0.224

Now your ZStack is successfully installed, visit [Getting Started With Manual Installation](../documentation/getstart-manual.html#manual) see how to configure and run ZStack. You can also use above steps to install all software on a single machine.

<div class="bs-callout bs-callout-info">
  <h4>Default Credential</h4>
  
  The default credential for UI login is admin/password.
</div>

<hr style="margin-bottom:50px">

### 2. Full-manual Install 

For curious users who want to install ZStack without help from any script/tool, as ZStack is a standard Java WAR file, you can follow below instructions.

<div class="bs-callout bs-callout-info">
  <h4>All below instructions use a single machine</h4>
  For the sake of demonstration, the instructions will install all software on a single machine.
</div>

#### Download ZStack ISO

ZStack user should download the ZStack customized ISO {{site.zstack_iso_name}}.<br>
 
<ul>
  <li><b>ZStack ISO:</b>{{site.zstack_iso}}</li>
  <li><b>The md5sum of ZStack ISO</b>:{{site.zstack_iso_md5}}</li>
</ul>

<div class="bs-callout bs-callout-info">
<h4>Burn ISO to USB:</h4>

In the hard drive list select the USB to burn.
</div>

##### 2.1. Install MySQL:

    sudo yum install mariadb mariadb-server
   
##### 2.2 Install RabbitMQ:

    sudo yum install rabbitmq-server

##### 2.3. Install Ansible:

    sudo easy_install pip
    pip install --upgrade pip
    yum install openssl-devel.x86_64
    sudo pip install ansible==1.9.6
    
> ***Note:** We specify Ansible version to 1.9.6 because it's the version we have tested. Later versions should work too.*

#### 2.4 Install Java:

ZStack requires JRE7 or later version.

    sudo yum install java-1.8.0-openjdk
    
#### 2.5. Install Tomcat:

As a standard Java WAR file, ZStack can be deployed in any Java web container; however, we recommend Tomcat because of its well-established
reputation. We recommend not to use the default Tomcat version shipped by Linux distributions, because they are usually old and contain modifications
that may cause troubles. You can download and install Tomcat from the official site by:

    wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.35/bin/apache-tomcat-7.0.35.tar.gz
    tar xzf apache-tomcat-7.0.35.tar.gz
    
<div class="bs-callout bs-callout-info">
  <h4>We have tested Tomcat 7.0.35</h4>
  We specify Tomcat version to 7.0.35 only because it's the version we have tested. Any later Tomcat version should work fine as
  well. You can download them from [Tomcat Download Page](http://tomcat.apache.org/download-70.cgi).
</div>
    
#### 2.6. Install ZStack WAR:

Assuming your Tomcat `$CATALINA_HOME` is */usr/local/apache-tomcat-7.0.35*, you can download and install ZStack by:

    cd /usr/local/apache-tomcat-7.0.35/webapps
    wget {{site.war_en}}
    yum install unzip
    unzip {{site.war_en_name}} -d zstack
    
**In following sections, we assume the `$CATALINA_HOME` is */usr/local/apache-tomcat-7.0.35/*.**
    
#### 2.7. Install Control Tool:

    sudo sh /usr/local/zstack/apache-tomcat-7.0.35/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-ctl
    
#### 2.8. Install Command Line Tool:

    sudo sh /usr/local/zstack/apache-tomcat-7.0.35/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-cli
    
#### 2.0. Install Web UI:

You can install ZStack web UI by:

    sudo sh /usr/local/zstack/apache-tomcat-7.0.35/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-ui

Now your ZStack environment is successfully installed, visit [Getting Started With Manual Installation](../documentation/getstart-manual.html#manual) see how to configure and run ZStack.
