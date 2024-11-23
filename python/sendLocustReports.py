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

'''获取ini/config.ini的邮件配置信息'''
def getConfig(section, key):
    cf.read(cfp, encoding="utf8")
    value = cf.get(section, key)
    return value


'''截取HTML测试报告关键信息'''
def reportElementHandle(wfile):
    # 读取HTML文件
    with open(wfile, 'r', encoding='utf-8') as file:
        html_content = file.read()

    # 使用BeautifulSoup解析HTML
    soup = BeautifulSoup(html_content, 'lxml')
    dic = {}
    timeoutAPI90 = 0
    timeoutAPI95 = 0
    failAPI = 0

    # 读取config.ini API超时设置
    api_90timeout = int(getConfig('apitimeout', 'api_90timeout'))
    api_95timeout = int(getConfig('apitimeout', 'api_95timeout'))

    ## HTML-info
    summ = soup.find(class_='info')
    allspan = summ.find_all('span')
    dic['starttime']=allspan[0].text
    dic['endtime'] = allspan[1].text
    dic['host'] = allspan[2].text

    ## HTML-requests
    rq = soup.find(class_='requests')
    alltd = rq.find_all('td')
    dic['total RPS'] = alltd[-2].text
    dic['Failures/s'] = alltd[-1].text

    alltr = rq.find('tbody').find_all('tr')
    dic['API Amount'] = len(alltr) - 1
    for tr in alltr:
        alltd = tr.find_all('td')
        if int(alltd[3].text) > 0:
            failAPI += 1
    # 去掉聚合td的统计
    if failAPI > 0:
        failAPI -= 1
    dic['failAPIs'] = failAPI

    ## HTML-responses
    rs = soup.find(class_='responses')
    alltr = rs.find('tbody').find_all('tr')
    for tr in alltr:
        alltd = tr.find_all('td')
        if int(alltd[6].text) > api_90timeout:
            timeoutAPI90 += 1
        if int(alltd[7].text) > api_95timeout:
            timeoutAPI95 += 1
    dic['90timeoutAPIs'] = timeoutAPI90
    dic['95timeoutAPIs'] = timeoutAPI95

    return dic


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
    mail = MIMEMultipart('alternative')
    mail['Subject'] = subject
    mail['From'] = sender
    mail['To'] = ",".join(receiver)

    # HTML内容
    if float(dicbody['Failures/s']) > 0:
        color_Failures = "red"
    else:
        color_Failures = "green"

    if dicbody['failAPIs'] > 0:
        color_failAPIs = "red"
    else:
        color_failAPIs = "green"

    if dicbody['90timeoutAPIs'] > 0:
        color_90timeoutAPIs = "red"
    else:
        color_90timeoutAPIs = "green"

    if dicbody['95timeoutAPIs'] > 0:
        color_95timeoutAPIs = "red"
    else:
        color_95timeoutAPIs = "green"

    html_content = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Email Example</title>
        </head>
        <body>
            <table id="summary", style="width: 100%; margin:auto">
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">Host</th>
                  <td colspan="4",style="font-size: 15px;">{dicbody['host']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">StartTime</th>
                  <td colspan="4",style="font-size: 15px;">{dicbody['starttime']}+00:00</td>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">EndTime</th>
                  <td colspan="4",style="font-size: 15px;">{dicbody['endtime']}+00:00</td>
                </tr>
                <tr>
                  <th style="font-weight: bold; color: orange;font-size: 17px;">RPS</th>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">Totals</th>
                  <td colspan="4",style="font-weight: bold; font-size: 17px; color: green;">{dicbody['total RPS']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">Failures</th>
                  <td colspan="4",style="font-weight: bold; font-size: 17px; color: {color_Failures};">{dicbody['Failures/s']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold; color: orange;font-size: 17px;">APIs</th>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">Totals</th>
                  <td colspan="4",style="font-size: 15px;">{dicbody['API Amount']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">Failures</th>
                  <td colspan="4",style="font-size: 15px; font-weight: bold; color: {color_failAPIs};">{dicbody['failAPIs']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold; font-size: 15px;">90%Tout</th>
                  <td colspan="4",style="font-size: 15px; font-weight: bold; color: {color_90timeoutAPIs};">{dicbody['90timeoutAPIs']}</td>
                </tr>
                <tr>
                  <th style="font-weight: bold;font-size: 15px;">95%Tout</th>
                  <td colspan="4",style="font-size: 15px; font-weight: bold; color: {color_95timeoutAPIs};">{dicbody['95timeoutAPIs']}</td>
                </tr>
            </table>
        </body>
        </html>
        """
    mail.attach(MIMEText(html_content, 'html'))

    # # 纯文本
    # bodytext = f"failAPIs:\n {dicbody['failAPIs']}\n timeoutAPIs:\n {dicbody['timeoutAPIs']}"
    # mail.attach(MIMEText(bodytext, 'plain', 'utf-8'))

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
