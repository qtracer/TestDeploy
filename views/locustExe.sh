#!/bin/bash
# 性能测试主流程

workdir=$1
JOB_NAME=$2
tag=$3
workerNum=$4
appointedHost=$5
appointedCase=$6

projectPacakge=$JOB_NAME$tag

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 判断性能开启模式，获取从机开启worker数量
bash ${workdir}/func/countCores.sh ${workdir} ${workerNum} ${appointedCase}
openModel=$(cat ${workdir}/ini/cores.ini | awk -F , '{print $1}')
echo "openModel is: $openModel"
realWorkers=$(cat ${workdir}/ini/cores.ini | awk -F , '{print $2}')
locustlog=$(cat ${workdir}/ini/config.ini | grep "locustlog" | awk -F = '{print $2}')

# copy 压测项目/镜像构建文件/docker-compose.yml等文件到/opt/locust目录
bash ${workdir}/func/locust_packCode.sh $workdir $JOB_NAME $tag $openModel $appointedCase
# 改变.env配置以及通过切换压测项目的环境和数据源
bash ${workdir}/func/changeComposeEnv.sh $workdir $JOB_NAME $appointedHost $appointedCase

# 构建locust镜像
bash ${workdir}/views/buildLocustImage.sh $workdir $JOB_NAME

echo "realWorkers is: $realWorkers"
echo "openModel is: $openModel"

# 检测locust
mkdir -vp ${locustlog}/$JOB_NAME/$(date +%Y%m%d)
nohup bash ${workdir}/crontab/checkLocustState.sh $workdir $JOB_NAME > ${locustlog}/$JOB_NAME/$(date +%Y%m%d)/nohup_checkLocustState.out &  
sleep 2

if [ "$openModel" = "single" ];then
  cat ${workdir}/data/statement_locust.txt
  nohup bash ${workdir}/func/locust_compose.sh $workdir $JOB_NAME $realWorkers $appointedCase > ${locustlog}/$JOB_NAME/$(date +%Y%m%d)/nohup_locust_compose.out
  #bash ${workdir}/func/locust_compose.sh $workdir $JOB_NAME $realWorkers $appointedCase
else
  bash ${workdir}/func/prepareFiles.sh $workdir $openModel $JOB_NAME $workerNum
  cat ${workdir}/data/statement_locust.txt
  bash ${workdir}/func/locust_compose_master.sh $workdir $JOB_NAME
fi
