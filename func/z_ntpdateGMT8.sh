#!/bin/bash

workdir=$1
release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

export info="$0: timeSync for the machine"
bash $workdir/comm/echoInfo.sh $workdir

which ntpdate &> /dev/null
if [ $? -eq 0 ];then
  if [ "$release" == "centos" ];then
    yum install ntpdate -y
  else
    apt install ntpdate -y
  fi

  /usr/sbin/ntpdate ntp.aliyun.com
  sudo timedatectl set-timezone Asia/Shanghai
fi
