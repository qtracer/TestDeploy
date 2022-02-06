workdir=$1
JOB_NAME=$2

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

cd /opt/locust/$JOB_NAME

docker-compose -f docker-compose-master.yml up
