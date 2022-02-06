#!/bin/bash

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

yum install crontabs -y

/bin/systemctl restart crond.service

chkconfig -level 35 crond on
