#!/bin/bash

workdir=$1
JOB_NAME=$2
appointedHost=$3
appointedCase=$4

locust_main=$(cat ${workdir}/ini/config.ini | grep "locust_main" | awk -F = '{print $2}')
locust_project_setEnv=$(cat ${workdir}/ini/config.ini | grep "locust_project_setEnv" | awk -F = '{print $2}')
mainhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')
locust_workspace=$(cat ${workdir}/ini/config.ini | grep "locust_workspace" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir


cd ${locust_workspace}/${JOB_NAME}
# 重置.env
sed -i 's/^mainhost=.*/mainhost='"${mainhost}"'/' .env
sed -i 's/default/'"${JOB_NAME}"'/g' .env
sed -i 's/^locust_main=.*/locust_main='"${locust_main}"'/' .env
sed -i 's#^locust_workspace=.*#locust_workspace='"${locust_workspace}"'#' .env
if [ $appointedCase ];then
  sed -i 's/^appointedCase=.*/appointedCase='"${appointedCase}"'/' .env
  # sed -i 's/all/'"${appointedCase}"'/g' .env
fi


# 压测前执行压测项目的环境和数据源的切换
# 不存在时,默认不切换
echo $locust_project_setEnv
if [ -f "$locust_project_setEnv" ];then
  which python3 &> /dev/null
  if [ $? -eq 0 ];then
    # 需要locust_project_setEnv参数值对应的文件对参数appointedHost进行判断
    python3 $locust_project_setEnv $appointedHost
  else
    python $locust_project_setEnv $appointedHost
  fi
fi

export info="$0: cat .env after do changeComposeEnv"
bash ${workdir}/comm/echoInfo.sh $workdir
cat .env

