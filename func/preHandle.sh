#!/bin/bash

workdir=$1

master_cronExist_flag=$(cat ${workdir}/ini/config.ini | grep "master_cronExist_flag" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 判断是否有新节点加入
cat ${workdir}/ini/hosts.ini | grep -q 'isnew' &> /dev/null
if [ $? -eq 0 ];then
  # sed -i 's/true/false/g' ${workdir}/ini/config.ini
  sed -i 's/^installedEnv=.*/installedEnv=false/' ${workdir}/ini/config.ini
fi


# 设置定时任务
if [ $master_cronExist_flag -eq 0 ];then
  bash ${workdir}/views/cronForlogAndContainer.sh ${workdir}
  sed -i 's/^master_cronExist_flag=.*/master_cronExist_flag=1/' ${workdir}/ini/config.ini
fi
