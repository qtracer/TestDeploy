#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jdkVersion=$(cat $workdir/ini/config.ini | grep "jdkVersion" | awk -F = '{print $2}')
release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

java -version &> /dev/null
if [ $? -ne 0 ];then
  if [ "$release" == "centos" ];then
    yum install -y java-${jdkVersion}-openjdk.x86_64
  else
    apt install openjdk-${jdkVersion}-jdk
  fi
fi

export info="$0: cat java version after install JDK"
bash ${workdir}/comm/echoInfo.sh $workdir
java -version | tee -a ${workdir}/log/${curdate}.log

