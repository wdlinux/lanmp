#!/bin/bash
#
# Wdcp Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Since 2010.04.08
#

. lib/common.conf
. lib/common.sh
. lib/basic_packages.sh
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
# Get os version info
GetOSVersion
install_basic_packages
ntpdate tiger.sina.com.cn
hwclock -w

if [ ! -d $IN_DIR ]; then
    mkdir -p $IN_DIR/{etc,init.d,wdcp_bk}
    if is_debian_based; then
        ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser
        adduser --system --group --home /nonexistent --no-create-home mysql >/dev/null 2>&1
    else
        groupadd -g 27 mysql >/dev/null 2>&1
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www >/dev/null 2>&1
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www > /dev/null 2>&1
###
fi

cd $IN_SRC

wget_down $MYSQL_DU $PHP_DU $EACCELERATOR_DU $PUREFTP_DU $PHPMYADMIN_DU

if [ ! -d /www/wdlinux/wdapache ]; then
    if is_rhel_based; then
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi
    groupadd -g 999 wdcpg
    useradd -g 999 -u 999 -d /www/wdlinux/wdcp -s /sbin/nologin wdcpu
fi

mysql_ins
wdapache_ins
wdphp_ins 
pureftpd_ins
wdcp_ins
wdcp_in_finsh
