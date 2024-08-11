#!/bin/bash
docker rm -f $(docker ps -qf status=exited)
