## wdcp php install function
function wdphp_ins {
    PHP_VER=5.2.17
    local IN_LOG=$LOGPATH/${logpre}_php_install.log
    echo
    [ -f $wdphp_inf ] && return
    echo "installing wdcp php..."
    cd $IN_SRC
    rm -fr php-$PHP_VER
    tar xf php-$PHP_VER.tar.gz >$IN_LOG 2>&1
    cd php-$PHP_VER/
    ./configure \
        --prefix=/www/wdlinux/wdphp \
        --with-apxs2=/www/wdlinux/wdapache/bin/apxs \
        --with-mysql=/www/wdlinux/mysql \
        --with-curl --with-zlib --enable-ftp --with-gd \
        --enable-gd-native-ttf --enable-mbstring \
        --enable-zip --without-iconv >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdphp configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdphp make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdphp make install err"
    cp php.ini-dist /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/upload_max_filesize = 2/upload_max_filesize = 20/g' /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/post_max_size = 8/post_max_size = 20/g' /www/wdlinux/wdphp/lib/php.ini
    sed -i 's/display_errors = On/display_errors = Off/g' /www/wdlinux/wdphp/lib/php.ini
    if [[ $os_ARCH = x86_64 ]]; then
        mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
        file_cp php_wdcpm64.so \
            /www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613/php_wdcpm.so
        echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-non-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
    else
        mkdir -p /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
        file_cp php_wdcpm.so /www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613/php_wdcpm.so
        echo 'extension_dir=/www/wdlinux/wdphp/lib/php/extensions/no-debug-zts-20060613
extension=php_wdcpm.so' >> /www/wdlinux/wdphp/lib/php.ini
    fi
    touch $wdphp_inf
}

