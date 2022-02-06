#!/bin/bash

workdir=$1

openrestyVersion=$(cat ${workdir}/ini/store.ini | grep "openrestyVersion" | awk -F = '{print $2}')
openrestyHome=$(cat ${workdir}/ini/store.ini | grep "openrestyHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

cd $openrestyHome/openresty-${openrestyVersion}/sockproc &> /dev/null
if [ $? != 0 ];then
  bash ${workdir}/func/z_nginxProxy.sh $workdir
fi
