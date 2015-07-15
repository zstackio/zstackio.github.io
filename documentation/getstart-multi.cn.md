---
title: 通过多节点安装来启动ZStack
layout: docPage
---

<h2 id="manual">通过多节点安装来启动ZStack</h2>

当您使用[多节点安装手册](../installation/multi-node.html)完成ZStack的安装之后，您可以继续进行一些必要的配置
以便用它来自动云环境。ZStack的管控工具`zstack-ctl`会安装到每一个ZStack管理节点，您可以使用它来控制本地管理节点，
或其他管理节点。

### zstack.properties

特别需要注意的是，zstack.properties是ZStack的核心配置文件。它会存放在每一个管理节点中。
每一个管理节点上的zstack.properties文件的内容基本上是一致的。它的路径可以通过`zstack-ctl status`来获得。
如果是默认安装的话，它会存放在/usr/local/zstack/apache-tomcat/webapps/zstack/WEB-INF/classes/zstack.properties 。
你可以手动编辑它，也可以通过<code>zstack-ctl configure`来完成配置。不过通常情况下，
当用户在使用`zstack-ctl`命令来安装或者部署对应的服务的时候，`zstack-ctl`会自动的完成部署。

### 1. 配置ZStack第一个管理节点

在多台管理节点的环境下，最好的配置方式是在第一台管理节点上完成配置后，把配置文件复制到其他的管理节点上去。
我们已经在[多节点安手册](../installation/multi-node.html)中，通过第一个管理节点安装了MySQL和RabbitMQ。

<div class="bs-callout bs-callout-info">
  <h4>选择第一个节点的原因</h4>
  我们选择第一个管理节点是因为<code>zstack-ctl install_rabbitmq</code>命令已经把RabbitMQ服务器的IP地址更新到了 
zstack.properties 文件。您可以使用任意一个节点，只要您使用下面1.2步骤里的方法更新了RabbitMQ IP地址。
</div>

#### 1.1 初始化数据库

安装完ZStack管理节点和MySQL服务器后，ZStack的数据库并没有建立。您需要运行下面的命令来初始化数据库：

    zstack-ctl deploydb --host=ip_of_mysql_machine --root-password=root_password_of_mysql --zstack-password=password_for_mysql_user_zstack
    
    例如: zstack-ctl deploydb --host=192.168.0.212 --root-password=abcd --zstack-password=1234
    
如果您的MySQL是通过`zstack-ctl install_db`来安装的，那么MySQL默认的root密码是为空的，您可以不用`--root-password`:

    zstack-ctl deploydb --host=ip_of_mysql_machine --zstack-password=password_for_mysql_user_zstack
    
    例如: zstack-ctl deploydb --host=192.168.0.212 --zstack-password=1234
    
或者您不需要给自己的ZStack数据设置任何的访问密码：

    zstack-ctl deploydb --host=ip_of_mysql_machine 
    
    例如: zstack-ctl deploydb --host=192.168.0.212
    
<div class="bs-callout bs-callout-info">
  <h4>初始化数据库的命令会把数据的访问信息更新到zstack.properties</h4>
  <code>zstack</code>用户是ZStack用于访问ZStack数据库的用户名。
  <code>deploydb</code> 会把MySQL数据库的地址、访问的用户名和密码等信息更新到 zstack.properties 文件中的: <code>DbFacadeDataSource.jdbcUrl</code>, <code>DbFacadeDataSource.user</code>,
  <code>DbFacadeDataSource.password</code>, <code>RESTApiDataSource.jdbcUrl</code>, <code>RESTApiDataSource.user</code> and <code>RESTApiDataSource.password</code>.
</div>

#### 1.2. 配置 RabbitMQ 服务

如果您通过`zstack-ctl install_rabbitmq`命令来安装RabbitMQ服务，您不需要配置RabbitMQ的IP地址，因为zstack-ctl已经把
相关的配置`CloudBus.serverIp.0`更新到了zstack.properties里面。
如果您的RabbitMQ服务是装在非ZStack管理节点的机器上，您还需要配置RabbitMQ的用户名和密码：

    zstack-ctl configure CloudBus.rabbitmqUsername = zstack
    zstack-ctl configure CloudBus.rabbitmqPassword = zstack123

### 2. 复制zstack.properties到其他管理节点

一旦完成了第一个管理节点的配置，您就可以把配置文件复制到其他管理节点：

    zstack-ctl configure --duplicate-to-remote=ip_of_other_node
    
    例如: zstack-ctl configure --duplicate-to-remote=192.168.0.225
    
重复执行上述命令，直到把配置文件都复制到了所有的管理节点。

但是您还需要给每一个管理节点手动配置一下各自的IP地址：

    zstack-ctl configure --remote=ip_of_remote_zstack management.server.ip=ip_of_current_management_node

    例如: zstack-ctl configure --remote=192.168.0.226 management.server.ip=192.168.0.226

最后保存一下config文件：

    zstack-ctl save_config

### 3. 启动管理节点

#### 3.1 启动第一个管理节点

在第一个管理节点上，您只需要执行下面的一条命令就可以启动ZStack管理进程:

    zstack-ctl start_node
   
或者使用我们在 /etc/init.d/目录里的服务程序:

    /etc/init.d/zstack-server start
    
#### 3.2 启动其他管理节点

当第一个管理节点启动成功后，您就可以使用下面的命令来启动其他的管理节点：
 
    zstack-ctl start_node --remote=ip_of_other_node
    
    例如: zstack-ctl start_node --remote=192.168.0.224
    
重复这条命令，直到所有的管理节点都已经启动完毕。
    
### 4. 启动Web管理界面

在第一个管理节点，如果ZStack Dashboard UI是安装在本地的，您可以使用下面的命令启动：

    zstack-ctl start_ui 

如果UI不是安装在本地，那么您可以使用如下命令启动：

    zstack-ctl start_ui --host=ip_of_ui_host
    
默认情况下ZStack的UI是加载在5000端口，您可以在Chrome浏览器或者FireFox浏览器（IE浏览器可能会遇到使用问题）上打开如下地址：

    `http://ip_of_ui_machine:5000`.

<div class="bs-callout bs-callout-info">
  <h4>所有的管理节点可以共享相同的Web UI</h4>
  所有的管理节点都可以共享相同的ZStack UI界面。您无需在每个管理节点上都安装和启动一份UI界面。
  当然您也可以启动多个Web UI并使用相关HA软件来保证Web 界面的高可用性。
</div>

### zstack-ctl 命令的更多使用方法：

停止本机ZStack管理节点:

    zstack-ctl stop_node
    
停止非本机的管理节点:

    zstack-ctl stop_node --remote=ip_of_node
    
    例如: zstack-ctl stop_node --remote=192.168.0.224
    
ZStack管理节点上的日志文件默认存放在 `/var/log/zstack/management-server.log`, 您可以通过下面的命令监控最新产生的日志：

    zstack-ctl taillog
    
您可以通过下面的命令来添加或者更新ZStack的配置文件（我们前面已经用过）：
 
    zstack-ctl configure property_name=property_value
    
    例如: zstack-ctl configure CloudBus.serverIp.0=192.168.0.225 
    
您也可以通过下面的命令来添加或者更新非本机的ZStack配置文件：

    zstack-ctl configure --remote=ip_of_node property_name=property_value
    
    例如: zstack-ctl configure --remote=192.168.0.224 CloudBus.serverIp.0=192.168.0.225 
    
### 使用ZStack命令行工具

除了ZStack Web界面，您还可以使用ZStack命令行工具来操作ZStack：

    zstack-cli
    
现在您的多节点ZStack环境已经准备完毕，您可以跟着[用户教程](../tutorials)来搭建自己的云环境了
如果要获得更多的关于ZStack Web界面和命令行工具的使用说明，请访问我们的[用户手册](http://zdoc.readthedocs.org/en/latest/)来获取完整的帮助.


