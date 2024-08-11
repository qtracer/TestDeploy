#!/bin/bash

echo "del logs start..."
workdir=$(find / -type d -name "TestDeploy*" | head -1)

hrunlog=$(cat ${workdir}/ini/config.ini | grep "hrunlog" | awk -F = '{print $2}')
locustlog=$(cat ${workdir}/ini/config.ini | grep "locustlog" | awk -F = '{print $2}')

if [ -d "${hrunlog}" ];then
  rm -rf ${hrunlog}/*
fi

if [ -d "${locustlog}" ];then
  rm -rf ${locustlog}/*
fi

echo "del logs end..."
