#!/bin/bash
#
# Wdcp Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Last Updated 2013.03.24
# 

. lib/common.conf
. lib/common.sh
. lib/mysql.sh
. lib/wdapache.sh
. lib/wdphp.sh
. lib/pureftp.sh
. lib/wdcp.sh
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH

ping -c 1 -t 1 www.wdlinux.cn >/dev/null 2>&1
if [[ $? == 2 ]]; then
    #echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "dns err"
    exit
fi
###

if [ $OS_RL == 2 ]; then
    apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
        libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
        libssl-dev libcurl4-openssl-dev patch libmcrypt-dev libmhash-dev \
        libncurses5-dev bzip2 libcap-dev ntpdate chkconfig unzip
else
    rpm --import lanmp/RPM-GPG-KEY.dag.txt
    if [ $X86 == 1 ]; then
        rpm -ivh lanmp/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
    else
        rpm -ivh lanmp/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
    fi
    yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
        freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel \
        curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
        libcap-devel ntp sysklogd unzip
fi
ntpdate tiger.sina.com.cn
hwclock -w

if [ ! -d $IN_DIR ]; then
    mkdir -p $IN_DIR/{etc,init.d,wdcp_bk}
    if [ $OS_RL == 2 ]; then
        ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser
        adduser --system --group --home /nonexistent --no-create-home mysql
    else
        groupadd -g 27 mysql
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www > /dev/null 2>&1
    if [ $OS_RL == 2 ]; then
        apt-get remove -y sendmail
    else
        chkconfig --level 35 sendmail off
    fi
###
fi

cd $IN_SRC

if [ $SERVER == "apache" ]; then
    wget_down $HTTPD_DU
elif [ $SERVER == "nginx" ]; then
    wget_down $NGINX_DU $PHP_FPM $PCRE_DU
fi

if [ $X86 == "1" ]; then
    wget_down $ZENDX86_DU
else
    wget_down $ZEND_DU
fi
wget_down $MYSQL_DU $PHP_DU $EACCELERATOR_DU $VSFTPD_DU $PHPMYADMIN_DU

if [ ! -d /www/wdlinux/wdapache ]; then
    if [ $OS_RL == 1 ]; then
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi
    useradd -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    groupadd -g 999 wdcpg
    useradd -g 999 -u 999 -d /www/wdlinux/wdcp -s /sbin/nologin wdcpu
fi

mysql_ins
wdapache_ins
wdphp_ins 
pureftpd_ins
wdcp_ins
wdcp_in_finsh
