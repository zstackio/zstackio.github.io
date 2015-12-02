---
title: 通过手动安装来启动ZStack
layout: docPage.cn
---

<h2 id="manual">通过手动安装来启动ZStack</h2>

当您使用[手动安装手册](../installation/manual.html)完成ZStack的安装之后，您可以继续进行一些必要的配置
以便用它来自动云环境。ZStack的管控工具`zstack-ctl`会安装到每一个ZStack管理节点，您可以使用它来控制本地管理节点，
或其他管理节点。

### zstack.properties

特别需要注意的是，zstack.properties是ZStack的核心配置文件。它会存放在每一个管理节点中。
zstack.properties文件中会存放诸如数据库URL，用于数据库访问用户名密码，RabbitmMQ的IP地址等等。
每一个管理节点上的zstack.properties文件的内容基本上是一致的。它的路径可以通过`zstack-ctl status`来获得。
如果是默认安装的话，它会存放在/usr/local/zstack/apache-tomcat/webapps/zstack/WEB-INF/classes/zstack.properties 。
你可以手动编辑它，也可以通过<code>zstack-ctl configure`来完成配置。不过通常情况下，
当用户在使用`zstack-ctl`命令来安装或者部署对应的服务的时候，`zstack-ctl`会自动的完成部署。

#### 1 初始化数据库

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

#### 2. 配置 RabbitMQ 服务

如果您通过`zstack-ctl install_rabbitmq`命令来安装RabbitMQ服务，您不需要配置RabbitMQ的IP地址，因为zstack-ctl已经把
相关的配置`CloudBus.serverIp.0`更新到了zstack.properties里面。
如果您的RabbitMQ服务是装在非ZStack管理节点的机器上，您还需要配置RabbitMQ的用户名和密码：

    zstack-ctl configure CloudBus.rabbitmqUsername = zstack
    zstack-ctl configure CloudBus.rabbitmqPassword = zstack123

### 3. 启动管理节点

您只需要执行下面的一条命令就可以启动ZStack管理进程:

    zstack-ctl start_node
   
或者使用我们在 /etc/init.d/目录里的服务程序:

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

### 4. 启动Web管理界面

在第一个管理节点，如果ZStack Dashboard UI是安装在本地的，您可以使用下面的命令启动：

    zstack-ctl start_ui 

如果UI不是安装在本地，那么您可以使用如下命令启动：

    zstack-ctl start_ui --host=ip_of_ui_host
    
默认情况下ZStack的UI是加载在5000端口，您可以在Chrome浏览器或者FireFox浏览器（IE浏览器可能会遇到使用问题）上打开如下地址：

    `http://ip_of_ui_machine:5000`.

### zstack-ctl 命令的更多使用方法：

停止本机ZStack管理节点:

    zstack-ctl stop_node
    
ZStack管理节点上的日志文件默认存放在 `/var/log/zstack/management-server.log`, 您可以通过下面的命令监控最新产生的日志：

    zstack-ctl taillog
    
您可以通过下面的命令来添加或者更新ZStack的配置文件（我们前面已经用过）：
 
    zstack-ctl configure property_name=property_value
    
    例如: zstack-ctl configure CloudBus.serverIp.0=192.168.0.225 
    
### 使用ZStack命令行工具

除了ZStack Web界面，您还可以使用ZStack命令行工具来操作ZStack：

    zstack-cli
    
现在您的ZStack环境已经准备完毕，您可以跟着[用户教程](../tutorials)来搭建自己的云环境了
如果要获得更多的关于ZStack Web界面和命令行工具的使用说明，请访问我们的[用户手册](http://zstackdoc.readthedocs.org/en/latest/)来获取完整的帮助.

