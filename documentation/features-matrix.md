---
title: ZStack Feature Matrix
layout: docPage
---

## Feature Matrix

In current version (1.3), the supported features are listed as follows:


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
      <td rowspan=6>Storage</td>
      <td>Primary Storage</td>
      <td>Block storage for virtual machine volumes. Similar to OpenStack's Cinder. Support NFS, Local Storage, iSCSI, Shared Mount Storage, Ceph and Fusionstor. </td>
    </tr>
    <tr>
      <td>Backup Storage</td>
      <td>Storage for storing images. Similar to OpenStack's Glance in combination with Image. Support Sftp, Ceph and Fusionstor.</td>
    </tr>
    <tr>
      <td>Image</td>
      <td>Templates for creating volumes. Similar to OpenStack's Glance in combination with Backup Storage. Support raw, Qcow2 and ISO.</td>
    </tr>
    <tr>
      <td>Volume</td>
      <td>Virtual disks. Supporting live attach/detach</td>
    </tr>
    <tr>
      <td>Volume Snapshot</td>
      <td>Snapshots of volumes</td>
    </tr>
    <tr>
      <td>ISO</td>
      <td>Live attach/detach ISO. Adjust VM boot order. </td>
    </tr>
    
    <tr>
      <td rowspan=2>Networking</td>
      <td>L2 Network</td>
      <td>Layer2 broadcast domains for traffic isolation. Supporting non-VLAN and VLAN</td>
    </tr>
    <tr>
      <td>L3 Network</td>
      <td>Subnets with network services. Support live attach/detach L3 Network to VM.</td>
    </tr>
    
    <tr>
      <td rowspan=10>Network Services</td>
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
      <td>Elastic Load Balancer</td>
      <td>Similar to Amazon EC2 Elastic Load Balancer</td>
    </tr>
    <tr>
      <td>Distributed EIP</td>
      <td>Similar with EIP, but not using single Virtual Router</td>
    </tr>
    <tr>
      <td>Distributed DHCP</td>
      <td>Similar with DHCP, but not using single Virtual Router</td>
    </tr>
    <tr>
      <td>User Data</td>
      <td>Similar with Amazon Cloud-init</td>
    </tr>
    
    
    <tr>
      <td>Account & Identity</td>
      <td>Identity Management</td>
      <td>Resource access control for accounts and users. Similar to Amazon IAM</td>
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
