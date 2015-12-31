---
title: ZStack使用教程
layout: tutorialPage.cn
---

<div class="container">
  <div class="row" style="padding-top: 25px">
    <p>
    这套教程仅仅展示了用ZStack来创建一些经典的云环境的方法。当您熟悉了ZStack的基本功能后，
    您完全可以灵活的创造更多的云解决方案。在您跟随使用教程来搭建自己的云主机的时候，我们假定您已经通过
    ZStack的<a href="../installation/index.html">快速安装手册</a>完成了ZStack在单台Linux机器上的安装。
    您可以在单台Linux机器上完成所有教程的案例而无需更多的主机。
    </p>
    <p>
    <b>此外，我们还准备了大量的<a href="http://so.iqiyi.com/so/q_zstack?source=input&sr=1026211706497">视频教程</a>，大家可以点击观看。</b>
    </p>
  </div>
  <div class="container">
    <div class="row">
      <div class="col-sm-6">
        <img class="img-responsive" src="/images/flat_network.png">
      </div>
      <div class="col-sm-6" style="padding-top: 50px">
        <h3>扁平网络</h3>
        <p>在一个扁平网络中，所有的云主机都在一个大二层的网络环境中。它们属于一个相同的子网。他们的网关和路由通常由数据中心的其他节点或者交换机提供。ZStack的虚拟机交换机可以给云主机分配动态或者静态的IP地址。这个是私有云环境中的典型环境。</p>
        <p>
          <a href="flat-network-ui.html" class="btn btn-primary" role="button">
            图形界面版本
          </a>
          <a href="flat-network-cli.html" class="btn btn-default" role="button">
            命令行版本
          </a>
        </p>
      </div>
    </div>
  </div>
</div>

<div  style="background: #f7f7f7">
  <div class="container">
    <div class="row">
      <div class="col-sm-6">
        <img class="img-responsive" src="/images/eip.png">
      </div>
      <div class="col-sm-6" style="padding-top: 50px">
        <h3>经典公有云Amazon EC2 弹性IP（EIP）</h3>
        <p>一个亚马逊经典的EC2环境可以分配一个公网的弹性IP地址给私有网络中的云主机</p>
        <p>
          <a href="ec2-ui.html" class="btn btn-primary" role="button">
            图形界面版本
          </a>
          <a href="ec2-cli.html" class="btn btn-default" role="button">
            命令行版本
          </a>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="container">
  <div class="row">
    <div class="col-sm-6">
      <img class="img-responsive" src="/images/tier_3_networks.png">
    </div>
    <div class="col-sm-6" style="padding-top: 50px">
      <h3>三层网络</h3>
      <p>在传统的互联网业务中流行着三层网络架构，分别给三类服务器提供隔离的网络环境：Web服务器，应用服务器和数据库服务器。其中Web服务器可以跨接共有网络和应用层网络，应用服务器可以跨接应用层网络和数据库网络，而数据库服务器只存在于数据库网络。</p>
      <p>
        <a href="three-tiered-ui.html" class="btn btn-primary" role="button">
          图形界面版本
        </a>
        <a href="three-tiered-cli.html" class="btn btn-default" role="button">
          命令行版本
        </a>
      </p>
    </div>
  </div>
</div>

<div  style="background: #f7f7f7">
  <div class="container">
    <div class="row">
      <div class="col-sm-6">
        <img class="img-responsive" src="/images/flat_network_with_security_group.png">
      </div>
      <div class="col-sm-6" style="padding-top: 50px">
        <h3>安全组防火墙</h3>
        <p>云主机可以通过设置安全组来控制进出云主机的网络包的安全规则，以达到安全防护的目的。</p>
        <p>
          <a href="security-group-ui.html" class="btn btn-primary" role="button">
            图形界面版本
          </a>
          <a href="security-group-cli.html" class="btn btn-default" role="button">
            命令行版本
          </a>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="container">
  <div class="row">
    <div class="col-sm-6">
      <img class="img-responsive" src="/images/port_forwarding.png">
    </div>
    <div class="col-sm-6" style="padding-top: 50px">
      <h3>端口转发</h3>
      <p>端口转发可以把共有网络的IP地址通过区分端口的方式让多台云主机共享相同的公网IP地址，同时也具有防火墙的功能。</p>
      <p>
        <a href="elastic-port-forwarding-ui.html" class="btn btn-primary" role="button">
          图形界面版本
        </a>
        <a href="elastic-port-forwarding-cli.html" class="btn btn-default" role="button">
          命令行版本
        </a>
      </p>
    </div>
  </div>
</div>

<div  style="background: #f7f7f7">
  <div class="container">
    <div class="row">
      <div class="col-sm-6">
        <img class="img-responsive" src="/images/snapshot.png">
      </div>
      <div class="col-sm-6" style="padding-top: 50px">
        <h3>磁盘快照</h3>
        <p>我们将在一个快照树上创建两个磁盘快照的分支</p>
        <p>
          <a href="snapshot-ui.html" class="btn btn-primary" role="button">
            图形界面版本
          </a>
          <a href="snapshot-cli.html" class="btn btn-default" role="button">
            命令行版本
          </a>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="container">
  <div class="row">
    <h2>更多教程：</h2>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/install-image-by-iso.html>使用ISO安装模板</a>
    </div>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/local-stroage-tutorials.html>本地存储教程</a>
    </div>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/build-zstack-network-on-single-machine.html>扁平模式还是EIP摸索——单机搭建ZStack教程</a>
    </div>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/zstack-account-user-tutorials.html>账号用户系统教程</a>
    </div>
  </div>
  <div class="row">
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/attach-detach-l3-tutorials.html>添加删除三层网络教程</a>
    </div>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/update-system-tags-by-delete-add.html>更改云主机静态IP地址和hostname</a>
    </div>
    <div class="col-sm-3" style="padding-top: 50px; padding-bottom: 50px">
        <a href=/cn_blog/assign_vr_offering_for_different_l3.html>给不同的L3网络设置不同的 VirtualRouter Offering</a>
    </div>
  </div>
</div>

