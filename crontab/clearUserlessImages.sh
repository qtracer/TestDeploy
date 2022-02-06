#!/bin/bash

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

docker rmi $(docker images -qf dangling=true)

