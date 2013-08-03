# libiconv install function
function libiconv_ins {
    local IN_LOG=$LOGPATH/${logpre}_libiconv_install.log
    echo
    [ -f $libiconv_inf ] && return
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
    touch $libiconv_inf
}

