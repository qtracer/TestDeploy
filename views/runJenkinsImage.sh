#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
# jenkins_image=$(cat ${workdir}/ini/config.ini | grep "jenkins_image" | awk -F = '{print $2}')
jenkins_img=$(cat ${workdir}/ini/config.ini | grep "jenkins_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
jenkins_tag=$(cat ${workdir}/ini/config.ini | grep "jenkins_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
jenkins_home=$(cat ${workdir}/ini/config.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
port=$(cat ${workdir}/ini/config.ini | grep "jenkins_port" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_jenkins_img=$(cat ${workdir}/ini/config.ini | grep "registry_jenkins" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_jenkins_tag=$(cat ${workdir}/ini/config.ini | grep "registry_jenkins" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 存在则删除
num=$(docker ps -a | grep $jenkins_container | wc -l)
if [ $num -ge 1 ];then
  docker stop $jenkins_container
  docker rm -f $jenkins_container
fi


mkdir -vp ${jenkins_home}/updates
sudo chown -R 1000:1000 ${jenkins_home}
sudo chmod -R 755 ${jenkins_home}
cp -f ${workdir}/data/default.json ${jenkins_home}/updates/


if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_jenkins_img" ] || [ -z "$registry_password" ];then
  # 任一为空，则公网拉镜像
  echo "local"
  docker build \
    -t ${jenkins_img}:debug-${jenkins_tag} \
    -f ${workdir}/dockerfile/jenkins-dockerfile \
    --build-arg images=jenkins/jenkins:lts .

  docker run -d \
    -p ${port}:8080 \
    --name ${jenkins_container} \
    -e TZ='Asia/Shanghai' --privileged=true \
    -v ${jenkins_home}:/var/jenkins_home \
    ${jenkins_img}:debug-${jenkins_tag}

else
  echo "registry"
  # 不为空先判断本地是否存在，不存在再拉私库
  docker images | grep "$registry_jenkins_img" | grep "debug-$registry_jenkins_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}

    docker build \
      -t ${registry_jenkins_img}:debug-${registry_jenkins_tag} \
      -f ${workdir}/dockerfile/jenkins-dockerfile \
      --build-arg images=${registry_url_download}/${registry_jenkins_img}:${registry_jenkins_tag} .
  fi

  docker run -d \
    -p ${port}:8080  \
    --name ${jenkins_container} \
    -e TZ='Asia/Shanghai' \
    --privileged=true \
    -v ${jenkins_home}:/var/jenkins_home \
    ${registry_jenkins_img}:debug-${registry_jenkins_tag}
fi
 
sleep 5s

docker exec ${jenkins_container} sh -c "cat /var/jenkins_home/updates/default.json | grep 'tsinghua'" &> /dev/null
if [ $? -eq 0 ];then
  echo "tsinghua已存在"
else
  echo "tsinghua不存在"
fi
  
export info="$0: cat docker ps after run JenkinsImage"
bash ${workdir}/comm/echoInfo.sh $workdir
docker ps

cat ${workdir}/data/statement_mirror.txt

