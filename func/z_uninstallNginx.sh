#!/bin/bash

workdir=$1

openrestyVersion=$(cat ${workdir}/ini/config.ini | grep "openrestyVersion" | awk -F = '{print $2}')
openrestyHome=$(cat ${workdir}/ini/config.ini | grep "openrestyHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

rm -rf /data/tomcattemp $openrestyHome/openresty-${openrestyVersion}* /usr/local/openresty
