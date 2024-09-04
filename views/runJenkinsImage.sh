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
  echo "jenkins重跑,报错无需理会"
  
  mkdir -vp ${jenkins_home}/updates
  sudo chown -R 1000:1000 ${jenkins_home}
  sudo chmod -R 755 ${jenkins_home}

  cp -f ${workdir}/data/default.json ${jenkins_home}/updates/
 
  docker run -it -d -p ${port}:8080  --name ${jenkins_container} -e TZ='Asia/Shanghai' --privileged=true -v ${jenkins_home}:/var/jenkins_home $jenkins_image
  
  sleep 3s
 
  docker exec ${jenkins_container} sh -c "cat /var/jenkins_home/updates/default.json | grep 'tsinghua'" &> /dev/null
  if [ $? -eq 0 ];then
    echo "tsinghua已存在"
  else
    echo "tsinghua不存在"
  fi


  export info="$0: cat docker ps after run JenkinsImage"
  bash ${workdir}/comm/echoInfo.sh $workdir
  docker ps | tee -a /${workdir}/log/${curdate}.log
}


docker ps -a | grep ${jenkins_container} &> /dev/null
if [ $? == 0 ];then
  :
else
  reRunJenkins
  cat ${workdir}/data/statement_mirror.txt
fi


