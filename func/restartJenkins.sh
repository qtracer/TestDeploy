#!/bin/bash

service network restart
service docker restart
docker restart myjenkins
