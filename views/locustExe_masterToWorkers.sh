#!/bin/bash

targetDir=$1
cores=$2

# 多主机的统一执行入口
curdate="$(date +%Y%m%d)"
workdir=$(find $targetDir -type d -name "TestDeploy*" | head -1)

echo "curdate=$curdate" > ${workdir}/ini/global.ini
echo "workdir=$workdir" >> ${workdir}/ini/global.ini

JOB_NAME=$(cat ${workdir}/ini/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')

echo "this is locustExe_masterToWorkers"
# bash ${workdir}/views/prepareFiles.sh 
bash ${workdir}/views/installDocker.sh $workdir &\
bash ${workdir}/func/installDockerCompose.sh ${workdir} &\
cat ${workdir}/data/daemon.json > /etc/docker/daemon.json

bash ${workdir}/func/locust_build.sh $workdir $JOB_NAME

# bash ${workdir}/func/countCores.sh ${workdir} ${workerNum}
# realWorkers=$(cat ${workdir}/ini/cores.ini | awk -F , '{print $2}')
# totalCores=$[ $(cat /proc/cpuinfo | grep "cpu cores" | wc -l) - 2 ]

echo "locustExe_mw cores are: $cores"
cd /opt/locust/$JOB_NAME
docker-compose -f docker-compose-worker.yml up --scale worker=$cores


#bash ${workdir}/func/locust_compose.sh $workdir $JOB_NAME $realWorkers

