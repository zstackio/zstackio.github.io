---
title: ZStack Multi-node Installation
layout: installationPage
---

# Multi-node Installation

For users wanting to build a scaled out and high available production environment, ths recommended way is to 
install 2 ZStack management nodes, MySQL, and RabbitMQ on separate machines:

<img src="../images/multi-node-install.png" class="center-img img-responsive">

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
      <p>ZStack OS</p>
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

### 1. Install ZStack Management Node 1

<div class="bs-callout bs-callout-success">
  <h4 class="hand" data-toggle="collapse" data-target="#china">The Introduction of ZStack OS</h4>
      <ul>
        <li>ZStack OS is customized from CentOS 7.2, including required system libs, with friendly Terminal UI (TUI) and well tested by hundreds of cloud users.</li>
        <li>ZStack OS ISO includes all ZStack required components. So installing ZStack OS does not need Internet connection. </li>
        <li>Provide four installation modes: Enterprise management node mode, community management node mode, computing node mode, expert mode. </li>
      </ul>
      
      <h4 style="margin-bottom:15px">The Introduction of Four <i>Installation Modes</i>:</h4>
  
      <table class="table table-striped table-bordered">
        <tr>
          <td><b>ZStack Enterprise management node</b></td>
          <td>Install ZStack OS and ZStack Enterprise Management Node, which includes full Enterprise features (like VM HA, QoS, VM password resetting ...) with 1 free computing node license.</td>
        </tr>
        <tr>
          <td><b>ZStack Community Management Node</b></td>
          <td>Install ZStack OS and ZStack Community Management Node, which could add unlimited computing nodes.</td>
        </tr>
        <tr>
          <td><b>ZStack Computing Node</b></td>
          <td>Install ZStack OS and the computing node essential packages.</td>
        </tr>
        <tr>
          <td><b>ZStack Expert Node</b></td>
          <td>Install ZStack OS and config the local yum. This is for advanced usage, e.g. installing multiple ZStack Management Nodes.</td>
        </tr>
      </table>
  </div>
</div>

#### Install ZStack Management Node

<div class="bs-callout bs-callout-warning">
  <h4>Download ZStack iso</h4>
  ZStack user should download the ZStack OS {{site.zstack_iso_name}} and ZStack-installer package {{site.all_in_one_en_name}}.<br>
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
  
If you want to use multi-node Installation, please choose `ZStack Expert Mode`.

<img src="../images/install-manual3.PNG" class="center-img img-responsive">

<div class="bs-callout bs-callout-success">
Please be patient, the installation will cost a moment. You can click the <i>root password</i> to set the password.<br>
Depending on the hardware performance, the process may take 5 ~ 15 minutes.
</div>

#### Use *wget*:

    After ZStack OS expert mode is installed, please login System and do:

    wget {{site.all_in_one_en}}
    
    bash {{site.all_in_one_en_name}} -i

<div class="bs-callout bs-callout-info">
  <h4>Install ZStack with -i parameter</h4> 
  Mysql and RabbitMQ aren't installed, and only the management node is installed, after adding the -i parameter. 
</div>

Once you successfully installed the node, configure the IP into zstack.properties:

    zstack-ctl configure management.server.ip=ip_of_management_node1

    Example: zstack-ctl configure management.server.ip=10.89.13.57

    zstack-ctl save_config

### 2. Install MySQL

You can use ZStack control tool `zstack-ctl`, which is automatically installed along with ZStack in step 1. To install
MySQL.

    sudo zstack-ctl install_db --host=ip_of_machine_to_install_mysql
    
    Example: sudo zstack-ctl install_db --host=192.168.0.225

`zstack-ctl` leverages [Ansible](http://www.ansible.com/home) to do the installation; it will ask you for SSH root password
if the SSH key is not set on the remote machine.

### 3. Install RabbitMQ

As step 2, you can use `zstack-ctl` to install RabbitMQ too:

    sudo zstack-ctl install_rabbitmq --host=ip_of_machine_to_install_rabbitmq
    
    Example: sudo zstack-ctl install_rabbitmq --host=192.168.0.225

Once you successfully installed RabbitMQ, you need to create credentials for remote access:

    rabbitmqctl add_user username password

    Example: rabbitmqctl add_user zstack zstack123

    rabbitmqctl set_user_tags username administrator

    Example: rabbitmqctl set_user_tags zstack administrator

    rabbitmqctl change_password username password

    Example: rabbitmqctl change_password zstack zstack123

    rabbitmqctl set_permissions -p / username ".*" ".*" ".*"

    Example: rabbitmqctl set_permissions -p / zstack ".*" ".*" ".*"

Now you need to configure above RabbitMQ credentials to zstack.properties:

    zstack-ctl configure CloudBus.rabbitmqUsername=rabbitmq_username

    Example: zstack-ctl configure CloudBus.rabbitmqUsername=zstack

    zstack-ctl configure CloudBus.rabbitmqPassword=rabbitmq_password

    Example: zstack-ctl configure CloudBus.rabbitmqPassword=zstack123

    zstack-ctl save_config

### 4. Install ZStack Management Node 2

On the management node 1, you can use `zstack-ctl` to install extra management nodes:

    sudo zstack-ctl install_management_node --host=ip_of_machine_to_install_node_2
    
    Example: sudo zstack-ctl install_management_node --host=192.168.0.225

Once you successfully installed the node, configure the IP into zstack.properties:

    zstack-ctl configure management.server.ip=ip_of_management_node2

    Example: zstack-ctl configure management.server.ip=10.89.13.57

    zstack-ctl save_config

you can repeat this step to install more nodes if needed.
    
### 5. Install Web UI

On the management node 1, you can use `zstack-ctl` to install web UI:

#### 5.1 Install to local

    sudo zstack-ctl install_ui
    
#### 5.2 Install to separate machine

    sudo zstack-ctl install_ui --host=ip_of_machine_to_install_ui
    
    Example: sudo zstack-ctl install_ui --host=192.168.0.225

    
<div class="bs-callout bs-callout-info">
  <h4>Default Credential</h4>
  
  The default credential for UI login is admin/password.
</div>
    
Now your multi-node ZStack environment is successfully installed, visit [Getting Started With Multi-node Installation](../documentation/getstart-multi.html) see how to configure and run ZStack.

