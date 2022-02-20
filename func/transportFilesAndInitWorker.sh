#!/bin/bash
# 分布式性能测试时，向各worker节点传送必要的文件

workdir=$1
projectPackage=$2

sourceDir=$(cat ${workdir}/ini/config.ini | grep "sourceDir" | awk -F = '{print $2}')
targetDir=$(cat ${workdir}/ini/config.ini | grep "targetDir" | awk -F = '{print $2}')

projectPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')
shellPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')
baseLocustHome=$(cat ${workdir}/ini/config.ini | grep "baseLocustHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

sn=$[ $(cat ${workdir}/ini/locontainer.ini | grep "${baseLocustHome}" | wc -l)]


while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')
  cores=$(echo $line | awk -F , '{print $6}')

expect -c "
  set timeout 10
  spawn /usr/bin/scp /data/${sourceDir}${sn}.tar ${account}@${host}:${targetDir}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*password*\" {send \"${password}\r\";}
  } 
  expect \"]*\" {send \"exit\n\"}

  spawn /usr/bin/ssh ${account}@${host}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*assword*\" {send \"${password}\r\";}
  }
  expect \"]*\" {send \"mkdir -vp /opt/locust\n\"}
  expect \"]*\" {send \"cd ${targetDir}\n\"}
  expect \"]*\" {send \"tar zxvf ${sourceDir}${sn}.tar\n\"}
  expect \"]*\" {send \"cd /opt/locust && rm -rf ${projectPackage} && mv /${targetDir}/${sourceDir}${sn}/${projectPackage} /opt/locust\n\"}
  expect \"]*\" {send \"rm -rf ${targetDir}/${shellPackage} && mv ${targetDir}/${sourceDir}${sn}/${shellPackage} ${targetDir} \n\"}
  expect \"]*\" {send \"cd ${targetDir}/${shellPackage} \n\"}
  expect \"]*\" {send \"nohup bash views/locustExe_masterToWorkers.sh ${targetDir} ${cores} &\n\"}
  expect \"]*\" {send \"exit\n\"}
  expect eof;"
  
done < ${workdir}/data/usableNetWork.txt

