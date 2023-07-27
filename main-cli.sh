#!/bin/bash
# @author GHJ qtracer

# Jenkins或命令行终端传入参数
JOB_NAME=$1
tag=$2
workerNum=$3
arg1=$4
arg2=$5


# ------@设置全局变量，并写入全局变量配置文件------
curdate="$(date +%Y%m%d)"
workdir=$PWD
keyword="TestDeploy"

if [[ $PWD == *$keyword* ]];then
  :
else
  workdir=$(find / -type d -name "TestDeploy*" | head -1)
fi

ifexist=$(cat ${workdir}/ini/config.ini | grep "installedEnv" | awk -F = '{print $2}')
installedCI=$(cat ${workdir}/ini/config.ini | grep "installedCI" | awk -F = '{print $2}')
echo "ifexist is: "$ifexist

# 单机环境下(不配置hosts.ini)安装依赖环境
bash ${workdir}/views/buildEnvDepend.sh ${workdir}

# 搭建CI平台
if [ "$installedCI" = "notInstalled" ];then
  bash ${workdir}/views/buildCIPlatform.sh ${workdir}
fi

# ----@初始化Node----
bash ${workdir}/views/initJenkinsNode.sh ${workdir}

# 注意:默认Jenkins下执行,若cli执行需要将代码包放置在pwd的上级目录
if [ "$ifexist" = "false" ];then
  sed -i 's/false/true/g' ${workdir}/ini/config.ini
elif [ $workerNum -ge 1 ];then
  bash ${workdir}/views/locustExe.sh $workdir $JOB_NAME $tag $workerNum $arg1
else
  bash ${workdir}/views/hrunExe.sh $workdir $JOB_NAME $tag $arg1 $arg2
fi
