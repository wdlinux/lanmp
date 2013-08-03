# pcre install function
function pcre_ins {
    local IN_LOG=$LOGPATH/${logpre}_pcre_install.log
    echo
    echo "pcre installing..."
    cd $IN_SRC
    rm -fr pcre-$PCRE_VER
    tar xf pcre-$PCRE_VER.tar.gz >$IN_LOG 2>&1
    cd pcre-$PCRE_VER
    ./configure --prefix=/usr >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "pcre make install err"
}

