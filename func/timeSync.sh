#!/bin/bash

workdir=$1
export info="$0: timeSync for the machine"
bash $workdir/comm/echoInfo.sh $workdir

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
