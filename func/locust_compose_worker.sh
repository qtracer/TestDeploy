workdir=$1
JOB_NAME=$2
workerNum=$3

bash ${workdir}/func/countCores.sh ${workdir} ${workerNum}

realWorkers=$(cat ${workdir}/data/tmp.txt)

cd /opt/locust/$JOB_NAME

docker-compose -f docker-compose-worker.yml up
