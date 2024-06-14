#!/bin/bash

workdir=$1
JOB_NAME=$2
# appointedCase=$3
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')
locustVersion=$(cat ${workdir}/ini/config.ini | grep "locustVersion" | awk -F = '{print $2}')
reqVersion=$(cat ${workdir}/ini/config.ini | grep "reqVersion" | awk -F = '{print $2}')
redisVersion=$(cat ${workdir}/ini/config.ini | grep "redisVersion" | awk -F = '{print $2}')

export info="$0: build locust image of $JOB_NAME"
bash ${workdir}/comm/echoInfo.sh $workdir

# 构建locust镜像
cd /opt/locust/${JOB_NAME}
docker build -t ${JOB_NAME} -f locust-dockerfile \
 --build-arg locustVersion=$locustVersion \
 --build-arg reqVersion=$reqVersion \
 --build-arg redisVersion=$redisVersion \
 --build-arg pyVersion=$pyVersion . | tee -a ${workdir}/log/${curdate}.log
