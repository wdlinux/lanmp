# zend install function
function zend_ins {
    local IN_LOG=$LOGPATH/${logpre}_zend_install.log
    if [[ -n $SERVER ]]; then
        local install_lock=/tmp/${SERVER}-php-zend_install.lock
    else
        local install_lock=/tmp/php-zend_install.lock
    fi
    echo
    [ -f $install_lock ] && return
    echo "Zend installing..."
    cd $IN_SRC
    if [[ $os_ARCH = x86_64 ]]; then
        tar xf zend_64.tar.gz -C $IN_DIR >$IN_LOG 2>&1
    else
        tar xf zend_32.tar.gz -C $IN_DIR >$IN_LOG 2>&1
    fi
    echo '[Zend]
zend_extension_manager.optimizer='$IN_DIR'/Zend/lib/Optimizer-3.3.3
zend_extension_manager.optimizer_ts='$IN_DIR'/Zend/lib/Optimizer_TS-3.3.3
zend_optimizer.version=3.3.3
zend_extension='$IN_DIR'/Zend/lib/ZendExtensionManager.so
zend_extension_ts='$IN_DIR'/Zend/lib/ZendExtensionManager_TS.so' >> $IN_DIR/etc/php.ini
    touch $install_lock
}

