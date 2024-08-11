#!/bin/bash
# @author GHJ qtracer

# Jenkins或命令行终端传入参数
JOB_NAME=$1
tag=$2
workerNum=$3
arg1=$4
arg2=$5


# ------@设置全局变量，并写入全局变量配置文件------
workdir=$PWD
keyword="TestDeploy"

# echo "curdate=$(date +%Y%m%d)" >> ${workdir}/ini/global.ini

if [[ $PWD == *$keyword* ]];then
  :
else
  workdir=$(find / -type d -name "TestDeploy*" | head -1)
fi

echo "workdir is: ${workdir}"

ifexist=$(cat ${workdir}/ini/config.ini | grep "installedEnv" | awk -F = '{print $2}')
installedCI=$(cat ${workdir}/ini/config.ini | grep "installedCI" | awk -F = '{print $2}')
echo "ifexist is: "$ifexist
echo "installedCI is:"$installedCI

# ----单机环境下(不配置hosts.ini)安装依赖环境----
bash ${workdir}/views/buildEnvDepend.sh ${workdir}

# ----搭建CI平台----
if [ "$installedCI" == "notInstalled" ];then
  bash ${workdir}/views/buildCIPlatform.sh ${workdir}
fi

# ----初始化Node,读取hosts.ini----
bash ${workdir}/views/initJenkinsNode.sh ${workdir}

# 注意:默认Jenkins下执行,若cli执行需要将代码包放置在pwd的上级目录下
if [ "$ifexist" = "false" ];then
  sed -i 's/false/true/g' ${workdir}/ini/config.ini
elif [ $workerNum -ge 1 ];then
  # arg1:即locust @tag，指定标签的用例[locust暂未支持切换环境]
  bash ${workdir}/views/locustExe.sh $workdir $JOB_NAME $tag $workerNum $arg1
else
  # tag:即jenkins ${BUILD_NUMBER}
  # arg1:即执行项目的环境,如release
  # arg2:即执行项目指定用例路径,默认testcases,ini/config.ini可配置
  bash ${workdir}/views/hrunExe.sh $workdir $JOB_NAME $tag $arg1 $arg2
fi
