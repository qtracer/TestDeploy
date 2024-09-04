#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
redis_port=$(cat ${workdir}/ini/config.ini | grep "redis_port" | awk -F = '{print $2}')
redis_container=$(cat ${workdir}/ini/config.ini | grep "redis_container" | awk -F = '{print $2}')
redis_img=$(cat ${workdir}/ini/config.ini | grep "redis_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
redis_tag=$(cat ${workdir}/ini/config.ini | grep "redis_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
rVersion=$(cat ${workdir}/ini/config.ini | grep "redisVersion" | awk -F = '{print $2}')
redis_data=$(cat ${workdir}/ini/config.ini | grep "redis_data" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_redis_img=$(cat ${workdir}/ini/config.ini | grep "registry_redis" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_redis_tag=$(cat ${workdir}/ini/config.ini | grep "registry_redis" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

num=$(docker ps -a | grep $redis_container | wc -l)
if [ $num -ge 1 ];then
  docker stop $redis_container
  docker rm -f $redis_container
fi

export info="$0: run redis image"
bash ${workdir}/comm/echoInfo.sh $workdir

if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_redis_img" ] || [ -z "$registry_password" ];then
  # 任一为空，则公网拉镜像
  echo "local"
  docker build -t ${redis_img}:debug-${redis_tag} \
    -f ${workdir}/dockerfile/redis-dockerfile \
    --build-arg images=redis:${rVersion} .

  docker run -d --name ${redis_container} \
    -p ${redis_port}:6379 -e TZ='Asia/Shanghai' \
    ${redis_img}:debug-${redis_tag}
else
  # 不为空先判断本地是否存在，不存在再拉私库
  echo "registry"
  docker images | grep "$registry_redis_img" | grep "debug-$registry_redis_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}

    docker build -t ${registry_redis_img}:debug-${registry_redis_tag} \
      -f ${workdir}/dockerfile/redis-dockerfile \
      --build-arg images=${registry_url_download}/${registry_redis_img}:${registry_redis_tag} .
  fi

  docker run -d --name ${redis_container} \
    -p ${redis_port}:6379 -e TZ='Asia/Shanghai' \
    ${registry_redis_img}:debug-${registry_redis_tag}
fi


