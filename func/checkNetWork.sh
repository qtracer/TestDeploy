#!/bin/bash

workdir=$1
workerNum=$2

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

totalCores=0

sed -i '1,$d' ${workdir}/data/usableNetWork.txt

while read line
do
  echo $line
  # cores=$(cat $line | awk -F , '{print $4}')
  ping $(echo $line | awk -F , '{print $1}') -c 1 -w 1 | grep "ttl=" 
  
  if [ $? -eq 0 ];then
    cores=$(echo $line | awk -F , '{print $4}')
    totalCores=$[ $cores + $totalCores ]
    echo $line >> ${workdir}/data/usableNetWork.txt
    
    if [ $totalCores -gt $workerNum ];then
      remain=$[ $totalCores - $workerNum ]
      remain=$[ $cores - $remain ]
      echo "remain is : $remain"
      sed -i '$s/'"$cores"'$/'"$remain"'/' ${workdir}/data/usableNetWork.txt
      break
    fi

  fi
done < ${workdir}/ini/hosts.ini

export info="$0: cat usableNetWork.txt which will run workers"
bash ${workdir}/comm/echoInfo.sh $workdir
cat ${workdir}/data/usableNetWork.txt | tee -a /${workdir}/log/${curdate}.log
