#!/bin/bash

workdir=$1

curdate=$(cat ${workdir}/ini/global.ini | grep "curdate" | awk -F = '{print $2}')
psql_image=$(cat ${workdir}/ini/config.ini | grep "psql_image" | awk -F = '{print $2}')
psql_user=$(cat ${workdir}/ini/config.ini | grep "psql_user" | awk -F = '{print $2}')
psql_passsword=$(cat ${workdir}/ini/config.ini | grep "psql_password" | awk -F = '{print $2}')
psql_db=$(cat ${workdir}/ini/config.ini | grep "psql_db" | awk -F = '{print $2}')
psqlVersion=$(cat ${workdir}/ini/config.ini | grep "psqlVersion" | awk -F = '{print $2}')

psql_network=$(cat ${workdir}/ini/config.ini | grep "psql_network" | awk -F = '{print $2}')
psql_port=$(cat ${workdir}/ini/config.ini | grep "psql_port" | awk -F = '{print $2}')
psql_container=$(cat ${workdir}/ini/config.ini | grep "psql_container" | awk -F = '{print $2}')
psql_data=$(cat ${workdir}/ini/config.ini | grep "psql_data" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

docker network create ${psql_network}

export info="$0: build postgresql image"
bash ${workdir}/comm/echoInfo.sh $workdir


docker build -t ${psql_image}  -f ${workdir}/dockerfile/postgresql-dockerfile  \
  --build-arg psqlVersion=${psqlVersion} . | tee -a ${workdir}/log/${curdate}.log

num=$(docker ps -a | grep $psql_container | wc -l)
if [ $num -ge 1 ];then
  :
else
  export info="$0: run postgresql image"
  bash ${workdir}/comm/echoInfo.sh $workdir

  docker run -d --name ${psql_container} -p ${psql_port}:5432 --privileged \
    -e TZ='Asia/Shanghai' \
    -e POSTGRES_USER=${psql_user} \
    -e POSTGRES_PASSWORD=${psql_passsword} \
    -e POSTGRES_DB=${psql_db} \
    --network ${psql_network} \
    -v ${psql_data}:/var/lib/postgresql/data \
    $psql_image

  docker restart ${psql_container}
  sleep 3s
fi

