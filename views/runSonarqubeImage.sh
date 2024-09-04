#!/bin/bash

workdir=$1

localhost=$(ip addr | grep -e "eth0" -e "ens33" | grep "inet" | awk -F " " '{print $2}' | awk -F / '{print $1}')

# sonar_image=$(cat ${workdir}/ini/config.ini | grep "sonar_image" | awk -F = '{print $2}')
sonar_img=$(cat ${workdir}/ini/config.ini | grep "sonar_image" | awk -F = '{print $2}' | awk -F : '{print $1}')
sonar_tag=$(cat ${workdir}/ini/config.ini | grep "sonar_image" | awk -F = '{print $2}' | awk -F : '{print $2}')
sonarVersion=$(cat ${workdir}/ini/config.ini | grep "sonarVersion" | awk -F = '{print $2}')

psql_user=$(cat ${workdir}/ini/config.ini | grep "psql_user" | awk -F = '{print $2}')
psql_passsword=$(cat ${workdir}/ini/config.ini | grep "psql_password" | awk -F = '{print $2}')
psql_db=$(cat ${workdir}/ini/config.ini | grep "psql_db" | awk -F = '{print $2}')
psql_port=$(cat ${workdir}/ini/config.ini | grep "psql_port" | awk -F = '{print $2}')
psql_network=$(cat ${workdir}/ini/config.ini | grep "psql_network" | awk -F = '{print $2}')
sonar_container=$(cat ${workdir}/ini/config.ini | grep "sonar_container" | awk -F = '{print $2}')
sonar_javaOpts=$(cat ${workdir}/ini/config.ini | grep "sonar_javaOpts" | awk -F = '{print $2}')
sonar_memory=$(cat ${workdir}/ini/config.ini | grep "sonar_memory" | awk -F = '{print $2}')
sonar_port=$(cat ${workdir}/ini/config.ini | grep "sonar_port" | awk -F = '{print $2}')
sonar_data=$(cat ${workdir}/ini/config.ini | grep "sonar_data" | awk -F = '{print $2}')
sonar_logs=$(cat ${workdir}/ini/config.ini | grep "sonar_logs" | awk -F = '{print $2}')
sonar_ext=$(cat ${workdir}/ini/config.ini | grep "sonar_ext" | awk -F = '{print $2}')
sonar_conf=$(cat ${workdir}/ini/config.ini | grep "sonar_conf" | awk -F = '{print $2}')

registry_url_login=$(cat ${workdir}/ini/config.ini | grep "registry_url_login" | awk -F = '{print $2}')
registry_url_download=$(cat ${workdir}/ini/config.ini | grep "registry_url_download" | awk -F = '{print $2}')
registry_sonar_img=$(cat ${workdir}/ini/config.ini | grep "registry_sonarqube" | awk -F = '{print $2}' | awk -F : '{print $1}')
registry_sonar_tag=$(cat ${workdir}/ini/config.ini | grep "registry_sonarqube" | awk -F = '{print $2}' | awk -F : '{print $2}')
registry_user=$(cat ${workdir}/ini/config.ini | grep "registry_user" | awk -F = '{print $2}')
registry_password=$(cat ${workdir}/ini/config.ini | grep "registry_password" | awk -F = '{print $2}')


export info="$0: build sonarqube image"
bash ${workdir}/comm/echoInfo.sh $workdir

mkdir -vp $sonar_data
mkdir -vp $sonar_logs
mkdir -vp $sonar_ext
mkdir -vp $sonar_conf
chmod -R 777 $sonar_data
chmod -R 777 $sonar_logs
chmod -R 777 $sonar_ext
chmod -R 777 $sonar_conf

num=$(docker ps -a | grep $sonar_container | wc -l)
if [ $num -ge 1 ];then
  docker stop $sonar_container
  docker rm -f $sonar_container
fi

if [ -z "$registry_url_login" ] || [ -z "$registry_url_download" ] || [ -z "$registry_sonar_img" ] || [ -z "$registry_password" ];then
  echo "local"
  docker build \
    -t ${sonar_img}:debug-${sonar_tag} \
    -f ${workdir}/dockerfile/sonarqube-dockerfile \
    --build-arg images=sonarqube:${sonarVersion} .

  docker run -d --name ${sonar_container} -p ${sonar_port}:9000 --privileged \
    -e TZ='Asia/Shanghai' \
    --network $psql_network \
    -e SONAR_JDBC_URL=jdbc:postgresql://${localhost}:${psql_port}/${psql_db} \
    -e SONAR_JDBC_USERNAME=${psql_user} \
    -e SONAR_JDBC_PASSWORD=${psql_passsword} \
    -e SONARQUBE_JAVA_OPTS=${sonar_javaOpts} \
    --memory=${sonar_memory} \
    -v ${sonar_data}:/opt/sonarqube/data \
    -v ${sonar_logs}:/opt/sonarqube/logs \
    -v ${sonar_ext}:/opt/sonarqube/extensions \
    -v ${sonar_conf}:/opt/sonarqube/conf \
    ${sonar_img}:debug-${sonar_tag}
else
  echo "registry"
  docker images | grep "$registry_sonar_img" | grep "debug-$registry_sonar_tag" &> /dev/null
  if [ $? -ne 0 ];then
    docker login -u ${registry_user} -p ${registry_password} ${registry_url_login}
    
    docker build \
    -t ${registry_sonar_img}:debug-${registry_sonar_tag} \
    -f ${workdir}/dockerfile/sonarqube-dockerfile \
    --build-arg images=${registry_url_download}/${registry_sonar_img}:${registry_sonar_tag} .
  fi
  
  docker run -d --name ${sonar_container} -p ${sonar_port}:9000 --privileged \
    -e TZ='Asia/Shanghai' \
    --network $psql_network \
    -e SONAR_JDBC_URL=jdbc:postgresql://${localhost}:${psql_port}/${psql_db} \
    -e SONAR_JDBC_USERNAME=${psql_user} \
    -e SONAR_JDBC_PASSWORD=${psql_passsword} \
    -e SONARQUBE_JAVA_OPTS=${sonar_javaOpts} \
    --memory=${sonar_memory} \
    -v ${sonar_data}:/opt/sonarqube/data \
    -v ${sonar_logs}:/opt/sonarqube/logs \
    -v ${sonar_ext}:/opt/sonarqube/extensions \
    -v ${sonar_conf}:/opt/sonarqube/conf \
    ${registry_sonar_img}:debug-${registry_sonar_tag}
fi

