#!/bin/bash
# Memcache install scripts
# Author:wdlinux
# Url http://www.wdlinux.cn

echo "Select php version:
    1 php-5.2.17 (default)
    2 php-5.3.27
"
sleep 0.1
read -p "Please Input 1,2: " PHP_VER_ID
if [[ $PHP_VER_ID == 2 ]]; then
    PHP_VER="5.3.27"
    ext_dir="no-debug-non-zts-20090626"
else
    PHP_VER="5.2.17"
    ext_dir="no-debug-zts-20060613"
fi
TOP=$(cd $(dirname $0)/.. && pwd)
###
if [ ! -f /usr/bin/gcc ]; then
    yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel \
        gd-devel freetype-devel libxml2-devel libjpeg-devel \
        libpng-devel openssl-devel curl-devel patch libmcrypt-devel \
        libmhash-devel ncurses-devel sudo bzip2
fi
yum install -y zlib-devel

###
cd /tmp
wget -c https://github.com/downloads/libevent/libevent/libevent-1.4.14b-stable.tar.gz
wget -c http://memcached.googlecode.com/files/memcached-1.4.15.tar.gz
wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
tar xf libevent-1.4.14b-stable.tar.gz
cd libevent-1.4.14b-stable
./configure --prefix=/usr
make
[ $? != 0 ] && exit
make install
cd ..

tar xf memcached-1.4.15.tar.gz
cd memcached-1.4.15
./configure --prefix=/www/wdlinux/memcached --with-libevent=/usr
make
[ $? != 0 ] && exit
make install
cd ..

if grep -qi 'debian\|ubuntu' /etc/issue; then
    wget http://www.wdlinux.cn/conf/init.d/init.memcached-ubuntu -O /www/wdlinux/init.d/memcached
    chmod 755 /www/wdlinux/init.d/memcached
    ln -s /www/wdlinux/init.d/memcached /etc/init.d/memcached
    update-rc.d -f memcached defaults
    update-rc.d -f memcached enable 235
else
    wget http://www.wdlinux.cn/conf/init.d/init.memcached -O /www/wdlinux/init.d/memcached
    chmod 755 /www/wdlinux/init.d/memcached
    ln -s /www/wdlinux/init.d/memcached /etc/init.d/memcached
    chkconfig --level 35 memcached on
fi
touch /www/wdlinux/etc/memcached.conf
service memcached start

###
tar zxvf memcache-2.2.7.tgz
cd memcache-2.2.7
/www/wdlinux/php/bin/phpize
./configure --enable-memcache --with-php-config=/www/wdlinux/php/bin/php-config --with-zlib-dir
make
[ $? != 0 ] && exit
make install

grep -q 'memcache.so' /www/wdlinux/etc/php.ini
if [ $? != 0 ]; then
    echo "
[memcache]
extension_dir ="/www/wdlinux/php/lib/php/extensions/$ext_dir"
extension=memcache.so" >> /www/wdlinux/etc/php.ini
fi

if [ -d /www/wdlinux/apache ]; then
    service httpd restart
else
    service nginxd restart
fi

echo
echo "memcache install is OK"
echo
