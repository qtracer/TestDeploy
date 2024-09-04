#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
python_image=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}')
hrunVersion=$(cat ${workdir}/ini/config.ini | grep "hrunVersion" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')
reqVersion=$(cat ${workdir}/ini/config.ini | grep "reqVersion" | awk -F = '{print $2}')
masaVersion=$(cat ${workdir}/ini/config.ini | grep "masaVersion" | awk -F = '{print $2}')
# ifexist=$(cat ${workdir}/ini/config.ini | grep "installedEnv" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 构建Python基础镜像
#if [ "$ifexist" = "false" ];then
#docker pull python:$pyVersion
#fi

docker build -t ${python_image} -f ${workdir}/dockerfile/python-dockerfile \
 --build-arg hrunVersion=$hrunVersion \
 --build-arg reqVersion=$reqVersion \
 --build-arg masaVersion=$masaVersion \
 --build-arg pyVersion=$pyVersion . | tee -a ${workdir}/log/${curdate}.log
