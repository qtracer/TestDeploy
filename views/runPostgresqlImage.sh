#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
# psql_image=$(cat ${workdir}/ini/config.ini | grep "psql_image" | awk -F = '{print $2}')
psql_img=$(cat ${workdir}/ini/config.ini | grep "psql_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
psql_tag=$(cat ${workdir}/ini/config.ini | grep "psql_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
psql_user=$(cat ${workdir}/ini/config.ini | grep "psql_user" | awk -F = '{print $2}')
psql_passsword=$(cat ${workdir}/ini/config.ini | grep "psql_password" | awk -F = '{print $2}')
psql_db=$(cat ${workdir}/ini/config.ini | grep "psql_db" | awk -F = '{print $2}')
psqlVersion=$(cat ${workdir}/ini/config.ini | grep "psqlVersion" | awk -F = '{print $2}')

psql_network=$(cat ${workdir}/ini/config.ini | grep "psql_network" | awk -F = '{print $2}')
psql_port=$(cat ${workdir}/ini/config.ini | grep "psql_port" | awk -F = '{print $2}')
psql_container=$(cat ${workdir}/ini/config.ini | grep "psql_container" | awk -F = '{print $2}')
psql_data=$(cat ${workdir}/ini/config.ini | grep "psql_data" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_psql_img=$(cat ${workdir}/ini/config.ini | grep "registry_postgresql" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_psql_tag=$(cat ${workdir}/ini/config.ini | grep "registry_postgresql" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')


export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

docker network create ${psql_network}

num=$(docker ps -a | grep $psql_container | wc -l)
if [ $num -ge 1 ];then
  docker stop $psql_container
  docker rm -f $psql_container
fi

if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_psql_img" ] || [ -z "$registry_password" ];then
  echo "local"
  docker build \
    -t ${psql_img}:debug-${psql_tag} \
    -f ${workdir}/dockerfile/postgresql-dockerfile \
    --build-arg images=postgres:${psqlVersion} .

  docker run -d \
    --name ${psql_container} \
    -p ${psql_port}:5432 \
    --privileged \
    -e TZ='Asia/Shanghai' \
    -e POSTGRES_USER=${psql_user} \
    -e POSTGRES_PASSWORD=${psql_passsword} \
    -e POSTGRES_DB=${psql_db} \
    --network ${psql_network} \
    -v ${psql_data}:/var/lib/postgresql/data \
    ${psql_img}:debug-${psql_tag}
else
  echo "registry"
  docker images | grep "$registry_psql_img" | grep "debug-$registry_psql_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}
    docker build \
      -t ${registry_psql_img}:debug-${registry_psql_tag} \
      -f ${workdir}/dockerfile/postgresql-dockerfile \
      --build-arg images=${registry_url_download}/${registry_psql_img}:${registry_psql_tag} .
  fi
  
  docker run -d \
    --name ${psql_container} \
    -p ${psql_port}:5432 \
    --privileged \
    -e TZ='Asia/Shanghai' \
    -e POSTGRES_USER=${psql_user} \
    -e POSTGRES_PASSWORD=${psql_passsword} \
    -e POSTGRES_DB=${psql_db} \
    --network ${psql_network} \
    -v ${psql_data}:/var/lib/postgresql/data \
    ${registry_psql_img}:debug-${registry_psql_tag}
fi

sleep 3s
