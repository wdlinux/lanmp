# eaccelerator install function
function eaccelerator_ins {
    local IN_LOG=$LOGPATH/${logpre}_eaccelerator_install.log
    [ -f $eac_inf ] && return
    [[ $os_DISTRO = rhel6 ]] && return
    is_debian_based && return
    echo
    echo "installing eaccelerator..."
    cd $IN_SRC
    rm -fr eaccelerator-$EACCE_VER/
    tar xf eaccelerator-$EACCE_VER.tar.bz2 >$IN_LOG 2>&1
    cd eaccelerator-$EACCE_VER/
    make_clean
    $IN_DIR/php/bin/phpize >>$IN_LOG 2>&1
    ./configure --enable-eaccelerator=shared \
        --with-eaccelerator-shared-memory \
        --with-php-config=$IN_DIR/php/bin/php-config >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator configure err"
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator make err"
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "eaccelerator make install err"
    mkdir $IN_DIR/eaccelerator_cache >$IN_LOG 2>&1
    EA_DIR="$IN_DIR/php/lib/php/extensions/no-debug-zts-20060613"
    ln -s $IN_DIR/php/lib/php/extensions/no-debug-zts-20060613 \
        $IN_DIR/php/lib/php/extensions/no-debug-non-zts-20060613
    echo '[eaccelerator]
extension_dir="'$EA_DIR'"
extension="/eaccelerator.so"
eaccelerator.shm_size="8"
eaccelerator.cache_dir="'$IN_DIR'/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"' >> $IN_DIR/etc/php.ini
    touch $eac_inf
}

