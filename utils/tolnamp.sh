#!/bin/bash
#
# Web Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# 2010.04.08
# Last Updated 2010.05.27
# 

IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/lanmp
IN_LOG=${IN_SRC}/lanmp_install.log
IN_DIR="/www/wdlinux"
IN_DIR_ME=0
SERVER="apache"
RE_INS=1
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
nginx_inf="/tmp/nginx_ins.txt"
httpd_inf="/tmp/httpd_ins.txt"
pureftp_inf="/tmp/pureftp_ins.txt"
php_inf="/tmp/php_ins.txt"
na_inf="/tmp/na_ins.txt"
eac_inf="/tmp/eac_ins.txt"
zend_inf="/tmp/zend_ins.txt"
conf_inf="/tmp/conf_ins.txt"


if [ ! -d $IN_SRC ];then
        mkdir $IN_SRC
fi

###
	SERVER="na"

OS_RL=1
if grep -i 'ubuntu' /etc/issue;then
	OS_RL=2
fi

ping -c 1 -t 1 www.wdlinux.cn
if [[ $? == 2 ]];then
        echo "nameserver 8.8.8.8
nameserver 202.96.128.68" > /etc/resolv.conf
	echo "dns err"
	exit
fi

uname -a | grep "stab" >/dev/null 2>&1
if [ $? == 1 ];then
	httpd_m="--with-mpm=worker"
fi
if [ $OS_RL == 1 ];then
r6=0
grep "release 6" /etc/redhat-release
if [ $? == 0 ];then
	httpd_m=""
	r6=1
fi
fi
if [ `uname -m | grep "x86_64"` ];then
	X86=1
fi

###

if [ ! -d $IN_DIR ];then
        ###
	mkdir -p $IN_DIR
	mkdir -p $IN_DIR/etc
	mkdir -p $IN_DIR/init.d
	mkdir -p /www/web
	if [ $OS_RL == 2 ];then
        /etc/init.d/apparmor stop
        update-rc.d -f apparmor remove
        apt-get remove -y apparmor apparmor-utils
	sed -i 's/1000:1000/1010:1010/' /etc/passwd
	sed -i 's/:1000:/:1010:/' /etc/group
	else
	setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	service httpd stop
	service mysqld stop
	chkconfig --level 35 httpd off
	chkconfig --level 35 mysqld off
	chkconfig --level 35 sendmail off
	fi
	useradd -d /dev/null -s /sbin/nologin mysql > /dev/null 2>&1
	groupadd -g 1000 www
	useradd -g 1000 -u 1000 -d /dev/null -s /sbin/nologin www > /dev/null 2>&1
fi

cd $IN_SRC

if [ $IN_DIR != "/www/wdlinux" ];then
	IN_DIR_ME=1
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
function file_cpv {
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

# install function
function mysql_ins {
	echo
	if [ -f $mysql_inf ];then
		return
	fi
	echo "installing mysql..."
	cd $IN_SRC
	tar zxvf mysql-5.1.61.tar.gz > $IN_LOG 2>&1
	if [ $OS_RL == 2 ];then
        if [ -f /usr/lib/x86_64-linux-gnu/libncurses.so ];then
                #LIBNCU="/usr/lib/x86_64-linux-gnu/libncurses.so"
                LIBNCU=""
        elif [ -f /usr/lib/i386-linux-gnu/libncurses.so ];then
                #LIBNCU="/usr/lib/i386-linux-gnu/libncurses.so"
                LIBNCU=""
        else
                LIBNCU=""
        fi
	else
	if [ -f /usr/lib64/libncursesw.so ];then
		LIBNCU="--with-named-curses-libs=/usr/lib64/libncursesw.so"
	elif [ -f /usr/lib/libncursesw.so ];then
		LIBNCU="--with-named-curses-libs=/usr/lib/libncursesw.so"
	else	
		LIBNCU=""
	fi
	fi		
	cd mysql-5.1.61/
	make_clean
	./configure --prefix=$IN_DIR/mysql-5.1.61 --sysconfdir=$IN_DIR/etc --enable-assembler --enable-thread-safe-client --with-extra-charsets=complex --with-ssl --with-embedded-server $LIBNCU 
	[ $? != 0 ] && err_exit "mysql configure err"
	make
	[ $? != 0 ] && err_exit "mysql make err"
	make install 
	[ $? != 0 ] && err_exit "mysql make install err"
	ln -sf $IN_DIR/mysql-5.1.61 $IN_DIR/mysql
	if [ -f /etc/my.cnf ];then
		mv /etc/my.cnf /etc/my.cnf.old
	fi
	cp support-files/mysql.server $IN_DIR/init.d/mysqld
	file_cp my.cnf $IN_DIR/etc/my.cnf
	ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
	$IN_DIR/mysql/bin/mysql_install_db > $IN_LOG 2>&1
	chown -R mysql.mysql $IN_DIR/mysql/var
	chmod 755 $IN_DIR/init.d/mysqld
	ln -sf $IN_DIR/init.d/mysqld /etc/init.d/mysqld
	if [ $OS_RL == 2 ];then
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
	if [ -f $httpd_inf ];then
		ln -s /www/wdlinux/httpd-2.2.22 /www/wdlinux/apache
		return
	fi
	echo "installing httpd..."
	cd $IN_SRC
	tar zxvf httpd-2.2.22.tar.gz > $IN_LOG 2>&1
	cd httpd-2.2.22
	make_clean
	./configure --prefix=$IN_DIR/httpd-2.2.22 --enable-rewrite --enable-deflate --disable-userdir --enable-so --enable-expires --enable-headers
	[ $? != 0 ] && err_exit "apache configure err"
	make
	[ $? != 0 ] && err_exit "apache make err"
	make install
	[ $? != 0 ] && err_exit "apache make install err"
	ln -sf $IN_DIR/httpd-2.2.22 $IN_DIR/apache
	sed -i 's/User daemon/User www/g' $IN_DIR/apache/conf/httpd.conf
	sed -i 's/Group daemon/Group www/g' $IN_DIR/apache/conf/httpd.conf
	echo "NameVirtualHost *:80" >> $IN_DIR/apache/conf/httpd.conf
	echo "Include conf/httpd-wdl.conf" >> $IN_DIR/apache/conf/httpd.conf
	#echo "Include conf/default.conf" >> $IN_DIR/apache/conf/httpd.conf
	#echo "Include conf/wdcp.conf" >> $IN_DIR/apache/conf/httpd.conf
	echo "Include conf/vhost/*.conf" >> $IN_DIR/apache/conf/httpd.conf
	mkdir $IN_DIR/apache/conf/vhost
	mkdir $IN_DIR/apache/conf/rewrite
	chown -R wdcpu.wdcpg $IN_DIR/apache/conf/vhost
	chown -R wdcpu.wdcpg $IN_DIR/apache/conf/rewrite
	sed -i '/#ServerName/a\
ServerName localhost
' $IN_DIR/apache/conf/httpd.conf
	mkdir -p /www/web/default
	mkdir -p /www/web_logs
        file_cp phpinfo.php /www/web/default/phpinfo.php
        file_cp iProber2.php /www/web/default/iProber2.php
        file_cp wdlinux_a.php /www/web/default/index.php
	chown -R www.www /www/web
        file_cp httpd-wdl.conf $IN_DIR/apache/conf/httpd-wdl.conf
        #file_cp wdcp_a.conf $IN_DIR/apache/conf/wdcp.conf
        file_cpv defaulta.conf $IN_DIR/apache/conf/vhost/00000.default.conf
        file_cp dz7_apache.conf $IN_DIR/apache/conf/rewrite/dz7_apache.conf
        file_cp dzx15_apache.conf $IN_DIR/apache/conf/rewrite/dzx15_apache.conf
        if [ $OS_RL == 2 ];then
	file_cp init.httpd-ubuntu $IN_DIR/init.d/httpd
	else
	file_cp init.httpd $IN_DIR/init.d/httpd
	fi
        chmod 755 $IN_DIR/init.d/httpd
        ln -sf $IN_DIR/init.d/httpd /etc/init.d/httpd
	if [ $OS_RL == 2 ];then
	update-rc.d httpd defaults
        update-rc.d httpd enable 235
	else
        chkconfig --add httpd
        chkconfig --level 35 httpd on
	fi
        mkdir -p $IN_DIR/apache/conf/vhost
        if [ $IN_DIR_ME == 1 ];then
                sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/httpd
        fi
	touch $httpd_inf
}

function nginx_ins {
	if [ -f $nginx_inf ];then
		ln -s /www/wdlinux/nginx-1.0.15 /www/wdlinux/nginx
		return
	fi
	pcre_ins
	echo
	echo "installing nginx..."
	cd $IN_SRC
	tar zxvf nginx-1.0.15.tar.gz > $IN_LOG 2>&1
	cd nginx-1.0.15
	make_clean
	./configure --user=www --group=www --prefix=$IN_DIR/nginx-1.0.15 --with-http_stub_status_module --with-http_ssl_module
	[ $? != 0 ] && err_exit "nginx configure err"
	make
	[ $? != 0 ] && err_exit "nginx make err"
	make install
	[ $? != 0 ] && err_exit "nginx make install err"
	ln -sf $IN_DIR/nginx-1.0.15 $IN_DIR/nginx
	mkdir $IN_DIR/nginx/conf/vhost
	mkdir $IN_DIR/nginx/conf/rewrite
	mkdir -p /www/web/default
	mkdir -p /www/web_logs
	chown -R wdcpu.wdcpg $IN_DIR/nginx/conf/vhost
	chown -R wdcpu.wdcpg $IN_DIR/nginx/conf/rewrite
        file_cp phpinfo.php /www/web/default/phpinfo.php
        file_cp iProber2.php /www/web/default/iProber2.php
        file_cp wdlinux_n.php /www/web/default/index.php
	chown -R www.www /www/web
        file_cp fcgi.conf $IN_DIR/nginx/conf/fcgi.conf
        file_cp nginx.conf $IN_DIR/nginx/conf/nginx.conf
        #file_cp wdcp_n.conf $IN_DIR/nginx/conf/wdcp.conf
        file_cpv defaultn.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
        file_cp dz7_nginx.conf $IN_DIR/nginx/conf/rewrite/dz7_nginx.conf
        file_cp dzx15_nginx.conf $IN_DIR/nginx/conf/rewrite/dzx15_nginx.conf
        mkdir -p $IN_DIR/nginx/conf/vhost
	if [ $OS_RL == 2 ];then
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
	if [ $OS_RL == 2 ];then
	update-rc.d -f nginxd defaults
        update-rc.d -f nginxd enable 235
	else
        chkconfig --add nginxd
        chkconfig --level 35 nginxd on
	fi
        if [ $IN_DIR_ME == 1 ];then
                sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/nginxd
                sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/php-fpm
                sed -i "s#/www/wdlinux#$IN_DIR#g" $IN_DIR/nginx/conf/nginx.conf
        fi
	touch $nginx_inf
}

function php_ins {
	echo
	libiconv_ins
	echo
	echo "installing php..."
	if [ -d /www/wdlinux/apache_php-5.2.17 ];then
		return
	fi
	cd $IN_SRC
	tar zxvf php-5.2.17.tar.gz > $IN_LOG 2>&1
	if [ $OS_RL == 2 ];then
	if [ $X86 == 1 ];then
        ln -s /usr/lib/x86_64-linux-gnu/libssl.* /usr/lib/
	else
        ln -s /usr/lib/i386-linux-gnu/libssl.* /usr/lib/
	fi
        patch -d php-5.2.17 -p1 < debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
	fi
	NV=""
	[ $SERVER == "nginx" ] && NV="--enable-fastcgi --enable-fpm --with-fpm-conf=$IN_DIR/etc/php-fpm.conf" && gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -fd php-5.2.17 -p1 > $IN_LOG 2>&1
	[ $SERVER == "apache" -o $SERVER == "na" ] && NV="--with-apxs2=$IN_DIR/apache/bin/apxs"
	cd php-5.2.17/
	make clean >/dev/null 2>&1
	./configure --prefix=$IN_DIR/apache_php-5.2.17 --with-config-file-path=$IN_DIR/apache_php-5.2.17/etc --with-mysql=$IN_DIR/mysql --with-iconv=/usr --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt=/usr --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-ftp $NV
	[ $? != 0 ] && err_exit "php configure err"
	make
	[ $? != 0 ] && err_exit "php make err"
	make install
	[ $? != 0 ] && err_exit "php make install err"
	ln -sf $IN_DIR/apache_php-5.2.17 $IN_DIR/apache_php
	rm -f $IN_DIR/php
	ln -sf $IN_DIR/apache_php $IN_DIR/php
	cp php.ini-dist $IN_DIR/apache_php/etc/php.ini
	ln -sf IN_DIR/apache_php/etc/php.ini $IN_DIR/etc/php.ini
	if [ $SERVER == "nginx" ];then
        	ln -sf $IN_DIR/php/sbin/php-fpm $IN_DIR/init.d/php-fpm
	        chmod 755 $IN_DIR/init.d/php-fpm
	        ln -sf $IN_DIR/php/sbin/php-fpm /etc/init.d/php-fpm
		if [ $OS_RL == 2 ];then
		file_cp nginxd.fpm-ubuntu /www/wdlinux/init.d/nginxd
		else
		file_cp nginxd.fpm /www/wdlinux/init.d/nginxd
		fi
		chmod 755 /www/wdlinux/init.d/nginxd
		sed -i '/nobody/s#<!--##g' $IN_DIR/etc/php-fpm.conf
		sed -i '/nobody/s#-->##g' $IN_DIR/etc/php-fpm.conf
		sed -i 's/>nobody</>www</' $IN_DIR/etc/php-fpm.conf
	fi
	touch $php_inf
}

function na_ins {
	echo
	nginx_ins
	apache_ins
	sed -i 's/Listen 80/Listen 88/g' /www/wdlinux/apache/conf/httpd.conf
	sed -i 's/NameVirtualHost \*:80/NameVirtualHost \*:88/g' /www/wdlinux/apache/conf/httpd.conf
	sed -i 's/VirtualHost \*:80/VirtualHost \*:88/g' /www/wdlinux/apache/conf/vhost/00000.default.conf
	cd $IN_SRC
	tar -zxvf mod_rpaf-0.6.tar.gz
	cd mod_rpaf-0.6/
	#/www/wdlinux/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
	/www/wdlinux/apache/bin/apxs -i -c -a mod_rpaf-2.0.c
	file_cp rpaf.conf /www/wdlinux/apache/conf
	file_cp naproxy.conf /www/wdlinux/nginx/conf
	file_cpv defaultna.conf /www/wdlinux/nginx/conf/vhost/00000.default.conf
	file_cp wdlinux_na.php /www/web/default/index.php
	echo 'Include conf/rpaf.conf' >> /www/wdlinux/apache/conf/httpd.conf
        if [ $OS_RL == 2 ];then
        file_cp init.nginxd-ubuntu $IN_DIR/init.d/nginxd
        else
        file_cp init.nginxd $IN_DIR/init.d/nginxd
        fi
	chmod 755 $IN_DIR/init.d/nginxd
	#/etc/rc.d/init.d/php-fpm stop
	#chkconfig --level 35 php-fpm off
	service httpd restart
	service nginxd restart
	touch $na_inf
}

function libiconv_ins {
	echo
	echo "installing libiconv..."
	cd $IN_SRC
	tar zxvf libiconv-1.14.tar.gz
	cd libiconv-1.14
	./configure --prefix=/usr
	[ $? != 0 ] && err_exit "libiconv configure err"
	make
	[ $? != 0 ] && err_exit "libiconv make err"
	make install
	[ $? != 0 ] && err_exit "libiconv make install err"
	ldconfig
}

function eaccelerator_ins {
	if [ -f $eac_inf ];then
		return
	fi
	if [ $r6 == 1 ];then
		return
	fi
	echo
	echo "installing eaccelerator..."
	cd $IN_SRC
	tar jxvf eaccelerator-0.9.5.3.tar.bz2 > $IN_LOG 2>&1
	cd eaccelerator-0.9.5.3/
	make_clean
	$IN_DIR/php/bin/phpize > $IN_LOG 2>&1
	./configure --enable-eaccelerator=shared --with-eaccelerator-shared-memory --with-php-config=$IN_DIR/php/bin/php-config
	[ $? != 0 ] && err_exit "eaccelerator configure err"
	make
	[ $? != 0 ] && err_exit "eaccelerator make err"
	make install
	[ $? != 0 ] && err_exit "eaccelerator make install err"
	mkdir $IN_DIR/eaccelerator_cache > $IN_LOG 2>&1
	if [ $SERVER == "nginx" ];then
		EA_DIR="$IN_DIR/php/lib/php/extensions/no-debug-non-zts-20060613"
		ln -s $IN_DIR/php/lib/php/extensions/no-debug-non-zts-20060613 $IN_DIR/php/lib/php/extensions/no-debug-zts-20060613
	else
		EA_DIR="$IN_DIR/php/lib/php/extensions/no-debug-zts-20060613"
		ln -s $IN_DIR/php/lib/php/extensions/no-debug-zts-20060613 $IN_DIR/php/lib/php/extensions/no-debug-non-zts-20060613
	fi
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
	echo
	if [ -f $zend_inf ];then
		return
	fi
        echo "Zend installing..."
        cd $IN_SRC
	if [ $X86 == "1" ];then
		tar zxvf zend_64.tar.gz -C $IN_DIR > $IN_LOG 2>&1
	else
		tar zxvf zend_32.tar.gz -C $IN_DIR > $IN_LOG 2>&1
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
	echo
	echo "vsftpd installing..."
	cd $IN_SRC
	tar zxvf vsftpd-2.3.4.tar.gz > $IN_LOG 2>&1
	cd vsftpd-2.3.4
	make
	[ $? != 0 ] && err_exit "vsftpd make err"
	mkdir /usr/share/empty > $IN_LOG 2>&1
	mkdir -p $IN_DIR/vsftpd > $IN_LOG 2>&1
	install -m 755 vsftpd $IN_DIR/vsftpd/vsftpd
	install -m 644 vsftpd.8 /usr/share/man/man8
	install -m 644 vsftpd.conf.5 /usr/share/man/man5
	install -m 644 vsftpd.conf $IN_DIR/etc/vsftpd.conf
}

function pureftpd_ins {
	echo
	if [ -f $pureftp_inf ];then
		return
	fi
	echo "prureftpd installing..."
	cd $IN_SRC
	tar zxvf pure-ftpd-1.0.35.tar.gz
	cd pure-ftpd-1.0.35/
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IN_DIR/mysql/lib/mysql
	cp -pR $IN_DIR/mysql/lib/mysql/* /usr/lib/
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
        cp configuration-file/pure-config.py $IN_DIR/pureftpd/sbin/
        chmod 755 $IN_DIR/pureftpd/sbin/pure-config.py
	cd $IN_SRC
	file_cp pureftpd-mysql.conf $IN_DIR/etc
	file_cp pure-ftpd.conf $IN_DIR/etc
	if [ $OS_RL == 2 ];then
	file_cp init.pureftpd-ubuntu $IN_DIR/init.d/pureftpd
	else
	file_cp init.pureftpd $IN_DIR/init.d/pureftpd
	fi
	chmod 755 $IN_DIR/init.d/pureftpd
        #dbpw=`grep dbpw /www/wdlinux/wdcp/data/db.inc.php | awk -F"'" '{print $2}'`
        #sed -i 's/{passwd}/$dbpw/g' $IN_DIR/etc/pureftpd-mysql.conf
	ln -sf $IN_DIR/init.d/pureftpd /etc/init.d/pureftpd
	if [ $OS_RL == 2 ];then
        update-rc.d pureftpd defaults
        update-rc.d pureftpd enable 235
	else
	chkconfig --add pureftpd
	chkconfig --level 35 pureftpd on
	fi
	touch /var/log/pureftpd.log
	if [ $OS_RL == 2 ];then
        if [[ -f /etc/rsyslog.d/50-default.conf ]];then
                sed -i 's#mail,news.none#mail,news.none;ftp.none#g' /etc/rsyslog.d/50-default.conf
                echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/rsyslog.d/60-pureftpd.conf
                service rsyslog restart
        fi
	else
	if [[ -f /etc/syslog.conf ]];then
		sed -i 's/cron.none/cron.none;ftp.none/g' /etc/syslog.conf
		echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/syslog.conf
		/etc/init.d/syslog restart
	fi
	fi
	#service pureftpd start
	touch $pureftp_inf
}

function pcre_ins {
	echo
	echo "pcre installing..."
	cd $IN_SRC
	tar zxvf pcre-8.10.tar.gz > $IN_LOG 2>&1
	cd pcre-8.10
	./configure --prefix=/usr
	[ $? != 0 ] && err_exit "pcre configure err"
	make
	[ $? != 0 ] && err_exit "pcre make err"
	make install
	[ $? != 0 ] && err_exit "pcre make install err"
}

function conf {
	if [ -f $conf_inf ];then
		return
	fi
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
	if [ $IN_DIR_ME == 1 ];then
		#sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/rc.d/init.d/vsftpd
		#sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/vsftpd.conf
		sed -i "s#/www/wdlinux#$IN_DIR#g" /bin/vhost.sh
	fi
	if [ $SERVER == "apache" ];then
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
#function wdcp_ins {
#	cd $IN_SRC
#	rpm -ivh wdcp-1.1-1.noarch.rpm
#	[ $? != 0 ] && err_exit "wdcp install err"
#}

function start_srv {
	if [ -f $conf_inf ];then
		return
	fi
	echo
	echo "restart..."
	if [ $SERVER == "nginx" ];then
		service nginxd start
	elif [ $SERVER == "na" ];then
		service httpd start
		service nginxd start
	else
		service httpd start
	fi
	###
}

function in_finsh {
	echo
	echo
	echo
	echo "		configuration ,lamp or lnmp install is finshed"
	echo "		visit http://ip"
	echo "		more infomation please visit http://www.wdlinux.cn"
	echo
}

if [ $SOFT_DOWN == 1 ];then
	cd $IN_PWD
	if [ -f lanmp.tar.gz ];then
		tar zxvf lanmp.tar.gz 
	else
		wget -c http://dl.wdlinux.cn:5180/lanmp.tar.gz
		tar zxvf lanmp.tar.gz
	fi
fi
na_ins
php_ins	
eaccelerator_ins
zend_ins
start_srv
in_finsh
