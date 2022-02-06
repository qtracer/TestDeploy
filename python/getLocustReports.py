# -*- coding:utf-8 -*-

import requests as r
import time
import os
import re
import sys
sys.path[0] = os.path.dirname(__file__)
print(sys.path[0])

# get 内网ip
re_ipaddr = re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b")
ipstring = os.popen('ip addr | grep -e "eth0" -e "ens33" | grep "inet"')
net_stat = ipstring.read()
master_ip = re_ipaddr.search(net_stat)
print(master_ip)

# get 公网ip
open_re_ipaddr = re.compile(r"\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
open_ipstring = os.popen('curl cip.cc | grep "URL"')
open_net_stat = open_ipstring.read()
open_master_ip = open_re_ipaddr.search(open_net_stat)
print(open_master_ip)

# 重设连接数
r.DEFAULT_RETRIES = 5
s = r.session()
s.keep_alive = False

os.popen('mkdir -vp /opt/reports/locusts')
name = time.strftime("%Y%m%d%H%M%S", time.localtime())

try:
    host = 'http://' + master_ip.group(0) + ':8089'  # master_ip.group(0)
    down_res = r.get(host + "/stats/report?download=1")
    with open('/opt/reports/locusts/' + name + ".html", 'wb') as file:
        file.write(down_res.content)
    file.close()
except BaseException as e:
    host = 'http://' + open_master_ip.group(0) + ':8089'  # master_ip.group(0)
    down_res = r.get(host + "/stats/report?download=1")
    with open('/opt/reports/locusts/' + name + ".html", 'wb') as file:
        file.write(down_res.content)
    file.close()
