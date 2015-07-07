---
title: Documentation
layout: docPage
---

<h2 id="manual">Getting Started With Manual Installation</h2>

Once you have installed ZStack on a Linux machine following instructions in [Manual Installation](../installation/manual.html), you are
ready to configure and start the management node using `zstack-ctl` which is ZStack control tool installed on the machine
that ZStack management node is installed.

### zstack.properties

All configurations about ZStack management node such as database URL, database password, RabbitMQ server IP and so on are stored
in zstack.properties that is a standard Java properties file. You can retrieve its path by:

    zstack-ctl status
    
You can manually edit this file just as a normal text file, however, most `zstack-ctl` commands will update corresponding entries
automatically, which you will see soon in following sections.

### 1. Deploy database

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
    
### 2. Configure RabbitMQ

If you installed RabbitMQ message broker using command `zstack-ctl install_rabbitmq`, you don't have to do any configuration
because the command has automatically updated entry `CloudBus.serverIp.0` with the IP of RabbitMQ machine. If you installed
RabbitMQ manually, please edit zstack.properties updating `CloudBus.serverIp.0` to the IP of RabbitMQ machine.

### 3. Start management node

You can start the management node by:

    zstack-ctl start_node
   
or use the service file in init.d/:

    /etc/init.d/zstack-server start
    
### 4. Start web UI

If the UI is installed in localhost, you can start the web UI by:

    zstack-ctl start_ui 

If the UI is installed on different host, you can start the web UI by:

    zstack-ctl start_ui --host=ip_of_ui_host
    
the web UI will listen on port `5000`, you can visit it with URL `http://ip_of_ui_machine:5000`.

### Useful zstack-ctl commands

You can stop a management node by:

    zstack-ctl stop_node
    
The log file of ZStack management node locates at `/var/log/zstack/management-server.log`, you can view it by:

    zstack-ctl taillog
    
which essentially runs `tail -f /var/log/zstack/management-server.log`.

You can add or update a property in zstack.properties by:
 
    zstack-ctl configure property_name=property_value
    
    Example: zstack-ctl configure CloudBus.serverIp.0=192.168.0.225
    
### Use Command Line Tool

You can launch ZStack command line tool by:

    zstack-cli

Now your ZStack environment is ready, please visit [Tutorials](../tutorials) to create your first cloud deployment
using either web UI or command line tool, or check out [User Manual](http://zdoc.readthedocs.org/en/latest/) for a full reference.

