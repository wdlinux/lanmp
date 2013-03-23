#!/bin/bash
# mysql innodb install scripts
# Author:wdlinux
# Url http://www.wdlinux.cn

if [ ! -f /usr/bin/gcc ];then
        yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2
fi

if [ -d /root/lanmp/mysql-5.1.63 ];then
	cd /root/lanmp/mysql-5.1.63
	make clean
elif [ -f /root/lanmp/mysql-5.1.63.tar.gz ];then
	cd /root/lanmp
	tar zxvf mysql-5.1.63.tar.gz
	cd mysql-5.1.63
else
	cd /tmp
	wget -c http://dl.wdlinux.cn:5180/soft/mysql-5.1.63.tar.gz
	tar zxvf mysql-5.1.63.tar.gz
	cd mysql-5.1.63
fi
if grep -i 'ubuntu' /etc/issue;then
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
IN_DIR="/www/wdlinux"
./configure \
        --prefix=$IN_DIR/mysql-5.1.63 \
        --sysconfdir=$IN_DIR/etc \
        --enable-assembler \
        --enable-thread-safe-client \
        --with-extra-charsets=complex \
        --with-ssl \
        --with-embedded-server \
        --with-plugins=innobase,innodb_plugin
make
[ $? != 0 ] && exit
service mysqld stop
make install
cp /www/wdlinux/etc/my.cnf /www/wdlinux/etc/my.cnf.old
cp -f support-files/my-medium.cnf /www/wdlinux/etc/my.cnf
service mysqld start
echo 
echo "mysql innodb install is OK"
echo
