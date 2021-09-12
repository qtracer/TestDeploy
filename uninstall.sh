#!/bin/bash

# #author GHJ  功能已废置，停止维护

keyword=$(cat ./ini/global.ini | grep "keyword" | awk -F = '{print $2}')
workdir=$(cat ./ini/global.ini | grep "workdir" | awk -F = '{print $2}')

# 查看所有容器
docker ps -a
jenkins_home=$(cat ./ini/store.ini | grep "jenkins_home" | awk -F = '{print $2}')
jenkins_image=$(cat ./ini/store.ini | grep "jenkins_image" | awk -F = '{print $2}')
jenkins_container=$(cat ./ini/store.ini | grep "jenkins_container" | awk -F = '{print $2}')  
python_image=$(cat ./ini/store.ini | grep "python_image" | awk -F = '{print $2}')
python_container=$(cat ./ini/container.ini | awk -F , '{print $1}')
python_home=$(cat ./ini/container.ini | awk -F , '{print $2}')

# 停止并删除容器
docker stop $python_container $jenkins_container
docker rm -f $python_container $jenkins_container

# 删除镜像
docker images

docker rmi -f $python_image $jenkins_image

# 清理文件 
rm -rf $jenkins_home
rm -rf $python_home
sed -i '1,$d' ${workdir}/ini/container.ini
sed -i '1,$d' ${workdir}/ini/global.ini

sed -i 's/true/false/g' ${workdir}/ini/store.ini

# 删除docker环境
yum list installed | grep docker

export statement="请输入需要删除的应用："
bash comm/kwIfEqual.sh $(pwd)
app=$(cat data/tmp.txt)

yum remove ${app} -y

echo "----清理结束！----" 

