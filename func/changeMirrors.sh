#!/bin/bash

workdir=$1

jenkins_home=$(cat ${workdir}/ini/config.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 改变docker的镜像源
# cat ${workdir}/data/daemon.json > /etc/docker/daemon.json


# 改变jenkins下载组件的镜像源
export info="$0: 更换容器Jenkins镜像源(判断tsinghua是否存在，存在1,不存在0)"
bash ${workdir}/comm/echoInfo.sh $workdir $curdate

cd ${jenkins_home}/updates && ls -al
sudo sed -i 's/https:\/\/updates.jenkins.io\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' ${jenkins_home}/updates/default.json
sudo sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' ${jenkins_home}/updates/default.json

cat ${jenkins_home}/updates/default.json | grep "tsinghua" &> /dev/null
if [ $? -eq 0 ];then
  echo "tsinghua已存在"
else
  echo "tsinghua不存在"
fi

docker restart ${jenkins_container}

sleep 2s

cat ${workdir}/data/statement_mirror.txt
