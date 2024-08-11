#!/bin/bash

JOB_NAME=$1
tag=$2
workerNum=$3
appointedHost=$4
appointedCase=$5

# workdir handle
workdir=$PWD
keyword="TestDeploy"

if [[ $PWD == *$keyword* ]];then
  :
else
  workdir=$(find / -type d -name "TestDeploy*" | head -1)
fi

hrunlog=$(cat ${workdir}/ini/config.ini | grep "hrunlog" | awk -F = '{print $2}')

# ----pipeline runAPIAuto----
mkdir -vp ${hrunlog}/$JOB_NAME
bash ${workdir}/views/runAPIAuto.sh ${workdir} ${JOB_NAME} $appointedHost $appointedCase | tee -a ${hrunlog}/$JOB_NAME/$(date +%Y%m%d).log  # 执行接口自动化
