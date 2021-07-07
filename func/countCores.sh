#!/bin/bash

#cpus=$(cat /proc/cpuinfo | grep "physical id" | uniq | wc -l)
#ecores=$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)

workdir=$1
inputNum=$2

totalCores=$[ $(cat /proc/cpuinfo | grep "cpu cores" | wc -l) - 2 ]

if [ $inputNum -ge $totalCores ];then
  if [ $totalCores -gt 0 ];then
    echo $totalCores > ${workdir}/data/tmp.txt
  else 
    echo "1" > ${workdir}/data/tmp.txt
  fi
else
  echo $inputNum > ${workdir}/data/tmp.txt
fi

