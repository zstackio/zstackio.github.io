---
layout: post
title:  "ZStack Roadmap"
date:   2015-6-9
categories: blog
tags: en
author: Frank Zhang
---

Since the first release 0.6, we received a lot of feedback from our users and customers. Many people want us to post a
roadmap so they can plan their production environment in line with our feature development process. Here I would like to
share an initial version. Feedback is welcome(please post them in the comments).

## Roadmap

<table class="table table-bordered black-table">
  <tr>
    <td><b>RELEASE</b></td>
    <td><b>DATE</b></td>
    <td><b>FEATURES</b></td>
  </tr>
  <tr>
    <td>0.7</td>
    <td>6/20/2015</td>
    <td>
        <p>ISCSI primary storage</p>
        <p>Static IP</p>
        <p>Seamless upgrade</p>
    </td>
  </tr>
  <tr>
    <td>0.8</td>
    <td>7/20/2015</td>
    <td>
        <p>Local primary storage</p>
        <p>Dynamic network attaching/detaching</p>
        <p>Change instance offering</p>
        <p>Monitoring tech-preview</p>
    </td>
  </tr>
  <tr>
    <td>0.9</td>
    <td>9/20/2015</td>
    <td>
        <p>Ceph primary storage/backup storage</p>
        <p>Console proxy appliance VM</p>
        <p>User account system(API open)</p>
    </td>
  </tr>
  <tr>
    <td>1.0</td>
    <td>10/20/2015</td>
    <td>
        In planning
    </td>
  </tr>
</table>

## Details

### 0.7

#### ISCSI Primary Storage

Support ISCSI storage as primary storage. At KVM side, up to different libvirt version, the iscsi devices are exposed through blk-scsi
driver or virtio-scsi driver. The backend is an open framework that allows different ISCSI servers to be plugged in. In this version, a
default implementation based on BTRFS + Open-ISCSI is provided, which builds an iscsi server using a Linux server.

#### Static IP

Allow users to specify an IP address a VM when calling API CreateVm, using a system tag.

#### Seamless Upgrade

Allow previous ZStack versions to be upgraded to current and later versions.

### 0.8

#### Local Storage

Support local disk as primary storage.

#### Dynamic Network Attaching/Detaching

Allow users to hot-plug/unplug a nic to a VM.

#### Change Instance Offering

Allow users to change an instance offering of a VM, in order to change its CPU and memory capacity.

#### Monitoring tech-preview

A tech-preview version of monitoring system

### 0.9

#### Ceph Primary Storage/Backup Storage

Support Ceph as unified primary storage and backup storage. That is to say, users can use one Ceph deployment as both
primary storage and backup storage.

#### Console proxy appliance VM

Using appliance VMs as console proxies, so users can use a public network to allow remote access to VMs' consoles.

#### User account system(API open)

Enable API of user-account system that is similar to current AWS IAM.

