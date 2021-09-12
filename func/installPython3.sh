#!/bin/bash

# @author GHJ 2021-05-17

workdir=$1
jenkins_home=$(tail -3 ${workdir}/ini/store.ini | grep "jenkins_home" | awk -F , '{print $2}')
container_name=$(tail -3 ${workdir}/ini/store.ini | grep "container_name" | awk -F , '{print $2}')
port=$(tail -3 ${workdir}/ini/store.ini | grep "port" | awk -F , '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
pyVersion=$(cat ${workdir}/ini/appVersion.ini | grep "pyVersion" | awk -F = '{print $2}')


# 存放python3安装包
function installPy(){
  yum -y install wget
  mkdir ${jenkins_home}/python3
  cd ${jenkins_home}/python3
  echo `pwd`  
  wget http://python.org/ftp/python/${pyVersion}/Python-${pyVersion}.tgz
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
  docker exec ${container_name} sh -c "rm -f /usr/bin/python3"
  docker exec ${container_name} sh -c "rm -f /usr/bin/pip3"

  # 验证python3环境是否安装成功，不成功会有报错
  docker exec ${container_name} sh -c "ln -s ${jenkins_home}/python3/bin/python3 /usr/bin/python3"
  docker exec ${container_name} sh -c "ln -s ${jenkins_home}/python3/bin/pip3 /usr/bin/pip3"
  export info="容器内python3环境"
  bash ${workdir}/comm/echoInfo.sh $workdir $curdate
  docker exec ${container_name} sh -c 'python3 -V' >> ${workdir}/log/${curdate}.log
  docker exec ${container_name} sh -c 'pip3 -V' >> ${workdir}/log/${curdate}.log

  ln -s ${jenkins_home}/python3/bin/python3 /usr/bin/python3
  ln -s ${jenkins_home}/python3/bin/pip3 /usr/bin/pip3
  export info="主机python3环境"
  bash ${workdir}/comm/echoInfo.sh $workdir $curdate
  echo "主机python3命令是否可运行：$(python3 -V)" >> ${workdir}/log/${curdate}.log
  echo "主机pip3命令是否可运行：$(pip3 -V)" >> ${workdir}/log/${curdate}.log
}

# 重试三次
function retry(){
  local count=0
  while [ $count -lt 3 ]
  do
    docker exec ${container_name} sh -c "${jenkins_home}/python3/bin/python3 -V" &> /dev/null
    echo $(docker exec ${container_name} sh -c "${jenkins_home}/python3/bin/python3 -V")
    sleep 2s
    if [ $? -eq 0 ];then
      break
    else
      count=$[ $count + 1 ]
      installPy
      compile
    fi
  done
  
  # 安装失败，则自动删除jenkins_home、container_name和port
  docker exec ${container_name} sh -c "${jenkins_home}/python3/bin/python3 -V" &> /dev/null
  echo $(docker exec ${container_name} sh -c "${jenkins_home}/python3/bin/python3 -V")
  cat ${workdir}/ini/store.ini  
  sleep 2s
  if [ $? -eq 0 ];then
    echo "successful"
  else
    sed -i '/'"${jenkins_home}"'/d' ${workdir}/ini/store.ini
    sed -i '/'"${container_name}"'/d' ${workdir}/ini/store.ini
    sed -i '/'"${port}"'/d' ${workdir}/ini/store.ini
  fi
  cat ${workdir}/ini/store.ini
}


# 容器内部安装常用命令
function installCommand(){
  docker exec ${container_name} sh -c "apt-get update && apt-get -y install vim || apt-get -y install lrzsz"
}

installPy
installDepend "下载python3依赖环境"
compile "编译"
retry "安装失败重试"
addLink "添加软链接，加入到环境变量"
installCommand "容器内安装常用命令"
