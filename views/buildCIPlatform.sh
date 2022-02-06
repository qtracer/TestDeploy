#!/bin/bash
# 搭建CI平台Jenkins和相关的一些组件

workdir=$1

logpath=$(cat ${workdir}/ini/store.ini | grep "logpath" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

bash ${workdir}/views/buildJenkinsImage.sh ${workdir}
bash ${workdir}/views/runJenkinsImage.sh ${workdir}

bash ${workdir}/func/changeMirrors.sh ${workdir}

bash ${workdir}/func/installExpect.sh $workdir
bash ${workdir}/views/runRedisImage.sh ${workdir}
