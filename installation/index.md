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
    <td>ZStack OS</td>
  </tr>
</table>


Installing ZStack must use the ZStack OS ({{site.zstack_iso}}) and prepare the ZStack installation package.
<div class="bs-callout bs-callout-info">
  <h4>The Introduction of ZStack OS</h4>
  <ul>
    <li>ZStack OS is customized from CentOS 7.2, including required system libs, with friendly Terminal UI (TUI) and well tested by hundreds of cloud users.</li>
    <li>ZStack OS ISO includes all ZStack required components. So installing ZStack OS does not need Internet connection. </li>
    <li>Provide four installation modes: Enterprise management node mode, community management node mode, computing node mode, expert mode. </li>
    <li>Default options: DATE & TIME is East Asia, LANGUAGE is English and KEYBOARD is English (US). </li>

  </ul>

  <h4>ZStack OS Four Installation Modes</h4>
  
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

This manual will introduce the ZStack Community Management Node installation, which is easiest mode to build a private cloud. 

#### 1.Download ZStack ISO

ZStack user should download the ZStack OS {{site.zstack_iso_name}}.<br>
 
#### Download link :
<ul>
  <li><b>ZStack ISO:</b>{{site.zstack_iso}}</li>
  <li><b>The md5sum of ZStack ISO</b>:{{site.zstack_iso_md5}}</li>
</ul>

#### 2. Burn ISO to USB:

In the hard drive list select the USB to burn.

<div class="bs-callout bs-callout-warning">
  <h4>Precautions in using USB</h4>
  If the system is only inserted a USB, which is the default USB to burn and write. Before burning, please backup USB content.
  After the buring, the USB can be used as a boot disk.
</div>

#### 3.System Installation

The system has been pre-configured default options: DATE & TIME for the East Asia Area, LANGUAGE is English, KEYBOARD is English (US). The administrator can change the configuration.
  
Please make sure the network is configed. The static IP configuration is preferred.

<img src="../images/Quick_Installation1.png" class="center-img img-responsive">

<div class="bs-callout bs-callout-info">
  <h4>Mode selection</h4>
  Please choose <i>ZStack Community Management mode</i>.
</div>

<img src="../images/Quick_Installation2.PNG" class="center-img img-responsive">

You can click the <i>root password</i> to set the password.
Depending on the hardware performance, the process may take 5 ~ 15 minutes.

<img src="../images/Quick_Installation3.PNG" class="center-img img-responsive">

After Operation System installed, please reboot the system. When the system boots up again, it will automatically install ZStack and start up ZStack TUI.

The ISO will install the machine with:

* Apache Tomcat 7 with zstack.war deployed
* ZStack web UI
* ZStack command line tool (zstack-cli)
* ZStack control tool (zstack-ctl)
* MySQL(will set MySQL root password, if it is empty.)
* RabbitMQ server
* NFS server
* Apache HTTP server

<div class="bs-callout bs-callout-warning">
  <h4>If failed to install ZStack</h4>
  May be lack of NIC configuration or other causes lead to ZStack installation failure. The installation page will exit to the terminal.<br>
  For example: <i>If the server does not have available IP when installing ISO, the ZStack management node can't be installed properly.</i>
  <div class="bs-callout bs-callout-success">
    <h4>After configuring the network, do the following command to install ZStack:</h4>
      <pre><code>bash /opt/zstack*installer.bin</code></pre>
  </div>
</div>

<div class="bs-callout bs-callout-info">
  <h4>Default Credential</h4>

  The default credential for UI login is admin/password.
</div>

Now your ZStack is successfully installed, visit [Getting started with quick installation](../documentation/getstart-quick.html) see how to access web UI and command line tool.
