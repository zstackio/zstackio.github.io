---
layout: post
title:  "Why Do We Need New IaaS Software Other Than OpenStack"
date:   2015-4-5
categories: blog
category: en
author: Frank Zhang
---

Three years ago, when I was working on another IaaS software, my friend joked: "you guys are making a product
killing IT administrators' job." I did think so then. In my opinion, enterprises could
be liberated from boring tasks of maintaining old-fashion datacenters, by adopting IaaS technology and moving
every underlying infrastructure to software-defined datacenter. Thereby, manpower is transferred to more revenue-driven work such as 
applications that drive companies' core business, and leaves only a few in operations team in charge of running the entire infrastructure.
However, three years later, IaaS software has not impacted the administrators' job. Ironically, it has created a lot of new jobs.
Nowadays, businesses adopting private clouds based on IaaS need not only an operations team to daily maintain their
infrastructure, but also a dev team or a consultant company to maintain the IaaS software itself. This may be good for
engineers, as people with such skills are easier to get good pay (searching OpenStack on online hiring websites
will prove this), but sad for developers like me who are supposed to create something to relieve life.

Complexity and stability are two major problems that have been plaguing IaaS software for a long time. Many different opinions have
been formed to explain the situation.

A popular point has been that a cloud is supposed to be complex, because
it's a distributed system managing individual complex sub-systems including compute, networking, and storage. I partially agree.
The complexity of a cloud doesn't mean installation of IaaS software should be complex; doesn't mean the upgrading should be complex;
doesn't mean the maintenance should be complex; and certainly doesn't mean the usage should be complex. In 2011, I spent one week reading and
following OpenStack documentation to setup my first OpenStack cloud, but failed; I eventually managed to bring up a POC environment
with the help of DevStack. In 2014, I tried again to check out Neutron, but even DevStack failed this time.
OpenStack is not alone in this; you only have to browse through users groups of other IaaS software to find the long list of users complaining about their
complexity. These complaints do not touch the real complexities entailed by massive physical servers, networking topologies, and
distributed storage. Most of them are actually simply trying to setup a POC environment on a single machine. The complexity stems from
the design of the software itself, stems from lack of end users' perspectives.

One of my friends, who is in charge of a team managing an OpenStack cloud with 2000 physical servers in a web company, told me
the complexity was not a big deal to them, at least not making them feel too uncomfortable. I totally understand that. Because
his team is full of OpenStack experts who have learned tricks, workarounds, and caveats of this software in past two years and
are now used to it. But the complexity does scare away traditional enterprises that want to evolve their IT infrastructure into
the cloud era. Plenty of voices from inside OpenStack community have warned this, some good reads are [Open Source and OpenStack: Complexity and lack of knowledge raise risks](https://www.mirantis.com/openstack-portal/external-news/open-source-openstack-complexity-lack-knowledge-raise-risks/),
[OpenStack's Next Move Is To Remove Complexity](http://tesora.com/blog/openstacks-next-move-remove-complexity),
[We Need To Simplify OpenStack](http://www.rackspace.com/blog/we-need-to-simplify-openstack/); find more by searching
"OpenStack complexity". Though we have seen a couple of success stories,
for example, eBay(my friend in eBay's OpenStack team told me their main task in 2014 was upgrading OpenStack from Folsom to Havana), not
every traditional enterprise can afford a DevOps team running vital infrastructure on their own risk.  

Can this be fixed in OpenStack? Perhaps, but not easy. The complexity is not because OpenStack community lacks talent or skilled developers, but
is rooted in its design principles, philosophy, and architectural thoughts from the very beginning. Fixing the complexity is not just
to patch several projects, but to re-design a lot of things from scratch; however, it's not OpenStack then, you can call it NewStack,
FutureStack or whatever stack, but not OpenStack anymore. There is a lot to say about this topic which I would like to address in another
post.

In terms of stability, even my aforementioned friend who said the complexity wasn't their paint points admitted it
did matter much; their main suffering is unexpected failures including weird API errors, unstable clusters, frozen message bus,
fragile networking and some I can't recall. It's not a secret. Ubuntu publicly [described](https://plus.google.com/107021066102930532296/posts/U1sU3zEZAiQ)
OpenStack as "fragile" in its summit in HK, and similar complaints can be found in various OpenStack discussion forums.

I admit as a distributed system integrating a variety of external sub-systems, IaaS software must confront more challenges than
standalone applications. I have learned this lesson in my former experience working in this field. I've watched OpenStack
community closely for years, and deeply feel how a crowded community can be distracted from constructive architectural thoughts. Three years
ago a thread on [RabbitMQ Scaling](http://lists.openstack.org/pipermail/openstack-dev/2012-November/002730.html) caught my attention because
I couldn't imagine a message broker capable of handling 20k ~ 100k message per second failed in an IaaS software; it turned out
OpenStack used temporary queues that would entail dynamic construction and destruction of queues/exchanges; I was curious how this
architecture decision was made; though it's theoretically a valid pattern that you could find in AMQP specification or pattern books
like [Enterprise Integration Patterns](http://books.google.com/books/about/Enterprise_Integration_Patterns.html?id=qqB7nrrna_sC), developers'
intuition would tell you it might cause stability and performance issue; I was delighted that somebody raised this topic with decent
evidences and actively worked on it. Unfortunately, yesterday, when going through the code in oslo.messaging and the [documentation](http://docs.openstack.org/developer/nova/devref/rpc.html),
I found it still worked in the old way. This fundamental problem was stuck there while a bunch of projects emerged in OpenStack in
past three years. This is not hard to observe; simply flooding your OpenStack setup with 10,000 concurrent APIs creating 1 million VMs
will tell you what is going on; test it with simulator, you don't need to create real VMs. Without a stable transportation layer, you cannot
expect a stable system. Stability of IaaS software is a long topic; I'd like to talk more in another post.

Can the stability issue be fixed in OpenStack? Perhaps, but not easy too. I don't think the issue can be fixed without re-designing major components
from scratch. People may argue OpenStack can slow down feature development and focus on fixing bugs, and with comprehensive
testing, it can reach a stable stage. That's partly true; because once you reopen the valve of features, the issue will come back again.
A robust software should be able to remain stable in the race of adding features. "Software's stability is guaranteed by its architecture,
not by testing," said my partner, who runs QA teams of Linux kernel and Xen hypervisor for many years.

Given the frustrating situation of current IaaS software, we think it's time to build something new that takes those issues into
account in the architecture design; we hope the new IaaS software fulfill goals of:

* **Simplicity**. IT administrators should be able to create their cloud on commodity hardware from a single physical server to
hundreds of thousands of servers, without special skills.
* **Robust**. The software must be stable for long-term operation while allowing developers to add new useful functions. 
* **Flexibility**. Besides the well-known Amazon EC2 model, the software should be able to implement new models that fit
traditional enterprise needs. 

My friend, who is the CEO of an OpenStack company, told me I was not going to succeed because his company used to aim those goals
but finally realized it's impossible. I told him that's the reason we decided to start a new thing instead of pining to OpenStack.
We believe we can do it because we have learned a lot of lessons from pioneers of this field, standing on shoulders of those
giants.

In the very beginning of our open source project -- [ZStack](http://zstack.org), we didn't hurry to add features to make the project apparently feature-rich and
mature, because we knew these fancy things like VPC, ELB, VPN, Ceph, and Swift would not be obstacles as current IaaS software had
successfully integrated them. Instead, we spent our major time in conceiving an architecture that can solve issues of complexity,
stability, and flexibility from the root. For example, we designed our message transportation layer to reliably serve tens of thousands
concurrent requests, designed a versatile plugin system that avoids impact of adding or removing features, designed a
full-automation mechanism that frees administrators from installing, configuring, upgrading, and managing agents on massive physical
servers, designed a workflow engine that can rollback completed changes on error, and a long list I can't elaborate here. I know you
may ask me to show you the details, as we claim to have cures for challenges mentioned above. Despite we have sixteen blogs demonstrating
our architecture on our [website](http://zstack.org/blog), it's still a little difficult for people to associate them with concrete issues like
complexity and stability. I will post other two blogs specific to those topics explaining how we tackle them at the architecture level.

Recently, the emergence of Docker (and other container based technologies) and the thriving public clouds may shake people's conviction of
IaaS based private clouds. It's an interesting topic that I'd like to discuss in a future post too.

At last, I want to say that even I share some negative thoughts of OpenStack, I absolutely do not mean to offend this great project.
Instead, I have paid close attention to it for years, with my respect. Without the effort of OpenStack community, the IaaS industry will
remain primitive; administrators will still struggle to manage infrastructure with ad-hoc scripts. Though OpenStack encounters
some difficulties, that's just because it's the pioneer in this field and have few things to reference. We are lucky. We learned a lot
from current IaaS software, and you will see in my future posts that we definitely borrow some brilliant ideas from them.

We name our project as **Z**Stack because we hope it's the last effort to make a simple, reliable, and flexible IaaS software.

Well, that's my two cents.
