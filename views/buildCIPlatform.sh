#!/bin/bash

workdir=$1

bash ${workdir}/views/installDocker.sh ${workdir} # 宿主机安装Docker环境
bash ${workdir}/func/installGit.sh ${workdir}  # 宿主机安装Git环境
bash ${workdir}/views/buildJenkinsImage.sh ${workdir}  # build Jenkins镜像
bash ${workdir}/views/runJenkinsImage.sh ${workdir}  # run Jenkins镜像
bash ${workdir}/func/changeMirrors.sh ${workdir}  # 更换镜像源
bash ${workdir}/func/installJDK.sh    # 给宿主机装JDK环境，ln -s
bash ${workdir}/views/buildPythonImage.sh ${workdir}   # build Python镜像
sed -i 's/false/true/g' ${workdir}/ini/store.ini            # 替换标记
sed -i '/github/d' /etc/hosts
