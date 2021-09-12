#!/bin/bash

workdir=$1
JOB_NAME=$2
realWorkers=$3
appointedCase=$4
#curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

# bash ${workdir}/func/countCores.sh ${workdir} ${workerNum}

# realWorkers=$(cat ${workdir}/data/tmp.txt)

cd /opt/locust/$JOB_NAME

if [ $appointedCase ];then
  docker-compose -f docker-compose-withCase.yml up --scale worker=${realWorkers}
else
  docker-compose -f docker-compose.yml up --scale worker=${realWorkers}
fi
