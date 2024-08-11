#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

#curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

#num=$(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | grep "$tag" | wc -l)
#echo "Tag of JOB_NAME,num is : $num"
containerName=$(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | tail -1 | awk -F , '{print $1}')

export info="$0: if container exist then stop it"
bash ${workdir}/comm/echoInfo.sh $workdir

docker stop $containerName
docker rm -f $containerName

# 接口自动化前，提供python环境的容器
#if [ $(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | grep "$tag" |  wc -l) -ge 1 ];then
#  echo "remove and new a container!" | tee -a ${workdir}/log/${curdate}.log
#  docker stop ${JOB_NAME}_${tag}
#  docker rm -f ${JOB_NAME}_${tag}
#elif [ $(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | wc -l)  -ge 1 ];then
#  echo "stop and new a container!" | tee -a ${workdir}/log/${curdate}.log
#  container=$(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $1}')
#  docker stop ${container}
#  docker rm -f ${container}
#else
#  echo "new a container!" | tee -a ${workdir}/log/${curdate}.log
#fi

