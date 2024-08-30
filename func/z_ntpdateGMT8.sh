#!/bin/bash

workdir=$1
export info="$0: timeSync for the machine"
bash $workdir/comm/echoInfo.sh $workdir

rpm -qi ntpdate > /dev/null
if [ $? -ne 0 ];then
  yum install ntpdate -y
  /usr/sbin/ntpdate ntp.aliyun.com
fi
