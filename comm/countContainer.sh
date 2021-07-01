#!/bin/bash

workdir=$1

cat ${workdir}/ini/store.ini | grep "port" | wc -l > ${workdir}/data/tmp.txt
