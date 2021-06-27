#!/bin/bash

workdir=$1
JOB_NAME=$2
tag=$3

bash ${workdir}/func/ifContainerExist.sh ${workdir} ${JOB_NAME} $tag  # 判断代码是否同一个项目同一个版本
bash ${workdir}/views/runPythonImage.sh ${workdir} ${JOB_NAME} $tag # run Python镜像
bash ${workdir}/views/packCode.sh ${workdir} ${JOB_NAME} $tag  # 打包代码
bash ${workdir}/views/executeAPIAuto.sh ${workdir} ${JOB_NAME} # 执行接口自动化
