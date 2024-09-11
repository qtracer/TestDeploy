#! /bin/bash

workdir=$1

while true; do
  basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')
  hrun_container_wait=$(cat ${workdir}/ini/config.ini | grep "hrun_container_wait" | awk -F = '{print $2}')
  hrun_container_interval=$(cat ${workdir}/ini/config.ini | grep "hrun_container_interval" | awk -F = '{print $2}')
  global_wait_flag=$(cat ${workdir}/ini/config.ini | grep "global_wait_flag" | awk -F = '{print $2}')

  if [ $global_wait_flag -eq 0 ];then
    break
  fi

  if [ -d "$basePythonHome" ];then
    find $basePythonHome -type f -mtime +${hrun_container_interval} -exec rm -f {} \; -exec bash -c 'rmdir $(dirname "{}") 2>/dev/null' \;
  fi

  sleep $((${hrun_container_wait}*24*3600))
done
