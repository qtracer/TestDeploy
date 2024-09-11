#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

/usr/bin/expect -v &> /dev/null

if [ $? -ne 0 ];then
  if [ "$release" == "centos" ];then
    yum -y install expect
  else
    apt -y install expect
  fi
fi

export info="$0: cat expect version after install it"
bash ${workdir}/comm/echoInfo.sh $workdir
expect -v


