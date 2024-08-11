#! /bin/bash

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

# 获取执行报告
bash ${workdir}/func/getHrunReports.sh ${workdir} ${JOB_NAME}
# 运行完即删掉容器,不在定时任务处理
bash ${workdir}/func/removeContainer.sh ${workdir} ${JOB_NAME} $tag
# 获取报告后清除宿主机映射文件
# bash ${workdir}/func/hrunClean.sh ${workdir}  # warning:多任务并行容易冲突  solution:定时任务定时清除
