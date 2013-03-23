#!/bin/bash
# Memcache install scripts
# Author:wdlinux
# Url http://www.wdlinux.cn

###
if [ ! -f /usr/bin/gcc ];then
        yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2
fi
yum install -y zlib-devel

###
cd /tmp
wget -c http://www.monkey.org/~provos/libevent-1.4.11-stable.tar.gz
wget -c http://memcached.googlecode.com/files/memcached-1.4.12.tar.gz
wget -c http://pecl.php.net/get/memcache-2.2.5.tgz
tar -zxvf libevent-1.4.11-stable.tar.gz
cd libevent-1.4.11-stable
./configure --prefix=/usr
make
[ $? != 0 ] && exit
make install
cd ..

tar zxvf memcached-1.4.12.tar.gz
cd memcached-1.4.12
./configure --prefix=/www/wdlinux/memcached --with-libevent=/usr
make
[ $? != 0 ] && exit
make install
cd ..

if grep -i 'ubuntu' /etc/issue;then
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
tar zxvf memcache-2.2.5.tgz
cd memcache-2.2.5
/www/wdlinux/php/bin/phpize
./configure --enable-memcache --with-php-config=/www/wdlinux/php/bin/php-config --with-zlib-dir
make
[ $? != 0 ] && exit
make install

grep 'memcache.so' /www/wdlinux/etc/php.ini
if [ $? != 0 ];then
echo '
[memcache]
extension_dir ="/www/wdlinux/php/lib/php/extensions/no-debug-zts-20060613/"
extension=memcache.so' >> /www/wdlinux/etc/php.ini
fi

if [ -d /www/wdlinux/apache ];then
	service httpd restart
else
	service nginxd restart
fi

echo
echo "memcache install is OK"
echo
