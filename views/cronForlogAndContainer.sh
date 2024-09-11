#!/bin/bash

workdir=$1

# 设置定时任务
nohup bash ${workdir}/crontab/hrunContainerClean.sh ${workdir} > /dev/null &
nohup bash ${workdir}/crontab/hrunLogClean.sh ${workdir} > /dev/null &
nohup bash ${workdir}/crontab/locustLogClean.sh ${workdir} > /dev/null &

