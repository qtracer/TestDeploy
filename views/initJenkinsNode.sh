#!/bin/bash
# Jenkins Master-Slave模式下，初始化slave节点

workdir=$1

shellPackage=$(echo $workdir | awk -F / '{print $NF}')
targetDir=$(cat ${workdir}/ini/config.ini | grep "targetDir" | awk -F = '{print $2}')
localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')
  ifnew=$(echo $line | awk -F , '{print $4}')
  
  if [ "$ifnew" = "isnew" ];then
    cp -f ${workdir}/ini/hosts.ini ${workdir}/ini/hosts_bak.ini
    sed -i 's/isnew/notnew/g' ${workdir}/ini/hosts.ini
    # 初始化Nodes,installedEnv设置为已初始化
    sed -i 's/false/true/g' ${workdir}/ini/config.ini

    dirname0=$(dirname $workdir)
    cd $dirname0 && bash ${workdir}/func/cvfTarCode.sh $shellPackage $shellPackage
    if [ "$dirname0" != "/opt" ];then
      cp -rf ${shellPackage}.tar /opt
    fi

    rm -f ${workdir}/ini/hosts.ini
    mv ${workdir}/ini/hosts_bak.ini ${workdir}/ini/hosts.ini

    expect -c "
      set timeout -1
      spawn ssh-keygen -R $host
      expect eof
      wait

      spawn /usr/bin/ssh ${account}@${host}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*assword*\" {send \"${password}\r\";}
      }
      expect -re {\\$|#} {send \"sudo mkdir -vp ${targetDir} && cd ${targetDir} && sudo chmod 775 ${targetDir}\n\"}
      expect -re {\\$|#} {send \"sudo chown -R ${account}:${account} ${targetDir} && exit\n\"}

      spawn sudo /usr/bin/scp ${dirname0}/${shellPackage}.tar ${account}@${host}:${targetDir}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*password*\" {send \"${password}\r\";}
      }
      expect -re {\\$|#} {send \"sleep 1s \n\"}

      spawn /usr/bin/ssh ${account}@${host}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*assword*\" {send \"${password}\r\";}
      }
      expect -re {\\$|#} {send \"cd ${targetDir} \n\"}
      expect -re {\\$|#} {send \"sudo mkdir -vp ${targetDir}/${shellPackage} \n\"}
      expect -re {\\$|#} {send \"sudo rm -rf ${shellPackage}/ \n\"}
      expect -re {\\$|#} {send \"sudo tar zxvf ${shellPackage}.tar \n\"}
      expect -re {\\$|#} {send \"sudo rm -f ${targetDir}/${shellPackage}.tar \n\"}
      expect -re {\\$|#} {send \"cd ${targetDir}/${shellPackage} \n\"}
      expect -re {\\$|#} {send \"sudo bash func/setGlobal.sh ${targetDir}/${shellPackage} \n\"}
      expect -re {\\$|#} {send \"sudo bash func/installExpect.sh ${targetDir}/${shellPackage} && sleep 5s \n\"}
      expect -re {\\$|#} {send \"nohup sudo bash views/buildEnvDepend.sh ${targetDir}/${shellPackage} > ${targetDir}/tdbuildEnvnohup.out & \n\"}
      expect -re {\\$|#} {send \"exit \n\"}
      expect eof;"
  fi
done < ${workdir}/ini/hosts.ini

sed -i 's/isnew/notnew/g' ${workdir}/ini/hosts.ini
