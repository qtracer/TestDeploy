#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3
python_container=$(tail -1 ${workdir}/ini/container.ini | awk -F , '{print $1}')
python_home=$(tail -1 ${workdir}/ini/container.ini | awk -F , '{print $2}')

# 将打包shell脚本copy一份到Jenkins工作路径，并打包到python容器
echo "this is packCode.sh,whereis pwd：$(pwd)"
echo 2s
packageName=${JOB_NAME}${tag}
cp ${workdir}/func/cvfTarCode.sh $(dirname $(pwd))/cvfTarCode.sh
cd $(dirname $(pwd)) && chmod +x cvfTarCode.sh && ./cvfTarCode.sh ${packageName} ${JOB_NAME}

docker cp ${packageName}.tar ${python_container}:${python_home}
docker cp ${workdir}/func/xvfTarCode.sh ${python_container}:${python_home}
docker exec ${python_container} sh -c "cd ${python_home} && chmod +x xvfTarCode.sh && ./xvfTarCode.sh ${packageName}"

rm -f ${packageName}.tar cvfTarCode.sh
