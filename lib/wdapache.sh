# wdcp apache install function
function wdapache_ins {
    local IN_LOG=$LOGPATH/${logpre}_apache_install.log
    echo
    [ -f $wdapache_inf ] && return
    echo "installing apache..."
    cd $IN_SRC
    tar xf httpd-$APA_VER.tar.gz >$IN_LOG 2>&1
    cd httpd-$APA_VER
    make_clean
    ./configure \
        --prefix=/www/wdlinux/wdapache \
        --disable-asis \
        --disable-status \
        --disable-userdir \
        --disable-status \
        --disable-cgid  \
        --disable-cgi \
        --disable-imap \
        --enable-rewrite \
        --enable-so >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdapache configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdapache make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "wdapache make install err"
    file_cp httpd.conf.wdapache /www/wdlinux/wdapache/conf/httpd.conf
    [ -d /www/wdlinux/init.d ] || mkdir -p /www/wdlinux/init.d
    if [ $OS_RL == 2 ]; then
        file_cp init.wdapache-ubuntu /www/wdlinux/init.d/wdapache
    else
        file_cp init.wdapache /www/wdlinux/init.d/wdapache
    fi
    chmod 755 /www/wdlinux/init.d/wdapache
    ln -s /www/wdlinux/init.d/wdapache /etc/init.d/wdapache
    if [ $OS_RL == 2 ]; then
        update-rc.d wdapache defaults
        update-rc.d wdapache enable 235
    else
        chkconfig --add wdapache
        chkconfig --level 35 wdapache on
    fi
    service wdapache start
    /sbin/iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
    if [ $OS_RL == 2 ]; then
        iptables-save > /etc/sysconfig/iptables
    else
        service iptables save
    fi
    touch $wdapache_inf
}
