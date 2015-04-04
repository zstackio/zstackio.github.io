---
title: Documentation
layout: docPage
---

## Feature Matrix

In current version (0.6), the supported features are listed as follows:


<table class="table black-table">
  <thead>
    <th>Category</th>
    <th>Name</th>
    <th>Note</th>
  </thead>
  
  <tbody>
    <tr>
      <td rowspan=3>Compute</td>
      <td>Zone</td>
      <td>A logic group of resources. Similar to Amazon EC2 availability zone</td>
    </tr>
    <tr>
      <td>Cluster</td>
      <td>A logic group of hosts</td>
    </tr>
    <tr>
      <td>Host</td>
      <td>only KVM support</td>
    </tr>
    
    <tr>
      <td rowspan=5>Storage</td>
      <td>Primary Storage</td>
      <td>Block storage for virtual machine volumes. Similar to OpenStack's Cinder</td>
    </tr>
    <tr>
      <td>Backup Storage</td>
      <td>Storage for storing images. Similar to OpenStack's Glance in combination with Image</td>
    </tr>
    <tr>
      <td>Image</td>
      <td>Templates for creating volumes. Similar to OpenStack's Glance in combination with Backup Storage</td>
    </tr>
    <tr>
      <td>Volume</td>
      <td>Virtual disks</td>
    </tr>
    <tr>
      <td>Volume Snapshot</td>
      <td>Snapshots of volumes</td>
    </tr>
    
    <tr>
      <td rowspan=2>Networking</td>
      <td>L2 Network</td>
      <td>Layer2 broadcast domains for traffic isolation. Supporting non-VLAN and VLAN</td>
    </tr>
    <tr>
      <td>L3 Network</td>
      <td>Subnets with network services</td>
    </tr>
    
    <tr>
      <td rowspan=6>Network Services</td>
      <td>DHCP</td>
      <td></td>
    </tr>
    <tr>
      <td>DNS</td>
      <td></td>
    </tr>
    <tr>
      <td>SNAT</td>
      <td>Source NAT</td>
    </tr>
    <tr>
      <td>Elastic Port Forwarding</td>
      <td>Port forwarding rules that can be bound to virtual machines dynamically</td>
    </tr>
    <tr>
      <td>EIP</td>
      <td>Similar to Amazon EC2 elastic IP</td>
    </tr>
    <tr>
      <td>Security Group</td>
      <td>A distributed firewall. Similar to Amazon EC2 security group</td>
    </tr>
    
    <tr>
      <td rowspan=2>Configurations</td>
      <td>Instance Offering</td>
      <td>A specification for creating virtual machines. Similar to OpenStack flavor</td>
    </tr>
    <tr>
      <td>Disk Offering</td>
      <td>A specification for creating volumes</td>
    </tr>
  </tbody>
</table>
