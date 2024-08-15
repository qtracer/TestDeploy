#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_image=$(cat ${workdir}/ini/config.ini | grep "jenkins_image" | awk -F = '{print $2}')
jenkins_home=$(cat ${workdir}/ini/config.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
port=$(cat ${workdir}/ini/config.ini | grep "jenkins_port" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

function reRunJenkins(){
  docker stop ${jenkins_container}
  docker rm -f ${jenkins_container}
  
  docker run -it -d -p ${port}:8080  --name ${jenkins_container} -e TZ='Asia/Shanghai' --privileged=true -v ${jenkins_home}:/var/jenkins_home $jenkins_image
  
  echo "sleep 25s,等待jenkins ready"
  sleep 25s
  sudo chown -R 1000:1000 ${jenkins_home}
  sudo chmod -R 755 ${jenkins_home}


  export info="$0: cat docker ps after run JenkinsImage"
  bash ${workdir}/comm/echoInfo.sh $workdir
  docker ps | tee -a /${workdir}/log/${curdate}.log
}


docker ps -a | grep ${jenkins_container} &> /dev/null
if [ $? == 0 ];then
  :
else
  reRunJenkins
fi


