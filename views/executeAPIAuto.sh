#!/bin/bash

workdir=$1
JOB_NAME=$2

python_container=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $1}')
python_home=$(cat ${workdir}/ini/container.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $2}')
hrun_path=$(cat ${workdir}/ini/hrunpath.ini | grep "hrun_path" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

docker exec ${python_container} sh -c "cd ${python_home}/${JOB_NAME} && hrun ${hrun_path}" | tee -a ${workdir}/log/${curdate}.log
