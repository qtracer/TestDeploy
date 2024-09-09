#!/bin/bash

# 定时检测locust状态,当状态由running转为stopped,即保存并发送报告

workdir=$1
JOB_NAME=$2

masterhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

LOCUST_URL="http://${masterhost}:8089/stats/requests"

flag=1
ifstate=0
ifsend=0

# 循环检查 Locust 状态
while true; do
  # 使用 curl 获取 Locust 的状态信息
  response=$(curl -s $LOCUST_URL)

  if echo "$response" | grep "state"; then
    # 检测到locust服务运行中,重置状态值和标识
    ifstate=1
    flag=0
  else
    # 若locust没有启动或者启动后关闭,重置状态值
    ifstate=0
  fi
  
  # 重置[是否保存report和发送邮件]状态
  if echo "$response" | grep "running"; then
    ifsend=1
  fi

  # 若locust服务关闭,退出检测
  if [ $flag -eq 0 ] && [ $ifstate -eq 0 ];then
    break
  fi

  # 每当state由running转为stopped,均保存一次report并邮件
  if echo "$response" | grep "state" | grep "stopped" && [ $ifsend -eq 1 ]; then
    echo "Locust is stopped and send report"
    bash ${workdir}/func/getLocustReport.sh ${workdir} ${JOB_NAME} ${masterhost}
    ifsend=0
  fi

  # 每隔 2秒 检查一次
  sleep 2
done

