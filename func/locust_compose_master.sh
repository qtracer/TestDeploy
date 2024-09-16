workdir=$1
JOB_NAME=$2

locust_workspace=$(cat ${workdir}/ini/config.ini | grep "locust_workspace" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

cd ${locust_workspace}/$JOB_NAME

/usr/local/bin/docker-compose -f docker-compose-master.yml up
