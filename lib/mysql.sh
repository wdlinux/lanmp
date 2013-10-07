# mysql install function
function mysql_ins {
    local IN_LOG=$LOGPATH/${logpre}_mysql_install.log
    echo
    [ -f $mysql_inf ] && return
    echo "installing mysql,this may take a few minutes,hold on plz..."
    cd $IN_SRC
    rm -fr mysql-$MYS_VER/
    tar xf mysql-$MYS_VER.tar.gz >$IN_LOG 2>&1
    if is_debian_based; then
        if [ -f /usr/lib/x86_64-linux-gnu/libncurses.so ]; then
            #LIBNCU="/usr/lib/x86_64-linux-gnu/libncurses.so"
            LIBNCU=""
        elif [ -f /usr/lib/i386-linux-gnu/libncurses.so ]; then
            #LIBNCU="/usr/lib/i386-linux-gnu/libncurses.so"
            LIBNCU=""
        else
            LIBNCU=""
        fi
    else
        if [ -f /usr/lib64/libncursesw.so ]; then
            LIBNCU="--with-named-curses-libs=/usr/lib64/libncursesw.so"
        elif [ -f /usr/lib/libncursesw.so ]; then
            LIBNCU="--with-named-curses-libs=/usr/lib/libncursesw.so"
        else
            LIBNCU=""
        fi
    fi      
    cd mysql-$MYS_VER/
    make_clean
    echo "configure in progress ..."
    ./configure --prefix=$IN_DIR/mysql-$MYS_VER \
        --sysconfdir=$IN_DIR/etc \
        --enable-assembler \
        --enable-thread-safe-client \
        --with-extra-charsets=complex \
        --with-ssl \
        --with-embedded-server $LIBNCU >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "mysql configure err"
    echo "make in progress ..."
    make >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "mysql make err"
    echo "make install in progress ..."
    make install >>$IN_LOG 2>&1
    [ $? != 0 ] && err_exit "mysql make install err"
    ln -sf $IN_DIR/mysql-$MYS_VER $IN_DIR/mysql
    [ -f /etc/my.cnf ] && mv /etc/my.cnf /etc/my.cnf.old
    cp support-files/mysql.server $IN_DIR/init.d/mysqld
    file_cp my.cnf $IN_DIR/etc/my.cnf
    ln -sf $IN_DIR/etc/my.cnf /etc/my.cnf
    $IN_DIR/mysql/bin/mysql_install_db >>$IN_LOG 2>&1
    chown -R mysql.mysql $IN_DIR/mysql/var
    chmod 755 $IN_DIR/init.d/mysqld
    ln -sf $IN_DIR/init.d/mysqld /etc/init.d/mysqld
    enable_service mysqld >>$IN_LOG 2>&1
    ln -sf $IN_DIR/mysql/bin/mysql /bin/mysql
    mkdir -p /var/lib/mysql
    service mysqld start
    echo "PATH=\$PATH:$IN_DIR/mysql/bin" > /etc/profile.d/mysql.sh
    echo "$IN_DIR/mysql" > /etc/ld.so.conf.d/mysql-wdl.conf
    ldconfig >>$IN_LOG 2>&1
    $IN_DIR/mysql/bin/mysqladmin -u root password "wdlinux.cn"
    /www/wdlinux/mysql/bin/mysql -uroot -p"wdlinux.cn" -e \
        "use mysql;update user set password=password('wdlinux.cn') where user='root';
        delete from user where user='';
        DROP DATABASE test;
        drop user ''@'%';flush privileges;"
    ln -sf /tmp/mysql.sock /var/lib/mysql/
    touch $mysql_inf
}

