#! /bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')
masterip=$(cat ${workdir}/ini/hosts.ini | grep "master" | head -1 | awk -F , '{print $1}')
hrunReportBaseHome=$(cat ${workdir}/ini/config.ini | grep "hrunReportBaseHome" |  awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

sed -i 's/'"0"'$/'"1"'/g' ${workdir}/ini/pycontainer.ini
year=$(date +%Y)
mday=$(date +%m%d)

mkdir -vp ${hrunReportBaseHome}/$JOB_NAME/$year/$mday
mkdir -vp ${hrunReportBaseHome}/tmp

# 获取新生成的报告
path=$(cat ${workdir}/ini/pycontainer.ini | grep "${JOB_NAME}" | tail -1 | awk -F , '{print $2}')/${JOB_NAME}/reports
file=$(cd $path && ls -l | tail -1 | awk -F " {1,3}" '{print $9}')
cp -f $path/$file ${hrunReportBaseHome}/$JOB_NAME/$year/$mday

# 处理Hrun报告
which python3 &> /dev/null
if [ $? -eq 0 ];then
  pip3 install beautifulsoup4 lxml
  python3 ${workdir}/python/sendHrunReport.py ${JOB_NAME}_${tag} $path/$file
else
  pip install beautifulsoup4 lxml
  python ${workdir}/python/sendHrunReport.py ${JOB_NAME}_${tag} $path/$file
fi

:<<!
# 如果是slave节点，则需要将report传master
if [ "$localhost" != "$masterip" ] && [ $masterip ];then
  # 将新增reports存放到目录tmp
  cp -rf $file ${hrunReportBaseHome}/tmp

  current=`date "+%Y-%m-%d %H:%M:%S"`
  timeStamp=`date -d "$current" +%s`
  #将current转换为时间戳，精确到毫秒
  currentTimeStamp=`expr $(date '+%s') \* 1000 + $(date '+%N') / 1000000`

  cd ${hrunReportBaseHome}/tmp
  tar cvf reports${currentTimeStamp}.tar ./*

  account=$(cat ${workdir}/ini/hosts.ini | grep "master" | head -1 | awk -F , '{print $2}')
  password=$(cat ${workdir}/ini/hosts.ini | grep "master" | head -1 | awk -F , '{print $3}')

  # 传送到master,先远程创建项目报告存放目录，然后传输报告压缩包，最后解压
  expect -c "
  set timeout -1
  spawn /usr/bin/scp ${hrunReportBaseHome}/tmp/reports${currentTimeStamp}.tar ${account}@${masterip}:${hrunReportBaseHome}/$JOB_NAME
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*password*\" {send \"${password}\r\";}
  }

  spawn /usr/bin/ssh ${account}@${masterip}
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*assword*\" {send \"${password}\r\";}
  }
  expect \"]*\" {send \"sudo mkdir -vp ${hrunReportBaseHome}/$JOB_NAME/$year/$mday\n\"}
  expect \"]*\" {send \"cd ${hrunReportBaseHome}/$JOB_NAME/$year/$mday\n\"}
  expect \"]*\" {send \"sudo tar xvf reports${currentTimeStamp}.tar\n\"}
  expect \"]*\" {send \"sudo rm -f reports${currentTimeStamp}.tar\n\"}
  expect eof;"

  # 删除slave缓存区的内容，逐个删除，避免影响期间其他项目生成的报告
  cd ${hrunReportBaseHome}/tmp
  for((i=0;i<${#fileList[*]};i++))
  do
    rm -f ${fileList[i]}
  done
  rm -f reports${currentTimeStamp}.tar
fi
!
