#!/bin/bash

workdir=$1
JOB_NAME=$2
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

# 构建镜像
cd /opt/locust/${JOB_NAME}
sed -i 's/default/'"${JOB_NAME}"'/g' .env

docker build -t ${JOB_NAME} . | tee -a ${workdir}/log/${curdate}.log
