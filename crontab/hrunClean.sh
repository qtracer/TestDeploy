#! /bin/bash

#workdir=$1
workdir=$(find / -type d -name "TestDeploy*" | head -1)
#basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

#sn=$[ $(cat ${workdir}/ini/pycontainer.ini | grep "${basePythonHome}" | wc -l) ]
#sn=$(( $sn % 56000 ))
#rm -rf ${basePythonHome}/python${sn}/*

# 删除指定目录下所有的文件
while read line
do
  if [ -d "$(echo $line | awk -F , '{print $2}')" ];then
    rm -rf $(echo $line | awk -F , '{print $2}')/*
  fi
done < ${workdir}/ini/pycontainer.ini

