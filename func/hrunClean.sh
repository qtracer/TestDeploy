#! /bin/bash

workdir=$1

basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

sn=$[ $(cat ${workdir}/ini/pycontainer.ini | grep "${basePythonHome}" | wc -l) ]
sn=$(( $sn % 56000 ))

rm -rf ${basePythonHome}/python${sn}/*

