#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

echo "++++++++++++++++++++${info}++++++++++++++++++++" | tee -a ${workdir}/log/${curdate}.log
