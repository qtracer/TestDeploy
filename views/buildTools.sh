#!/bin/bash
# 安装工具或组件

workdir=$1

# logpath=$(cat ${workdir}/ini/config.ini | grep "logpath" | awk -F = '{print $2}')
ifJenkins=$(cat ${workdir}/ini/config.ini | grep "installedJenkins" | awk -F = '{print $2}')
ifSonarqube=$(cat ${workdir}/ini/config.ini | grep "installedSonarqube" | awk -F = '{print $2}')
ifRedis=$(cat ${workdir}/ini/config.ini | grep "installedRedis" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ "$ifJenkins" = "notJenkins" ];then
  bash ${workdir}/views/buildJenkinsImage.sh ${workdir}
  bash ${workdir}/views/runJenkinsImage.sh ${workdir}
  sed -i 's/notJenkins/isJenkins/g' ${workdir}/ini/config.ini
fi

if [ "$ifSonarqube" = "notSonarqube" ];then
  bash ${workdir}/views/runPostgresqlImage.sh ${workdir}
  bash ${workdir}/views/runSonarqubeImage.sh ${workdir}
  sed -i 's/notSonarqube/isSonarqube/g' ${workdir}/ini/config.ini
fi

if [ "$ifRedis" = "notRedis" ];then
  bash ${workdir}/views/runRedisImage.sh ${workdir}
  sed -i 's/notRedis/isRedis/g' ${workdir}/ini/config.ini
fi

