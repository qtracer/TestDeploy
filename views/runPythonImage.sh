#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
python_image=$(cat ${workdir}/ini/config.ini | grep "python_image" | awk -F = '{print $2}')
basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

sn=$[ $(cat ${workdir}/ini/pycontainer.ini | grep "${basePythonHome}" | wc -l) + 1 ]
sn=$(( $sn % 56000 ))
python_home=${basePythonHome}/python${sn}
python_container=${JOB_NAME}_${tag}
port=$[ 9000 + $sn ]

echo "${python_container},${python_home},${port},0" >> ${workdir}/ini/pycontainer.ini

# 需要添加镜像构建失败重试机制
docker run -it -d -p ${port}:8080 --name ${python_container} --privileged=true -v ${python_home}:${python_home} $python_image /bin/bash

export info="$0: cat docker containers after run PythonImage"
bash ${workdir}/comm/echoInfo.sh $workdir
docker ps | tee -a ${workdir}/log/${curdate}.log
