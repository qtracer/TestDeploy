#!/bin/bash

workdir=$1
inputNum=$2
appointedCase=$3

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

remaincores=$(cat ${workdir}/ini/config.ini | grep "remaincores" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

totalCores=$[ $(cat /proc/cpuinfo | grep "cpu cores" | wc -l) - ${remaincores} ]

# 判断性能测试采用哪种模式，single代表单机执行，multiple表示分布式执行
if [ $inputNum -gt $totalCores ];then
  if [ $totalCores -gt 0 ];then
    echo "multiple,$inputNum" > ${workdir}/ini/cores.ini
  else 
    echo "single,1" > ${workdir}/ini/cores.ini
  fi
else
  echo "single,$inputNum" > ${workdir}/ini/cores.ini
fi

if [ $appointedCase ];then
  if [ $inputNum -ge $totalCores ];then
    echo "single,$totalCores" > ${workdir}/ini/cores.ini
  fi
fi

export info="locust: cat openModel and machines‘ cores after count cores"
bash ${workdir}/comm/echoInfo.sh $workdir
cat ${workdir}/ini/cores.ini | tee -a /${workdir}/log/${curdate}.log

