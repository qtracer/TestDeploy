#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
openModel=$4
appointedCase=$5

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/config.ini | grep "jenkins_container" | awk -F = '{print $2}')
locust_workspace=$(cat ${workdir}/ini/config.ini | grep "locust_workspace" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

mkdir -vp $locust_workspace

# 性能项目代码来源方式:(1)jenkins_workspace:git拉取 (2)放置在TestDeploy上级目录下:直接上传到服务器
# 将jenkins_workspace/的性能项目代码复制到/opt/locust
jenkins_workspace=$(pwd)

if [ -d "${locust_workspace}/${JOB_NAME}" ];then
  rm -rf ${locust_workspace}/${JOB_NAME}
fi
cp -rf $(dirname $jenkins_workspace)/${JOB_NAME} $locust_workspace

# 根据条件,将TestDeploy中的部分文件copy一份到Locust工作目录
cd ${locust_workspace}/${JOB_NAME}
echo "appointedCase is : $appointedCase"
echo "openModel is: $openModel"
if [ $appointedCase ];then 
  cp -f ${workdir}/locusts/docker-compose-withCase.yml $(pwd)
else
  if [ "$openModel" = "single" ];then
    cp -f ${workdir}/locusts/docker-compose.yml $(pwd)
  else
    cp -f ${workdir}/locusts/docker-compose-worker.yml $(pwd)
    cp -f ${workdir}/locusts/docker-compose-master.yml $(pwd)
  fi
fi

cp -f ${workdir}/locusts/.env $(pwd)
cp -f ${workdir}/dockerfile/locust-dockerfile $(pwd)
cp -f ${workdir}/locusts/requirements.txt $(pwd)

export info="$0: list files of $JOB_NAME after pack code to ${locust_workspace}/$JOB_NAME"
bash ${workdir}/comm/echoInfo.sh $workdir
ls -al

