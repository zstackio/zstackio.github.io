---
layout: post
title:  "Networking Model 2: Virtual Router Network Service Provider"
date:   2015-4-4 15:44:00
author: Frank Zhang
categories: blog
category: en
---

*In ZStack's networking model, OSI layer 4 ~ 7 network services are implemented as small plugins from different service providers.
The default provider, called virtual router provider, uses a customized Linux VM as a virtual appliance to provide
network services including DHCP, DNS, SNAT, EIP, and Port Forwarding for every L3 network. The way of using virtual router VMs has advantages
of no single failure point, and no special requirements for physical infrastructure so that users can realize various network services
on commodity hardware without purchasing expensive equipments.*

### Overview

As mentioned in [Networking Model 1: L2 and L3 Network](network-l2.html), ZStack designs network services as small plugins
that vendors can selectively implement network services supported by their hardware or software by creating network service providers.
By default, ZStack comes with a provider called virtual router provider that implements all network services using an appliance
VM -- Virtual Router VM.

>***Note**: In fact ZStack has another provider called security group provider that provides a distributed firewall. We call
the virtual router provider as the default provider because it provides most common network services a cloud needs.*

There are a few ways to implement network services in IaaS software. One way is using central, powerful networking nodes that are usually
physical servers; by congregating traffics from different tenants, networking nodes are responsible for traffic isolation
and providing network services using technologies like Linux network namespace. Another way is using dedicated networking hardware, for
example, programmable physical switch, physical firewall, and physical load balancer, which will require users to purchase
specific hardware. The last way is using [Network Functions Virtualization(NFV)](http://en.wikipedia.org/wiki/Network_Functions_Virtualization),
like ZStack's virtual router VMs, to virtualize network services on commodity x86 servers.

Each way has strengths and weaknesses; we choose the NFV as our solution with below considerations:

1. **Minimal infrastructure requirements**: the solution should have small or zero requirements for user's physical infrastructure;
that is to say, users should not have to change existing infrastructure or plan special infrastructure to cater to the networking model
of IaaS software. We don't want to force users to buy specific hardware or require them to put special functional servers in front
of a group of hosts. 

2. **No single failure point**: the solution should provide a distributed way having no single failure point. A networking node
crash should only affect its owner tenant and should not impact any other tenants. 

3. **Stateless**: networking nodes should be stateless, so the IaaS software can easily destroy and re-create them after unexpected errors
happened.

4. **Easy for high availability(HA)**: the solution should be easy for HA that tenants can require deploying redundant networking nodes.

5. **Hypervisor ignorant**: the solution should not depend on hypervisors and should seamlessly work for major hypervisors including KVM,
Xen, VMWare, and Hyper-V.

6. **Reasonable performance**: the solution should provide reasonable networking performance for most use cases. 

The NFV solution backed by virtual router VMs fulfills all above considerations. We choose it as the default implementation while providing
developers possibilities of adopting other solutions. 

### Virtual Router VM

*Appliance VMs* are special VMs that run customized Linux operating systems with special agents to help manage a cloud. The *Virtual
Router VM* is the first implementation of the concept of appliance VM. The idea, in simple words, is to create a virtual router VM that provides all network services
on an L3 network at the first time a user VM is being created, as long as the L3 network has enabled network services from the virtual router provider. Every virtual router VM
contains a Python agent receiving commands from ZStack management nodes through HTTP protocol, and offers network services including DHCP, DNS, SNAT, EIP, and Port
Forwarding to user VMs on the same L3 network.

<img src="../../images/blogs/scalability/vr1.png" class="center-img img-responsive">

The above picture shows a network topology with all network services enabled on the guest L3 network. A virtual router VM typically has three L3 networks:

1. **A management L3 network** is the network that ZStack management nodes communicate to the Python agent inside the virtual router VM through HTTP protocol, which is the mandatory network
every virtual router will have.

2. **A public L3 network** is an optional network that can reach internet and that provides the default routing inside the virtual router VM. If omitted, the management
L3 network is used as both management network and public network. 

>***The public network doesn't need to be publicly accessible**: a public network that bridges user VMs and the outside world(the internet or other networks
of the datacenter) does NOT need to be publicly accessible. For example, a network 10.0.1.0/24 can be a public network when bridging a
guest L3 network(192.168.1.0/24) isolated by a VLAN and rest networks (10.x.x.x/x) in the datacenter, though it cannot be reached by the internet.*

3. **A guest L3 network** is the network to which user VMs connect; traffics related to network services flow amid user VMs and the virtual router VM
through this network.

Up to different network service combinations, the number of L3 networks is variable. For example, if only DHCP and DNS are enabled, the network topology
becomes:

<img src="../../images/blogs/scalability/vr2.png" class="center-img img-responsive">

because without NAT related services(e.g. SNAT, EIP), user VMs don't need a separate, isolated guest L3 network but directly connect to the public network.

>***Note**: you can, of course, create an isolated guest L3 network with only DHCP and DNS services, VMs on the guest network can get IPs but cannot reach
outside world due to lack of SNAT.*

If we omit the public L3 network in above picture, the network topology becomes:

<img src="../../images/blogs/scalability/vr3.png" class="center-img img-responsive">

Users can use a `virtual router offering` to configure the management L3 network, the public L3 network, CPU speed, and memory size of a virtual router VM.
When creating a virtual router VM, ZStack will try to find an appropriate virtual router offering; a system tag `guestL3Network::{l3NetworkUuid}` can be used to
specify a virtual router offering for a guest L3 network, if no designated offering found, a default offering will be used.

>***Note**: For system tag, read more in [The Tag System](tag.html).*

In this ZStack version(0.6), a guest L3 network can have one and only one virtual router VM; for a multi-tired network environment, several virtual router
VMs will serve different tiers:

<img src="../../images/blogs/scalability/vr4.png" class="center-img img-responsive">

ZStack management nodes will send commands to the Python agent inside a virtual router VM when user VMs start or stop, to realize network services using
dnsmasq and ipatbles. A snippet of iptables rules is like:

<img src="../../images/blogs/scalability/vr5.png" class="center-img img-responsive">

>***Note**: In future ZStack version, network services: load balancing, VPN, and GRE tunnel will be implemented using virtual router VMs
as well. And the virtual router VM will also be the core element of the Virtual Private Cloud(VPC) implementation.*


### How the virtual router VM meets the considerations

Let's review our aforementioned considerations and see how virtual router VMs can fulfill them.

1. **Minimal infrastructure requirements**: virtual router VMs has zero requirement to datacenter's physical infrastructure. They are
just VMs similar to user VMs that can be created on physical hosts. Administrators don't have to plan for complex hardware interlinking
for using them.

2. **No single failure point**: a virtual router VM is per an L3 network; if it crashes for some reason, only user VMs on that L3 network
will be affected, without any impact on other L3 networks. In most use cases, an L3 network will belong to a single tenant, that is to say,
only one tenant will suffer the failure of a virtual router VM. It is particular useful when the L3 network is under malicious attack, for
example, DDOS; attackers cannot bring down the entire network in a cloud by attacking a single tenant.

3. **Stateless**: virtual router VMs are stateless, all configurations, which can be rebuilt anytime, are from ZStack management nodes.
Users have various choices to rebuild configurations in virtual router VMs, for example, stopping/starting them, destroying/re-creating
them, or calling the ReconnectVirtualRouter API.

4. **Easy for high availability(HA)**: two virtual router VMs that work as master-slave using [Virtual Router Redundancy Protocol](http://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol)
can be deployed to achieve HA. Once the master fails the slave will automatically take over, which makes downtime of the network negligible.

   >***Note**: This feature of redundant virtual router VMs is not supported in the current version(0.6).*

5. **Hypervisor ignorant**: virtual router VMs don't depend on hypervisors. ZStack has a script that can build templates
of virtual router VMs for major hypervisors.

6. **Reasonable performance**: as using Linux, virtual router VMs can achieve reasonable network performance that the Linux
can give. Users can configure a `virtual router offering` with more CPUs and big memory size, to assign enough computing capacity
to virtual router VMs for heavy network traffics. The main performance concern is about traffics
between the public nic of a virtual router VM and user VMs behind, when the virtual router VM provides NAT related services including SNAT, EIP, and Port Forwarding.
In most cases, as a public IP normally has tens of megabytes bandwidth, the virtual router VM is competent for decent performance.  

   However, when traffics through the virtual router VM requires extremely high bandwidth, the significant network performance downgrade
   caused by virtualization is inevitable; nevertheless, two technologies can relieve the problem:

   a. LXC/Docker: as ZStack can support multiple hypervisors once LXC or Docker is supported, as lightweight virtualization technology,
   virtual router VMs run as containers can achieve native approximate performance. 

   b. SR-IOV: virtual router VMs can be assigned with physical nics using SR-IOV, to get the native network performance.

   >***Note**: LXC/Docker and SR-IOV are not supported in the current version(0.6).*

   Besides, users can utilize `system tags` and `virtual router offering` to control host allocation for virtual router VMs; what's more,
   users can even dedicate a physical server to one virtual router VM; accompanying with LXC/Docker or SR-IOV, the virtual router VM can get
   close to native network performance a Linux server can give.

   Regardless, software solution has natural weaknesses of performance; users may choose a mixed solution for high-performance networks;
   for example, using virtual router VMs for only DHCP and DNS, and leaving performance-sensitive services to providers that use
   physical hardware.

### Summary

In this article, we demonstrated ZStack's default network service provider: virtual router provider, explaining how it works
and elaborating how it meets our considerations about network services. With virtual router VMs, ZStack takes an ideal balance
between flexibility and performance, we believe 90% users can easily and precisely construct their network services on commodity
hardware. 







