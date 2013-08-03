# vsftpd install function
function vsftpd_ins {
    local IN_LOG=$LOGPATH/${logpre}_vsftpd_install.log
    echo
    echo "vsftpd installing..."
    cd $IN_SRC
    rm -fr vsftpd-2.3.4
    tar xf vsftpd-2.3.4.tar.gz >$IN_LOG 2>&1
    cd vsftpd-2.3.4
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "vsftpd make err"
    mkdir /usr/share/empty >>$IN_LOG 2>&1
    mkdir -p $IN_DIR/vsftpd >>$IN_LOG 2>&1
    install -m 755 vsftpd $IN_DIR/vsftpd/vsftpd >>$IN_LOG 2>&1
    install -m 644 vsftpd.8 /usr/share/man/man8 >>$IN_LOG 2>&1
    install -m 644 vsftpd.conf.5 /usr/share/man/man5 >>$IN_LOG 2>&1
    install -m 644 vsftpd.conf $IN_DIR/etc/vsftpd.conf >>$IN_LOG 2>&1
}

