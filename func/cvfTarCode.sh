#!/bin/bash

packageName=$1
JOB_NAME=$2


tar -zcvf ${packageName}.tar $(ls | grep "${JOB_NAME}$")
