#!/bin/bash

workdir=$1

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

sed -i '1,$d' ${workdir}/ini/global.ini

# 支持Ubuntu/Centos
cat /etc/os-release | grep 'ubuntu' &> /dev/null
if [ $? -eq 0 ];then
  echo "release=ubuntu" >> ${workdir}/ini/global.ini
else
  echo "release=centos" >> ${workdir}/ini/global.ini
fi

# echo "curdate=$(date +%Y%m%d)" >> ${workdir}/ini/global.ini
