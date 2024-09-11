#!/bin/bash

:<<!
'''author @GHJ qtracer'''
!

# Jenkins或命令行终端传入参数
JOB_NAME=$1
tag=$2
workerNum=$3
arg1=$4
arg2=$5

# ----@定位根目录----
workdir=$PWD
keyword="TestDeploy"

if [[ $PWD == *$keyword* ]];then
  :
else
  workdir=$(sudo find / -type d -name "TestDeploy*" | head -1)
fi
echo "workdir is: ${workdir}"

# ----@动态全局变量----
sudo bash ${workdir}/func/setGlobal.sh ${workdir}

# ----@一些前置处理----
sudo bash ${workdir}/func/preHandle.sh ${workdir}

ifexist=$(cat ${workdir}/ini/config.ini | grep "installedEnv" | awk -F = '{print $2}')

# ----@单机(不配置hosts.ini)安装依赖环境----
sudo bash ${workdir}/views/buildEnvDepend.sh ${workdir}

# ----@安装各种工具,默认不安装----
sudo bash ${workdir}/views/buildTools.sh ${workdir}

# ----@初始化Nodes,读取hosts.ini----
sudo bash ${workdir}/views/initNodes.sh ${workdir}

# tips: 默认Jenkins下执行,若cli执行需要将代码包放置在pwd的上级目录下
if [ "$ifexist" = "false" ];then
  #sudo sed -i 's/false/true/g' ${workdir}/ini/config.ini
  sudo sed -i 's/^installedEnv=.*/installedEnv=true/' ${workdir}/ini/config.ini
elif [ $workerNum -ge 1 ];then
  # arg1:即locust @tag，指定标签的用例[locust暂未支持切换环境]
  sudo bash ${workdir}/views/locustExe.sh $workdir $JOB_NAME $tag $workerNum $arg1
else
  # tag:即jenkins ${BUILD_NUMBER}
  # arg1:即执行项目的环境,如release
  # arg2:即执行项目指定用例路径,默认testsuites,ini/config.ini可配置
  sudo bash ${workdir}/views/hrunExe.sh $workdir $JOB_NAME $tag $arg1 $arg2
fi
