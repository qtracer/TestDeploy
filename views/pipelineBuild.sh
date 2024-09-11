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
  workdir=$(sudo find / -type d -name "TestDeploy*" | head -1)
fi

ifexist=$(cat ${workdir}/ini/config.ini | grep "installedEnv" | awk -F = '{print $2}')

# install docker/git/jdk/dockercompose/Crontab && build Python Image
sudo bash ${workdir}/views/buildEnvDepend.sh ${workdir}

if [ "$ifexist" = "false" ];then
  # sudo sed -i 's/false/true/g' ${workdir}/ini/config.ini
  sed -i 's/^installedEnv=.*/installedEnv=true/' ${workdir}/ini/config.ini
fi

# run PythonImage
sudo bash ${workdir}/views/runPythonImage.sh ${workdir} ${JOB_NAME} $tag 
# 打包代码 若不想代码暴露在jenkins控制台，可以注释并将TestDeploy放置在工作目录workspace下
sudo bash ${workdir}/func/hrun_packCode.sh ${workdir} ${JOB_NAME} $tag 

