#!/bin/bash
# Jenkins Master-Slave模式下，初始化slave节点

workdir=$1

shellPackage=$(echo $workdir | awk -F / '{print $NF}')
targetDir=$(cat ${workdir}/ini/config.ini | grep "targetDir" | awk -F = '{print $2}')
localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

mkdir -vp /opt/reports/hrun/

while read line
do
  host=$(echo $line | awk -F , '{print $1}')
  account=$(echo $line | awk -F , '{print $2}')
  password=$(echo $line | awk -F , '{print $3}')
  ifnew=$(echo $line | awk -F , '{print $4}')

  if [ "$ifnew" = "isnew" ];then
    sed -i 's/notInstalled/isInstalled/g' ${workdir}/ini/config.ini
    cp -rf ${workdir}/ini/hosts.ini ${workdir}/ini/hosts_bak.ini
    sed -i 's/isnew/notnew/g' ${workdir}/ini/hosts.ini
    sed -i 's/true/false/g' ${workdir}/ini/config.ini

    dirname0=$(dirname $workdir)
    cd $dirname0 && bash ${workdir}/func/cvfTarCode.sh $shellPackage $shellPackage
    if [ "$dirname0" != "/opt" ];then
      cp -rf ${shellPackage}.tar /opt
    fi

    rm -f ${workdir}/ini/hosts.ini
    mv ${workdir}/ini/hosts_bak.ini ${workdir}/ini/hosts.ini

    expect -c "
      set timeout 10
      spawn /usr/bin/scp ${dirname0}/${shellPackage}.tar ${account}@${host}:${targetDir}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*password*\" {send \"${password}\r\";}
      }

      spawn /usr/bin/ssh ${account}@${host}
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*assword*\" {send \"${password}\r\";}
      }
      expect \"]*\" {send \"yum -y install expect\n\"}
      expect \"]*\" {send \"cd ${targetDir}\n\"}
      expect \"]*\" {send \"tar zxvf ${shellPackage}.tar \n\"}
      expect \"]*\" {send \"rm -f ${targetDir}/${shellPackage}.tar \n\"}
      expect \"]*\" {send \"cd ${targetDir}/${shellPackage} && bash views/buildEnvDepend.sh ${targetDir}/${shellPackage} \n\"}
      expect \"]*\" {send \"exit\n\"}
      expect eof;"
  fi
done < ${workdir}/ini/hosts.ini

sed -i 's/isnew/notnew/g' ${workdir}/ini/hosts.ini
