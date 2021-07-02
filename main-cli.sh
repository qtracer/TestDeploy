#!/bin/bash

# ------@设置全局变量，并写入全局变量配置文件------

# @author GHJ

keyword="again"
curdate="$(date +%Y%m%d)"
workdir=$(find / -type d -name "TestDeploy*" | head -1)

echo "keyword=$keyword" > ${workdir}/ini/global.ini
echo "curdate=$curdate" >> ${workdir}/ini/global.ini
echo "workdir=$workdir" >> ${workdir}/ini/global.ini

JOB_NAME=$1
tag=$2
workerNum=$3

ifexist=$(cat ${workdir}/ini/store.ini | grep "installed" | awk -F = '{print $2}')
echo "ifexists' value is：$ifexist"
if [ "$ifexist" = "false" ];then
  bash ${workdir}/views/buildCIPlatform.sh ${workdir}
elif [ $workerNum -ge 1 ];then
  bash ${workdir}/views/runLocustImage.sh ${workdir} $JOB_NAME $tag ${workerNum}
else
  bash ${workdir}/views/runImageAndExe.sh ${workdir} $JOB_NAME $tag
fi
