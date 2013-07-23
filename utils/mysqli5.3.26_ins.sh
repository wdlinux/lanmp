#!/bin/bash
# mysqli install scripts
# Author:wdlinux
# Url http://www.wdlinux.cn

if [ ! -f /usr/bin/gcc ]; then
    yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel \
        gd-devel freetype-devel libxml2-devel libjpeg-devel \
        libpng-devel openssl-devel curl-devel patch \
        libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2
fi
    utils_pwd=`dirname $0`
if [ -d $utils_pwd/../lanmp/php-5.3.26/ext/mysqli ]; then
    cd $utils_pwd/../lanmp/php-5.3.26/ext/mysqli
else
    cd $utils_pwd/../lanmp
    wget -c http://tw2.php.net/distributions/php-5.3.26.tar.gz
    tar zxf php-5.3.26.tar.gz
    cd php-5.3.26/ext/mysqli
fi
/www/wdlinux/php/bin/phpize
./configure --with-php-config=/www/wdlinux/php/bin/php-config
#./configure --with-php-config=/www/wdlinux/php/bin/php-config --with-mysqli=/www/wdlinux/mysql/bin/mysql_config

make
[ $? != 0 ] && exit
make install

echo 
grep 'no-debug-non-zts-20090626' /www/wdlinux/etc/php.ini
if [ $? != 0 ]; then
    echo '' >> /www/wdlinux/etc/php.ini
    echo 'extension_dir=/www/wdlinux/apache_php-5.3.26/lib/php/extensions/no-debug-non-zts-20090626/' >>/www/wdlinux/etc/php.ini
fi
grep 'mysqli.so' /www/wdlinux/etc/php.ini
if [ $? != 0 ]; then
    echo '' >> /www/wdlinux/etc/php.ini
    echo 'extension=mysqli.so' >> /www/wdlinux/etc/php.ini
fi
if [ -d /www/wdlinux/apache ]; then
    service httpd restart
else
    service nginxd restart
fi
echo 
echo "mysqli install is OK"
echo
