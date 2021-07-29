#!/bin/bash

# workdir=$(find /opt -type d -name "TestDeploy*" | head -1)
remaincores=$1

totalCores=$[ $(cat /proc/cpuinfo | grep "cpu cores" | wc -l) - $remaincores ]

echo "$totalCores"
exit $totalCores

