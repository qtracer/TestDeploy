#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

expect -v &> /dev/null

if [ $? -eq 0 ];then
  pwd
else  
  yum -y install expect
fi

export info="$0: cat expect version after install it"
bash ${workdir}/comm/echoInfo.sh $workdir
expect -v | tee -a /${workdir}/log/${curdate}.log


