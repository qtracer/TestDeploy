#!/bin/bash

# @author GHJ 2021/05/15

workdir=$1

dVersion=$(cat ${workdir}/ini/config.ini | grep "dVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 安装Docker依赖环境
function setDockerRepo(){
  # echo `yum list installed`
  yum install -y yum-utils device-mapper-persistent-data lvm2 && 
  yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo &&
  yum makecache fast

  echo "列出Docker所有版本"
  yum list docker-ce --showduplicates | sort -r 
}

:<<!
function choiceVersion(){
  echo "列出Docker所有版本"
  yum list docker-ce --showduplicates | sort -r

  echo "0:最新 1:配置默认版本  2:输入其他版本"
  read -p "请选择Docker版本：" choice

  if [ $choice -eq 0 ];then 
    dVersion="docker-ce"
  elif [ $choice -eq 1 ];then
    echo "配置默认版本为：${dVersion}"
  else
    read -p "请输入版本号（如18.06.1）：" version
    dVersion="docker-ce-${version}.ce"
  fi
}
!

# 安装Docker
installDocker(){
  echo "$dVersion"
  # 自动确认license声明，并回车继续安装
  echo y | yum install -y $dVersion

   #更改docker的镜像源
  cp ${workdir}/data/daemon.json /etc/docker/

  systemctl restart docker.service
  systemctl enable docker.service
  sleep 3s
}

setDockerRepo "安装docker仓库和依赖"
# choiceVersion "选择docker版本"
installDocker "安装docker环境并且加入开机自启动"
