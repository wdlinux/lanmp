# apache install function
function apache_ins {
    local IN_LOG=$LOGPATH/${logpre}_apache_install.log
    echo
    [ -f $httpd_inf ] && return
    echo "installing httpd..."
    cd $IN_SRC
    tar xf httpd-$APA_VER.tar.gz >$IN_LOG 2>&1
    cd httpd-$APA_VER
    make_clean
    ./configure --prefix=$IN_DIR/httpd-$APA_VER \
        --enable-rewrite --enable-deflate \
        --disable-userdir --enable-so \
        --enable-expires --enable-headers \
        --with-included-apr --with-apr=/usr \
        --with-apr-util=/usr --enable-ssl \
        --with-ssl=/usr >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "apache make install err"
    ln -sf $IN_DIR/httpd-$APA_VER $IN_DIR/apache
    sed -i 's/User daemon/User www/g' $IN_DIR/apache/conf/httpd.conf
    sed -i 's/Group daemon/Group www/g' $IN_DIR/apache/conf/httpd.conf
    echo "NameVirtualHost *:80" >> $IN_DIR/apache/conf/httpd.conf
    echo "Include conf/httpd-wdl.conf" >> $IN_DIR/apache/conf/httpd.conf
    #echo "Include conf/default.conf" >> $IN_DIR/apache/conf/httpd.conf
    #echo "Include conf/wdcp.conf" >> $IN_DIR/apache/conf/httpd.conf
    echo "Include conf/vhost/*.conf" >> $IN_DIR/apache/conf/httpd.conf
    mkdir -p $IN_DIR/apache/conf/{vhost,rewrite}
    sed -i '/#ServerName/a\
ServerName localhost
' $IN_DIR/apache/conf/httpd.conf
    mkdir -p /www/{web/default,web_logs}    
    file_cp phpinfo.php /www/web/default/phpinfo.php
    file_cp iProber2.php /www/web/default/iProber2.php
    file_cp wdlinux_a.php /www/web/default/index.php
    chown -R www.www /www/web
    file_cp httpd-wdl.conf $IN_DIR/apache/conf/httpd-wdl.conf
    #file_cp wdcp_a.conf $IN_DIR/apache/conf/wdcp.conf
    file_cpv defaulta.conf $IN_DIR/apache/conf/vhost/00000.default.conf
    file_cp dz7_apache.conf $IN_DIR/apache/conf/rewrite/dz7_apache.conf
    file_cp dzx15_apache.conf $IN_DIR/apache/conf/rewrite/dzx15_apache.conf
    if [ $OS_RL == 2 ]; then
        file_cp init.httpd-ubuntu $IN_DIR/init.d/httpd
    else
        file_cp init.httpd $IN_DIR/init.d/httpd
    fi
    chmod 755 $IN_DIR/init.d/httpd
    ln -sf $IN_DIR/init.d/httpd /etc/init.d/httpd
    if [ $OS_RL == 2 ]; then
        update-rc.d httpd defaults >>$IN_LOG 2>&1
        update-rc.d httpd enable 235 >>$IN_LOG 2>&1
    else
        chkconfig --add httpd >>$IN_LOG 2>&1
        chkconfig --level 35 httpd on >>$IN_LOG 2>&1
    fi
    mkdir -p $IN_DIR/apache/conf/vhost
    [ $IN_DIR_ME == 1 ] && sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/httpd
    touch $httpd_inf
}

