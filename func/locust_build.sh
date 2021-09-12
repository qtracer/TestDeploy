#!/bin/bash

workdir=$1
JOB_NAME=$2
# appointedCase=$3
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: build locust image of $JOB_NAME"
bash ${workdir}/comm/echoInfo.sh $workdir

# 构建镜像
cd /opt/locust/${JOB_NAME}
docker build -t ${JOB_NAME} -f locust-dockerfile . | tee -a ${workdir}/log/${curdate}.log
