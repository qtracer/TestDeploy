#!/bin/bash

workdir=$1
JOB_NAME=$2
appointedCase=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 构建镜像
cd /opt/locust/${JOB_NAME}
sed -i 's/default/'"${JOB_NAME}"'/g' .env
if [ $appointedCase ];then
  sed -i 's/all/'"${appointedCase}"'/g' .env
fi

export info="$0: cat .env after do changeComposeEnv"
bash ${workdir}/comm/echoInfo.sh $workdir
cat .env | tee -a /${workdir}/log/${curdate}.log

