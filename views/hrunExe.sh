#!/bin/bash
# 接口自动化主流程

workdir=$1
JOB_NAME=$2
tag=$3
appointedHost=$4
appointedCase=$5

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ $JOB_NAME ];then
  bash ${workdir}/func/ifContainerExist.sh ${workdir} ${JOB_NAME} $tag  # 判断代码是否同一个项目同一个版本
  bash ${workdir}/views/runPythonImage.sh ${workdir} ${JOB_NAME} $tag # run Python镜像
  bash ${workdir}/func/hrun_packCode.sh ${workdir} ${JOB_NAME} $tag  # 打包代码。若不想代码暴露在jenkins控制台，可以注释并将TestDeploy放置在工作目录workspace下
  bash ${workdir}/views/runAPIAuto.sh ${workdir} ${JOB_NAME} $appointedHost $appointedCase  # 执行接口自动化
  bash ${workdir}/func/getHrunReports.sh ${workdir} ${JOB_NAME} # 获取执行报告
  bash ${workdir}/func/hrunClean.sh ${workdir} # 获取报告后清除宿主机映射文件
fi
