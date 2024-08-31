#!/bin/bash

workdir=$1
jenkins_home=$(cat ${workdir}/ini/config.ini | grep "jenkins_home" | awk -F = '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/config.ini | grep "pyVersion" | awk -F = '{print $2}')
release=$(cat ${workdir}/ini/global.ini | grep "release" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 存放python3安装包
function installPy(){
  if [ "$release" == "centos" ];then
    yum -y install wget
    mkdir -vp ${jenkins_home}/python3
    cd ${jenkins_home}/python3
    wget http://python.org/ftp/python/${pyVersion}/Python-${pyVersion}.tgz --no-check-certificate
    sleep 1s
    tar -zxvf Python-${pyVersion}.tgz
    sleep 2s
  fi
}

# 下载依赖包
function installDepend(){
  if [ "$release" == "centos" ];then
    yum -y install gcc automake autoconf libtool make
    yum -y install make* 
    yum -y install zlib* 
    yum -y install openssl libssl-dev openssl-devel
    yum -y install sudo
  else
    apt -y install python3-dev python3-pip python3-venv build-essential libssl-dev libffi-dev
    apt -y install libsqlite3-dev zlib1g-dev libbz2-dev libreadline-dev libncurses5-dev libgdbm-dev liblzma-dev uuid-dev
    apt -y install python3
    apt -y install python3-pip
    pip3 -y install --upgrade pip
  fi
}

# 编译
function compile(){
  if [ "$release" == "centos" ];then
    cd Python-${pyVersion}
    ./configure --prefix=${jenkins_home}/python3 --with-ssl
    sleep 2s
    make && make install
  fi
}

# 建立软链接
function addLink(){
  if [ "$release" == "centos" ];then  
    rm -f /usr/bin/python3
    rm -f /usr/bin/pip3

    ln -s ${jenkins_home}/python3/bin/python3 /usr/bin/python3
    ln -s ${jenkins_home}/python3/bin/pip3 /usr/bin/pip3
    export info="主机python3环境"
    bash ${workdir}/comm/echoInfo.sh $workdir $curdate
    echo "主机python3命令是否可运行：$(python3 -V)" >> ${workdir}/log/${curdate}.log
    echo "主机pip3命令是否可运行：$(pip3 -V)" >> ${workdir}/log/${curdate}.log
  fi
}

function addTools(){
  pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple
  pip3 config set install.trusted-host mirrors.aliyun.com
  pip3 install --upgrade pip
  pip3 install requests urllib3==1.25.11
  pip3 install mock rsa
  pip3 install redis pymysql
  pip3 install beautifulsoup4 lxml
}

installPy
installDepend "下载python3依赖环境"
compile "编译"
addLink "添加软链接，加入到环境变量"
addTools
