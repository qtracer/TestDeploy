#!/bin/bash
# 分布式性能测试时，打包需要传输到各worker的文件

workdir=$1
openModel=$2
projectPackage=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
tmp=$(cat ${workdir}/ini/config.ini | grep "sourceDir" | awk -F = '{print $2}')
baseLocustHome=$(cat ${workdir}/ini/config.ini | grep "baseLocustHome" | awk -F = '{print $2}')

locust_workspace=$(cat ${workdir}/ini/config.ini | grep "locust_workspace" | awk -F = '{print $2}')

sn=$[ $(cat ${workdir}/ini/locontainer.ini | grep "${baseLocustHome}" | wc -l) + 1 ]
locust_home=${baseLocustHome}/locust${sn}
echo "${locust_home}" >> ${workdir}/ini/locontainer.ini

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

# 牺牲高可用性，支持多并发
find /data -name "${tmp}*.tar" -delete
mkdir -vp /data/${tmp}${sn}

project_path=$(cd `dirname $0`; pwd)
project_path=$(dirname $project_path)
shellPackage="${project_path##*/}"

echo "shellPackage=$shellPackage" > ${workdir}/ini/remoteProject.ini
# echo "package=$tmp" > ${workdir}/ini/remoteProject.ini

if [ "$openModel" = "multiple" ];then
  cp -r ${locust_workspace}/${projectPackage} /data/${tmp}${sn}
  echo "projectPackage=${projectPackage}" >> ${workdir}/ini/remoteProject.ini
fi

dirname0=$(dirname $workdir)
echo "dirname is : $dirname0"

cd $dirname0 && cp -r $shellPackage /data/${tmp}${sn}
cd /data/${tmp}${sn}/$shellPackage/log && find . -name "*.log" -delete

# 将shellPackage和projectPackage打包进$tmp目录下，并在另一台主机上用xvf解压。
cd /data
bash ${workdir}/func/cvfTarCode.sh ${tmp}${sn} ${tmp}${sn}
rm -rf /data/${tmp}${sn}

export info="$0: list files of /data/${tmp}${sn} after copyFilesToTmp"
bash ${workdir}/comm/echoInfo.sh $workdir
