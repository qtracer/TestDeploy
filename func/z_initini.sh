#!/bin/bash

workdir=$1
basePythonHome=$(cat ${workdir}/ini/store.ini | grep "basePythonHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 发布前，初始化配置
sed -i '1,$d' ${workdir}/ini/pycontainer.ini
sed -i '1,$d' ${workdir}/ini/locontainer.ini
sed -i '1,$d' ${workdir}/ini/global.ini
sed -i 's/true/false/g' ${workdir}/ini/store.ini
sed -i 's/isInstalled/notInstalled/g' ${workdir}/ini/store.ini
sed -i '1,$d' ${workdir}/ini/cores.ini
sed -i '1,$d' ${workdir}/ini/hosts.ini
sed -i '1,$d' ${workdir}/ini/remoteProject.ini
sed -i '1,$d' ${workdir}/data/usableNetWork.txt


rm -rf $basePythonHome/*

# 删除日志
find ${workdir} -name "*.log" -delete
