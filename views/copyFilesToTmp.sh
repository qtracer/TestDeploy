#!/bin/bash

workdir=$1
openModel=$2
projectPackage=$3

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
tmp=$(cat ${workdir}/ini/store.ini | grep "sourceDir" | awk -F = '{print $2}')

if [ ! -d "/data/$tmp" ]; then
  cd / && mkdir -vp /data/$tmp
else
  rm -rf /data/$tmp
  mkdir -vp /data/$tmp
fi


project_path=$(cd `dirname $0`; pwd)
project_path=$(dirname $project_path)
shellPackage="${project_path##*/}"

echo "shellPackage=$shellPackage" > ${workdir}/ini/remoteProject.ini
# echo "package=$tmp" > ${workdir}/ini/remoteProject.ini

if [ "$openModel" = "multiple" ];then
  # 基于locust_packCode.sh
  # cd /opt/locust
  # rm -rf ${projectPackage}.tar 
  # bash ${workdir}/func/cvfTarCode.sh $projectPackage $projectPackage
  # echo "tar JOB_NAME"
  # cp /opt/locust/${projectPackage}.tar /$tmp
  cp -r /opt/locust/${projectPackage} /data/$tmp
  echo "projectPackage=${projectPackage}" >> ${workdir}/ini/remoteProject.ini
fi

# cp ${workdir}/func/xvfTarCode.sh /$tmp
# cp ${workdir}/ini/remoteProject.ini /$tmp

dirname0=$(dirname $workdir)
echo "dirname is : $dirname0"
# cd $dirname0 && bash ${workdir}/func/cvfTarCode.sh $shellPackage $shellPackage && mv ${shellPackage}.tar /${tmp}
cd $dirname0 && cp -r $shellPackage /data/${tmp}
cd /data/${tmp}/$shellPackage/log && find . -name "*.log" -delete

# 将shellPackage和projectPackage打包进$tmp目录下，并在另一台主机上用xvf解压。
cd /data
bash ${workdir}/func/cvfTarCode.sh $tmp $tmp

export info="$0: list files of /data/${tmp} after copyFilesToTmp"
bash ${workdir}/comm/echoInfo.sh $workdir
ls -al /data/${tmp} | tee -a /${workdir}/log/${curdate}.log



