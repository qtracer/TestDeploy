#!/bin/bash

workdir=$1

sourceDir=$(cat ${workdir}/ini/store.ini | grep "sourceDir" | awk -F = '{print $2}')
targetDir=$(cat ${workdir}/ini/store.ini | grep "targetDir" | awk -F = '{print $2}')

remaincores=$(cat ${workdir}/ini/store.ini | grep "remaincores" | awk -F = '{print $2}')
shellPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')

cores=0

echo "sourceDir is : $sourceDir"
echo "targetDir is : $targetDir"
echo "shellPackage is : $shellPackage"


while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')


  echo "line is : $line"
  coresExist=$(echo $line | awk -F , '{print $4}')
  echo "coreExist is : $coresExist"
  if [ $coresExist ];then
    pwd
  else
    expect -c "
      set timeout 2
      spawn /usr/bin/scp ${workdir}/func/countCores_byworker.sh ${account}@${host}:${targetDir}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*assword*\" {send \"${password}\r\";}
      }
      expect \"]*\" {send \"exit\n\"}
      
      spawn /usr/bin/ssh ${account}@${host}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*assword*\" {send \"${password}\r\";}
      }
      expect \"]*\" {send \"cd ${targetDir}\n\"}
      expect \"]*\" {send \"bash countCores_byworker.sh ${remaincores}\n\"}
      expect \"]*\" {send \"exit\n\"}
      expect eof
      catch wait result
      exit [lindex \$result 3]
      ;" 
    cores=$?
    if [ $cores -eq 255 ];then
      cores=0
    fi
    echo "cores is: $cores"
    sed -i 's/'"$host"'.*/&,'"$cores"'/g' ${workdir}/ini/hosts.ini
  fi
done < ${workdir}/ini/hosts.ini
