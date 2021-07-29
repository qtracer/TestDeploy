#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
workerNum=$4
appointedCase=$5

projectPacakge=$JOB_NAME$tag

# init 
bash ${workdir}/views/installDocker.sh $workdir &\
bash ${workdir}/func/installDockerCompose.sh ${workdir}

# 判断性能开启模式，获取从机开启worker数量
bash ${workdir}/func/countCores.sh ${workdir} ${workerNum} ${appointedCase}
openModel=$(cat ${workdir}/ini/cores.ini | awk -F , '{print $1}')
# echo "openModel is: $openModel"
realWorkers=$(cat ${workdir}/ini/cores.ini | awk -F , '{print $2}')

# copy 镜像文件、docker-compose.yml等文件到项目内部
bash ${workdir}/func/locust_packCode.sh $workdir $JOB_NAME $tag $openModel $appointedCase &&\
bash ${workdir}/func/changeComposeEnv.sh $workdir $JOB_NAME $appointedCase  # 改变locusts/.env配置


# 构建locust镜像
bash ${workdir}/func/locust_build.sh $workdir $JOB_NAME


if [ "$openModel" = "single" ];then
  bash ${workdir}/func/locust_compose.sh $workdir $JOB_NAME $realWorkers $appointedCase
else
  bash ${workdir}/views/prepareFiles.sh $workdir $openModel $JOB_NAME $workerNum
  bash ${workdir}/func/locust_compose_master.sh $workdir $JOB_NAME
  # bash ${workdir}/func/locust_controlWorkers.sh
fi

