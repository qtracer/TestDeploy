#!/bin/bash

workdir=$1
workerNum=$2

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 初始化变量并赋值
totalCores=0

sed -i '1,$d' ${workdir}/data/usableNetWork.txt

# 性能测试时，根据workNum、各slave主机cores计算需要多少主机
while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  echo $line
  ping $(echo $line | awk -F , '{print $1}') -c 1 -w 1 | grep "ttl=" 
  
  if [ $? -eq 0 ];then
    cores=$(echo $line | awk -F , '{print $6}')
    totalCores=$[ $cores + $totalCores ]
    if [ "$localhost" != "$host" ];then
      echo $line >> ${workdir}/data/usableNetWork.txt
    fi

    if [ $totalCores -gt $workerNum ];then
      remain=$[ $totalCores - $workerNum ]
      remain=$[ $cores - $remain ]
      echo "remain is : $remain"
      sed -i '$s/'"$cores"'$/'"$remain"'/' ${workdir}/data/usableNetWork.txt
      break
    fi

  fi
done < ${workdir}/ini/hosts.ini

export info="$0: cat usableNetWork.txt which will run workers while performance"
bash ${workdir}/comm/echoInfo.sh $workdir
cat ${workdir}/data/usableNetWork.txt | tee -a /${workdir}/log/${curdate}.log
