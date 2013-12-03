# libiconv install function
function libiconv_ins {
    local IN_LOG=$LOGPATH/${logpre}_libiconv_install.log
    local install_lock=/tmp/libiconv_install.lock
    echo
    [ -f $install_lock ] && return
    echo "installing libiconv..."
    cd $IN_SRC
    rm -fr libiconv-$LIBICONV_VER
    tar xf libiconv-$LIBICONV_VER.tar.gz >$IN_LOG 2>&1
    cd libiconv-$LIBICONV_VER
    ./configure --prefix=/usr >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "libiconv configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "libiconv make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "libiconv make install err"
    ldconfig
    touch $install_lock
}

