#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jdkVersion=$(cat $workdir/ini/config.ini | grep "jdkVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

java -version &> /dev/null
if [ "$?" != "0" ];then
  yum install -y java-${jdkVersion}-openjdk.x86_64
fi

export info="$0: cat java version after install JDK"
bash ${workdir}/comm/echoInfo.sh $workdir
java -version | tee -a /${workdir}/log/${curdate}.log

