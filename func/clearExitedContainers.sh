#!/bin/bash

docker rm $(docker ps -qf status=exited)
