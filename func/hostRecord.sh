#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
mainhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 分布式性能测试前，写入master ip
sed -i '/'"mainhost"'/d' ${workdir}/locusts/.env
sed -i '$amainhost='"${mainhost}" ${workdir}/locusts/.env

export info="$0: cat .env after record locust master's host"
bash ${workdir}/comm/echoInfo.sh $workdir
cat ${workdir}/locusts/.env | tee -a /${workdir}/log/${curdate}.log

