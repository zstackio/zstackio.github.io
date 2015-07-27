---
title: ZStack多节点安装
layout: installationPage.cn
---

# 多节点安装

如果用户希望搭建一个高可用的产品级云环境，那么就需要部署至少两个ZStack管理节点，另外还需要单独配置高可用的MySQL和RabbitMQ。

<img src="../../images/multi-node-install.png" class="center-img img-responsive">

对于安装ZStack管理节点的机器，我们推荐使用如下硬件配置：

<table class="table table-striped table-bordered">
  <tr>
    <td><b>CPU</b></td>
    <td>>= 4 核支持VT-x或者SVM的 Intel/AMD CPUs</td>
  </tr>
  <tr>
    <td><b>物理内存</b></td>
    <td>
    <p>>= 4G</p>
   <div class="bs-callout bs-callout-info">
     <h4>物理内存的数量依赖于具体的云环境</h4>
     当提供10，000次并发API请求的时候，ZStack的Java进程可能会消耗大于4GB的内存空间。我们推荐
     您的物理机器最好有16GB以上的内存。如果用于演示环境的测试，您可以使用较少的内存。
   </div>
    </td>
  </tr>
  <tr>
    <td><b>磁盘剩余空间</b></td>
    <td>
      <p>>= 250G</p>
      <div class="bs-callout bs-callout-info">
        <h4>更少的磁盘剩余空间也行</h4>
        如果您需要把ZStack的日志监控等级调高到DEBUG或者TRACE，它将产生海量的日志信息。这些信息会在很短的时间内消耗几百GB的硬盘空间。
      </div>
    </td>
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

关于如何选择合适的硬件配置来安装MySQL和RabbitMQ服务，请您参考他们的官方网站。

<div class="bs-callout bs-callout-warning">
  <h4>过低的硬盘空间会导致 RabbitMQ 僵死</h4>
  请保证您的RabbitMQ服务器上有足够的内存和剩余空间。当内存或者剩余空间不足的时候，RabbitMQ会进入一种 <i>flow control mode</i>模式。
  这种模式会导致ZStack服务器变慢甚至中断服务。
</div>

### 1. 安装ZStack管理节点1

<div class="bs-callout bs-callout-warning">
<h4>注意配置YUM或者APT的镜像</h4>
在安装的过程中，脚本会从Linux发行商的repo里面安装需要的包。国内访问例如CentOS/RedHat/Ubuntu的repo通常会比较慢，如果你有常用的镜像repo，在执行脚本前
先设置好镜像repo可以大大加快安装速度。
</div>

国内用户在访问我们美国服务器时速度较慢，请使用以下链接：
      
<h4 style="margin-bottom:15px; margin-top:15px">使用<i>curl</i>:</h4>
<pre><code>curl -L http://download.zstack.org/releases/0.7/zstack-install-0.7.1.sh -o install-zstack.sh
sudo bash install-zstack.sh -i -f http://7xi3lj.com1.z0.glb.clouddn.com/releases/0.7/zstack-all-in-one-0.7.1.tgz</code></pre>
      
<h4 style="margin-bottom:15px">使用<i>wget</i>:</h4>
<pre><code>wget -O install-zstack.sh http://download.zstack.org/releases/0.7/zstack-install-0.7.1.sh
sudo bash install-zstack.sh -i -f http://7xi3lj.com1.z0.glb.clouddn.com/releases/0.7/zstack-all-in-one-0.7.1.tgz</code></pre>
      
<div class="bs-callout bs-callout-danger">
  <h4>注意DNS劫持</h4>
        
由于国内所有不能解析的域名都会被送到某DNS解析，造成在安装系统时随意设置的hostname也会被解析成IP，但该IP并不代表你本机。这会造成RabbitMQ在启动时出错，
并可能导致登录MySQL时出错。我们的安装脚本会在安装时检测DNS劫持，如果发现错误解析的hostname会报错并停止安装。我们建议国内用户在安装前先检查你的hostname:
        
  <pre><code>ping `hostname`</code></pre>
        
如果可以解析，但看到的IP不是127.x.x.x或者不是本机IP，则可能是DNS劫持，可以执行以下命令将hostname映射至本机：
        
  <pre><code>sudo echo "127.0.1.1 `hostname`" >> /etc/hosts</code></pre>
</div>

当第一个管理节点安装完成之后，配置本节点的IP地址到zstack.properties文件（假设本机的IP地址是10.89.13.57）：

    zstack-ctl configure management.server.ip=ip_of_management_node1

    Example: zstack-ctl configure management.server.ip=10.89.13.57

    zstack-ctl save_config

#### 1.2 安装 MySQL

当完成了1.1的安装之后，您就可以使用ZStack控制工具`zstack-ctl`来完成MySQL自动化的安装:

    sudo zstack-ctl install_db --host=ip_of_machine_to_install_mysql
    
    Example: sudo zstack-ctl install_db --host=192.168.0.224
    
`zstack-ctl` 会依赖 [Ansible](http://www.ansible.com/home)来完成对应的安装工作；它可能会在安装要求您输入MySQL服务器的SSH密码。

#### 1.3 安装 RabbitMQ

同样您可以使用 `zstack-ctl` 来完成RabbitMQ服务的安装:

    sudo zstack-ctl install_rabbitmq --host=ip_of_machine_to_install_mysql
    
    Example: sudo zstack-ctl install_rabbitmq --host=192.168.0.225
    
<div class="bs-callout bs-callout-info">
  <h4>这个命令会更新 zstack.properties</h4>
  使用<code>zstack-ctl</code>安装RabbitMQ之后，它会自动把RabbitMQ服务器的地址更新到 zstack.properties 文件.
  zstack.properties文件的地址可以用 `zstack-ctl status` 来获得。
</div>

当您成功的安装了RabbitMQ之后，您还需要为远程的RabbitMQ访问创建加密访问(需要在RabbitMQ的服务器上做如下操作)：

    rabbitmqctl add_user username password

    Example: rabbitmqctl add_user zstack zstack123

    rabbitmqctl set_user_tags username administrator

    Example: rabbitmqctl set_user_tags zstack administrator

    rabbitmqctl change_password username password

    Example: rabbitmqctl change_password zstack zstack123

    rabbitmqctl set_permissions -p / username ".*" ".*" ".*"

    Example: rabbitmqctl set_permissions -p / zstack ".*" ".*" ".*"

另外您还需要把RabbitMQ的加密访问配置记录到zstack.properties(在ZStack管理节点做如下步骤):

    zstack-ctl configure CloudBus.rabbitmqUsername=rabbitmq_username

    Example: zstack-ctl configure CloudBus.rabbitmqUsername=zstack

    zstack-ctl configure CloudBus.rabbitmqPassword=rabbitmq_password

    Example: zstack-ctl configure CloudBus.rabbitmqPassword=zstack123

    zstack-ctl save_config

### 4. 安装第二个ZStack管理节点

在装好ZStack的管理节点一上，您可以使用`zstack-ctl`来安装其他的管理节点：

    sudo zstack-ctl install_management_node --host=ip_of_machine_to_install_node_2
    
    Example: sudo zstack-ctl install_management_node --host=192.168.0.226

当新节点成功安装后，请在<b>新节点</b>上配置当前管理节点的IP地址：

    zstack-ctl configure management.server.ip=ip_of_management_node2

    Example: zstack-ctl configure management.server.ip=192.168.0.226

    zstack-ctl save_config

您可以重复这一步来安装更多的管理节点。
    
#### 5 安装 Web UI

使用`zstack-ctl`来安装web UI:

##### 5.1 安装到管理节点本地

    sudo zstack-ctl install_ui
    
##### 5.2 安装到另外一台机器

    sudo zstack-ctl install_ui --host=ip_of_machine_to_install_ui
    
    Example: sudo zstack-ctl install_ui --host=192.168.0.228
    
<div class="bs-callout bs-callout-info">
  <h4>默认的用户名和密码</h4>
  
  ZStack图形用户界面默认的用户名和密码是： admin/password.
</div>

现在您的多节点ZStack已经成功安装，请访问[通过多节点安装来启动ZStack](../documentation/getstart-multi.html) 来继续配置和启动ZStack。 

