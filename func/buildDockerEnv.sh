#!/bin/bash

workdir=$1

dVersion=$(cat ${workdir}/ini/config.ini | grep "dVersion" | awk -F = '{print $2}')
release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 安装Docker依赖环境
function setDockerRepo(){
  if [ "$release" == "centos" ];then
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast

    echo "列出Docker所有版本"
    yum list docker-ce --showduplicates | sort -r
  else
    apt update -y
    apt -y install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list
    
    echo "列出Docker所有版本"
    apt-cache madison docker-ce
  fi
}


# 安装Docker
installDocker(){
  echo "选中的docker-ce版本: $dVersion"
  if [ "$release" == "centos" ];then
    if [ "$dVersion" == "latest" ];then
      yum install -y docker-ce
    else
      yum install -y docker-ce-${dVersion}.ce
    fi
  else
    if [ "$dVersion" == "latest" ];then
      apt install -y docker-ce
    else
      apt install -y docker-ce=${dVersion}~ce~3-0~ubuntu
    fi
  fi
 
  #更改docker的镜像源
  sudo cp -f ${workdir}/data/daemon.json /etc/docker/

  systemctl restart docker.service
  systemctl enable docker.service
  sleep 3s
}


setDockerRepo "安装docker仓库和依赖"
installDocker "安装docker环境并且加入开机自启动"
