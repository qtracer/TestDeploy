#!/bin/bash

workdir=$1

# 根据最新配置动态处理
while true; do
  locustlog=$(cat ${workdir}/ini/config.ini | grep "locustlog" | awk -F = '{print $2}')
  locust_log_wait=$(cat ${workdir}/ini/config.ini | grep "locust_log_wait" | awk -F = '{print $2}')
  locust_log_interval=$(cat ${workdir}/ini/config.ini | grep "locust_log_interval" | awk -F = '{print $2}')
  global_wait_flag=$(cat ${workdir}/ini/config.ini | grep "global_wait_flag" | awk -F = '{print $2}')
  
  if [ $global_wait_flag -eq 0 ];then
    break
  fi

  if [ -d "$locustlog" ];then
    find $locustlog -type f -mtime +${locust_log_interval} -exec rm -f {} \; -exec bash -c 'rmdir $(dirname "{}") 2>/dev/null' \;
  fi

  sleep $((${locust_log_wait}*24*3600))
done

