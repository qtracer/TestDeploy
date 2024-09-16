#!/bin/bash

workdir=$1

which python3 &> /dev/null
if [ $? -ne 0 ];then
  python --version | grep "3.*" &> /dev/null
  if [ $? -ne 0 ];then
    nohup bash ${workdir}/func/z_installPython3.sh ${workdir} > /dev/null &
  fi
fi

