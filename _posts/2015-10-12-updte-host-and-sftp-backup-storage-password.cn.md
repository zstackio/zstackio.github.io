---
layout: post.cn
title:  "更新计算节点和备份存储的密码"
date:   2015-10-12
categories: blog
author: Yongkang You
category: cn_blog
---

当用户更新了计算节点（Host）或者备份存储（Sftp Backup Storage）密码后，如果没有通知ZStack，
之后可能会遇到ZStack重连该资源失败的问题。
所以用户在更改资源的用户密码后需要通过ZStack的API来更新ZStack记录的这些资源的root用户密码。

## 更新资源root密码的操作如下：

1. 登录zstack-cli

`zstack-cli LogInByAccount accountName=admin password=password`

2. 更新Host节点用户密码

`zstack-cli UpdateKVMHost uuid=YOUR_KVM_HOST_UUID password=YOUR_HOST_NEW_ROOT_PASSWORD`

3. 重连Host节点

`zstack-cli ReconnectHost uuid=YOUR_KVM_HOST_UUID`

4. 更新备份存储用户密码

`zstack-cli UpdateSftpBackupStorage uuid=YOUR_SFTP_BS_UUID password=YOUR_SFTP_BS_NEW_ROOT_PASSWORD`

5. 重连备份存储

`zstack-cli ReconnectSftpBackupStorage uuid=YOUR_SFTP_BS_UUID`

## 一次性更改主机密码并更新ZStack

因为zstack-cli是一个可以在shell执行的命令行工具，所以用户可以用shell script做一个wrapper。
用户使用该wrapper就可以把更改主机root密码和更新ZStack数据库的操作在一个脚本里完成。例如：

```
[root@localhost ~]# cat change_passwd_wrapper.sh
#Execute in management node. The target_host_ip is the host IP address recorded
# in ZStack. You need to install command jq to parse JSON.
which jq &>/dev/null|| (echo "please install jq firstly" && exit 1)
target_host_ip=$1
new_passwd=$2
ssh $target_host_ip "echo \"root:$new_passwd\" | chpasswd"
zstack-cli LogInByAccount accountName=admin password=password
host_uuid=`zstack-cli QueryHost managementIp=$target_host_ip |jq '.inventories[0].uuid'`
zstack-cli UpdateKVMHost uuid=$host_uuid password=$new_passwd
zstack-cli ReconnectHost uuid=$host_uuid
```

该脚本的使用方法是：

`[root@localhost ~]# ./change_passwd_wrapper.sh 10.0.101.2 new_passwd`

该命令首先会ssh到目标的host（10.0.101.2）上用chpasswd命令来更改root的密码为new_passwd。
然后会调用ZStack的API把相应的信息更新到ZStack的数据库中，并且重连Host。
需要注意的是这里的IP地址需要和Host在ZStack中使用的managementIp为相同的字符串，否则更新ZStack会失败。
另外该脚本中使用了`jq`来解析JSON字符串，所以用户需要预先安装jq。

用户在实际使用ZStack环境中如果遇到问题，可以到ZStack官方QQ群：**410185063** 寻求更多帮助。
