#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
# python_image=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}')
python_img=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
python_tag=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_python_img=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_python_tag=$(cat ${workdir}/ini/config.ini | grep "registry_python" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

sn=$[ $(cat ${workdir}/ini/pycontainer.ini | grep "${basePythonHome}" | wc -l) + 1 ]
sn=$(( $sn % 56000 ))
python_home=${basePythonHome}/python${sn}
python_container=${JOB_NAME}_${tag}
port=$[ 9000 + $sn ]

echo "${python_container},${python_home},${port},0" >> ${workdir}/ini/pycontainer.ini

if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_python_img" ] || [ -z "$registry_password" ];then
  echo "local"
  docker run -itd \
    -p ${port}:8080 \
    --name ${python_container} \
    -e TZ='Asia/Shanghai' \
    --privileged=true \
    -v ${python_home}:${python_home} \
    ${python_img}:debug-${python_tag} /bin/bash
else
  echo "registry"
  docker run -itd \
    -p ${port}:8080 \
    --name ${python_container} \
    -e TZ='Asia/Shanghai' \
    --privileged=true \
    -v ${python_home}:${python_home} \
    ${registry_python_img}:debug-${registry_python_tag} /bin/bash
fi


export info="$0: cat docker containers after run PythonImage"
bash ${workdir}/comm/echoInfo.sh $workdir
docker ps | tee -a ${workdir}/log/${curdate}.log
