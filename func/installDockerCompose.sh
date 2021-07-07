#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

docker-compose -v &> /dev/null
if [ $? -eq 0 ];then
  echo "docker-compose不需要重新安装"
else
  #yum -y install docker-compose | tee -a ${workdir}/log/${curdate}.log
  curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi
