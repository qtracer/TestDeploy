#! /bin/bash

workdir=$(find / -type d -name "TestDeploy*" | head -1)
echo "workdir is: $workdir"

# 删除指定目录下所有的文件
while read line
do
  if [ -d "$(echo $line | awk -F , '{print $2}')" ];then
    sudo rm -rf $(echo $line | awk -F , '{print $2}')
  fi
done < ${workdir}/ini/pycontainer.ini

