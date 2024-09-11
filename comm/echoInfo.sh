#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

echo "++++++++++$(date +%Y-%m-%d' '%H:%M:%S.%N | cut -b 1-23) ${info}++++++++++"

