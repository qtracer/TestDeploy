#!/bin/bash

# @author GHJ 2021-05-17

workdir=$1
jenkins_home=$(cat ${workdir}/ini/config.ini | grep "jenkins_home" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 存放python3安装包
function installPy(){
  yum -y install wget
  mkdir -vp ${jenkins_home}/python3
  cd ${jenkins_home}/python3
  echo `pwd`  
  wget http://python.org/ftp/python/${pyVersion}/Python-${pyVersion}.tgz --no-check-certificate
  sleep 2s
  tar -zxvf Python-${pyVersion}.tgz
  sleep 2s
}

# 下载依赖包
function installDepend(){
  yum -y install gcc automake autoconf libtool make
  yum -y install make* 
  yum -y install zlib* 
  yum -y install openssl libssl-dev openssl-devel
  yum -y install sudo
}

# 编译
function compile(){
  #echo `pwd`
  #sleep 2s
  cd Python-${pyVersion}
  ./configure --prefix=${jenkins_home}/python3 --with-ssl
  sleep 2s
  make && make install
}

# 建立软链接
function addLink(){
  
  rm -f /usr/bin/python3
  rm -f /usr/bin/pip3

  ln -s ${jenkins_home}/python3/bin/python3 /usr/bin/python3
  ln -s ${jenkins_home}/python3/bin/pip3 /usr/bin/pip3
  export info="主机python3环境"
  bash ${workdir}/comm/echoInfo.sh $workdir $curdate
  echo "主机python3命令是否可运行：$(python3 -V)" >> ${workdir}/log/${curdate}.log
  echo "主机pip3命令是否可运行：$(pip3 -V)" >> ${workdir}/log/${curdate}.log
}

function addTools(){
  pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple
  pip3 config set install.trusted-host mirrors.aliyun.com
  pip3 install --upgrade pip
  pip3 install requests urllib3==1.25.11 -y
  pip3 install mock csv rsa -y
  pip3 install redis pymysql -y
}

installPy
installDepend "下载python3依赖环境"
compile "编译"
addLink "添加软链接，加入到环境变量"
addTools
