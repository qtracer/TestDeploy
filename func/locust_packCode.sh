#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
jenkins_container=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_container" | awk -F = '{print $2}')

mkdir -vp /opt/locust
# cd /opt/locust/${JOB_HOME}

# 将容器内的代码包压缩
echo "this is locust_buildImage.sh,whereis pwd：$(pwd)"
echo 2s
packageName=${JOB_NAME}${tag}
docker cp ${workdir}/func/cvfTarCode.sh ${jenkins_container}:/var/jenkins_home/workspace
docker exec $jenkins_container sh -c "cd /var/jenkins_home/workspace && chmod +x cvfTarCode.sh && ./cvfTarCode.sh ${packageName} ${JOB_NAME}"

# 将代码从容器打包到工作目录
docker cp ${jenkins_container}:/var/jenkins_home/workspace/${packageName}.tar /opt/locust
cp ${workdir}/func/xvfTarCode.sh /opt/locust
cd /opt/locust && chmod +x xvfTarCode.sh && ./xvfTarCode.sh ${packageName} && rm -f ${packageName}.tar

# 将shell中文件copy一份到工作目录
cd /opt/locust/${JOB_NAME}
cp ${workdir}/locusts/.env $(pwd)
cp ${workdir}/locusts/docker-compose.yml $(pwd)
cp ${workdir}/dockerfile/locust-dockerfile $(pwd)
cp ${workdir}/locusts/requirements.txt $(pwd)

