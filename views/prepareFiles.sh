#!/bin/bash

workdir=$1
openModel=$2
projectPackage=$3
workerNum=$4

bash ${workdir}/func/hostRecord.sh $workdir &\
bash ${workdir}/func/installExpect.sh $workdir &\
bash ${workdir}/func/coresRecord.sh $workdir

bash ${workdir}/func/checkNetWork.sh $workdir $workerNum
bash ${workdir}/views/copyFilesToTmp.sh $workdir $openModel ${projectPackage}
bash ${workdir}/func/transportFilesAndInitWorker.sh $workdir $projectPackage
