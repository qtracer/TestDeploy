# -*- coding:utf-8 -*-
import requests as r
import time
from bs4 import BeautifulSoup
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

projectname = projectname + time.strftime("%Y%m%d%H%M%S", time.localtime())

host = 'http://' + masterHost + ':8089'  # master_ip.group(0)
down_res = r.get(host + "/stats/report?download=1")

with open(reportDir + projectname + ".html", 'wb') as file:
    file.write(down_res.content)
file.close()

'''截取HTML测试报告关键信息'''
def reportElementHandle(wfile):
    # 读取HTML文件
    with open(wfile, 'r', encoding='utf-8') as file:
        html_content = file.read()

    # 使用BeautifulSoup解析HTML
    soup = BeautifulSoup(html_content, 'lxml')

    summ = soup.find(class_='info')
    allspan = summ.find_all('span')
    dic = {}
    dic['starttime']=allspan[0].text
    dic['endtime'] = allspan[1].text
    return dic

'''获取ini/config.ini的邮件配置信息'''
def getConfig(section, key):
    cf.read(cfp, encoding="utf8")
    value = cf.get(section, key)
    return value

'''发送邮件'''
def send_email(subject, dicbody, file=None):
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

    starttime=dicbody['starttime']
    endtime=dicbody['endtime']
    bodytext=f"starttime:GMT{starttime}\nendtime:GMT{endtime}\n详细见附件"
    mail.attach(MIMEText(bodytext, 'plain', 'utf-8'))

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
        # 获取报告内容
        dicbody = reportElementHandle(reportDir + projectname + ".html")
        # 发送邮件
        subject = projectname+"项目性能测试报告"
        send_email(subject, dicbody, reportDir + projectname + ".html")
