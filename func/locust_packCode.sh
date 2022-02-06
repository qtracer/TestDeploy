#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
openModel=$4
appointedCase=$5

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
jenkins_container=$(cat ${workdir}/ini/store.ini | grep "jenkins_container" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

mkdir -vp /opt/locust
# cd /opt/locust/${JOB_HOME}

# 将容器内的代码包压缩
echo "this is locust_buildImage.sh,whereis pwd：$(pwd)"
jenkins_workspace=$(pwd)
packageName=${JOB_NAME}${tag}

cp -r $(dirname $jenkins_workspace)/${JOB_NAME} /opt/locust


# 将shell中文件copy一份到Locust工作目录
cd /opt/locust/${JOB_NAME}
echo "appointedCase is : $appointedCase"
echo "openModel is: $openModel"
if [ $appointedCase ];then 
  cp ${workdir}/locusts/docker-compose-withCase.yml $(pwd)
else
  if [ "$openModel" = "single" ];then
    cp ${workdir}/locusts/docker-compose.yml $(pwd)
  else
    cp ${workdir}/locusts/docker-compose-worker.yml $(pwd) &\
    cp ${workdir}/locusts/docker-compose-master.yml $(pwd)
  fi
fi

cp ${workdir}/locusts/.env $(pwd) &\
cat ${workdir}/locusts/.env &\
cp ${workdir}/dockerfile/locust-dockerfile $(pwd) &\
cp ${workdir}/locusts/requirements.txt $(pwd)

export info="$0: list files of $JOB_NAME after pack code to /opt/locust/$JOB_NAME"
bash ${workdir}/comm/echoInfo.sh $workdir
ls -al | tee -a /${workdir}/log/${curdate}.log

