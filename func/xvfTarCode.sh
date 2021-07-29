#!/bin/bash

packageName=$1
# $(cat ${workdir}/ini/transport.ini | grep "sourceDir" | awk -F = '{print $2}')

shellPackage=$(cat /opt/mytmp/remtoeProject.ini | grep "shellPackage" | awk -F = '{print $2}') 
projectPackage=$(cat /opt/mytmp/remtoeProject.ini | grep "projectPackage" | awk -F = '{print $2}')

function xvfCodePackage(){
  package=$1
  tar zxvf ${package}.tar $(ls | grep "${package}$")
}

echo "xvfTarCode.sh, pwd is: $(pwd)"

if [ $packageName ];then
  xvfCodePackage $packageName
else
  shellPackage=$(cat /opt/mytmp/remtoeProject.ini | grep "shellPackage" | awk -F = '{print $2}')
  projectPackage=$(cat /opt/mytmp/remtoeProject.ini | grep "projectPackage" | awk -F = '{print $2}')
  cd /opt/mytmp
  xvfCodePackage $shellPackage
  xvfCodePackage $projectPackage
fi

