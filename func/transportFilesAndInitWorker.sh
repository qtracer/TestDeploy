#!/bin/bash

workdir=$1
projectPackage=$2
sourceDir=$(cat ${workdir}/ini/store.ini | grep "sourceDir" | awk -F = '{print $2}')
targetDir=$(cat ${workdir}/ini/store.ini | grep "targetDir" | awk -F = '{print $2}')

projectPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')
shellPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')


while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')
  cores=$(echo $line | awk -F , '{print $4}')

expect -c "
  set timeout 10
  spawn /usr/bin/scp /data/${sourceDir}.tar ${account}@${host}:${targetDir}
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
  expect \"]*\" {send \"tar zxvf ${sourceDir}.tar\n\"}
  expect \"]*\" {send \"cd /opt/locust && rm -rf ${projectPackage} && mv /${targetDir}/${sourceDir}/${projectPackage} /opt/locust\n\"}
  expect \"]*\" {send \"rm -rf ${targetDir}/${shellPackage} && mv ${targetDir}/${sourceDir}/${shellPackage} ${targetDir} \n\"}
  expect \"]*\" {send \"cd ${targetDir}/${shellPackage} && echo $(pwd)\n\"}
  expect \"]*\" {send \"nohup bash views/locustExe_masterToWorkers.sh ${targetDir} ${cores} &\n\"}
  expect \"]*\" {send \"exit\n\"}
  expect eof;"
  
done < ${workdir}/data/usableNetWork.txt




:<<!
while read line
do
host=$(echo $line | awk -F , '{print $1}')
password=$(echo $line | awk -F , '{print $2}')

expect -c "
  spawn /usr/bin/ssh root@${host}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*password*\" {send \"${password}\r\";}
  }
  expect \"]#\" {send \"mkdir -vp /opt/locust\n\"}
  expect \"]#\" {send \"cd ${targetDir}\n\"}
  expect \"]#\" {send \"tar zxvf ${sourceDir}.tar\n\"}
  expect \"]#\" {send \"exit\n\"}
  
  expect eof
"
done < ${workdir}/data/usableNetWork.txt
!
