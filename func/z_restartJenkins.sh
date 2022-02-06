#!/bin/bash
# 不在标准化流程范围内，按需使用

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

service network restart
service docker restart
docker restart myjenkins
