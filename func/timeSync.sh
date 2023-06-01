#!/bin/bash
# 设置时间同步

workdir=$1

export info="$0: timeSync for the machine"
bash ${workdir}/comm/echoInfo.sh $workdir

yum install chrony -y
sed 's/0.centos.pool.ntp.org/time2.aliyun.com/' /etc/chrony.conf
systemctl start chronyd
chronyc sources
