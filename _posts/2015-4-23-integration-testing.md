---
layout: post
title:  "The Automation Testing System 1: Integration Testing"
date:   2015-4-23 21:14:07
categories: blog
---

*Testing is an important factor contributing to reliability, maturity, and maintainability of an IaaS software. Testing in ZStack
is fully automated. The automation testing system consists of three parts: integration testing, system testing, and model-based
testing. The integration testing system is built based on JUnit using simulators. With various utilities the integration testing
system supplies, developers can quickly write test cases to validate a new feature or a bug fix.*

### Overview

The crucial factor in making a reliable, mature, and maintainable software product is the architecture; this is the design principle  
we believe in throughout. ZStack has made a lot of efforts in conceiving an architecture that can keep the software stable from
adding new features, routine operational mistakes, and tailoring for special needs; our former articles [The In-Process Microservices Architecture](microservices.html),
[The Versatile Plugin System](plugin.html), [The Workflow Engine](workflow.html), and [The Tag System](tag.html) have revealed some
of our attempts. However, we also fully understand the importance of testing in the software development. ZStack, at the day one,
set the goal that every feature must be guarded by test cases, testing must be entirely automated, and writing test cases should
be the only way to validate a new feature or any code change.

To achieve the goal, we split our testing system into three components: integration testing, system testing, and model-based testing,
by their focus and functionality:

* **Integration Testing System** is constructed based on [JUnit](http://en.wikipedia.org/wiki/JUnit) all using simulators; test cases reside
in ZStack Java source code; developers can easily use regular JUnit commands to start testing suites.

* **System Testing System** is an individual Python project called *zstack-woodpecker*, which is built based on ZStack APIs, and which tests everything
in a real hardware environment.

* **Model-based Testing system** is based on the theory of [Model-based Testing](http://en.wikipedia.org/wiki/Model-based_testing) and is a sub-project
in *zstack-woodpecker*. Test cases in this system will continuously executing APIs in a random manner until some predefined conditions meet. 

Beginning this one, we will have a series of three articles elaborating our testing architecture, to show you the way we guard every
ZStack feature.

### A little words for unit testing

Curious people may have asked in the heart that why we don't mention [Unit Testing](http://en.wikipedia.org/wiki/Unit_testing), which may be
the most famous testing concept every sober testing driven developer will emphasize. We do have unit testing, if you look at the later section
*Testing Framework*, you may get puzzled that why names used in commands are called *UnitTest* something but this article is named as integration testing.

Initially we thought our testing is unit testing, because every case is to verify a unique component instead of the whole software; for example,
the case `TestCreateZone` only tests the zone service, other components like VM service, storage service will not even get loaded. However, our way
doing the testing does differentiate from the traditional unit testing concept that is to test a small piece of code, that is normally
white box testing that aims to internal structures, and that is using methodology of mocking and stubbing; current ZStack has about 120 cases that match
this definition while the rest 500+ cases don't. Most test cases, even focusing on individual services or components, are more like integration
testing cases that will load multiple dependent services/components in order to conduct a testing activity; for example, to test the VM service, the storage
and network related services must be loaded. On the other side, many our test cases based on simulators are actually testing at the API level, which in
unit testing definition is a black-box testing apt to integration testing. Given those facts, we finally change our mind that
we are doing the integration testing while leaving many old names stay to UnitTest-wise.

### Integration Testing

From our prior experience, we deeply understand that a main reason developers keep ignoring testing is ***writing test cases is too hard, sometimes
even harder than implementing a feature***. When we design the integration testing system, a deliberate consideration is taking the burden
off developers as much as possible, and letting the system itself do most boring, cumbersome work.

There are two kind of repeated work for almost every test case. The one is preparing a minimal but workable software; for example, to test creating a zone, you
only need core libraries and the zone service loaded, it's not necessary to load other services as we don't need them. The another is preparing environment; for example,
a case of testing VM creation will need an environment that has a zone, a cluster, a host, storage, networks and all other necessary resources ready;
developers won't want to repeat boring things like creating a zone, adding a host before they can really test their stuff; ideally they can get a ready environment
with minor effort to concentrate on things they want to test. 

#### Component Loader

We solve all these problems by a framework built upon JUnit. First of all, as ZStack manages all components using [Spring](https://spring.io/),
we create a `BeanConstructor` that testers can on demand specify components they want to load:

{% highlight java %}
public class TestCreateZone {
    Api api;
    ComponentLoader loader;
    DatabaseFacade dbf;

    @Before
    public void setUp() throws Exception {
        DBUtil.reDeployDB();
        BeanConstructor con = new BeanConstructor();
        loader = con.addXml("PortalForUnitTest.xml").addXml("ZoneManager.xml").addXml("AccountManager.xml").build();
        dbf = loader.getComponent(DatabaseFacade.class);
        api = new Api();
        api.startServer();
    }
{% endhighlight %}

In above example, we add three Spring configuration files to `BeanConstructor`, which implied by their names will load components for
the account service, the zone service, and other necessary libraries included in `PortalForUnitTest.xml`. By this way, testers can tailor
the software to a minimal size that only contains needed components, in order to fast the testing process and make things easy to debug.

#### Environment Deployer 

To help testers prepare an environment that has all necessary dependencies for activities to be tested, we create a `Deployer` that
can read an XML configuration file to deploy a complete simulator environment:

{% highlight java %}
public class TestCreateVm {
    Deployer deployer;
    Api api;
    ComponentLoader loader;
    CloudBus bus;
    DatabaseFacade dbf;

    @Before
    public void setUp() throws Exception {
        DBUtil.reDeployDB();
        deployer = new Deployer("deployerXml/vm/TestCreateVm.xml");
        deployer.build();
        api = deployer.getApi();
        loader = deployer.getComponentLoader();
        bus = loader.getComponent(CloudBus.class);
        dbf = loader.getComponent(DatabaseFacade.class);
    }
    
    @Test
    public void test() throws ApiSenderException, InterruptedException {
        InstanceOfferingInventory ioinv = api.listInstanceOffering(null).get(0);
        ImageInventory iminv = api.listImage(null).get(0);
        VmInstanceInventory inv = api.listVmInstances(null).get(0);
        Assert.assertEquals(inv.getInstanceOfferingUuid(), ioinv.getUuid());
        Assert.assertEquals(inv.getImageUuid(), iminv.getUuid());
        Assert.assertEquals(VmInstanceState.Running.toString(), inv.getState());
        Assert.assertEquals(3, inv.getVmNics().size());
        VmInstanceVO vm = dbf.findByUuid(inv.getUuid(), VmInstanceVO.class);
        Assert.assertNotNull(vm);
        Assert.assertEquals(VmInstanceState.Running, vm.getState());
        for (VmNicInventory nic : inv.getVmNics()) {
            VmNicVO nvo = dbf.findByUuid(nic.getUuid(), VmNicVO.class);
            Assert.assertNotNull(nvo);
        }
        VolumeVO root = dbf.findByUuid(inv.getRootVolumeUuid(), VolumeVO.class);
        Assert.assertNotNull(root);
        for (VolumeInventory v : inv.getAllVolumes()) {
            if (v.getType().equals(VolumeType.Data.toString())) {
                VolumeVO data = dbf.findByUuid(v.getUuid(), VolumeVO.class);
                Assert.assertNotNull(data);
            }
        }
    }
}
{% endhighlight %}

In above TestCreateVm case, the deployer read a configuration file at *deployerXml/vm/TestCreateVm.xml* and deploy a full environment
that is ready to create a new VM; what is more, we actually let the deployer create the VM, as you don't see any code in
method `test` calling `api.createVmByFullConfig()`; what the tester really does is verifying the VM is correctly created with
conditions we specify in *deployerXml/vm/TestCreateVm.xml*. Now you see how easy it is, the tester only writes ~60 lines code and
have the most important part of IaaS software -- creating VM tested.

The configuration file TestCreateVm.xml in above example is like:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<deployerConfig xmlns="http://zstack.org/schema/zstack">
    <instanceOfferings>
        <instanceOffering name="TestInstanceOffering"
            description="Test" memoryCapacity="3G" cpuNum="1" cpuSpeed="3000" />
    </instanceOfferings>

    <backupStorages>
        <simulatorBackupStorage name="TestBackupStorage"
            description="Test" url="nfs://test" />
    </backupStorages>

    <images>
        <image name="TestImage" description="Test" format="simulator">
            <backupStorageRef>TestBackupStorage</backupStorageRef>
        </image>
    </images>

    <diskOffering name="TestRootDiskOffering" description="Test"
        diskSize="50G" />
    <diskOffering name="TestDataDiskOffering" description="Test"
        diskSize="120G" />

    <vm>
        <userVm name="TestVm" description="Test">
            <rootDiskOfferingRef>TestRootDiskOffering</rootDiskOfferingRef>
            <imageRef>TestImage</imageRef>
            <instanceOfferingRef>TestInstanceOffering</instanceOfferingRef>
            <l3NetworkRef>TestL3Network1</l3NetworkRef>
            <l3NetworkRef>TestL3Network2</l3NetworkRef>
            <l3NetworkRef>TestL3Network3</l3NetworkRef>
            <defaultL3NetworkRef>TestL3Network1</defaultL3NetworkRef>
            <diskOfferingRef>TestDataDiskOffering</diskOfferingRef>
        </userVm>
    </vm>

    <zones>
        <zone name="TestZone" description="Test">
            <clusters>
                <cluster name="TestCluster" description="Test">
                    <hosts>
                        <simulatorHost name="TestHost1" description="Test"
                            managementIp="10.0.0.11" memoryCapacity="8G" cpuNum="4" cpuSpeed="2600" />
                        <simulatorHost name="TestHost2" description="Test"
                            managementIp="10.0.0.12" memoryCapacity="4G" cpuNum="4" cpuSpeed="2600" />
                    </hosts>
                    <primaryStorageRef>TestPrimaryStorage</primaryStorageRef>
                    <l2NetworkRef>TestL2Network</l2NetworkRef>
                </cluster>
            </clusters>

            <l2Networks>
                <l2NoVlanNetwork name="TestL2Network" description="Test"
                    physicalInterface="eth0">
                    <l3Networks>
                        <l3BasicNetwork name="TestL3Network1" description="Test">
                            <ipRange name="TestIpRange1" description="Test" startIp="10.0.0.100"
                                endIp="10.10.1.200" gateway="10.0.0.1" netmask="255.0.0.0" />
                        </l3BasicNetwork>
                        <l3BasicNetwork name="TestL3Network2" description="Test">
                            <ipRange name="TestIpRange2" description="Test" startIp="10.10.2.100"
                                endIp="10.20.2.200" gateway="10.10.2.1" netmask="255.0.0.0" />
                        </l3BasicNetwork>
                        <l3BasicNetwork name="TestL3Network3" description="Test">
                            <ipRange name="TestIpRange3" description="Test" startIp="10.20.3.100"
                                endIp="10.30.3.200" gateway="10.20.3.1" netmask="255.0.0.0" />
                        </l3BasicNetwork>
                    </l3Networks>
                </l2NoVlanNetwork>
            </l2Networks>

            <primaryStorages>
                <simulatorPrimaryStorage name="TestPrimaryStorage"
                    description="Test" totalCapacity="1T" url="nfs://test" />
            </primaryStorages>

            <backupStorageRef>TestBackupStorage</backupStorageRef>
        </zone>
    </zones>
</deployerConfig>
{% endhighlight %}

#### Simulator

Most integration testing cases are built on simulators; every resource that needs to communicate with backend devices has a simulator implementation;
for example, KVM simulator, virtual router VM simulator, NFS primary storage simulator. Because current resource backend are all Python based
HTTP servers, most simulators are constructed using Apache Tomcat embedded HTTP server. A snippet of KVM simulator is like:

{% highlight java %}
    @RequestMapping(value=KVMConstant.KVM_MERGE_SNAPSHOT_PATH, method=RequestMethod.POST)
    public @ResponseBody String mergeSnapshot(HttpServletRequest req) {
        HttpEntity<String> entity = restf.httpServletRequestToHttpEntity(req);
        MergeSnapshotCmd cmd = JSONObjectUtil.toObject(entity.getBody(), MergeSnapshotCmd.class);
        MergeSnapshotRsp rsp = new MergeSnapshotRsp();
        if (!config.mergeSnapshotSuccess) {
            rsp.setError("on purpose");
            rsp.setSuccess(false);
        } else {
            snapshotKvmSimulator.merge(cmd.getSrcPath(), cmd.getDestPath(), cmd.isFullRebase());
            config.mergeSnapshotCmds.add(cmd);
            logger.debug(entity.getBody());
        }

        replyer.reply(entity, rsp);
        return null;
    }

    @RequestMapping(value=KVMConstant.KVM_TAKE_VOLUME_SNAPSHOT_PATH, method=RequestMethod.POST)
    public @ResponseBody String takeSnapshot(HttpServletRequest req) {
        HttpEntity<String> entity = restf.httpServletRequestToHttpEntity(req);
        TakeSnapshotCmd cmd = JSONObjectUtil.toObject(entity.getBody(), TakeSnapshotCmd.class);
        TakeSnapshotResponse rsp = new TakeSnapshotResponse();
        if (config.snapshotSuccess) {
            config.snapshotCmds.add(cmd);
            rsp = snapshotKvmSimulator.takeSnapshot(cmd);
        } else  {
            rsp.setError("on purpose");
            rsp.setSuccess(false);
        }
        replyer.reply(entity, rsp);
        return null;
    }
{% endhighlight %}

Every simulator has a configuration object like `KVMSimulatorConfig` that testers can use to control simulator behaviors.

#### Testing Framework

As all test cases are actually JUnit test cases, testers can run each case individually using normal JUnit commands, for example:

    [root@localhost test]# mvn test -Dtest=TestAddImage
    
And all cases in a test suite can be executed in one command, for example:

    [root@localhost test]# mvn test -Dtest=UnitTestSuite 
    
<img src="../../images/blogs/scalability/testing1.png" class="center-img img-responsive">

Cases can also be executed in a group, for example:
    
    [root@localhost test]# mvn test -Dtest=UnitTestSuite -Dconfig=unitTestSuiteXml/eip.xml
    
An XML configuration file lists cases in the group, for example, the above eip.xml is like:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<UnitTestSuiteConfig xmlns="http://zstack.org/schema/zstack" timeout="120">
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip1"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip2"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip3"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip4"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip5"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip6"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip7"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip8"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip9"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip10"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip11"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip12"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip13"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip14"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip15"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip16"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip17"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip18"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip19"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip20"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip21"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip22"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip23"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip24"/>
    <TestCase class="org.zstack.test.eip.TestVirtualRouterEip25"/>
    <TestCase class="org.zstack.test.eip.TestQueryEip1"/>
    <TestCase class="org.zstack.test.eip.TestEipPortForwardingAttachableNic"/>
</UnitTestSuiteConfig>
{% endhighlight %}

Multiple cases can also be executed in one command by feeding their names, for example:

    [root@localhost test]# mvn test -Dtest=UnitTestSuite -Dcases=TestAddImage,TestCreateTemplateFromRootVolume,TestCreateDataVolume
    
    
### Summary

In this article, we introduced the first part of ZStack automation testing system -- integration testing. With it, developers
can write code with 100% confidence. And writing test cases is no longer a daunting and boring task; developers can finish most
cases with less than 100 lines code, which is easy and efficient;






