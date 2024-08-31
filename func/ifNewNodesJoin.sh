#!/bin/bash

workdir=$1

cat ${workdir}/ini/hosts.ini | grep 'isnew' &> /dev/null

if [ $? -eq 0 ];then
  sed -i 's/true/false/g' ${workdir}/ini/config.ini
fi
