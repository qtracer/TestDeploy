#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
python_image=$(cat ${workdir}/ini/python.ini | grep "python_image" | awk -F = '{print $2}')
hrunVersion=$(cat ${workdir}/ini/appVersion.ini | grep "hrunVersion" | awk -F = '{print $2}')

export info="build python&&install components"
bash ${workdir}/comm/echoInfo.sh $workdir

docker build -t ${python_image} -f ${workdir}/dockerfile/python36-dockerfile --build-arg envArg=${hrunVersion} . | tee -a ${workdir}/log/${curdate}.log
