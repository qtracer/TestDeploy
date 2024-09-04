#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
# python_image=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}')
python_img=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
python_tag=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
hrunVersion=$(cat ${workdir}/ini/config.ini | grep "hrunVersion" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')
reqVersion=$(cat ${workdir}/ini/config.ini | grep "reqVersion" | awk -F = '{print $2}')
masaVersion=$(cat ${workdir}/ini/config.ini | grep "masaVersion" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_python_img=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_python_tag=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_python_img" ] || [ -z "$registry_password" ];then
  echo "local"
  docker build \
   -t ${python_img}:debug-${python_tag} \
   -f ${workdir}/dockerfile/python-dockerfile \
   --build-arg hrunVersion=$hrunVersion \
   --build-arg reqVersion=$reqVersion \
   --build-arg masaVersion=$masaVersion \
   --build-arg images=python:$pyVersion .
else
  echo "registry"
  docker images | grep "$registry_python_img" | grep "debug-$registry_python_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}

    docker build \
      -t ${registry_python_img}:debug-${registry_python_tag} \
      -f ${workdir}/dockerfile/python-dockerfile \
      --build-arg hrunVersion=$hrunVersion \
      --build-arg reqVersion=$reqVersion \
      --build-arg masaVersion=$masaVersion \
      --build-arg images=${registry_url_download}/${registry_python_img}:${registry_python_tag} .
  fi

fi
