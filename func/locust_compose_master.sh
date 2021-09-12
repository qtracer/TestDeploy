workdir=$1
JOB_NAME=$2


cd /opt/locust/$JOB_NAME

docker-compose -f docker-compose-master.yml up
