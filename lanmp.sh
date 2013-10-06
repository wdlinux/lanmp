#!/bin/bash
#
# Web Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Since 2010.04.08
#

. lib/common.conf
. lib/common.sh
. lib/mysql.sh
. lib/apache.sh
. lib/nginx.sh
. lib/php.sh
. lib/na.sh
. lib/libiconv.sh
. lib/eaccelerator.sh
. lib/zend.sh
. lib/pureftp.sh
. lib/pcre.sh
. lib/webconf.sh
. lib/service.sh
# make sure source files dir exists.
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH

###
echo "Select Install
    1 apache + php + mysql + zend + eAccelerator + pureftpd + phpmyadmin
    2 nginx + php + mysql + zend + eAccelerator + pureftpd + phpmyadmin
    3 nginx + apache + php + mysql + zend + eAccelerator + pureftpd + phpmyadmin
    4 install all service
    5 don't install is now
"
sleep 0.1
read -p "Please Input 1,2,3,4,5: " SERVER_ID
if [[ $SERVER_ID == 2 ]]; then
    SERVER="nginx"
elif [[ $SERVER_ID == 1 ]]; then
    SERVER="apache"
elif [[ $SERVER_ID == 3 ]]; then
    SERVER="na"
elif [[ $SERVER_ID == 4 ]]; then
    SERVER="all"
else
    exit
fi
echo "Select php version:
    1 php-5.2.17 (default)
    2 php-5.3.27
"
sleep 0.1
read -p "Please Input 1,2: " PHP_VER_ID
if [[ $PHP_VER_ID == 2 ]]; then
    PHP_VER="5.3.27"
else
    PHP_VER="5.2.17"
fi
 
# make sure network connection usable.
ping -c 1 -t 1 www.wdlinux.cn >/dev/null 2>&1
if [[ $? == 2 ]]; then
    echo "nameserver 8.8.8.8
nameserver 202.96.128.68" > /etc/resolv.conf
    echo "dns err"
fi
ping -c 1 -t 1 www.wdlinux.cn >/dev/null 2>&1
if [[ $? == 2 ]]; then
    echo "dns err"
    exit
fi

# Get os version info
GetOSVersion
if is_rhel_based; then
    sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
fi

###
if is_debian_based; then
    service apache2 stop 2>/dev/null
    service mysql stop 2>/dev/null
    service pure-ftpd stop 2>/dev/null
    apt-get update
    apt-get remove -y apache2 apache2-utils apache2.2-common apache2.2-bin \
        apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-common \
        mysql-client mysql-server php5 php5-fpm pure-ftpd pure-ftpd-common \
        pure-ftpd-mysql 2>/dev/null
    apt-get -y autoremove
    [ -f /etc/mysql/my.cnf ] && mv /etc/mysql/my.cnf /etc/mysql/my.cnf.lanmpsave
    apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
        libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
        libcurl4-openssl-dev libssl-dev patch libmcrypt-dev libmhash-dev \
        libncurses5-dev  libreadline-dev bzip2 libcap-dev ntpdate \
        diffutils exim4 iptables unzip sudo
    if [[ $os_ARCH = x86_64 ]]; then
        ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
    fi
elif is_rhel_based; then
    rpm --import lanmp/RPM-GPG-KEY.dag.txt
    if [[ $os_DISTRO = rhel6 ]]; then
        el="el6"
        syslog=rsyslog
        mta=postfix
    else
        el="el5"
        syslog=sysklogd
        mta=sendmail
    fi
    rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.$el.rf.$(uname -m).rpm
    yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
        freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel \
        curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
        libcap-devel ntp diffutils iptables unzip $syslog $mta
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib64/libjpeg.so /usr/lib/
        ln -sf /usr/lib64/libpng.so /usr/lib/
    fi
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
else
    err_exit "os not supported yet."
fi

ntpdate tiger.sina.com.cn
hwclock -w

if [ ! -d $IN_DIR ]; then
    mkdir -p $IN_DIR/{etc,init.d,wdcp_bk/conf}
    mkdir -p /www/web
    if is_debian_based; then
        /etc/init.d/apparmor stop >/dev/null 2>&1
        update-rc.d -f apparmor remove >/dev/null 2>&1
        apt-get remove -y apparmor apparmor-utils >/dev/null 2>&1
        ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup >/dev/null 2>&1
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser >/dev/null 2>&1
        adduser --system --group --home /nonexistent --no-create-home mysql >/dev/null 2>&1
    else
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        service httpd stop >/dev/null 2>&1
        service mysqld stop >/dev/null 2>&1
        chkconfig --level 35 httpd off >/dev/null 2>&1
        chkconfig --level 35 mysqld off >/dev/null 2>&1
        chkconfig --level 35 sendmail off >/dev/null 2>&1
        groupadd -g 27 mysql >/dev/null 2>&1
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www >/dev/null 2>&1
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www >/dev/null 2>&1
fi

cd $IN_SRC

[ $IN_DIR = "/www/wdlinux" ] || IN_DIR_ME=1

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

function in_all {
    na_ins
    SERVER="nginx"; php_ins
    eaccelerator_ins
    zend_ins
    rm -f $php_inf $eac_inf $zend_inf
    SERVER="apache"; php_ins
    eaccelerator_ins
    zend_ins
}

if [ $SOFT_DOWN == 1 ]; then
    cd $IN_PWD
    if [ -f lanmp.tar.gz ]; then
        tar zxvf lanmp.tar.gz 
    else
        wget -c http://dl.wdlinux.cn:5180/lanmp.tar.gz
        tar zxvf lanmp.tar.gz
    fi
fi

mysql_ins
if [ $SERVER == "all" ]; then
    in_all
else
    ${SERVER}_ins
    php_ins 
    eaccelerator_ins
    zend_ins
fi
pureftpd_ins
start_srv
lanmp_in_finsh
