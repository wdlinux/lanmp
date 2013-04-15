#!/bin/bash
#
# Wdcp Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Last Updated 2013.03.24
# 

IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/lanmp
IN_LOG=${IN_SRC}/wdcp_install.log
IN_DIR="/www/wdlinux"
IN_DIR_ME=0
SERVER="apache"
RE_INS=0
X86=0
SOFT_DOWN=0

#soft url and down
HTTPD_DU="http://apache.freelamp.com/httpd/httpd-2.2.16.tar.gz"
NGINX_DU="http://nginx.org/download/nginx-0.8.51.tar.gz"
MYSQL_DU="http://mirrors.sohu.com/mysql/MySQL-5.1/mysql-5.1.50.tar.gz"
PHP_DU="http://www.php.net/get/php-5.2.14.tar.gz/from/cn.php.net/mirror"
EACCELERATOR_DU="http://bart.eaccelerator.net/source/0.9.6/eaccelerator-0.9.6.tar.bz2"
ZEND_DU="http://downloads.zend.com/optimizer/3.3.3/ZendOptimizer-3.3.3-linux-glibc23-i386.tar.gz"
ZENDX86_DU="http://downloads.zend.com/optimizer/3.3.3/ZendOptimizer-3.3.3-linux-glibc23-x86_64.tar.gz"
PHP_FPM_DU="http://php-fpm.org/downloads/php-5.2.14-fpm-0.5.14.diff.gz"
VSFTPD_DU="http://dl.wdlinux.cn:5180/vsftpd-2.2.2.tar.gz"
PHPMYADMIN_DU="http://dl.wdlinux.cn:5180/phpMyAdmin-3.3.3-all-languages.tar.gz"
PCRE_DU="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.10.tar.gz"

mysql_inf="/tmp/mysql_ins.txt"
wdapache_inf="/tmp/wdapache_ins.txt"
wdphp_inf="/tmp/wdphp_ins.txt"
pureftp_inf="/tmp/pureftp_ins.txt"
wdcp_inf="/tmp/wdcp_ins.txt"

[ -d $IN_SRC ] || mkdir $IN_SRC
OS_RL=1
grep -qi 'ubuntu' /etc/issue && OS_RL=2
if [ $OS_RL == 1 ]; then
    grep "release 6" /etc/redhat-release
    R6=$?
fi
if [ $(uname -m | grep "x86_64") ]; then
    X86=1
fi
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
        #groupadd mysql
        useradd --system -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    else
        groupadd -g 27 mysql
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www > /dev/null 2>&1
    if [ $OS_RL ==2 ]; then
        apt-get remove -y sendmail
    else
        chkconfig --level 35 sendmail off
    fi
###
fi

cd $IN_SRC

function make_clean {
    if [ $RE_INS == 1 ]; then
        make clean
    fi
}

function wget_down {
    if [ $SOFT_DOWN == 1 ]; then
        echo "start down..."
        for i in $*; do
            [ `wget -c $i` ] && exit
        done
    fi
}

function err_exit {
    echo 
    echo 
    echo "----Install Error: $1 -----------"
    echo
    echo
    exit
}

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

function error {
        echo "ERROR: "$1
        exit
}

function file_cp {
    [ -f $2 ] && mv $2 ${2}$(date +%Y%m%d%H)
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_rm {
    [ -f $1 ] && rm -f $1
}

function file_bk {
    [ -f $1 ] && mv $1 ${1}_$(date +%Y%m%d%H)
}

if [ ! -d /www/wdlinux/wdapache ]; then
    if [ $OS_RL == 1 ]; then
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi
    useradd -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    groupadd -g 999 wdcpg
    useradd -g 999 -u 999 -d /www/wdlinux/wdcp -s /sbin/nologin wdcpu
fi

# install function
function mysql_ins {
    echo
    [ -f $mysql_inf ] && return
    echo "installing mysql..."
    cd $IN_SRC
    tar zxvf mysql-5.1.63.tar.gz > $IN_LOG 2>&1
    if [ $OS_RL == 2 ]; then
        if [ -f /usr/lib/x86_64-linux-gnu/libncurses.so ]; then
            LIBNCU="/usr/lib/x86_64-linux-gnu/libncurses.so"
        elif [ -f /usr/lib/i386-linux-gnu/libncurses.so ]; then
            LIBNCU="/usr/lib/i386-linux-gnu/libncurses.so"
        else
            LIBNCU=""
        fi
    else
        if [ -f /usr/lib64/libncursesw.so ]; then
            LIBNCU="/usr/lib64/libncursesw.so"
        elif [ -f /usr/lib/libncursesw.so ]; then
            LIBNCU="/usr/lib/libncursesw.so"
        else
            LIBNCU=""
        fi
    fi
    cd mysql-5.1.63/
    make_clean
    if [ $OS_RL == 2 ]; then
        LIBS="-lncurses"
    fi
    ./configure \
        --prefix=$IN_DIR/mysql-5.1.63 \
        --sysconfdir=$IN_DIR/etc \
        --enable-assembler \
        --enable-thread-safe-client \
        --with-extra-charsets=complex \
        --with-ssl \
        --with-embedded-server \
        --with-named-curses-libs=$LIBNCU 
    [ $? != 0 ] && err_exit "mysql configure err"
    make
    [ $? != 0 ] && err_exit "mysql make err"
    make install 
    [ $? != 0 ] && err_exit "mysql make install err"
    ln -sf $IN_DIR/mysql-5.1.63 $IN_DIR/mysql
    if [ -f /etc/my.cnf ]; then
        mv /etc/my.cnf /etc/my.cnf.old
    fi
    cp support-files/mysql.server $IN_DIR/init.d/mysqld
    file_cp my.cnf $IN_DIR/etc/my.cnf
    ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
    $IN_DIR/mysql/bin/mysql_install_db > $IN_LOG 2>&1
    chown -R mysql.mysql $IN_DIR/mysql/var
    chmod 755 $IN_DIR/init.d/mysqld
    ln -sf $IN_DIR/init.d/mysqld /etc/init.d/mysqld
    if [ $OS_RL == 2 ]; then
        update-rc.d -f mysqld defaults
        update-rc.d -f mysqld enable 235
    else
        chkconfig --add mysqld
        chkconfig --level 35 mysqld on
    fi
    service mysqld start
    echo "PATH=\$PATH:$IN_DIR/mysql/bin" > /etc/profile.d/mysql.sh
    echo "$IN_DIR/mysql" > /etc/ld.so.conf.d/mysql-wdl.conf
    ldconfig
    $IN_DIR/mysql/bin/mysqladmin -u root password "wdlinux.cn"
    ln -s $IN_DIR/mysql/bin/mysql /bin/mysql
    mkdir /var/lib/mysql
    ln -sf /tmp/mysql.sock /var/lib/mysql/
    touch $mysql_inf
}


function apache_ins {
    echo
    [ -f $wdapache_inf ] && return
    echo "installing apache..."
    cd $IN_SRC
    tar zxvf httpd-2.0.64.tar.gz > $IN_LOG 2>&1
    cd httpd-2.0.64
    make_clean
    ./configure \
        --prefix=/www/wdlinux/wdapache \
        --disable-asis \
        --disable-status \
        --disable-userdir \
        --disable-status \
        --disable-cgid  \
        --disable-cgi \
        --disable-imap \
        --enable-rewrite \
        --enable-so 
    [ $? != 0 ] && err_exit "wdapache configure err"
    make
    [ $? != 0 ] && err_exit "wdapache make err"
    make install
    [ $? != 0 ] && err_exit "wdapache make install err"
    file_cp httpd.conf.wdapache /www/wdlinux/wdapache/conf/httpd.conf
    [ -d /www/wdlinux/init.d ] || mkdir -p /www/wdlinux/init.d
    if [ $OS_RL == 2 ]; then
        file_cp init.wdapache-ubuntu /www/wdlinux/init.d/wdapache
    else
        file_cp init.wdapache /www/wdlinux/init.d/wdapache
    fi
    chmod 755 /www/wdlinux/init.d/wdapache
    ln -s /www/wdlinux/init.d/wdapache /etc/init.d/wdapache
    if [ $OS_RL == 2 ]; then
        update-rc.d wdapache defaults
        update-rc.d wdapache enable 235
    else
        chkconfig --add wdapache
        chkconfig --level 35 wdapache on
    fi
    service wdapache start
    /sbin/iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
    if [ $OS_RL == 2 ]; then
        iptables-save > /etc/sysconfig/iptables
    else
        service iptables save
    fi
    touch $wdapache_inf
}

function php_ins {
    echo
    [ -f $wdphp_inf ] && return
    echo "installing php..."
    cd $IN_SRC
    rm -fr php-5.2.17
    tar zxvf php-5.2.17.tar.gz > $IN_LOG 2>&1
    cd php-5.2.17/
    ./configure \
        --prefix=/www/wdlinux/wdphp \
        --with-apxs2=/www/wdlinux/wdapache/bin/apxs \
        --with-mysql=/www/wdlinux/mysql \
        --with-curl --with-zlib --enable-ftp --with-gd \
        --enable-gd-native-ttf --enable-mbstring \
        --enable-zip --without-iconv
    [ $? != 0 ] && err_exit "wdphp configure err"
    make
    [ $? != 0 ] && err_exit "wdphp make err"
    make install
    [ $? != 0 ] && err_exit "wdphp make install err"
    cp php.ini-dist /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/upload_max_filesize = 2/upload_max_filesize = 20/g' /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/post_max_size = 8/post_max_size = 20/g' /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/display_errors = On/display_errors = Off/g' /www/wdlinux/wdphp/lib/php.ini
    if [ $X86 == 1 ]; then
        mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
        file_cp php_wdcpm64.so \
            /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613/php_wdcpm.so
        echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
    else
        mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
        file_cp php_wdcpm.so /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613/
        echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
    fi
    touch $wdphp_inf
}

function pureftpd_ins {
    echo
    [ -f $pureftp_inf ] && return
    echo "prureftpd installing..."
    cd $IN_SRC
    tar zxvf pure-ftpd-1.0.35.tar.gz
    cd pure-ftpd-1.0.35/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IN_DIR/mysql/lib/mysql
    cp -pR /www/wdlinux/mysql/lib/mysql/* /usr/lib/
    if [ $X86 == 1 ]; then
        cp /usr/lib/libmysqlclient.so.16 /usr/lib64/
    fi
    ./configure --prefix=$IN_DIR/pureftpd-1.0.35 \
        --with-mysql=/www/wdlinux/mysql \
        --with-quotas \
        --with-cookie \
        --with-virtualhosts \
        --with-virtualchroot \
        --with-diraliases \
        --with-sysquotas \
        --with-ratios \
        --with-altlog \
        --with-paranoidmsg \
        --with-shadow \
        --with-welcomemsg  \
        --with-throttling \
        --with-uploadscript \
        --with-language=simplified-chinese
    [ $? != 0 ] && err_exit "pureftp configure err"
    make
    [ $? != 0 ] && err_exit "pureftpd make err"
    make install
    [ $? != 0 ] && err_exit "pureftpd makeinstall err"
    ln -sf $IN_DIR/pureftpd-1.0.35 $IN_DIR/pureftpd
    ln -sf /www/wdlinux/pureftpd/sbin/pure-ftpd /usr/sbin/
    cp configuration-file/pure-config.pl $IN_DIR/pureftpd/sbin/
    chmod 755 $IN_DIR/pureftpd/sbin/pure-config.pl
    cp configuration-file/pure-config.py $IN_DIR/pureftpd/sbin/
    chmod 755 $IN_DIR/pureftpd/sbin/pure-config.py
    cd $IN_SRC
    file_cp pureftpd-mysql.conf $IN_DIR/etc
    file_cp pureftpd-mysql.conf $IN_DIR/wdcp_bk
    file_cp pure-ftpd.conf $IN_DIR/etc
    if [ $OS_RL == 2 ]; then
        file_cp init.pureftpd-ubuntu $IN_DIR/init.d/pureftpd
    else
        file_cp init.pureftpd $IN_DIR/init.d/pureftpd
    fi
    dbpw=`grep dbpw /www/wdlinux/wdcp/data/db.inc.php | awk -F"'" '{print $2}'`
    sed -i 's/{passwd}/$dbpw/g' $IN_DIR/etc/pureftpd-mysql.conf
    chmod 755 $IN_DIR/init.d/pureftpd
    ln -sf $IN_DIR/init.d/pureftpd /etc/init.d/pureftpd
    if [ $OS_RL == 2 ]; then
        update-rc.d pureftpd defaults
        update-rc.d pureftpd enable 235
    else
        chkconfig --add pureftpd
        chkconfig --level 35 pureftpd on
    fi
    touch /var/log/pureftpd.log
    if [ $OS_RL == 2 ]; then
        if [ -f /etc/rsyslog.d/50-default.conf ]; then
            sed -i 's#mail,news.none#mail,news.none;ftp.none#g' /etc/rsyslog.d/50-default.conf
            echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/rsyslog.d/60-pureftpd.conf
            service rsyslog restart
        fi
    else
        if [ -f /etc/syslog.conf ]; then
            sed -i 's/cron.none/cron.none;ftp.none/g' /etc/syslog.conf
            echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/syslog.conf
            /etc/init.d/syslog restart
        fi
    fi
    service pureftpd start
    touch $pureftp_inf
}

function wdcp_ins {
    [ -f $wdcp_inf ] && return
    cd $IN_SRC
    tar xf wdcp_v2.5.tar.gz -C /
    [ $? != 0 ] && err_exit "wdcp install err"
    tar xf phpmyadmin.tar.gz -C /www/wdlinux/wdcp
    file_cp dz7_apache.conf /www/wdlinux/wdcp/data/rewrite/dz7_apache.conf
    file_cp dzx15_apache.conf /www/wdlinux/wdcp/data/rewrite/dzx15_apache.conf
    file_cp dz7_nginx.conf /www/wdlinux/wdcp/data/rewrite/dz7_nginx.conf
    file_cp dzx15_nginx.conf /www/wdlinux/wdcp/data/rewrite/dzx15_nginx.conf
    ####
    sqlrootpwd="wdlinux.cn"
    mysql="/www/wdlinux/mysql/bin/mysql"
    wdpwd=$(expr substr "$(echo $RANDOM | md5sum)" 1 8)
    $mysql -uroot -p"$sqlrootpwd" -e "CREATE database wdcpdb DEFAULT CHARACTER SET GBK;"
    $mysql -uroot -p"$sqlrootpwd" -e "grant SELECT, INSERT, UPDATE, DELETE, CREATE,DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, CREATE VIEW, SHOW VIEW on wdcpdb.* to 'wdcp'@'localhost' identified by '$wdpwd';"
    $mysql -uroot -p"$sqlrootpwd" wdcpdb < /www/wdlinux/wdcp/wdcpdb.sql
    [ -f /www/wdlinux/wdcp/data/db.inc.php ] ||
        echo "<?
\$dbhost = 'localhost';
\$dbuser = 'wdcp';
\$dbpw = '$wdpwd';
\$dbname = 'wdcpdb';
\$pconnect = 0;
\$dbcharset = 'gbk';
?>" > /www/wdlinux/wdcp/data/db.inc.php
    [ -f /www/wdlinux/wdcp/data/dbr.inc.php ] ||
        echo "<?
\$sqlrootpw='$sqlrootpwd';
\$sqlrootpw_en='0';
?>" > /www/wdlinux/wdcp/data/dbr.inc.php
    sed -i "s/{passwd}/$wdpwd/g" $IN_DIR/etc/pureftpd-mysql.conf
    chown -R wdcpu.wdcpg /www/wdlinux/wdcp/data
    chmod 600 /www/wdlinux/wdcp/data/db.inc.php
    chmod 600 /www/wdlinux/wdcp/data/dbr.inc.php
    /www/wdlinux/wdphp/bin/php /www/wdlinux/wdcp/task/wdcp_perm_check.php
    service wdapache restart
    service pureftpd restart
    touch $wdcp_inf
}

function in_finsh {
    echo
    echo
    echo
    echo "      configuration ,wdcp install is finshed"
    echo "      visit http://ip:8080"
    echo "      more infomation please visit http://www.wdlinux.cn"
    echo
}


mysql_ins
apache_ins
php_ins 
pureftpd_ins
wdcp_ins
in_finsh
