#!/bin/bash

workdir=$1

release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

if [ "$release" == "centos" ];then
  yum -y install crontabs

  /bin/systemctl restart crond.service
  chkconfig -level 35 crond on
else
  apt -y install cron
  systemctl start cron
  systemctl enable cron
fi

