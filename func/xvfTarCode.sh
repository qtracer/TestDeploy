#!/bin/bash
# 解压文件

workdir=$1
packageName=$2

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

function xvfCodePackage(){
  package=$1
  tar zxvf ${package}.tar $(ls | grep "${package}$") > /dev/null
}

echo "xvfTarCode.sh, pwd is: $(pwd)"

if [ $packageName ];then
  xvfCodePackage $packageName
else
  sourceDir=$(cat ${workdir}/ini/config.ini | grep "sourceDir" | awk -F = '{print $2}')
  targetDir=$(cat ${workdir}/ini/config.ini | grep "targetDir" | awk -F = '{print $2}')

  shellPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')
  projectPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')

  shellPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')
  projectPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')
  cd /opt/mytmp
  xvfCodePackage $shellPackage
  xvfCodePackage $projectPackage
fi

