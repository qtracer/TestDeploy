#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
redis_port=$(cat ${workdir}/ini/config.ini | grep "redis_port" | awk -F = '{print $2}')
redis_container=$(cat ${workdir}/ini/config.ini | grep "redis_container" | awk -F = '{print $2}')
redis_image=$(cat ${workdir}/ini/config.ini | grep "redis_image" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

num=$(docker ps -a | grep $redis_container | wc -l)
if [ $num -ge 1 ];then
  :
else
  export info="$0: run redis image"
  bash ${workdir}/comm/echoInfo.sh $workdir

  docker build -t $redis_image -f ${workdir}/dockerfile/redis-dockerfile . | tee -a ${workdir}/log/${curdate}.log
  docker run -itd --name ${redis_container} -p ${redis_port}:6379 -e TZ='Asia/Shanghai' $redis_image
  docker restart ${redis_container}

fi


