#!/bin/bash

# ------@设置全局变量，并写入全局变量配置文件------

# @author GHJ qtracer

JOB_NAME=$1
tag=$2
workerNum=$3
appointedCase=$4


curdate="$(date +%Y%m%d)"
workdir=$PWD
keyword="TestDeploy"
if [[ $PWD == *$keyword* ]];then
  :
else
  workdir=$(find / -type d -name "TestDeploy*" | head -1)
fi

bash ${workdir}/views/initJenkinsNode.sh ${workdir}
bash ${workdir}/views/buildEnvDepend.sh ${workdir}

ifexist=$(cat ${workdir}/ini/store.ini | grep "installedEnv" | awk -F = '{print $2}')
installedCI=$(cat ${workdir}/ini/store.ini | grep "installedCI" | awk -F = '{print $2}')
echo "ifexist is: "$ifexist

# 注意:默认Jenkins下执行,若cli执行需要将代码包放置在pwd的上级目录
if [ "$ifexist" = "false" ];then
  sed -i 's/false/true/g' ${workdir}/ini/store.ini 
elif [ $workerNum -ge 1 ];then
  bash ${workdir}/views/locustExe.sh ${workdir} ${JOB_NAME} $tag ${workerNum} $appointedCase
else
  bash ${workdir}/views/hrunExe.sh ${workdir} $JOB_NAME $tag $appointedCase
fi


if [ "$installedCI" = "notInstalled" ];then
  bash ${workdir}/views/buildCIPlatform.sh ${workdir}
fi
