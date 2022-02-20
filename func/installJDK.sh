#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jdkVersion=$(cat $workdir/ini/config.ini | grep "jdkVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

java -version &> /dev/null
if [ "$?" != "0" ];then
  yum install -y java-${jdkVersion}-openjdk && sleep 2s && ln -s /usr/lib/jvm/java-${jdkVersion}-openjdk-${jdkVersion}.312.b07-1.el7_9.x86_64/jre/bin/java /usr/local/bin
fi

export info="$0: cat java version after install JDK"
bash ${workdir}/comm/echoInfo.sh $workdir
java -version | tee -a /${workdir}/log/${curdate}.log

