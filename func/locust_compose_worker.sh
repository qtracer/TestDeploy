workdir=$1
JOB_NAME=$2
workerNum=$3

locust_workspace=$(cat ${workdir}/ini/config.ini | grep "locust_workspace" | awk -F = '{print $2}')

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

bash ${workdir}/func/countCores.sh ${workdir} ${workerNum}

realWorkers=$(cat ${workdir}/data/tmp.txt)

cd ${locust_workspace}/$JOB_NAME

/usr/local/bin/docker-compose -f docker-compose-worker.yml up
