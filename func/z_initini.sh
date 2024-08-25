#!/bin/bash

workdir=$1
basePythonHome=$(cat ${workdir}/ini/config.ini | grep "basePythonHome" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 发布前，初始化配置
sed -i '1,$d' ${workdir}/ini/pycontainer.ini
sed -i '1,$d' ${workdir}/ini/locontainer.ini
sed -i '1,$d' ${workdir}/ini/global.ini
sed -i 's/true/false/g' ${workdir}/ini/config.ini
sed -i '1,$d' ${workdir}/ini/cores.ini
sed -i '1,$d' ${workdir}/ini/hosts.ini
sed -i '1,$d' ${workdir}/ini/remoteProject.ini
sed -i '1,$d' ${workdir}/data/usableNetWork.txt
sed -i '1,$d' ${workdir}/data/tmp.txt
sed -i '1,$d' ${workdir}/locusts/.env

# 清空email配置
FIELDS=("receiver" "sender" "sender_password" "smtp_server" "smtp_port")
# 循环处理每个指定的字段
for field in "${FIELDS[@]}"; do
    # 使用 sed 命令清空指定字段后面的内容
    sed -i "s/^\($field\s*=\).*/\1/" $workdir/ini/config.ini
done


if [ $basePythonHome ];then
   rm -rf $basePythonHome/*
fi

# 删除日志
find ${workdir} -name "*.log" -delete
