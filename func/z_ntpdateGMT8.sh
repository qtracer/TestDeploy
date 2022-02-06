#!/bin/bash

# 脚本由 @https://blog.51cto.com/u_13719882/2129104 提供
# 该功能用于同步服务器时间，并不写入标准化流程里面，可以按需使用

export info="$0: $PWD"
bash ${workdir}/comm/echoInfo.sh $workdir

[ "`rpm -qa | egrep ^rdate`" ] || yum -y install rdate > /dev/null 2>&1
tz=`date -R | awk '{print $NF}'`
if [ $tz != "+0800" ]
   then
       \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        echo ZONE=\"Asia/Shanghai\" > /etc/sysconfig/clock
fi

yum install ntpdate -y 
/usr/sbin/ntpdate us.ntp.org.cn
if [ $? != 0 ]
   then
      /usr/bin/rdate -s time.nist.gov
fi
 
/sbin/hwclock -w
