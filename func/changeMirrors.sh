#!/bin/bash

workdir=$1

jenkins_home=$(cat ${workdir}/ini/store.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/store.ini | grep "jenkins_container" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 改变docker的镜像源
cat ${workdir}/data/daemon.json > /etc/docker/daemon.json


# 改变jenkins下载组件的镜像源
export info="$0: 更换容器Jenkins镜像源(判断tsinghua是否存在，存在1,不存在0)"
bash ${workdir}/comm/echoInfo.sh $workdir $curdate

docker exec ${jenkins_container} sh -c "cd /var/jenkins_home/updates &&\
sed -i 's/https:\/\/updates.jenkins.io\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json &&\
sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json"

if [ $? -eq 0 ];then
  echo "default.json已存在"
else
  docker exec ${jenkins_container} sh -c "cd /var/jenkins_home && mkdir updates"
  docker cp ${workdir}/data/default.json ${jenkins_container}:/var/jenkins_home/updates/
fi

sleep 2s

docker exec ${jenkins_container} sh -c "cat /var/jenkins_home/updates/default.json | grep "tsinghua" | wc -l" | tee -a ${workdir}/log/${curdate}.log

cat ${workdir}/data/statement_mirror.txt

