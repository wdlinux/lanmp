#!/bin/bash
# libiconv install scripts
# Author:wdlinux
# Url http://www.wdlinux.cn

if [ ! -f /usr/bin/gcc ]; then
        yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel \
        gd-devel freetype-devel libxml2-devel libjpeg-devel \
        libpng-devel openssl-devel curl-devel patch libmcrypt-devel \
        libmhash-devel ncurses-devel sudo bzip2
fi

cd /tmp
wget -c http://dl.wdlinux.cn:5180/soft/libiconv-1.14.tar.gz
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr
make
[ $? != 0 ] && exit
make install
ldconfig
echo
echo "install is OK"
