#!/bin/bash

workdir=$1
packageName=$2

function xvfCodePackage(){
  package=$1
  tar zxvf ${package}.tar $(ls | grep "${package}$")
}

echo "xvfTarCode.sh, pwd is: $(pwd)"

if [ $packageName ];then
  xvfCodePackage $packageName
else
  sourceDir=$(cat ${workdir}/ini/store.ini | grep "sourceDir" | awk -F = '{print $2}')
  targetDir=$(cat ${workdir}/ini/store.ini | grep "targetDir" | awk -F = '{print $2}')

  shellPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')
  projectPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')

  shellPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "shellPackage" | awk -F = '{print $2}')
  projectPackage=$(cat ${targetDir}/${sourceDir}/remoteProject.ini | grep "projectPackage" | awk -F = '{print $2}')
  cd /opt/mytmp
  xvfCodePackage $shellPackage
  xvfCodePackage $projectPackage
fi

