#!/bin/bash
# 安装必要的支持环境

workdir=$1

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

mkdir -vp $logpath
bash ${workdir}/func/timeSync.sh ${workdir}
bash ${workdir}/views/installDocker.sh ${workdir}
bash ${workdir}/func/installGit.sh ${workdir}

bash ${workdir}/func/installJDK.sh ${workdir}
bash ${workdir}/views/buildPythonImage.sh ${workdir}

bash ${workdir}/func/installDockerCompose.sh ${workdir}

# bash ${workdir}/views/ifNginxProxy.sh ${workdir}
bash ${workdir}/func/installCrontab.sh

sed -i '/github/d' /etc/hosts

exit
