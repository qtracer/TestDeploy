#!/bin/bash

workdir=$1
JOB_NAME=$2
workerNum=$3
#curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

bash ${workdir}/func/countCores.sh ${workdir} ${workerNum}

realWorkers=$(cat ${workdir}/data/tmp.txt)

cd /opt/locust/$JOB_NAME

docker-compose up --scale worker=${realWorkers} 
