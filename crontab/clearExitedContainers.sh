#!/bin/bash

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

docker rm $(docker ps -qf status=exited)
