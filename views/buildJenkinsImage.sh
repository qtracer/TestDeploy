#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_image=$(cat ${workdir}/ini/config.ini | grep "jenkins_image" | awk -F = '{print $2}')

export info="$0: build jenkins image"
bash ${workdir}/comm/echoInfo.sh $workdir
docker build -t $jenkins_image -f ${workdir}/dockerfile/jenkins-dockerfile . | tee -a ${workdir}/log/${curdate}.log
