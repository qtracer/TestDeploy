#!/bin/bash

docker rmi $(docker images -qf dangling=true)

