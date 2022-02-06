#!/bin/bash

packageName=$1
JOB_NAME=$2

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

echo $0
tar zcvf ${packageName}.tar $(ls | grep "${JOB_NAME}$")

project_path=$(cd `dirname $0`; pwd)
project_name="${project_path##*/}"
echo $project_name
