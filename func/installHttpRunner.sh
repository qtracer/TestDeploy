#!/bin/bash

workdir=$1
hrunVersion=$(cat ${workdir}/ini/appVersion.ini | grep "hrunVersion" | awk -F = '{print $2}')

jenkins_home=$(tail -3 ${workdir}/ini/store.ini | grep "jenkins_home" | awk -F , '{print $2}')
container_name=$(tail -3 ${workdir}/ini/store.ini | grep "container_name" | awk -F , '{print $2}')
curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 安装HttpRunner
pip3 install httprunner==${hrunVersion}

rm -rf /usr/bin/hrun
ln -s ${jenkins_home}/python3/bin/hrun /usr/bin/hrun

# 检查HttpRunner是否安装成功
export info="$0: 主机hrun命令是否可运行"
bash ${workdir}/comm/echoInfo.sh $workdir $curdate
echo "$0: 检验主机hrun命令是否运行成功：$(hrun -V)" >> ${workdir}/log/${curdate}.log

export info="容器内hrun命令是否可运行"
bash ${workdir}/comm/echoInfo.sh $workdir $curdate

docker exec ${container_name} sh -c "ln -s ${jenkins_home}/python3/bin/hrun /usr/bin/hrun && hrun -V" >> ${workdir}/log/${curdate}.log
