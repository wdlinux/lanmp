#!/bin/bash
#
# Web Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# 2010.04.08
# Last Updated 2013.05.26
# 

IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/lanmp
LOGPATH=${IN_PWD}/logs
IN_DIR="/www/wdlinux"
IN_DIR_ME=0
SERVER="apache"
RE_INS=0
X86=0
SOFT_DOWN=0

#soft url and down
HTTPD_DU="http://mirror.bjtu.edu.cn/apache/httpd/httpd-2.2.24.tar.gz"
NGINX_DU="http://nginx.org/download/nginx-1.2.8.tar.gz"
MYSQL_DU="http://cdn.mysql.com/Downloads/MySQL-5.1/mysql-5.1.69.tar.gz"
PHP_DU="http://www.php.net/get/php-5.2.17.tar.gz/from/cn.php.net/mirror"
EACCELERATOR_DU="http://bart.eaccelerator.net/source/0.9.6/eaccelerator-0.9.6.tar.bz2"
ZEND_DU="http://downloads.zend.com/optimizer/3.3.3/ZendOptimizer-3.3.3-linux-glibc23-i386.tar.gz"
ZENDX86_DU="http://downloads.zend.com/optimizer/3.3.3/ZendOptimizer-3.3.3-linux-glibc23-x86_64.tar.gz"
PHP_FPM_DU="http://php-fpm.org/downloads/php-5.2.14-fpm-0.5.14.diff.gz"
VSFTPD_DU="http://dl.wdlinux.cn:5180/vsftpd-2.2.2.tar.gz"
PHPMYADMIN_DU="http://dl.wdlinux.cn:5180/phpMyAdmin-3.3.3-all-languages.tar.gz"
PCRE_DU="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.10.tar.gz"

###ver
MYS_VER="5.1.69"
NGI_VER="1.2.8"
APA_VER="2.2.24"
PHP_VER="5.2.17"
PUR_VER="1.0.36"

mysql_inf="/tmp/mysql_ins.txt"
nginx_inf="/tmp/nginx_ins.txt"
httpd_inf="/tmp/httpd_ins.txt"
pureftp_inf="/tmp/pureftp_ins.txt"
php_inf="/tmp/php_ins.txt"
na_inf="/tmp/na_ins.txt"
eac_inf="/tmp/eac_ins.txt"
zend_inf="/tmp/zend_ins.txt"
conf_inf="/tmp/conf_ins.txt"

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
if [ $SERVER_ID == 2 ]; then
    SERVER="nginx"
elif [ $SERVER_ID == 1 ]; then
    SERVER="apache"
elif [ $SERVER_ID == 3 ]; then
    SERVER="na"
elif [ $SERVER_ID == 4 ]; then
    SERVER="all"
else
    exit
fi
echo "Select php version:
    1 php-5.2.17 (default)
    2 php-5.3.24
"
sleep 0.1
read -p "Please Input 1,2: " PHP_VER_ID
if [ $PHP_VER_ID == 2 ]; then
    PHP_VER="5.3.24"
else
    PHP_VER="5.2.17"
fi
 
OS_RL=1
if grep -qi 'ubuntu' /etc/issue; then
    OS_RL=2
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

uname -a | grep -q "stab"
if [ $? == 1 ]; then
    httpd_m="--with-mpm=worker"
fi
if [ $OS_RL == 1 ]; then
    r6=0
    grep -q "release 6" /etc/redhat-release
    if [ $? == 0 ]; then
        httpd_m=""
        r6=1
    fi
    sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
fi
if [ $(uname -m | grep "x86_64") ]; then
    X86=1
fi

###
if [ $OS_RL == 2 ]; then
    service apache2 stop 2>/dev/null
    service mysql stop 2>/dev/null
    service pure-ftpd stop 2>/dev/null
    apt-get update
    apt-get remove -y apache2 apache2-utils apache2.2-common apache2.2-bin \
        apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-common \
        mysql-client mysql-server php5 php5-fpm pure-ftpd pure-ftpd-common \
        pure-ftpd-mysql
    apt-get -y autoremove
    [ -f /etc/mysql/my.cnf ] && mv /etc/mysql/my.cnf /etc/mysql/my.cnf.lanmpsave
    apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
        libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
        libcurl4-openssl-dev libssl-dev patch libmcrypt-dev libmhash-dev \
        libncurses5-dev  libreadline-dev bzip2 libcap-dev ntpdate chkconfig \
        diffutils sendmail iptables unzip
    if [ $X86 == 1 ]; then
        ln -s /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -s /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -s /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -s /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
    fi
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
        libcap-devel ntp sysklogd diffutils sendmail iptables unzip
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib64/libjpeg.so /usr/lib/
        ln -sf /usr/lib64/libpng.so /usr/lib/
    fi
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi

ntpdate tiger.sina.com.cn
hwclock -w

if [ ! -d $IN_DIR ]; then
    mkdir -p $IN_DIR/{etc,init.d,wdcp_bk}
    mkdir -p /www/web
    if [ $OS_RL == 2 ]; then
        /etc/init.d/apparmor stop
        update-rc.d -f apparmor remove
        apt-get remove -y apparmor apparmor-utils
        ogroup=$(awk -F':' '/x:1000:/ {print $1}' /etc/group)
        [ -n "$ogroup" ] && groupmod -g 1010 $ogroup
        ouser=$(awk -F':' '/x:1000:/ {print $1}' /etc/passwd)
        [ -n "$ouser" ] && usermod -u 1010 -g 1010 $ouser
        adduser --system --group --home /nonexistent --no-create-home mysql
    else
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        service httpd stop
        service mysqld stop
        chkconfig --level 35 httpd off
        chkconfig --level 35 mysqld off
        chkconfig --level 35 sendmail off
        groupadd -g 27 mysql
        useradd -g 27 -u 27 -d /dev/null -s /sbin/nologin mysql >/dev/null 2>&1
    fi
    groupadd -g 1000 www
    useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www >/dev/null 2>&1
fi

cd $IN_SRC

[ $IN_DIR = "/www/wdlinux" ] || IN_DIR_ME=1

function make_clean {
    if [ $RE_INS == 1 ]; then
        make clean
    fi
}

function wget_down {
    if [ $SOFT_DOWN == 1 ]; then
        echo "start down..."
        for i in $*; do
            [ $(wget -c $i) ] && exit
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
    echo "ERROR: $1"
    exit
}

function file_cp {
    [ -f $2 ] && mv $2 ${2}$(date +%Y%m%d%H)
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}
function file_cpv {
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}
function file_rm {
    [ -f $1 ] && rm -f $1
}
function file_bk {
    [ -f $1 ] && mv $1 ${1}_$(date +%Y%m%d%H)
}

# install function
function mysql_ins {
    IN_LOG=$LOGPATH/mysql_install.log
    echo
    [ -f $mysql_inf ] && return
    echo "installing mysql..."
    cd $IN_SRC
    tar xf mysql-$MYS_VER.tar.gz >$IN_LOG 2>&1
    if [ $OS_RL == 2 ]; then
        if [ -f /usr/lib/x86_64-linux-gnu/libncurses.so ]; then
            #LIBNCU="/usr/lib/x86_64-linux-gnu/libncurses.so"
            LIBNCU=""
        elif [ -f /usr/lib/i386-linux-gnu/libncurses.so ]; then
            #LIBNCU="/usr/lib/i386-linux-gnu/libncurses.so"
            LIBNCU=""
        else
            LIBNCU=""
        fi
    else
        if [ -f /usr/lib64/libncursesw.so ]; then
            LIBNCU="--with-named-curses-libs=/usr/lib64/libncursesw.so"
        elif [ -f /usr/lib/libncursesw.so ]; then
            LIBNCU="--with-named-curses-libs=/usr/lib/libncursesw.so"
        else
            LIBNCU=""
        fi
    fi      
    cd mysql-$MYS_VER/
    make_clean
    ./configure --prefix=$IN_DIR/mysql-$MYS_VER \
        --sysconfdir=$IN_DIR/etc \
        --enable-assembler \
        --enable-thread-safe-client \
        --with-extra-charsets=complex \
        --with-ssl \
        --with-embedded-server $LIBNCU >>$IN_LOG 2>&1 
    [ $? != 0 ] && err_exit "mysql configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "mysql make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "mysql make install err"
    ln -sf $IN_DIR/mysql-$MYS_VER $IN_DIR/mysql
    [ -f /etc/my.cnf ] && mv /etc/my.cnf /etc/my.cnf.old
    cp support-files/mysql.server $IN_DIR/init.d/mysqld
    file_cp my.cnf $IN_DIR/etc/my.cnf
    ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
    $IN_DIR/mysql/bin/mysql_install_db >>$IN_LOG 2>&1
    chown -R mysql.mysql $IN_DIR/mysql/var
    chmod 755 $IN_DIR/init.d/mysqld
    ln -sf $IN_DIR/init.d/mysqld /etc/init.d/mysqld
    if [ $OS_RL == 2 ]; then
        update-rc.d -f mysqld defaults >>$IN_LOG 2>&1
        update-rc.d -f mysqld enable 235 >>$IN_LOG 2>&1
    else
        chkconfig --add mysqld >>$IN_lOG 2>&1
        chkconfig --level 35 mysqld on >>$IN_LOG 2>&1
    fi
    service mysqld start
    echo "PATH=\$PATH:$IN_DIR/mysql/bin" > /etc/profile.d/mysql.sh
    echo "$IN_DIR/mysql" > /etc/ld.so.conf.d/mysql-wdl.conf
    ldconfig >>$IN_LOG 2>&1
    $IN_DIR/mysql/bin/mysqladmin -u root password "wdlinux.cn"
    /www/wdlinux/mysql/bin/mysql -uroot -p"wdlinux.cn" -e \
        "use mysql;update user set password=password('wdlinux.cn') where user='root';
        delete from user where user='';
        DROP DATABASE test;
        drop user ''@'%';flush privileges;"
    ln -s $IN_DIR/mysql/bin/mysql /bin/mysql
    mkdir /var/lib/mysql
    ln -sf /tmp/mysql.sock /var/lib/mysql/
    touch $mysql_inf
}

function apache_ins {
    IN_LOG=$LOGPATH/apache_install.log
    echo
    [ -f $httpd_inf ] && return
    echo "installing httpd..."
    cd $IN_SRC
    tar xf httpd-$APA_VER.tar.gz >$IN_LOG 2>&1
    cd httpd-$APA_VER
    make_clean
    ./configure --prefix=$IN_DIR/httpd-$APA_VER \
        --enable-rewrite --enable-deflate --disable-userdir \
        --enable-so --enable-expires --enable-headers \
        --with-included-apr --with-apr=/usr \
        --with-apr-util=/usr --enable-ssl --with-ssl=/usr >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache make install err"
    ln -sf $IN_DIR/httpd-$APA_VER $IN_DIR/apache
    sed -i 's/User daemon/User www/g' $IN_DIR/apache/conf/httpd.conf
    sed -i 's/Group daemon/Group www/g' $IN_DIR/apache/conf/httpd.conf
    echo "NameVirtualHost *:80" >> $IN_DIR/apache/conf/httpd.conf
    echo "Include conf/httpd-wdl.conf" >> $IN_DIR/apache/conf/httpd.conf
    #echo "Include conf/default.conf" >> $IN_DIR/apache/conf/httpd.conf
    #echo "Include conf/wdcp.conf" >> $IN_DIR/apache/conf/httpd.conf
    echo "Include conf/vhost/*.conf" >> $IN_DIR/apache/conf/httpd.conf
    mkdir -p $IN_DIR/apache/conf/{vhost,rewrite}
    sed -i '/#ServerName/a\
ServerName localhost
' $IN_DIR/apache/conf/httpd.conf
    mkdir -p /www/{web/default,web_logs}    
    file_cp phpinfo.php /www/web/default/phpinfo.php
    file_cp iProber2.php /www/web/default/iProber2.php
    file_cp wdlinux_a.php /www/web/default/index.php
    chown -R www.www /www/web
    file_cp httpd-wdl.conf $IN_DIR/apache/conf/httpd-wdl.conf
    #file_cp wdcp_a.conf $IN_DIR/apache/conf/wdcp.conf
    file_cpv defaulta.conf $IN_DIR/apache/conf/vhost/00000.default.conf
    file_cp dz7_apache.conf $IN_DIR/apache/conf/rewrite/dz7_apache.conf
    file_cp dzx15_apache.conf $IN_DIR/apache/conf/rewrite/dzx15_apache.conf
    if [ $OS_RL == 2 ]; then
        file_cp init.httpd-ubuntu $IN_DIR/init.d/httpd
    else
        file_cp init.httpd $IN_DIR/init.d/httpd
    fi
    chmod 755 $IN_DIR/init.d/httpd
    ln -sf $IN_DIR/init.d/httpd /etc/init.d/httpd
    if [ $OS_RL == 2 ]; then
        update-rc.d httpd defaults >>$IN_LOG 2>&1
        update-rc.d httpd enable 235 >>$IN_LOG 2>&1
    else
        chkconfig --add httpd >>$IN_LOG 2>&1
        chkconfig --level 35 httpd on >>$IN_LOG 2>&1
    fi
    mkdir -p $IN_DIR/apache/conf/vhost
    [ $IN_DIR_ME == 1 ] && sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/httpd
    touch $httpd_inf
}

function nginx_ins {
    IN_LOG=$LOGPATH/nginx_install.log
    [ -f $nginx_inf ] && return
    pcre_ins
    echo
    echo "installing nginx..."
    cd $IN_SRC
    tar xf nginx-$NGI_VER.tar.gz >$IN_LOG 2>&1
    cd nginx-$NGI_VER
    make_clean
    ./configure --user=www --group=www --prefix=$IN_DIR/nginx-$NGI_VER \
        --with-http_stub_status_module --with-http_ssl_module >>$IN_lOG 2>&1
    [ $? != 0 ] && err_exit "nginx configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "nginx make err"
    make install >>$IN_lOG 2>&1
    [ $? != 0 ] && err_exit "nginx make install err"
    ln -sf $IN_DIR/nginx-$NGI_VER $IN_DIR/nginx
    mkdir -p $IN_DIR/nginx/conf/{vhost,rewrite}
    mkdir -p /www/{web/default,web_logs}
    file_cp phpinfo.php /www/web/default/phpinfo.php
    file_cp iProber2.php /www/web/default/iProber2.php
    file_cp wdlinux_n.php /www/web/default/index.php
    chown -R www.www /www/web
    file_cp fcgi.conf $IN_DIR/nginx/conf/fcgi.conf
    file_cp nginx.conf $IN_DIR/nginx/conf/nginx.conf
    #file_cp wdcp_n.conf $IN_DIR/nginx/conf/wdcp.conf
    file_cp defaultn.conf $IN_DIR/wdcp_bk/conf/defaultn.conf
    file_cpv defaultn.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
    file_cp dz7_nginx.conf $IN_DIR/nginx/conf/rewrite/dz7_nginx.conf
    file_cp dzx15_nginx.conf $IN_DIR/nginx/conf/rewrite/dzx15_nginx.conf
    mkdir -p $IN_DIR/nginx/conf/vhost
    if [ $OS_RL == 2 ]; then
        file_cp init.nginxd-ubuntu $IN_DIR/init.d/nginxd
    else
        file_cp init.nginxd $IN_DIR/init.d/nginxd
    fi
    chmod 755 $IN_DIR/init.d/nginxd
    #ln -sf $IN_DIR/php/sbin/php-fpm $IN_DIR/init.d/php-fpm
    #chmod 755 $IN_DIR/init.d/php-fpm
    #ln -sf $IN_DIR/php/sbin/php-fpm /etc/rc.d/init.d/php-fpm
    file_rm /etc/init.d/nginxd
    ln -sf $IN_DIR/init.d/nginxd /etc/init.d/nginxd
    if [ $OS_RL == 2 ]; then
        update-rc.d -f nginxd defaults >>$IN_lOG 2>&1
        update-rc.d -f nginxd enable 235 >>$IN_lOG 2>&1
    else
        chkconfig --add nginxd >>$IN_lOG 2>&1
        chkconfig --level 35 nginxd on >>$IN_lOG 2>&1
    fi
    if [ $IN_DIR_ME == 1 ]; then
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/nginxd
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/php-fpm
        sed -i "s#/www/wdlinux#$IN_DIR#g" $IN_DIR/nginx/conf/nginx.conf
    fi
    touch $nginx_inf
}

function php_ins {
    IN_LOG=$LOGPATH/php_install.log
    echo
    [ -f $php_inf ] && return
    libiconv_ins
    echo
    echo "installing php..."
    cd $IN_SRC
    tar xf php-$PHP_VER.tar.gz >$IN_LOG 2>&1
    if [ $OS_RL == 2 ]; then
        if [ $X86 == 1 ]; then
            ln -s /usr/lib/x86_64-linux-gnu/libssl.* /usr/lib/
        else
            ln -s /usr/lib/i386-linux-gnu/libssl.* /usr/lib/
        fi
        patch -d php-$PHP_VER -p1 < debian_patches_disable_SSLv2_for_openssl_1_0_0.patch >>$IN_lOG 2>&1
    fi
    NV=""
    if [ $SERVER == "nginx" ]; then
        NV="--enable-fastcgi --enable-fpm --with-fpm-conf=$IN_DIR/etc/php-fpm.conf"
        if [ $PHP_VER == "5.2.17" ]; then
            gzip -cd php-$PHP_VER-fpm-0.5.14.diff.gz | patch -fd php-$PHP_VER -p1 >>$IN_LOG 2>&1
        fi
    fi
    [ $SERVER == "apache" -o $SERVER == "na" ] && NV="--with-apxs2=$IN_DIR/apache/bin/apxs"
    cd php-$PHP_VER/
    make clean >/dev/null 2>&1
    if [ $SERVER == "apache" -o $SERVER == "na" ]; then
        PHP_DIR="apache_php-$PHP_VER"
        PHP_DIRS="apache_php"
    elif [ $SERVER == "nginx" ];then
        PHP_DIR="nginx_php-$PHP_VER"
        PHP_DIRS="nginx_php"
    else
        PHP_DIR="def_php-$PHP_VER"
        PHP_DIRS="def_php"
    fi
    ./configure --prefix=$IN_DIR/$PHP_DIR \
        --with-config-file-path=$IN_DIR/$PHP_DIR/etc \
        --with-mysql=$IN_DIR/mysql --with-iconv=/usr \
        --with-freetype-dir --with-jpeg-dir \
        --with-png-dir --with-zlib \
        --with-libxml-dir=/usr --enable-xml \
        --disable-rpath --enable-discard-path \
        --enable-inline-optimization --with-curl \
        --enable-mbregex --enable-mbstring \
        --with-mcrypt=/usr --with-gd \
        --enable-gd-native-ttf --with-openssl \
        --with-mhash --enable-ftp \
        --enable-sockets --enable-zip $NV >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "php configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "php make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "php make install err"
    ln -sf $IN_DIR/$PHP_DIR $IN_DIR/$PHP_DIRS
    rm -rf $IN_DIR/php
    ln -sf $IN_DIR/$PHP_DIRS $IN_DIR/php
    cp php.ini-dist $IN_DIR/$PHP_DIR/etc/php.ini
    chown wdcpu.wdcpg $IN_DIR/$PHP_DIR/etc/php.ini
    ln -sf $IN_DIR/$PHP_DIRS/etc/php.ini $IN_DIR/etc/php.ini
    mkdir -p $IN_DIR/$PHP_DIR/lib/php/extensions/no-debug-zts-20060613
    ln -s $IN_DIR/$PHP_DIR/lib/php/extensions/no-debug-zts-20060613 \
        $IN_DIR/$PHP_DIR/lib/php/extensions/no-debug-non-zts-20060613
    
    if [ $SERVER == "nginx" ]; then
        ln -sf $IN_DIR/$PHP_DIR/sbin/php-fpm $IN_DIR/init.d/php-fpm
        chmod 755 $IN_DIR/init.d/php-fpm
        ln -sf $IN_DIR/init.d/php-fpm /etc/init.d/php-fpm
        if [ $OS_RL == 2 ]; then
            file_cp nginxd.fpm-ubuntu /www/wdlinux/init.d/nginxd
        else
            file_cp nginxd.fpm /www/wdlinux/init.d/nginxd
        fi
        chmod 755 /www/wdlinux/init.d/nginxd
        sed -i '/nobody/s#<!--##g' $IN_DIR/etc/php-fpm.conf
        sed -i '/nobody/s#-->##g' $IN_DIR/etc/php-fpm.conf
        sed -i 's/>nobody</>www</' $IN_DIR/etc/php-fpm.conf
    fi

    if [ $SERVER_ID == 4 ]; then
        sed -i 's/service/#service/g' /www/wdlinux/init.d/nginxd
    fi
    touch $php_inf
}

function na_ins {
    [ -f $na_inf ] && return
    echo
    nginx_ins
    apache_ins
    sed -i 's/Listen 80/Listen 88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/NameVirtualHost \*:80/NameVirtualHost \*:88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/VirtualHost \*:80/VirtualHost \*:88/g' /www/wdlinux/apache/conf/vhost/00000.default.conf
    cd $IN_SRC
    tar xf mod_rpaf-0.6.tar.gz
    cd mod_rpaf-0.6/
    #/www/wdlinux/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
    /www/wdlinux/apache/bin/apxs -i -c -a mod_rpaf-2.0.c
    file_cp rpaf.conf /www/wdlinux/apache/conf
    file_cp naproxy.conf /www/wdlinux/nginx/conf
    file_cp defaultna.conf $IN_DIR/wdcp_bk/conf/defaultna.conf
    file_cpv defaultna.conf /www/wdlinux/nginx/conf/vhost/00000.default.conf
    file_cp wdlinux_na.php /www/web/default/index.php
    echo 'Include conf/rpaf.conf' >> /www/wdlinux/apache/conf/httpd.conf
    #/etc/rc.d/init.d/php-fpm stop
    #chkconfig --level 35 php-fpm off
    #service httpd restart
    #service nginxd restart
    touch $na_inf
}

function libiconv_ins {
    IN_LOG=$LOGPATH/libiconv_install.log
    echo
    echo "installing libiconv..."
    cd $IN_SRC
    tar xf libiconv-1.14.tar.gz >$IN_LOG 2>&1
    cd libiconv-1.14
    ./configure --prefix=/usr >>$IN_lOG 2>&1
    [ $? != 0 ] && err_exit "libiconv configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "libiconv make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "libiconv make install err"
    ldconfig
}

function eaccelerator_ins {
    IN_LOG=$LOGPATH/eaccelerator_install.log
    [ -f $eac_inf ] && return
    [ $r6 == 1 ] && return
    [ $OS_RL = 2 -a $X86 = 1 ] && return
    echo
    echo "installing eaccelerator..."
    cd $IN_SRC
    tar xf eaccelerator-0.9.5.3.tar.bz2 >$IN_LOG 2>&1
    cd eaccelerator-0.9.5.3/
    make_clean
    $IN_DIR/php/bin/phpize >>$IN_LOG 2>&1
    ./configure --enable-eaccelerator=shared \
        --with-eaccelerator-shared-memory \
        --with-php-config=$IN_DIR/php/bin/php-config >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator make install err"
    mkdir $IN_DIR/eaccelerator_cache >$IN_LOG 2>&1
    EA_DIR="$IN_DIR/php/lib/php/extensions/no-debug-zts-20060613"
    ln -s $IN_DIR/php/lib/php/extensions/no-debug-zts-20060613 \
        $IN_DIR/php/lib/php/extensions/no-debug-non-zts-20060613
    echo '[eaccelerator]
extension_dir="'$EA_DIR'"
extension="/eaccelerator.so"
eaccelerator.shm_size="8"
eaccelerator.cache_dir="'$IN_DIR'/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"' >> $IN_DIR/etc/php.ini
    touch $eac_inf
}

function zend_ins {
    IN_LOG=$LOGPATH/zend_install.log
    echo
    [ -f $zend_inf ] && return
    echo "Zend installing..."
    cd $IN_SRC
    if [ $X86 == "1" ]; then
        tar xf zend_64.tar.gz -C $IN_DIR >$IN_LOG 2>&1
    else
        tar xf zend_32.tar.gz -C $IN_DIR >$IN_LOG 2>&1
    fi
    echo '[Zend]
zend_extension_manager.optimizer='$IN_DIR'/Zend/lib/Optimizer-3.3.3
zend_extension_manager.optimizer_ts='$IN_DIR'/Zend/lib/Optimizer_TS-3.3.3
zend_optimizer.version=3.3.3
zend_extension='$IN_DIR'/Zend/lib/ZendExtensionManager.so
zend_extension_ts='$IN_DIR'/Zend/lib/ZendExtensionManager_TS.so' >> $IN_DIR/etc/php.ini
    touch $zend_inf
}

function vsftpd_ins {
    IN_LOG=$LOGPATH/vsftpd_install.log
    echo
    echo "vsftpd installing..."
    cd $IN_SRC
    tar xf vsftpd-2.3.4.tar.gz >$IN_LOG 2>&1
    cd vsftpd-2.3.4
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "vsftpd make err"
    mkdir /usr/share/empty >>$IN_LOG 2>&1
    mkdir -p $IN_DIR/vsftpd >>$IN_LOG 2>&1
    install -m 755 vsftpd $IN_DIR/vsftpd/vsftpd >>$IN_LOG 2>&1
    install -m 644 vsftpd.8 /usr/share/man/man8 >>$IN_LOG 2>&1
    install -m 644 vsftpd.conf.5 /usr/share/man/man5 >>$IN_LOG 2>&1
    install -m 644 vsftpd.conf $IN_DIR/etc/vsftpd.conf >>$IN_LOG 2>&1
}

function pureftpd_ins {
    IN_LOG=$LOGPATH/pureftpd_install.log
    echo
    [ -f $pureftp_inf ] && return
    echo "prureftpd installing..."
    cd $IN_SRC
    tar xf pure-ftpd-$PUR_VER.tar.gz >$IN_LOG 2>&1
    cd pure-ftpd-$PUR_VER/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IN_DIR/mysql/lib/mysql
    cp -pR $IN_DIR/mysql/lib/mysql/* /usr/lib/
    if [ $X86 == 1 ]; then
        cp /usr/lib/libmysqlclient.so.16 /usr/lib64/
    fi
    ./configure --prefix=$IN_DIR/pureftpd-$PUR_VER \
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
        --with-language=simplified-chinese >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftp configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftpd make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftpd makeinstall err"
    ln -sf $IN_DIR/pureftpd-$PUR_VER $IN_DIR/pureftpd
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
    chmod 755 $IN_DIR/init.d/pureftpd
    #dbpw=`grep dbpw /www/wdlinux/wdcp/data/db.inc.php | awk -F"'" '{print $2}'`
    #sed -i 's/{passwd}/$dbpw/g' $IN_DIR/etc/pureftpd-mysql.conf
    ln -sf $IN_DIR/init.d/pureftpd /etc/init.d/pureftpd
    if [ $OS_RL == 2 ]; then
        update-rc.d pureftpd defaults >>$IN_lOG 2>&1
        update-rc.d pureftpd enable 235 >>$IN_lOG 2>&1
    else
        chkconfig --add pureftpd >>$IN_lOG 2>&1
        chkconfig --level 35 pureftpd on >>$IN_lOG 2>&1
    fi
    touch /var/log/pureftpd.log
    if [ $OS_RL == 2 ];then
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
    #service pureftpd start
    touch $pureftp_inf
}

function pcre_ins {
    IN_LOG=$LOGPATH/pcre_install.log
    echo
    echo "pcre installing..."
    cd $IN_SRC
    tar xf pcre-8.10.tar.gz >$IN_LOG 2>&1
    cd pcre-8.10
    ./configure --prefix=/usr >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre make install err"
}

function conf {
    [ -f $conf_inf ] && return
    cd $IN_PWD/conf
    #file_cp my.cnf $IN_DIR/etc/my.cnf
    #ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
    #file_cp vsftpd.conf $IN_DIR/etc/vsftpd.conf
    #file_cp vsftpd.denyuser $IN_DIR/etc/vsftpd.denyuser
    #file_cp vsftpd $IN_DIR/init.d
    #chmod 755 $IN_DIR/init.d/vsftpd
    #ln -sf $IN_DIR/init.d/vsftpd /etc/rc.d/init.d/vsftpd
    #ln -sf $IN_DIR/etc/vsftpd.conf /etc/vsftpd.conf
    #chkconfig --add vsftpd
    #chkconfig --level 35 vsftpd on
    file_cp vhost.sh /bin/
    mkdir -p /www/web/default
    if [ $IN_DIR_ME == 1 ]; then
        #sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/rc.d/init.d/vsftpd
        #sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/vsftpd.conf
        sed -i "s#/www/wdlinux#$IN_DIR#g" /bin/vhost.sh
    fi
    if [ $SERVER == "apache" ]; then
        file_cp phpinfo.php /www/web/default/phpinfo.php
        file_cp iProber2.php /www/web/default/iProber2.php
        file_cp wdlinux_a.php /www/web/default/index.php
        file_cp httpd-wdl.conf $IN_DIR/apache/conf/httpd-wdl.conf
        #file_cp wdcp_a.conf $IN_DIR/apache/conf/wdcp.conf
        file_cpv defaulta.conf $IN_DIR/apache/conf/vhost/00000.default.conf
        file_cp dz7_apache.conf $IN_DIR/apache/conf/rewrite/dz7_apache.conf
        file_cp dzx15_apache.conf $IN_DIR/apache/conf/rewrite/dzx15_apache.conf
        file_cp httpd $IN_DIR/init.d/httpd
        chmod 755 $IN_DIR/init.d/httpd
        ln -sf $IN_DIR/init.d/httpd /etc/init.d/httpd
        chkconfig --add httpd
        chkconfig --level 35 httpd on
        mkdir -p $IN_DIR/apache/conf/vhost
        if [ $IN_DIR_ME == 1 ];then
            sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/httpd
        fi
    else
        file_cp phpinfo.php /www/web/default/phpinfo.php
        file_cp iProber2.php /www/web/default/iProber2.php
        file_cp wdlinux_n.php /www/web/default/index.php
        file_cp fcgi.conf $IN_DIR/nginx/conf/fcgi.conf
        file_cp nginx.conf $IN_DIR/nginx/conf/nginx.conf
        #file_cp wdcp_n.conf $IN_DIR/nginx/conf/wdcp.conf
        file_cpv defaultn.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
        file_cp dz7_nginx.conf $IN_DIR/nginx/conf/rewrite/dz7_nginx.conf
        file_cp dzx15_nginx.conf $IN_DIR/nginx/conf/rewrite/dzx15_nginx.conf
        mkdir -p $IN_DIR/nginx/conf/vhost
        file_cp nginxd $IN_DIR/init.d/nginxd
        ln -sf $IN_DIR/php/sbin/php-fpm $IN_DIR/init.d/php-fpm
        chmod 755 $IN_DIR/init.d/nginxd
        chmod 755 $IN_DIR/init.d/php-fpm
        file_rm /etc/init.d/nginxd
        ln -sf $IN_DIR/init.d/nginxd /etc/init.d/nginxd
        ln -sf $IN_DIR/php/sbin/php-fpm /etc/init.d/php-fpm
        chkconfig --add nginxd
        chkconfig --level 35 nginxd on
        if [ $IN_DIR_ME == 1 ];then
            sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/nginxd
            sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/php-fpm
            sed -i "s#/www/wdlinux#$IN_DIR#g" $IN_DIR/nginx/conf/nginx.conf
        fi
    fi
    touch $conf_inf
}

function start_srv {
    [ -f $conf_inf ] && return
    echo
    echo "restart..."
    service mysqld restart
    if [ $SERVER == "nginx" ]; then
        service nginxd start
    elif [ $SERVER == "na" -o $SERVER_ID == 4 ]; then
        service httpd start
        service nginxd start
    else
        service httpd start
    fi
    service pureftpd start
    ###
    /sbin/iptables -I INPUT -p tcp -m tcp --dport 20000:20500 -m state --state NEW -j ACCEPT
    /sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    /sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
    if [ $OS_RL == 2 ]; then
        mkdir -p /etc/sysconfig
        iptables-save > /etc/sysconfig/iptables
    else
        service iptables save
    fi
}
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

function in_finsh {
    echo
    echo
    echo
    echo "      Congratulations ,lanmp install is complete"
    echo "      visit http://ip"
    echo "      more infomation please visit http://www.wdlinux.cn"
    echo
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
in_finsh
