#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_container" | awk -F = '{print $2}')
python_image=$(cat ${workdir}/ini/python.ini | grep "python_image" | awk -F = '{print $2}')
basePythonHome=$(cat ${workdir}/ini/python.ini | grep "basePythonHome" | awk -F = '{print $2}')

sn=$[ $(cat ${workdir}/ini/container.ini | grep "${basePythonHome}" | wc -l) + 1 ]
python_home=${basePythonHome}${sn}
python_container=${JOB_NAME}_${tag}
port=$[ 8080 + $sn ]

echo "${python_container},${python_home},${port}" >> ${workdir}/ini/container.ini

# 需要添加镜像构建失败重试机制
docker run -it -d -p ${port}:8080 --name ${python_container} --privileged=true -v ${python_home}:${python_home} $python_image /bin/bash


:<<!
# 将打包shell脚本copy一份到Jenkins工作路径，并打包到python容器
pwd
echo 10s
packageName=${JOB_NAME}${tag}
cp ${workdir}/func/cvfTarCode.sh $(dirname $(pwd))/cvfTarCode.sh
cd $(dirname $(pwd)) && chmod +x cvfTarCode.sh && ./cvfTarCode.sh ${packageName} ${JOB_NAME}

docker cp ${packageName}.tar ${python_container}:${python_home}
docker cp ${workdir}/func/xvfTarCode.sh ${python_container}:${python_home}
docker exec ${python_container} sh -c "cd ${python_home} && chmod +x xvfTarCode.sh && ./xvfTarCode.sh ${packageName}"

rm -f ${packageName}.tar cvfTarCode.sh
!
