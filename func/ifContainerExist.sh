#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

num=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | grep "$tag" | wc -l)
echo "num is : $num"

if [ $(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | grep "$tag" |  wc -l) -ge 1 ];then
  echo "remove and new a container!"
  docker stop ${JOB_NAME}_${tag}
  docker rm -f ${JOB_NAME}_${tag}
elif [ $(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | wc -l)  -ge 1 ];then
  echo "stop and new a container!"
  container=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $1}')
  docker stop ${container}
else
  echo "new a container!"
fi
