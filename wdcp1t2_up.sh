#!/bin/bash
#
# Wdcp Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Last Updated 2010.10.26
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

if [ ! -d $IN_SRC ];then
        mkdir $IN_SRC
fi
grep "release 6" /etc/redhat-release
R6=$?
if [ `uname -m | grep "x86_64"` ];then
	X86=1
fi
ping -c 1 -t 1 www.wdlinux.cn
if [[ $? == 2 ]];then
	#echo "nameserver 8.8.8.8" >> /etc/resolv.conf
	echo "dns err"
	exit
fi
###
rpm --import lanmp/RPM-GPG-KEY.dag.txt
if [ $X86 == 1 ];then
	rpm -ivh lanmp/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm

else
	rpm -ivh lanmp/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
fi

	yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 libcap-devel ntp sysklogd
	ntpdate tiger.sina.com.cn
	hwclock -w

	#useradd -d /dev/null -s /sbin/nologin mysql > /dev/null 2>&1
	userdel www
	groupdel www
	groupadd -g 1000 www
	useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www > /dev/null 2>&1
	chkconfig --level 35 sendmail off
####
#fi
if [ ! -d conf ];then
        wget -c http://down.wdlinux.cn/down/conf.tar.gz
        tar zxvf conf.tar.gz >/dev/null 2>&1
fi

cd $IN_SRC
if [ ! -f wdcp_v2.4.tar.gz ];then
wget -c http://dl.wdlinux.cn:5180/soft/httpd-2.0.64.tar.gz
wget -c http://dl.wdlinux.cn:5180/soft/pure-ftpd-1.0.35.tar.gz
wget -c http://dl.wdlinux.cn:5180/soft/php-5.2.17.tar.gz
wget -c http://down.wdlinux.cn/down/wdcp_v2.4.tar.gz
wget -c http://dl.wdlinux.cn:5180/soft/phpmyadmin.tar.gz
#wget -c http://down.wdlinux.cn/down/conf.tar.gz
#tar zxvf conf.tar.gz -C $IN_PWD
fi

function make_clean {
	if [ $RE_INS == 1 ];then
		make clean
	fi
}
function wget_down {
	if [ $SOFT_DOWN == 1 ];then
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

if [ $SERVER == "apache" ];then
	wget_down $HTTPD_DU
elif [ $SERVER == "nginx" ];then
	wget_down $NGINX_DU $PHP_FPM $PCRE_DU
fi
if [ $X86 == "1" ];then
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
	if [ -f $2 ];then
		mv $2 $2`date +%Y%m%d%H`
	fi
	cd $IN_PWD/conf
	if [ -f $1 ];then
		cp -f $1 $2
	fi
}
function file_rm {
	if [ -f $1 ];then
		rm -f $1
	fi
}
function file_bk {
	if [ -f $1 ];then
		mv $1 $1"_"`date +%Y%m%d%H`
	fi
}
if [[ ! -d /www/wdlinux/wdapache ]];then
	#setenforce 0
	#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	groupadd -g 999 wdcpg
	useradd -g 999 -u 999 -d /www/wdlinux/wdcp -s /sbin/nologin wdcpu
fi

# install function
function mysql_ins {
	echo
	if [ -d /www/wdlinux/mysql ];then
		return
	fi
	echo "installing mysql..."
	cd $IN_SRC
	tar zxvf mysql-5.1.56.tar.gz > $IN_LOG 2>&1
	#if [ $X86 == 1 ];then
	if [ -f /usr/lib64/libncursesw.so ];then
		LIBNCU="/usr/lib64/libncursesw.so"
	else
		LIBNCU="/usr/lib/libncursesw.so"
	fi		
	cd mysql-5.1.56/
	make_clean
	./configure \
		--prefix=$IN_DIR/mysql-5.1.56 \
		--sysconfdir=$IN_DIR/etc \
		--enable-assembler \
		--enable-thread-safe-client \
		--with-extra-charsets=complex \
		--with-ssl \
		--with-embedded-server \
		--with-plugins=innobase \
		--with-named-curses-libs=$LIBNCU 
	[ $? != 0 ] && err_exit "mysql configure err"
	make
	[ $? != 0 ] && err_exit "mysql make err"
	make install 
	[ $? != 0 ] && err_exit "mysql make install err"
	ln -sf $IN_DIR/mysql-5.1.56 $IN_DIR/mysql
	if [ -f /etc/my.cnf ];then
		mv /etc/my.cnf /etc/my.cnf.old
	fi
	cp support-files/mysql.server $IN_DIR/init.d/mysqld
	file_cp my.cnf $IN_DIR/etc/my.cnf
	ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
	$IN_DIR/mysql/bin/mysql_install_db > $IN_LOG 2>&1
	chown -R mysql.mysql $IN_DIR/mysql/var
	chmod 755 $IN_DIR/init.d/mysqld
	ln -sf $IN_DIR/init.d/mysqld /etc/rc.d/init.d/mysqld
	chkconfig --add mysqld
	chkconfig --level 35 mysqld on
	service mysqld start
	echo "PATH=\$PATH:$IN_DIR/mysql/bin" > /etc/profile.d/mysql.sh
	echo "$IN_DIR/mysql" > /etc/ld.so.conf.d/mysql-wdl.conf
	$IN_DIR/mysql/bin/mysqladmin -u root password "wdlinux.cn"
	ln -s $IN_DIR/mysql/bin/mysql /bin/mysql
        mkdir /var/lib/mysql
        ln -sf /tmp/mysql.sock /var/lib/mysql/
}


function apache_ins {
	echo
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
	if [ ! -d /www/wdlinux/init.d ];then
		mkdir -p /www/wdlinux/init.d
	fi
	file_cp init.wdapache /www/wdlinux/init.d/wdapache
	chmod 755 /www/wdlinux/init.d/wdapache
	ln -s /www/wdlinux/init.d/wdapache /etc/rc.d/init.d/wdapache
	chkconfig --add wdapache
	chkconfig --level 35 wdapache on
	#service wdapache start
	#/sbin/iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
	#/etc/rc.d/init.d/iptables save

}

function php_ins {
	echo
	echo "installing php..."
	cd $IN_SRC
	tar zxvf php-5.2.17.tar.gz > $IN_LOG 2>&1
	cd php-5.2.17/
	make clean > /dev/null 2>&1
	./configure \
		--prefix=/www/wdlinux/wdphp \
		--with-apxs2=/www/wdlinux/wdapache/bin/apxs \
		--with-mysql=/www/wdlinux/mysql \
		--with-curl --enable-ftp --with-gd --enable-gd-native-ttf --enable-mbstring --enable-zip
	[ $? != 0 ] && err_exit "wdphp configure err"
	make 
	[ $? != 0 ] && err_exit "wdphp make err"
	make install
	[ $? != 0 ] && err_exit "wdphp make install err"
	cp php.ini-dist /www/wdlinux/wdphp/lib/php.ini
	sed -i 's/upload_max_filesize = 2/upload_max_filesize = 20/g' /www/wdlinux/wdphp/lib/php.ini
	sed -i 's/post_max_size = 8/post_max_size = 20/g' /www/wdlinux/wdphp/lib/php.ini
	sed -i 's/display_errors = On/display_errors = Off/g' /www/wdlinux/wdphp/lib/php.ini
	if [ $X86 == 1 ];then
		mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
		file_cp php_wdcpm64.so /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613/php_wdcpm.so
		echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
	else
		mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
		file_cp php_wdcpm.so /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613/
		echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
	fi
}

function pureftpd_ins {
	echo
	if [ -d /www/wdlinux/pureftpd ];then
		return
	fi
	echo "prureftpd installing..."
	cd $IN_SRC
	tar zxvf pure-ftpd-1.0.35.tar.gz
	cd pure-ftpd-1.0.35/
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IN_DIR/mysql/lib/mysql
	cp -pR /www/wdlinux/mysql/lib/mysql/* /usr/lib/
	if [ $X86 == 1 ];then
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
	cd $IN_SRC
	file_cp pureftpd-mysql.conf $IN_DIR/etc
	file_cp pure-ftpd.conf $IN_DIR/etc
	file_cp init.pureftpd $IN_DIR/init.d/pureftpd
	chmod 755 $IN_DIR/init.d/pureftpd
	ln -sf $IN_DIR/init.d/pureftpd /etc/rc.d/init.d/pureftpd
	chkconfig --add pureftpd
	chkconfig --level 35 pureftpd on
	chkconfig --level 35 vsftpd off
	service vsftpd stop
	touch /var/log/pureftpd.log
	if [[ -f /etc/syslog.conf ]];then
		sed -i 's/cron.none/cron.none;ftp.none/g' /etc/syslog.conf
		echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/syslog.conf
		/etc/rc.d/init.d/syslog restart
	fi
	#service pureftpd start
}

function wdcp_ins {
        cd $IN_SRC
        tar zxvf wdcp_v2.4.tar.gz -C / >/dev/null 2>&1
        [ $? != 0 ] && err_exit "wdcp install err"
        tar zxvf phpmyadmin.tar.gz -C /www/wdlinux/wdcp >/dev/null 2>&1
        file_cp dz7_apache.conf /www/wdlinux/wdcp/data/rewrite/dz7_apache.conf
        file_cp dzx15_apache.conf /www/wdlinux/wdcp/data/rewrite/dzx15_apache.conf
        file_cp dz7_nginx.conf /www/wdlinux/wdcp/data/rewrite/dz7_nginx.conf
        file_cp dzx15_nginx.conf /www/wdlinux/wdcp/data/rewrite/dzx15_nginx.conf
	cp /www/web/wdcp/data/db.inc.php /www/wdlinux/wdcp/data
	cp /www/web/wdcp/data/dbr.inc.php /www/wdlinux/wdcp/data
	chown -R wdcpu.wdcpg /www/wdlinux/wdcp/data
	if [[ ! -d /www/backup ]];then
		mkdir -p /www/backup
	fi
	tar zcvf /www/backup/mysql_1to2.tar.gz /www/wdlinux/mysql/var/wdcpdb
	tar zcvf /www/backup/web_conf_1to2.tar.gz /www/wdlinux/nginx/conf /www/wdlinux/apache/conf
	dbpw=`grep dbpw /www/wdlinux/wdcp/data/db.inc.php | awk -F"'" '{print $2}'` > /dev/null 2>&1
	/www/wdlinux/mysql/bin/mysql -uwdcp -p"$dbpw" wdcpdb < /www/wdlinux/wdcp/wdcpdb.sql
	sed -i "s/{passwd}/$dbpw/g" $IN_DIR/etc/pureftpd-mysql.conf
	/www/wdlinux/wdphp/bin/php /www/wdlinux/wdcp/wdcp1to2.php
	/www/wdlinux/wdphp/bin/php /www/wdlinux/wdcp/wdcp21_up.php
	chown -R www.www /www/web
	chown -R www.www /home
	service nginxd restart
	service httpd restart
	service wdapache restart
	service pureftpd restart
}

function in_finsh {
	echo
	echo
	echo
	echo "		configuration ,wdcp update is finshed"
	echo "		visit http://ip:8080"
	echo "		more infomation please visit http://www.wdlinux.cn"
	echo
}


#mysql_ins
apache_ins
php_ins	
pureftpd_ins
wdcp_ins
in_finsh
