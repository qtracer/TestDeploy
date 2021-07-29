#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

rm -f /usr/bin/java
ln -s $(find /var/lib/docker -name java | grep "diff/opt/java/openjdk/bin/java") /usr/bin/java


export info="$0: cat java version after install JDK"
bash ${workdir}/comm/echoInfo.sh $workdir
java -version | tee -a /${workdir}/log/${curdate}.log

