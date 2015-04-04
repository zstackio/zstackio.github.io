---
title: Documentation
layout: docPage
---

## Unable to install a RabbitMQ server

### Symptom

When installing RabbitMQ using `zstack-ctl install_rabbitmq` you may encounter a failure caused by
unable to start RabbitMQ server, the error message in /tmp/zstack_installation.log is like:

    TASK: [enable RabbitMQ] *******************************************************
    failed: [192.168.0.199] => {"failed": true}
    msg: Starting rabbitmq-server: FAILED - check /var/log/rabbitmq/startup_{log, _err}
    rabbitmq-server.
    
    
This is most likely caused by you have changed your hostname and a previous RabbitMQ server still retains an old
hostname. RabbitMQ relies on hostname as node name, changing hostname may cause issues that you can find details
in [RabbitMQ in Amazon  EC2](http://www.rabbitmq.com/ec2.html)(see details in section "Issues with hostname").

### Solution

#### 1. Stop RabbitMQ server

As the tool `rabbitmqctl` may have failed because of hostname change, you may need to stop all running RabbitMQ related
processes by Linux `kill` command with `-9` option.

<div class="bs-callout bs-callout-warning">
  <h4>Make sure no RabbitMQ related processes running</h4>
  The <code>service rabbitmq-server stop</code> will mislead you that the RabbitMQ server is stopped but if you
  <code>ps -aux | grep rabbitmq</code> you will see a bunch of RabbitMQ process still running. So please use <code>ps</code>
  to check your system before proceeding.
</div>

#### 2. Reset environment variable HOSTNAME to current hostname

If you haven't logout/login shell sessions after changing the hostname, the environment variable HOSTNAME will remain
to the old one that fails `rabbitmqctl`. You can change the `$HOSTNAME` by:

    export HOSTNAME=`hostname`
    
or simply logout then login your shell

#### 3. Start RabbitMQ server

Now you can start the server by:

    service rabbitmq-server start
    
    
<div class="bs-callout bs-callout-info">
  <h4>The hostname may need to be routable</h4>
  
  We have seen some articles saying that the hostname must be routable otherwise RabbitMQ server won't work.
  However, in version (3.x) of RabbitMQ we don't see this issue. If you encounter it, please follow above
  <a href="http://www.rabbitmq.com/ec2.html">RabbitMQ in Amazon  EC2</a> to add IP/hostname pair in /etc/hosts file.
</div>

    


