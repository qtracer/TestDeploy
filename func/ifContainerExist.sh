#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

num=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | grep "$tag" | wc -l)
echo "Tag of JOB_NAME,num is : $num"

export info="$0: if container exist"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ $(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | grep "$tag" |  wc -l) -ge 1 ];then
  echo "remove and new a container!" | tee -a /${workdir}/log/${curdate}.log
  docker stop ${JOB_NAME}_${tag}
  docker rm -f ${JOB_NAME}_${tag}
elif [ $(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | wc -l)  -ge 1 ];then
  echo "stop and new a container!" | tee -a /${workdir}/log/${curdate}.log
  container=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $1}')
  docker stop ${container}
else
  echo "new a container!" | tee -a /${workdir}/log/${curdate}.log
fi
