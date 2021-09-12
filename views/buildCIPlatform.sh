#!/bin/bash

workdir=$1

logpath=$(cat ${workdir}/ini/store.ini | grep "logpath" | awk -F = '{print $2}')

mkdir -vp $logpath
bash ${workdir}/views/installDocker.sh ${workdir}
bash ${workdir}/func/installGit.sh ${workdir}

bash ${workdir}/views/buildJenkinsImage.sh ${workdir}
bash ${workdir}/views/runJenkinsImage.sh ${workdir}

bash ${workdir}/func/changeMirrors.sh ${workdir}
bash ${workdir}/func/installJDK.sh ${workdir}
bash ${workdir}/views/buildPythonImage.sh ${workdir}

bash ${workdir}/func/installExpect.sh $workdir
bash ${workdir}/func/installDockerCompose.sh ${workdir}
bash ${workdir}/views/runRedisImage.sh ${workdir}

sed -i 's/false/true/g' ${workdir}/ini/store.ini &\
sed -i '/github/d' /etc/hosts
