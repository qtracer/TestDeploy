#!/bin/bash

workdir=$1
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

# logpath=$(cat ${workdir}/ini/store.ini | grep "logpath" | awk -F = '{print $2}')

git --version &> /dev/null

if [ $? -eq 0 ];then
  echo "宿主机Git环境已安装，不需要重新安装"
else
  echo "尚未安装，docker环境安装中" 
  yum -y install git
fi

export info="$0: git version"
bash ${workdir}/comm/echoInfo.sh $workdir
git --version | tee -a ${workdir}/log/${curdate}.log

# 修改提交缓存大小
git config --global https.postBuffer 524288000
git config https.postBuffer 524288000
git config --global http.postBuffer 524288000
git config http.postBuffer 524288000

# 只有十分钟（600秒）传输速率都低于1KB/s的话才会timeout
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 600
