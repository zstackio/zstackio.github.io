---
title: Getting Started With Multi-node Installation
layout: docPage
---

<h2 id="manual">Getting Started With Multi-node Installation</h2>

Once you have installed ZStack on multiple Linux machines following instructions in [Multi-node Installation](../installation/multi-node.html), you are
ready to configure and start management nodes using `zstack-ctl` which is ZStack control tool installed on machines
that ZStack management nodes are installed. `zstack-ctl` is installed with every ZStack management node, you can use it to control
local management node as well as remote management nodes.

### zstack.properties

All configurations about ZStack management node such as database URL, database password, RabbitMQ server IP and so on are stored
in *zstack.properties* that is a standard Java properties file. You can retrieve its path by:

    zstack-ctl status
    
You can manually edit this file just as a normal text file, however, most `zstack-ctl` commands will update corresponding entries
automatically, which you will see soon in following sections.

### 1. Configure the first management node

As you have multiple ZStack management nodes, the best way to configure them is to configure the first management node and then
duplicate its configuration to other nodes. The first management node is the one you run `zstack-ctl` to install MySQL and
RabbitMQ in [Multi-node Installation](../multi-node.html); **commands in following sections are all run on the first management node**.

<div class="bs-callout bs-callout-info">
  <h4>The first node is chosen for reasons</h4>
  We select the first management node only because <code>zstack-ctl install_rabbitmq</code> command has updated RabbitMQ IP to
  the zstack.properties when you install RabbitMQ. You can use any node as the first node as long as you update RabbitMQ IP following
  step 1.2 below.
</div>

#### 1.1 Deploy database

First of all, you need to deploy a fresh ZStack database:

    zstack-ctl deploydb --host=ip_of_mysql_machine --root-password=root_password_of_mysql --zstack-password=password_for_mysql_user_zstack
    
    Example: zstack-ctl deploydb --host=192.168.0.212 --root-password=abcd --zstack-password=1234
    
if the MySQL is installed by `zstack-ctl install_db` the default root password is empty, you can omit `--root-password` then:

    zstack-ctl deploydb --host=ip_of_mysql_machine --zstack-password=password_for_mysql_user_zstack
    
    Example: zstack-ctl deploydb --host=192.168.0.212 --zstack-password=1234
    
or you want to use empty password for user `zstack` in a POC environment, you can omit `--zstack-password` then:

    zstack-ctl deploydb --host=ip_of_mysql_machine 
    
    Example: zstack-ctl deploydb --host=192.168.0.212
    
<div class="bs-callout bs-callout-info">
  <h4>This command will update zstack.properties</h4>
  User <code>zstack</code> is the MySQL username that ZStack management nodes use to access database.
  <code>deploydb</code> command will update zstack.properties for entries: <code>DbFacadeDataSource.jdbcUrl</code>, <code>DbFacadeDataSource.user</code>,
  <code>DbFacadeDataSource.password</code>, and <code>RESTApiDataSource.jdbcUrl</code>.
</div>

#### 1.2. Configure RabbitMQ

If you installed RabbitMQ message broker using command `zstack-ctl install_rabbitmq`, you don't have to do any configuration
because the command has automatically updated entry `CloudBus.serverIp.0` with the IP of RabbitMQ machine. If you installed
RabbitMQ manually, please edit zstack.properties updating `CloudBus.serverIp.0` to the IP of RabbitMQ machine.

### 2. Duplicate configuration to other nodes

Once you have configured the first management node, you can duplicate the configuration to other nodes by:

    zstack-ctl configure --duplicate-to-remote=ip_of_other_node
    
    Example: zstack-ctl configure --duplicate-to-remote=192.168.0.225
    
repeat this command to duplicate the configuration to all nodes.

Please set management node ip in each management node separately:

    zstack-ctl configure management.server.ip=ip_of_current_management_node

    Example: zstack-ctl configure management.server.ip=192.168.0.226

    zstack-ctl save_config

### 3. Start management nodes

#### 3.1 Start the first node

You can start the first management node by:

    zstack-ctl start_node
   
or use the service file in init.d/:

    /etc/init.d/zstack-server start
    
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

#### 3.2 Start other nodes

Once the first management node starts successfully, you can start other nodes by:
 
    zstack-ctl start_node --host=ip_of_other_node
    
    Example: zstack-ctl start_node --host=192.168.0.224
    
repeat this command to start all other nodes.
    
### 4. Start web UI

On the first management node, if the UI is installed in localhost, you can start the web UI by:

    zstack-ctl start_ui 

If the UI is installed on different host, you can start the web UI by:

    zstack-ctl start_ui --host=ip_of_ui_host
    
the web UI will listen on port `5000`, you can visit it with URL `http://ip_of_ui_machine:5000`.

<div class="bs-callout bs-callout-info">
  <h4>All management nodes share the same web UI</h4>
  All management nodes share the same web UI server, you don't need to start web UI on other management noes.
</div>

### Useful zstack-ctl commands

You can stop a local management node by:

    zstack-ctl stop_node
    
or stop a remote management node by:

    zstack-ctl stop_node --host=ip_of_node
    
    Example: zstack-ctl stop_node --host=192.168.0.224
    
The log file of ZStack management node locates at `/var/log/zstack/management-server.log`, you can view local log by:

    zstack-ctl taillog
    
which essentially runs `tail -f /var/log/zstack/management-server.log`.

You can add or update a property in zstack.properties by:
 
    zstack-ctl configure property_name=property_value
    
    Example: zstack-ctl configure CloudBus.serverIp.0=192.168.0.225 
    
or update a property to a remote node:

    zstack-ctl configure --host=ip_of_node property_name=property_value
    
    Example: zstack-ctl configure --host=192.168.0.224 CloudBus.serverIp.0=192.168.0.225 
    
### Use Command Line Tool

You can launch ZStack command line tool by:

    zstack-cli
    
Now your multi-node ZStack environment is ready, please visit [Tutorials](../tutorials) to create your first cloud deployment
using either web UI or command line tool, or check out [User Manual](http://zstackdoc.readthedocs.org/en/latest/) for a full reference.


