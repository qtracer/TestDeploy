#!/bin/bash

workdir=$1
JOB_NAME=$2
# appointedCase=$3
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')
locustVersion=$(cat ${workdir}/ini/config.ini | grep "locustVersion" | awk -F = '{print $2}')
reqVersion=$(cat ${workdir}/ini/config.ini | grep "reqVersion" | awk -F = '{print $2}')
redisVersion=$(cat ${workdir}/ini/config.ini | grep "redisVersion" | awk -F = '{print $2}')


registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_python_img=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_python_tag=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')

export info="$0: build locust image of $JOB_NAME"
bash ${workdir}/comm/echoInfo.sh $workdir

# 构建locust镜像
cd /opt/locust/${JOB_NAME}
if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_python_img" ] || [ -z "$registry_password" ];then
  echo "local"
  docker build -t ${JOB_NAME} -f locust-dockerfile \
    --build-arg locustVersion=$locustVersion \
    --build-arg reqVersion=$reqVersion \
    --build-arg redisVersion=$redisVersion \
    --build-arg images=python:$pyVersion .
else
  echo "registry"
  docker images | grep "$registry_python_img" | grep "debug-$registry_python_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}
    docker build -t ${JOB_NAME} -f locust-dockerfile \
      --build-arg locustVersion=$locustVersion \
      --build-arg reqVersion=$reqVersion \
      --build-arg redisVersion=$redisVersion \
      --build-arg images=${registry_url_download}/${registry_python_img}:${registry_python_tag} .
  fi
fi

