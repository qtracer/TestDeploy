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
    apt -y install apt-transport-https ca-certificates curl software-properties-common curl gnupg lsb-release
    curl -s http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/NAME.gpg --import
    sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" -y 
  fi
}


# 安装Docker
installDocker(){
  if [ "$release" == "centos" ];then
    if [ "$dVersion" == "latest" ];then
      yum install -y docker-ce
    else
      yum install -y docker-ce-${dVersion}.ce
    fi
  else
    apt install -y docker.io
    apt install -y docker-ce
  fi
 
  #更改docker的镜像源
  sudo cp -f ${workdir}/data/daemon.json /etc/docker/

  systemctl restart docker.service
  systemctl enable docker.service
  sleep 3s
}

docker version &> /dev/null
if [ $? -ne 0 ];then
  setDockerRepo "安装docker仓库和依赖"
  installDocker "安装docker环境并且加入开机自启动"
fi
