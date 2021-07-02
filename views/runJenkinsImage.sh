#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_image=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_image" | awk -F = '{print $2}')
jenkins_home=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/jenkins.ini | grep "jenkins_container" | awk -F = '{print $2}')


docker run -it -d -p 8080:8080 --name ${jenkins_container} --privileged=true -v ${jenkins_home}:${jenkins_home} $jenkins_image


# 等30s是为了等contain完全启动，否则可能会无法加载default.json文件
echo "正在配置，请稍等..."
sleep 30s
