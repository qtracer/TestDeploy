#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

docker-compose -v &> /dev/null
if [ $? -eq 0 ];then
  echo "docker-compose不需要重新安装"
else
  yum -y install docker-compose | tee -a ${workdir}/log/${curdate}.log
fi
