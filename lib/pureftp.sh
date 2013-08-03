# pureftpd install function
function pureftpd_ins {
    local IN_LOG=$LOGPATH/${logpre}_pureftpd_install.log
    echo
    [ -f $pureftp_inf ] && return
    echo "pureftpd installing..."
    cd $IN_SRC
    rm -fr pure-ftpd-$PUR_VER/
    tar xf pure-ftpd-$PUR_VER.tar.gz >$IN_LOG 2>&1
    cd pure-ftpd-$PUR_VER/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IN_DIR/mysql/lib/mysql
    cp -pR $IN_DIR/mysql/lib/mysql/* /usr/lib/
    if [ $X86 == 1 ]; then
        cp /usr/lib/libmysqlclient.so.16 /usr/lib64/
    fi
    ./configure --prefix=$IN_DIR/pureftpd-$PUR_VER \
        --with-mysql=/www/wdlinux/mysql \
        --with-quotas \
        --with-cookie \
        --with-virtualhosts \
        --with-virtualchroot \
        --with-diraliases \
        --with-sysquotas \
        --with-ratios \
        --with-altlog \
        --with-paranoidmsg \
        --with-shadow \
        --with-welcomemsg  \
        --with-throttling \
        --with-uploadscript \
        --with-language=simplified-chinese >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftp configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftpd make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pureftpd makeinstall err"
    ln -sf $IN_DIR/pureftpd-$PUR_VER $IN_DIR/pureftpd
    ln -sf /www/wdlinux/pureftpd/sbin/pure-ftpd /usr/sbin/
    cp configuration-file/pure-config.pl $IN_DIR/pureftpd/sbin/
    chmod 755 $IN_DIR/pureftpd/sbin/pure-config.pl
    cp configuration-file/pure-config.py $IN_DIR/pureftpd/sbin/
    chmod 755 $IN_DIR/pureftpd/sbin/pure-config.py
    cd $IN_SRC
    file_cp pureftpd-mysql.conf $IN_DIR/etc
    file_cp pureftpd-mysql.conf $IN_DIR/wdcp_bk
    file_cp pure-ftpd.conf $IN_DIR/etc
    if [ $OS_RL == 2 ]; then
        file_cp init.pureftpd-ubuntu $IN_DIR/init.d/pureftpd
    else
        file_cp init.pureftpd $IN_DIR/init.d/pureftpd
    fi
    chmod 755 $IN_DIR/init.d/pureftpd
    #dbpw=`grep dbpw /www/wdlinux/wdcp/data/db.inc.php | awk -F"'" '{print $2}'`
    #sed -i 's/{passwd}/$dbpw/g' $IN_DIR/etc/pureftpd-mysql.conf
    ln -sf $IN_DIR/init.d/pureftpd /etc/init.d/pureftpd
    if [ $OS_RL == 2 ]; then
        update-rc.d pureftpd defaults >>$IN_LOG 2>&1
        update-rc.d pureftpd enable 235 >>$IN_LOG 2>&1
    else
        chkconfig --add pureftpd >>$IN_LOG 2>&1
        chkconfig --level 35 pureftpd on >>$IN_LOG 2>&1
    fi
    touch /var/log/pureftpd.log
    if [ $OS_RL == 2 ];then
        if [ -f /etc/rsyslog.d/50-default.conf ]; then
            sed -i 's#mail,news.none#mail,news.none;ftp.none#g' /etc/rsyslog.d/50-default.conf
            echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/rsyslog.d/60-pureftpd.conf
            service rsyslog restart
        fi
    else
        if [ -f /etc/syslog.conf ]; then
            sed -i 's/cron.none/cron.none;ftp.none/g' /etc/syslog.conf
            echo 'ftp.*        -/var/log/pureftpd.log' >> /etc/syslog.conf
            /etc/init.d/syslog restart
        fi
    fi
    #service pureftpd start
    touch $pureftp_inf
}

