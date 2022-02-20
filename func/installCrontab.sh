#!/bin/bash

yum install crontabs -y

/bin/systemctl restart crond.service

chkconfig -level 35 crond on
