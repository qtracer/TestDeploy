#!/bin/bash

workdir=$1
JOB_NAME=$2
appointedCase=$3
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

# 构建镜像
cd /opt/locust/${JOB_NAME}
sed -i 's/default/'"${JOB_NAME}"'/g' .env
if [ $appointedCase ];then
  sed -i 's/all/'"${appointedCase}"'/g' .env
fi 

docker build -t ${JOB_NAME} -f locust-dockerfile . | tee -a ${workdir}/log/${curdate}.log
