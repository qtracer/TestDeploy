#!/bin/bash

# ------@设置全局变量，并写入全局变量配置文件------

# @author GHJ qtracer

JOB_NAME=$1
tag=$2
workerNum=$3
appointedCase=$4


curdate="$(date +%Y%m%d)"
workdir=$(find / -type d -name "TestDeploy*" | head -1)

echo "curdate=$curdate" > ${workdir}/ini/global.ini
echo "workdir=$workdir" >> ${workdir}/ini/global.ini


ifexist=$(cat ${workdir}/ini/store.ini | grep "installed" | awk -F = '{print $2}')
echo "ifexists' value is：$ifexist"

# 注意:默认Jenkins下执行,若cli执行需要将代码包放置在pwd的上级目录
if [ "$ifexist" = "false" ];then
  bash ${workdir}/views/buildCIPlatform.sh ${workdir}
elif [ $workerNum -ge 1 ];then
  bash ${workdir}/views/locustExe.sh ${workdir} ${JOB_NAME} $tag ${workerNum} $appointedCase
else
  bash ${workdir}/views/hrunExe.sh ${workdir} $JOB_NAME $tag $appointedCase
fi


