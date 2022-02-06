#!/bin/bash

remaincores=$1

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

totalCores=$[ $(cat /proc/cpuinfo | grep "cpu cores" | wc -l) - $remaincores ]

echo "$totalCores"
exit $totalCores

