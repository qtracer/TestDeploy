#!/bin/bash

workdir=$1
keyword=$(cat $workdir/ini/store.ini | grep "keyword" | awk -F = '{print $2}')

  while [ 1 == 1 ]; do
    read -p "$statement" readParam
    if [[ $readParam != *$keyword* ]];then
      echo $readParam > ${workdir}/data/tmp.txt
      break
    else
      continue
    fi
  done

