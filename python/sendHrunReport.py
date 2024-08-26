# -*- coding:utf-8 -*-
from bs4 import BeautifulSoup
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import os, sys, configparser

sys.path[0] = os.path.dirname(os.path.abspath(__file__))
cf = configparser.ConfigParser()
cfp = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))+"/ini/config.ini"

# bash脚本的传参
projectname = sys.argv[1]
print("projectname is:",projectname)
file = sys.argv[2]
#projectname="TestDeploy"
#file = sys.path[0]+"/20240811T135729.226559.html"

'''截取HTML测试报告关键信息'''
def reportElementHandle(wfile):
    # 读取HTML文件
    with open(wfile, 'r', encoding='utf-8') as file:
        html_content = file.read()

    # 使用BeautifulSoup解析HTML
    soup = BeautifulSoup(html_content, 'lxml')

    summ = soup.find(id='summary')
    alltd=summ.find_all('td')
    dic = {}
    # time
    startat=alltd[0].text
    duration=alltd[1].text
    dic['startat']=startat
    dic['duration']=duration

    ## testcases
    testcases=alltd[-2].text
    dic['testcases-sum'] = testcases.split()[0]
    # success
    detailtestcases=testcases.split()[1]
    successtestcases=detailtestcases.split('/')[0]
    successtestcases=successtestcases.split('(')[1]
    dic['testcases-success']=successtestcases
    # fail
    failtestcases=detailtestcases.split('/')[1]
    failtestcases=failtestcases.split(')')[0]
    dic['testcases-fail'] = failtestcases

    ## teststeps
    teststeps=alltd[-1].text
    dic['teststeps-sum']=teststeps.split()[0]
    # success
    detailteststeps=teststeps.split()[1]
    successteststeps=detailteststeps.split('/')[0]
    successteststeps=successteststeps.split('(')[1]
    dic['teststeps-success']=successteststeps
    # fail
    failteststeps=detailteststeps.split('/')[1]
    dic['teststeps-fail'] = failteststeps
    # error
    errorteststeps=detailteststeps.split('/')[2]
    dic['teststeps-error'] = errorteststeps
    # skip
    skipteststeps=detailteststeps.split('/')[3]
    skipteststeps=skipteststeps.split(')')[0]
    dic['teststeps-skip'] = skipteststeps

    return dic


'''获取ini/config.ini的邮件配置信息'''
def getConfig(section, key):
    cf.read(cfp, encoding="utf8")
    value = cf.get(section, key)
    return value


'''发送邮件'''
def send_email(subject, dicbody, file=None):
    # 从配置获取EMAIL信息
    receiver = getConfig('email', 'receiver')
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

    if int(dicbody['testcases-fail']) > 0:
        result = "不通过"
    else:
        result = "通过"
    # 邮件正文 创建HTML对象，填充数据
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
              <th>Project</th>
              <td colspan="4">{projectname}</td>
            </tr>
            <tr>
              <th>Result</th>
              <td colspan="4",style="color: red;font-weight: bold; font-size: 24px;">{result}</td>
            </tr>
            <tr>
              <th>Start At</th>
              <td colspan="4">{dicbody['startat']}</td>
            </tr>
            <tr>
              <th>Duration</th>
              <td colspan="4">{dicbody['duration']}</td>
            </tr>
            <tr>
              <th>Tips</th>
              <td colspan="4">.:suc || F:fail || E:err || s:skip</td>
            </tr>
        </table>
        <table style="width: 100%; margin:auto">
            <tr>
              <th style="text-align: center; color: blue;">TestCases (./F)</th>
              <th style="text-align: center; color: blue;">TestSteps (./F/E/s)</th>
            </tr>
            <tr>
              <td style="text-align: center;">{dicbody['testcases-sum']} ({dicbody['testcases-success']}/{dicbody['testcases-fail']})</td>
              <td style="text-align: center;">{dicbody['teststeps-sum']} ({dicbody['teststeps-success']}/{dicbody['teststeps-fail']}/{dicbody['teststeps-error']}/{dicbody['teststeps-skip']})</td>
            </tr>
        </table>
    </body>
    </html>
    """
    mail.attach(MIMEText(html_content, 'html'))

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
        # 获取报告关键指标
        dicbody = reportElementHandle(file)
        # print(dicbody)
        # 发送邮件
        subject = projectname+"项目接口自动化测试结果" # projectname 项目名+Jenkins构建号
        send_email(subject, dicbody, file)
