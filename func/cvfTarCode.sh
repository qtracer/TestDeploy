#!/bin/bash

packageName=$1
JOB_NAME=$2


echo $0
tar zcvf ${packageName}.tar $(ls | grep "${JOB_NAME}$") > /dev/null

project_path=$(cd `dirname $0`; pwd)
project_name="${project_path##*/}"
echo $project_name
