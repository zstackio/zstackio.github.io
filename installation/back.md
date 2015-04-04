---
title: ZStack Download
layout: installationPage
---

<h2 id="quickInstallation">Quick Installation</h2>

> ***Note**: This section is to install ZStack and all its dependencies on a single Linux machine which will be used as
the KVM host also. People can use this to install ZStack and create their first cloud in a few minutes.*

It's recommended to use a machine that has at least 8G memory, 250G free hard disk, Intel/AMD CPU that supports hardware
virtualization, and one network card that can reach internet. Once you have a Linux operating system installed on the machine,
you can:

#### 1. Use *curl* to install:

    curl -L http://zstack.org/download/install.sh -o install_zstack.sh
    sudo sh install_zstack.sh
    
#### 2. Use *wget* to install:

    wget -O install_zstack.sh http://zstack.org/download/install.sh 
    sudo sh install_zstack.sh
    
> ***Note**: The script has been tested on CentOS6.5/6.6/7 and Ubuntu14.04; it will install all ZStack dependencies including:
Tomcat, RabbitMQ, Ansible, and MySQL; to avoid unnecessary conflicts, it's recommended to use a fresh operating system.*

After the installation is done, you should see a summary as follows:

    ZStack All In One Installation Completed:
     - ZStack packages have been installed in /usr/local/zstack
     - ZStack server is running.
          You can use /etc/init.d/zstack-server (stop|start) to stop/start the service
     - ZStack dashboard is running: http://localhost:5000
          You can use /etc/init.d/zstack-dashboard (stop|start) to stop/start the service
     - ZStack command line tool is installed. Run zstack-cli to start
     
Now you are ready to create your first cloud through the web UI(http://localhost:5000) or the command line tool(zstack-cli).

+ see [Tutorials](../tutorials/index.html) to deploy classic clouds in a few minutes.
+ see [Documentation](../documentation/index.html) for detailed user manual.

<h2 id="manualInstallation" style="margin-top:30px">Manual Installation</h2>

Though quick installation script can install a full ZStack setup in several minutes, it hides details and configurations. In
some cases, people may want manual installation in order to customize installation directory path or create multiple management
nodes setup. Before downloading ZStack Java WAR file, you need to install a couple of dependent software as follows:

<h4 id="installMysql">1. Install MySQL:</h4>

ZStack defaults to MySQL database, you can install it by:

*CentOS6.5/6.6./7*

    sudo yum install mysql-server mysql
    
*Ubuntu14.04*

    sudo apt-get install mysql-server mysql
    
   
<h4 id="installRabbitMQ">2. Install RabbitMQ:</h4>

ZStack uses [RabbitMQ](http://www.rabbitmq.com/) as its message bus, you can install it by:

*CentOS6.5/6.6./7*

    sudo yum install rabbitmq-server
    
*Ubuntu14.04*

    sudo apt-get install rabbitmq-server
    
<h4 id="installAnsible">3. Install Ansible:</h4>

ZStack seamlessly integrates with [Ansible](http://www.ansible.com/home) and uses it to manage agents and KVM hosts; before installing it, you need to
install Python pip:

*CentOS6.5/6.6./7*

    sudo yum install python-setuptools
    sudo easy_install pip
    sudo pip install ansible==1.7.2
    
*Ubuntu14.04*

    sudo apt-get install python-setuptools
    sudo easy_install pip
    sudo pip install ansible==1.7.2
    
> ***Note:** We specify Ansible version to 1.7.2. Though versions later than 1.7.2 should work as well, it is the version we use in our test environment*

<h4 id="installJava">4. Install Java:</h4>

ZStack requires JRE7 or later version, you can install it by:

*CentOS6.5/6.6./7*

    sudo yum install java-1.7.0-openjdk
    
*Ubuntu14.04*

    sudo apt-get install openjdk-7-jdk
    
<h4 id="installTomcat">5. Install Tomcat:</h4>

As a standard Java WAR file, ZStack can be deployed in any Java web container; however, we recommend Tomcat because of its well-established
reputation. We recommend not to use the default Tomcat version shipped by Linux distribution, because it's usually old and contains modifications
that may cause troubles. You can download and install Tomcat from the official site by:

    wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.35/bin/apache-tomcat-7.0.35.tar.gz
    tar xzf apache-tomcat-7.0.35.tar.gz
    
> ***Note:** We specify Tomcat version to 7.0.35 only because it's the version we use in our test environment. Any later Tomcat version should work fine as
well. You can download them from [Tomcat Download Page](http://tomcat.apache.org/download-70.cgi).*


<h4 id="installZstack">6. Install ZStack WAR:</h4>

Assuming your Tomcat installation directory is */usr/local/apache-tomcat*, you can download and install ZStack by:

    cd /usr/local/apache-tomcat/webapps
    wget http://download.zstack.org/releases/0.6/zstack.war
    unzip zstack.war -d zstack
    
Now you have successfully installed ZStack, for following sections, we assume the ZStack installation path is ***/usr/local/apache-tomcat/webapps/zstack***.

<h4 id="installAdminTool">7. Install Admin Tool:</h4>

You can install ZStack admin tool by:

    sudo sh /usr/local/apache-tomcat/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-ctl
    
<h4 id="installCli">8. Install Command Line Tool:</h4>

You can install ZStack command line tool by:

    sudo sh /usr/local/apache-tomcat/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-cli
    
<h4 id="installUI">8. Install Web UI:</h4>

You can install ZStack web UI by:

    sudo sh /usr/local/apache-tomcat/webapps/zstack/WEB-INF/classes/tools/install.sh zstack-dashboard

<h2 id="configuration" style="margin-top:30px">Configure And Run</h2>

Once ZStack has been installed in the system, you needs a few more steps to bring it up.

>***Note**: If you use *Quick Installation*, you can skip this section as all configuration has been done automatically*

<h4 id="setHome">1. Set ZSTACK_HOME:</h4>

Before using ZStack management tool(zstack-ctl), you need to set environment variable to ZStack's installation path:

    export ZSTACK_HOME=/usr/local/apache-tomcat/webapps/zstack
    
it's recommended to keep this environment variable in your ~/.bashrc by:

    echo 'export ZSTACK_HOME=/usr/local/apache-tomcat/webapps/zstack' >> ~/.bashrc
    . ~/.bashrc

<h4 id="deploydb">2. Deploy Database:</h4>

Before starting ZStack management node, you need to deploy database using:

    zstack-ctl deploydb --root-password=your_db_root_password --zstack-password=the_password_you_want_to_set_to_db_user_zstack
    
it will deploy a fresh ZStack database and update zstack.properties with database information you input.


<h4 id="startNode">3. Start Management Node:</h4>

After deploying database, you can start ZStack management node by:

    sudo -E zstack-ctl start_node
    
<h4 id="startUI">4. Start Web UI:</h4>

After starting management node, you can launch the web UI by:
  
    /etc/init.d/zstack-dashboard start
    
<h4 id="startCLI">5. Use Command Line Tool:</h4>

Instead of web UI, you can also use the command line tool by:

    zstack-cli

Now your ZStack setup should have been up and running, enjoy!

For information, check out [Documentation](../documentation/index.html) 
    
