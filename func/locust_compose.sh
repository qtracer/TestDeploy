#!/bin/bash

workdir=$1
JOB_NAME=$2
realWorkers=$3
appointedCase=$4

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

cd /opt/locust/$JOB_NAME

# 单机模式下，docker-compose启动worker的方式
if [ $appointedCase ];then
  docker-compose -f docker-compose-withCase.yml up --scale worker=${realWorkers}
else
  docker-compose -f docker-compose.yml up --scale worker=${realWorkers}
fi
