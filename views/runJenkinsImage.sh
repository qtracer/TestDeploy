#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_image=$(cat ${workdir}/ini/store.ini | grep "jenkins_image" | awk -F = '{print $2}')
jenkins_home=$(cat ${workdir}/ini/store.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/store.ini | grep "jenkins_container" | awk -F = '{print $2}')
port=$(cat ${workdir}/ini/store.ini | grep "jenkins_port" | awk -F = '{print $2}')

docker ps -a | grep ${jenkins_container} &> /dev/null
if [ $? -eq 0 ];then
  docker stop ${jenkins_container}
  docker rm -f ${jenkins_container}
fi

docker run -it -d -p ${port}:8080 --name ${jenkins_container} --privileged=true -v ${jenkins_home}:${jenkins_home} $jenkins_image

export info="$0: cat docker ps after run JenkinsImage"
bash ${workdir}/comm/echoInfo.sh $workdir
docker ps | tee -a /${workdir}/log/${curdate}.log

# 等30s是为了等contain完全启动，否则可能会无法加载default.json文件
# echo "正在配置，请稍等..."
# sleep 30s
