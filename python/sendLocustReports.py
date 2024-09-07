# -*- coding:utf-8 -*-
import requests as r
import time
import re
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import os, sys, configparser

sys.path[0] = os.path.dirname(os.path.abspath(__file__))
cf = configparser.ConfigParser()
cfp = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))+"/ini/config.ini"

projectname = sys.argv[1]
reportDir = sys.argv[2]
masterHost = sys.argv[3]

'''
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

os.popen('sudo mkdir -vp ' + reportDir)
'''

projectname = projectname + time.strftime("%Y%m%d%H%M%S", time.localtime())

host = 'http://' + masterHost + ':8089'  # master_ip.group(0)
down_res = r.get(host + "/stats/report?download=1")

with open(reportDir + projectname + ".html", 'wb') as file:
    file.write(down_res.content)
file.close()

'''获取ini/config.ini的邮件配置信息'''
def getConfig(section, key):
    cf.read(cfp, encoding="utf8")
    value = cf.get(section, key)
    return value

'''发送邮件'''
def send_email(subject, file=None):
    # 从配置获取EMAIL信息
    receiver = getConfig('email', 'receiver').split(',')
    sender = getConfig('email', 'sender')
    sender_password = getConfig('email', 'sender_password')
    smtp_server = getConfig('email', 'smtp_server')
    smtp_port = int(getConfig('email', 'smtp_port'))

    # 创建 MIMEMultipart 对象
    # 邮件三个头部信息
    mail = MIMEMultipart()
    mail['Subject'] = subject
    mail['From'] = sender
    mail['To'] = ",".join(receiver)

    mail.attach(MIMEText("详细见附件", 'plain', 'utf-8'))

    # 附件
    att1 = MIMEText(open(file, 'rb').read(), 'html', 'utf-8')
    att1["Content-Type"] = 'application/octet-stream'
    # filename即邮件中附件显示的名字
    att1["Content-Disposition"] = "attachment; filename='"+projectname+".html' "
    mail.attach(att1)

    # 连接邮箱并发送邮件
    try:
        smtp = smtplib.SMTP_SSL(smtp_server)
        smtp.connect(host=smtp_server, port=smtp_port)
        smtp.login(sender, sender_password)
        smtp.sendmail(sender, receiver, mail.as_string())
        smtp.quit()
        print("Sending report completed ")
    except smtplib.SMTPException:
        print("Error:无法发送邮件")

if __name__ == '__main__':
    if getConfig('email', 'sender'):
        # 发送邮件
        subject = projectname+"项目性能测试报告"
        send_email(subject, reportDir + projectname + ".html")
