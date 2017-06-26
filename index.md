---
title: ZStack Home
layout: homePage
---
<div class="home-slogan-background">
  <div class="homepage-intro">
    <div class="container">
      <div class="row">
        <div class="col-xs-10 col-xs-offset-1" style="padding-top: 50px">
            <h1 class="homepage-slogan">ZStack: the IaaS software you have been looking for</h1>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1" style="padding-top: 10px">
        <h2>中文用户请访问<a href="http://zstack.io/"> www.zstack.io </a></h2>   
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1" style="padding-top: 10px">
        <h1>What Is ZStack</h1>
        <p>
          ZStack is open source IaaS(infrastructure as a service) software aiming to automate datacenters,
          managing resources of compute, storage, and networking all by APIs. Users can setup ZStack
          environments in a download-and-run manner, spending 5 minutes building a POC environment all on a single Linux machine,
          or 30 minutes building a multi-node production environment that can scale to hundreds of thousands of physical servers.
        </p>
      </div>
    </div>
  </div>
</div>


<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1" style="padding-top: 10px">
        <h3><i class="fa fa-sitemap">&nbsp; SCALABLE</i></h3>
        <p>A single management node is capable of managing <b>hundreds of thousands</b> of physical servers, managing <b>millions</b> of virtual machines,
          and serving <b>tens of thousands</b> of concurrent API requests.</p>

        <p>See:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/asynchronous-architecture.html">ZStack's Scalability Secrets Part 1: Asynchronous Architecture</a></li>
            <li><a href="blog/stateless-clustering.html">ZStack's Scalability Secrets Part 2: Stateless Services</a></li>
            <li><a href="blog/lock-free.html">ZStack's Scalability Secrets Part 3: Lock-free Architecture</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-bolt">&nbsp; FAST</i></h3>
        <p>Operations are <b>extremely fast</b>, see below performance data of creating VMs.
        <table class="table table-bordered home-table" style="margin-bottom: 0;">
          <tr>
            <th>VM NUMBER</td>
            <th>TIME COST&nbsp;&nbsp;
                <i class='fa fa-info-circle' style='cursor:help' title="Limited by hardware, this data is from a mixed environment containing real VMs created on nested virtualization hypervisor and simulator VMs, which are created by 100 threads using only one management node. We are 100% sure the performance will get better in the real data center with decent hardware."></i>
            </td>
          </tr>
          <tr>
            <td>1</td>
            <td>0.51 seconds</td>
          </tr>
          <tr>
            <td>10</td>
            <td>1.55 seconds</td>
          </tr>
          <tr>
            <td>100</td>
            <td>11.33 seconds</td>
          </tr>
          <tr>
            <td>1000</td>
            <td>103 seconds</td>
          </tr>
          <tr>
            <td>10000</td>
            <td>23 minutes</td>
          </tr>
        </table>
      </div>
    </div>
 </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">

      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-share-alt">&nbsp; NETWORK FUNCTIONS VIRTUALIZATION</i></h3>
        <p>
          The default networking model is built on <b>NFV(network functions virtualization)</b>, which provides every tenant a
          dedicated networking node implemented by a virtual appliance VM. The whole networking model is self-contained and
          self-managed, administrators need neither to purchase special hardware nor to deploy networking servers in front of
          computing servers.
        </p>
        <p>See:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/network-l2.html">Networking Model 1: L2 and L3 Network</a></li>
            <li><a href="blog/virtual-router.html">Networking Model 2: Virtual Router Network Service Provider</a></li>
          </ul>
        </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">

      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-search">&nbsp; COMPREHENSIVE QUERY APIS</i></h3>
        <p>
           Users can query everything everywhere by about <b>4,000,000</b> query conditions and <b>countless</b> query combinations.
           You will never need to write ad-hoc scripts or directly
           access database to search a resource, it's all handled by APIs.
        <pre id="pre-code"><code>>> QueryVmInstance vmNics.eip.guestIp=16.16.16.16 zone.name=west-coast</code></pre>
        <pre id="pre-code"><code>>> QueryHost fields=name,uuid,managementIp hypervisorType=KVM vmInstance.allVolumes.size>=549755813888000 vmInstance.state=Running start=0 limit=10</code></pre>
        <p>See:</p>
          <div class="home-links">
            <ul>
              <li><a href="blog/query.html">The Query API</a></li>
            </ul>
          </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-leaf">&nbsp; EASY TO DEPLOY AND UPGRADE </i></h3>

        <p>
          Installation and upgrade are as simple as deploying a <b>Java WAR file</b>. A POC environment can be
          installed in <b>5 minutes</b> with a bootstrap script; A multi-node production environment can be deployed in <b>30 minutes</b> including the
          time you read the documentation. <i class='fa fa-info-circle' style='cursor:help' title="If you are on a slow network, the real installation time may be a little longer."></i>
        </p>

        <pre id="pre-code"><code>[root@localhost ~]# curl {{site.all_in_one_ch}} |  bash -s -- -a</code></pre>
        <p>See:</p>
          <div class="home-links">
            <ul>
              <li><a href="installation/index.html">Quick Installation</a></li>
              <li><a href="installation/manual.html">Manual Installation</a></li>
              <li><a href="installation/multi-node.html">Multi-node Installation</a></li>
            </ul>
          </div>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-wrench">&nbsp; FULL AUTOMATION</i></h3>
        <p>
          <b>Everything is managed by APIs</b>, no manual, scattered configurations in your cloud. And
          the seamless, transparent integration with <a href="http://www.ansible.com/home"><b>Ansible</b></a>
          liberates you from installing, configuring, and upgrading agents on massive hardware.
        </p>
        <p>See:</p>
          <div class="home-links">
            <ul>
              <li><a href="blog/ansible.html">Full Automation By Ansible</a></li>
            </ul>
          </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-even">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-random">&nbsp; VERSATILE PLUGIN SYSTEM</i></h3>
        <p>
          The core orchestration is built on an <a href="https://eclipse.org/">Eclipse</a> and
          <a href="http://www.osgi.org/Main/HomePage">OSGI</a> like <b>plugin system</b> that
          everything is a plugin. ZStack affirms that adding or removing features will not
          impact the core orchestration, promising a robust software the cloud
          users deserve.
        </p>

        <p>See:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/microservices.html">The In-Process Microservices Architecture</a></li>
            <li><a href="blog/plugin.html">The Versatile Plugin System</a></li>
            <li><a href="blog/workflow.html">The Workflow Engine</a></li>
            <li><a href="blog/tag.html">The Tag System</a></li>
            <li><a href="blog/cascade.html">The Cascade Framework</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="homepage-padding-odd">
  <div class="container">
    <div class="row">
      <div class="col-xs-10 col-xs-offset-1">
        <h3><i class="fa fa-cubes">&nbsp; RIGOROUS TESTING SYSTEM</i></h3>
        <p>
          <b>Three full-automated, rigorous testing systems</b> ensure the quality of every feature.
        </p>

        <p>See:</p>
        <div class="home-links">
          <ul>
            <li><a href="blog/integration-testing.html">The Automation Testing System 1: Integration Testing</a></li>
            <li><a href="blog/system-testing.html">The Automation Testing System 2: System Testing</a></li>
            <li><a href="blog/model-based-testing.html">The Automation Testing System 3: Model-based Testing</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
