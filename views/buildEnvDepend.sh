#!/bin/bash
# 安装必要的支持环境

workdir=$1

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

logpath=$(cat ${workdir}/ini/config.ini | grep "logpath" | awk -F = '{print $2}')

# mkdir -vp $logpath
bash ${workdir}/views/installDocker.sh ${workdir}

bash ${workdir}/func/installGit.sh ${workdir}
bash ${workdir}/func/installJDK.sh ${workdir}
bash ${workdir}/func/installExpect.sh $workdir
bash ${workdir}/func/installDockerCompose.sh ${workdir}
bash ${workdir}/func/installCrontab.sh ${workdir}
# bash ${workdir}/views/ifNginxProxy.sh ${workdir}

bash ${workdir}/views/buildPythonImage.sh ${workdir}

# sed -i '/github/d' /etc/hosts

exit
