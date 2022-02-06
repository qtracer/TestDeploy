#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
python_image=$(cat ${workdir}/ini/store.ini | grep "python_image" | awk -F = '{print $2}')
hrunVersion=$(cat ${workdir}/ini/store.ini | grep "hrunVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

docker build -t ${python_image} -f ${workdir}/dockerfile/python-dockerfile --build-arg envArg=${hrunVersion} . | tee -a ${workdir}/log/${curdate}.log
