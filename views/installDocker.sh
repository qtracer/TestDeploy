#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

docker version &> /dev/null

if [ $? -eq 0 ];then
  echo "docker环境已安装，不需要重新安装"
else
  echo "尚未安装，docker环境安装中" 
  bash ${workdir}/func/buildDockerEnv.sh $workdir
fi

echo -e "\n\n\n\n$(date)\n" >> ${workdir}/log/${curdate}.log
export info="docker version"
bash ${workdir}/comm/echoInfo.sh $workdir

docker version | tee -a ${workdir}/log/${curdate}.log
