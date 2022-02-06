#!/bin/bash

# 脚本参考 https://blog.csdn.net/yckiven/article/details/116018616
# 模块可用，但不建议使用

workdir=$1

openrestyVersion=$(cat ${workdir}/ini/store.ini | grep "openrestyVersion" | awk -F = '{print $2}')
openrestyHome=$(cat ${workdir}/ini/store.ini | grep "openrestyHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

function installOpenresty(){
  yum install pcre-devel openssl-devel gcc curl wget net-tools git -y
  
  cd /$openrestyHome/openresty-${openrestyVersion} &> /dev/null
  if [ $? != 0 ];then
    cd $openrestyHome
    wget http://openresty.org/download/openresty-${openrestyVersion}.tar.gz
    tar -xzvf openresty-${openrestyVersion}.tar.gz
    cd openresty-${openrestyVersion}
    ./configure&&make&&make install
  fi
}

function sockproc(){
   cd $openrestyHome/openresty-${openrestyVersion}/sockproc &> /dev/null
   if [ $? != 0 ];then
     git clone https://gitee.com/dalotalk/sockproc.git
     # https://github.com/juce/sockproc
     cd $openrestyHome/openresty-${openrestyVersion}/sockproc
     make  
     mkdir -vp /data/tomcattemp
     ./sockproc /data/tomcattemp/shell.sock
     chmod 666 /data/tomcattemp/shell.sock
   fi
}

function installLuaRestyShell(){
   cd $openrestyHome/openresty-${openrestyVersion}/lua-resty-shell &> /dev/null
   if [ $? != 0 ];then
     cd $openrestyHome/openresty-${openrestyVersion}
     git clone https://gitee.com/dalotalk/lua-resty-shell.git
     # https://github.com/juce/lua-resty-shell 
     mv /usr/local/openresty/lualib/resty/shell.lua /usr/local/openresty/lualib/resty/shell_origin.lua
     cd lua-resty-shell
     cp lib/resty/shell.lua /usr/local/openresty/lualib/resty/
   fi
}


function killProcess(){
  pidMaster=$(netstat -anp | grep 81 | grep nginx | grep "LISTEN" | awk -F " " '{print $7}' | awk -F / '{print $1}')
  kill -9 $pidMaster
  pidWorker=$(netstat -anp | grep 81 | grep nginx | grep "LISTEN" | awk -F " " '{print $7}' | awk -F / '{print $1}')
  kill -9 $pidWorker
}

function setNginx(){
  cp $workdir/lua/ps.lua /usr/local/openresty/lualib/
  chmod +x /usr/local/openresty/lualib/ps.lua
  mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx_origin.conf
  cp $workdir/data/nginx.conf /usr/local/openresty/nginx/conf/
  /usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf &> /dev/null
  if [ $? != 0 ];then
    killProcess
    /usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf
  fi
  /usr/local/openresty/nginx/sbin/nginx -s reload 
}

installOpenresty
sockproc
installLuaRestyShell
setNginx
