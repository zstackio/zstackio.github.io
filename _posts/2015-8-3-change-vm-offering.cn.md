---
layout: post.cn
title:  "ZStack 修改云主机模板"
date:   2015-8-3
categories: blog
author: yongkang
category: cn_blog
---
### 介绍
从0.8版本开始，当用户选择某个模板（CPU/内存配置）创建云主机之后，如果需要增加CPU或者内存的数量，可以根据需求修改当前云主机的模板。
更改模板后修改后，仅需要重启云主机即可生效。该功能支持通过UI和命令行界面来修改模板。

###通过UI修改模板

<img src="/images/0.8/6.png" class="center-img img-responsive">

1. 选择一个云主机点击 'Action'
2. 点击'Change Instance Offering'

<img src="/images/0.8/7.png" class="center-img img-responsive">

1. 选择需要的云主机配置模板
2. 点击'Change'
3. 需要重启云主机以让它生效

###通过zstack-cli修改模板

    >>>ChangeInstanceOffering vmInstanceUuid=f9837cfbde574a7ab512ab3283d8da60 instanceOfferingUuid=d791a3f662ac48a99b9e998136eed2a1
    
第一个vmInstanceUuid就是你想要改变的云主机的UUID，第二个instanceOfferingUuid就是你希望改变之后的模板的UUID。

