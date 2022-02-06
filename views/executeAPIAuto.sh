#!/bin/bash
# 执行指定项目的接口自动化

workdir=$1
JOB_NAME=$2
appointedCase=$3

python_container=$(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $1}')
python_home=$(cat ${workdir}/ini/pycontainer.ini | grep "$JOB_NAME" | awk 'END {print}' | awk -F , '{print $2}')
hrun_path=$(cat ${workdir}/ini/store.ini | grep "hrun_path" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: auto execute apis and scenes"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ $appointedCase ];then
  docker exec ${python_container} sh -c "cd ${python_home}/${JOB_NAME} && hrun ${appointedCase}" | tee -a ${workdir}/log/${curdate}.log
else
  docker exec ${python_container} sh -c "cd ${python_home}/${JOB_NAME} && hrun ${hrun_path}" | tee -a ${workdir}/log/${curdate}.log
fi

