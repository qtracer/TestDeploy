#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
workerNum=$4
appointedCase=$5

bash ${workdir}/views/installDocker.sh $workdir
bash ${workdir}/func/installDockerCompose.sh ${workdir} 
bash ${workdir}/func/locust_packCode.sh $workdir $JOB_NAME $tag $appointedCase
bash ${workdir}/func/locust_build.sh $workdir $JOB_NAME $appointedCase
bash ${workdir}/func/locust_compose.sh $workdir $JOB_NAME $workerNum $appointedCase


