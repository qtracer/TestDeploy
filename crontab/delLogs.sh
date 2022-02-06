#!/bin/bash

echo "del logs start..."

workdir=$(find / -type d -name "TestDeploy*" | head -1)

echo "$workdir"

find ${workdir}/log -mtime +7 -name "*.log" -delete

echo "del logs end..."
