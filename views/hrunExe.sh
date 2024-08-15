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
  # 不再以gitlab仓库的tag作为版本判断，版本号即jenkins构建号
  # bash ${workdir}/func/ifContainerExist.sh ${workdir} ${JOB_NAME} $tag  
 
  bash ${workdir}/views/runPythonImage.sh ${workdir} ${JOB_NAME} $tag  # run Python镜像
  bash ${workdir}/func/hrun_packCode.sh ${workdir} ${JOB_NAME} $tag # 打包代码。若不想代码暴露在jenkins控制台，可以注释并将TestDeploy放置在jenkins workspace下
  bash ${workdir}/views/runAPIAuto.sh ${workdir} ${JOB_NAME} $appointedHost $appointedCase  # 执行接口自动化
  bash ${workdir}/func/getHrunReports.sh ${workdir} ${JOB_NAME} ${tag} # 获取执行报告
  bash ${workdir}/func/removeContainer.sh ${workdir} ${JOB_NAME} $tag # 运行完即删掉容器,不在定时任务处理
  # bash ${workdir}/func/hrunClean.sh ${workdir} # warning:多任务并行容易冲突  solution:定时任务定时清除
fi
