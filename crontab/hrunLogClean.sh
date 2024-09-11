#!/bin/bash

workdir=$1

while true; do
  hrunlog=$(cat ${workdir}/ini/config.ini | grep "hrunlog" | awk -F = '{print $2}')
  hrun_log_wait=$(cat ${workdir}/ini/config.ini | grep "hrun_log_wait" | awk -F = '{print $2}')
  hrun_log_interval=$(cat ${workdir}/ini/config.ini | grep "hrun_log_interval" | awk -F = '{print $2}')
  global_wait_flag=$(cat ${workdir}/ini/config.ini | grep "global_wait_flag" | awk -F = '{print $2}')

  if [ $global_wait_flag -eq 0 ];then
    break
  fi
  echo "$hrunlog"
  if [ -d "$hrunlog" ];then
    find $hrunlog -type f -mtime +${hrun_log_interval} -exec rm -f {} \; -exec bash -c 'rmdir $(dirname "{}") 2>/dev/null' \;
  fi

  sleep $((${hrun_log_wait}*24*3600))
done

