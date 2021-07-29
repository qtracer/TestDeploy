#!/bin/bash

workdir=$1

# 初始化配置
sed -i '1,$d' ${workdir}/ini/container.ini
sed -i '1,$d' ${workdir}/ini/global.ini
sed -i 's/true/false/g' ${workdir}/ini/store.ini
sed -i '1,$d' ${workdir}/ini/cores.ini
sed -i '1,$d' ${workdir}/ini/hosts.ini
sed -i '1,$d' ${workdir}/ini/remoteProject.ini
sed -i '1,$d' ${workdir}/data/usableNetWork.txt


# 删除日志
find ${workdir} -name "*.log" -delete
