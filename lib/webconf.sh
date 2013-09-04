# apache/nginx configure
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
    file_cp vhost.sh /bin/vhost.sh
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

