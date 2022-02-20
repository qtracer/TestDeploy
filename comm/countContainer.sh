#!/bin/bash

workdir=$1

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

cat ${workdir}/ini/config.ini | grep "port" | wc -l > ${workdir}/data/tmp.txt
