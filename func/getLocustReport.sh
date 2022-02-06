#!/bin/bash

workdir=$1
JOB_NAME=$2

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

container_name=${JOB_NAME}_master_1

docker attach --sig-proxy=false $container_name

`python3 ${workdir}/python/getLocustReports.py`
