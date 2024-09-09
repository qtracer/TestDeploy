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
locustlog=$(cat ${workdir}/ini/config.ini | grep "locustlog" | awk -F = '{print $2}')

while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')
  cores=$(echo $line | awk -F , '{print $6}')

expect -c "
  set timeout -1
  spawn ssh-keygen -R $host
  expect eof
  wait

  spawn sudo /usr/bin/scp /data/${sourceDir}${sn}.tar ${account}@${host}:${targetDir}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*password*\" {send \"${password}\r\";}
  }
  expect -re {\\$|#} {send \"sleep 1s\n\"}

  spawn /usr/bin/ssh ${account}@${host}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*assword*\" {send \"${password}\r\";}
  }
  expect -re {\\$|#} {send \"sudo mkdir -vp /opt/locust/${projectPackage} \n\"}
  expect -re {\\$|#} {send \"sudo mkdir -vp ${targetDir}/${shellPackage} \n\"}
  expect -re {\\$|#} {send \"sudo mkdir -vp ${targetDir}/${sourceDir}${sn} \n\"}
  expect -re {\\$|#} {send \"sudo mkdir -vp ${locustlog}/${projectPackage}/$(date +%Y%m%d)\n\"}
  expect -re {\\$|#} {send \"sudo chmod 775 ${locustlog}/${projectPackage}/$(date +%Y%m%d)\n\"}
  expect -re {\\$|#} {send \"sudo chown -R ${account}:${account} ${locustlog}/${projectPackage}/$(date +%Y%m%d)\n\"}
  expect -re {\\$|#} {send \"cd ${targetDir}\n\"}
  expect -re {\\$|#} {send \"sudo tar zxvf ${sourceDir}${sn}.tar\n\"}
  expect -re {\\$|#} {send \"cd /opt/locust && sudo rm -rf ${projectPackage} && sudo mv ${targetDir}/${sourceDir}${sn}/${projectPackage} /opt/locust\n\"}
  expect -re {\\$|#} {send \"sudo rm -rf ${targetDir}/${shellPackage} && sudo mv ${targetDir}/${sourceDir}${sn}/${shellPackage} ${targetDir} \n\"}
  expect -re {\\$|#} {send \"sudo rm -rf ${targetDir}/${sourceDir}${sn}* \n\"}
  expect -re {\\$|#} {send \"cd ${targetDir}/${shellPackage} \n\"}
  expect -re {\\$|#} {send \"nohup sudo bash views/locustExe_masterToWorkers.sh ${targetDir} ${cores} > ${locustlog}/${projectPackage}/$(date +%Y%m%d)/nohub.out &\n\"}
  expect -re {\\$|#} {send \"exit\n\"}
  expect eof;"
  
done < ${workdir}/data/usableNetWork.txt

