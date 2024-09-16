#!/bin/bash

workdir=$1
basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

:<<! 
发布前，初始化配置
!

## config.ini初始化
FIELDS=("receiver" "sender" "sender_password" "smtp_server" "smtp_port" "registry_url_login" "registry_url_download" "registry_user" "registry_password" "registry_python" "registry_redis" "registry_postgresql" "registry_sonarqube" "registry_jenkins")
# 循环处理每个指定的字段
for field in "${FIELDS[@]}"; do
    # 使用 sed 命令清空指定字段后面的内容
    sed -i "s/^\($field\s*=\).*/\1/" $workdir/ini/config.ini
done

sed -i 's/^installedEnv=.*/installedEnv=false/' ${workdir}/ini/config.ini
sed -i 's/^master_cronExist_flag=.*/master_cronExist_flag=0/' ${workdir}/ini/config.ini



## 清空运行数据
sed -i '1,$d' ${workdir}/ini/pycontainer.ini
sed -i '1,$d' ${workdir}/ini/locontainer.ini
sed -i '1,$d' ${workdir}/ini/global.ini
# sed -i 's/true/false/g' ${workdir}/ini/config.ini
sed -i '1,$d' ${workdir}/ini/cores.ini
sed -i '1,$d' ${workdir}/ini/hosts.ini
sed -i '1,$d' ${workdir}/ini/remoteProject.ini
sed -i '1,$d' ${workdir}/data/usableNetWork.txt
sed -i '1,$d' ${workdir}/data/tmp.txt

# 删除hrun容器  
if [ -d "$basePythonHome" ];then
   rm -rf $basePythonHome/*
fi

# 删除日志
if [ -d "$workdir" ];then
  find ${workdir} -name "*.log" -delete
fi
