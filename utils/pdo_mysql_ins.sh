#!/bin/bash
# PDO_mysql install scripts
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

if [ ! -f /usr/bin/gcc ]; then
    yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel \
        gd-devel freetype-devel libxml2-devel libjpeg-devel \
        libpng-devel openssl-devel curl-devel patch \
        libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2
fi

cd /tmp
wget -c http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
tar zxvf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2
/www/wdlinux/php/bin/phpize
./configure --with-php-config=/www/wdlinux/php/bin/php-config --with-pdo-mysql=/www/wdlinux/mysql
make
[ $? != 0 ] && exit
make install
echo 
grep -q "$ext_dir" /www/wdlinux/etc/php.ini
if [ $? != 0 ]; then
    echo '' >> /www/wdlinux/etc/php.ini
    echo "extension_dir=/www/wdlinux/php/lib/php/extensions/$ext_dir" >> /www/wdlinux/etc/php.ini
fi
grep -q 'pdo_mysql.so' /www/wdlinux/etc/php.ini
if [ $? != 0 ]; then
    echo '' >> /www/wdlinux/etc/php.ini
    echo 'extension=pdo_mysql.so' >> /www/wdlinux/etc/php.ini
fi
if [ -d /www/wdlinux/apache ]; then
    service httpd restart
else
    service nginxd restart
fi
echo 
echo "pdo_mysql install is OK"
echo
