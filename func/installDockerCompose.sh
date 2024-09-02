#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
dcVersion=$(cat ${workdir}/ini/config.ini | grep "dcVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

/usr/local/bin/docker-compose -v &> /dev/null
if [ $? -eq 0 ];then
  echo "docker-compose不需要重新安装"
else
  # 国外镜像
  # curl -L "https://github.com/docker/compose/releases/download/$dcVersion/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  # 国内镜像(该镜像源不可用)
  # curl -L "https://get.daocloud.io/docker/compose/releases/download/$dcVersion/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
  # 本地文件
  cat $workdir/data/docker-compose > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi
