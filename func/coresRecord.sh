#!/bin/bash

workdir=$1

localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

sourceDir=$(cat ${workdir}/ini/config.ini | grep "sourceDir" | awk -F = '{print $2}')
targetDir=$(cat ${workdir}/ini/config.ini | grep "targetDir" | awk -F = '{print $2}')

remaincores=$(cat ${workdir}/ini/config.ini | grep "remaincores" | awk -F = '{print $2}')
shellPackage=$(cat ${workdir}/ini/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')

cores=0

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 性能测试时，计算各可用slave的核数
while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')

  echo "line is : $line"
  coresExist=$(echo $line | awk -F , '{print $6}')
  echo "coreExist is : $coresExist"

  if [ "$localhost" != "$host" ];then
    if [ $coresExist ];then
      :
    else
      expect -c "
        set timeout -1
        spawn ssh-keygen -R $host
        expect eof
        wait

        spawn sudo /usr/bin/scp ${workdir}/func/countCores_byworker.sh ${account}@${host}:${targetDir}
        expect {
          \"*yes/no*\" {send \"yes\r\"; exp_continue}
          \"*assword*\" {send \"${password}\r\";}
        }
        expect -re {\\$|#} {send \"sleep 1s\n\"}

        spawn /usr/bin/ssh ${account}@${host}
        expect {
          \"*yes/no*\" {send \"yes\r\"; exp_continue}
          \"*assword*\" {send \"${password}\r\";}
        }
        expect -re {\\$|#} {send \"cd ${targetDir} && sudo chmod -777 countCores_byworker.sh\n\"}
        expect -re {\\$|#} {send \"sudo bash countCores_byworker.sh ${remaincores}\n\"}
        expect -re {\\$|#} {send \"exit\n\"}
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
  fi
done < ${workdir}/ini/hosts.ini
