#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
appointedCase=$4
jenkins_container=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_container" | awk -F = '{print $2}')

mkdir -vp /opt/locust/${JOB_NAME}
# cd /opt/locust/${JOB_HOME}

# 将容器内的代码包压缩
echo "this is locust_buildImage.sh,whereis pwd：$(pwd)"
jenkins_workspace=$(pwd)
packageName=${JOB_NAME}${tag}

cp -r $(dirname $jenkins_workspace)/${JOB_NAME}/ /opt/locust


:<<!
docker cp ${workdir}/func/cvfTarCode.sh ${jenkins_container}:/var/jenkins_home/workspace
docker exec $jenkins_container sh -c "cd /var/jenkins_home/workspace && chmod +x cvfTarCode.sh && ./cvfTarCode.sh ${packageName} ${JOB_NAME}"

# 将代码从容器打包到工作目录
docker cp ${jenkins_container}:/var/jenkins_home/workspace/${packageName}.tar /opt/locust
cp ${workdir}/func/xvfTarCode.sh /opt/locust
cd /opt/locust && chmod +x xvfTarCode.sh && ./xvfTarCode.sh ${packageName} && rm -f ${packageName}.tar
!


# 将shell中文件copy一份到工作目录
cd /opt/locust/${JOB_NAME}

if [ $appointedCase ];then 
  cp ${workdir}/locusts/docker-compose-withCase.yml $(pwd)
else
  cp ${workdir}/locusts/docker-compose.yml $(pwd)
fi

cp ${workdir}/locusts/.env $(pwd)
cp ${workdir}/dockerfile/locust-dockerfile $(pwd)
cp ${workdir}/locusts/requirements.txt $(pwd)

