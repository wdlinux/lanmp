# wdcp install function
function wdcp_ins {
    [ -f $wdcp_inf ] && return
    cd $IN_SRC
    tar xf wdcp_$WDCP_VER.tar.gz -C /
    [ $? != 0 ] && err_exit "wdcp install err"
    tar xf phpmyadmin.tar.gz -C /www/wdlinux/wdcp
    file_cp dz7_apache.conf /www/wdlinux/wdcp/data/rewrite/dz7_apache.conf
    file_cp dzx15_apache.conf /www/wdlinux/wdcp/data/rewrite/dzx15_apache.conf
    file_cp dz7_nginx.conf /www/wdlinux/wdcp/data/rewrite/dz7_nginx.conf
    file_cp dzx15_nginx.conf /www/wdlinux/wdcp/data/rewrite/dzx15_nginx.conf
    chown wdcpu.wdcpg $IN_DIR/*php*/etc/php.ini
    ####
    sqlrootpwd="wdlinux.cn"
    mysql="/www/wdlinux/mysql/bin/mysql"
    wdpwd=$(expr substr "$(echo $RANDOM | md5sum)" 1 8)
    $mysql -uroot -p"$sqlrootpwd" -e "CREATE database wdcpdb DEFAULT CHARACTER SET GBK;"
    $mysql -uroot -p"$sqlrootpwd" -e "grant SELECT, INSERT, UPDATE, DELETE, CREATE,DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, CREATE VIEW, SHOW VIEW on wdcpdb.* to 'wdcp'@'localhost' identified by '$wdpwd';"
    $mysql -uroot -p"$sqlrootpwd" wdcpdb < /www/wdlinux/wdcp/wdcpdb.sql
    [ -f /www/wdlinux/wdcp/data/db.inc.php ] ||
        echo "<?
\$dbhost = 'localhost';
\$dbuser = 'wdcp';
\$dbpw = '$wdpwd';
\$dbname = 'wdcpdb';
\$pconnect = 0;
\$dbcharset = 'gbk';
?>" > /www/wdlinux/wdcp/data/db.inc.php
    [ -f /www/wdlinux/wdcp/data/dbr.inc.php ] ||
        echo "<?
\$sqlrootpw='$sqlrootpwd';
\$sqlrootpw_en='0';
?>" > /www/wdlinux/wdcp/data/dbr.inc.php
    sed -i "s/{passwd}/$wdpwd/g" $IN_DIR/etc/pureftpd-mysql.conf
    chown -R wdcpu.wdcpg /www/wdlinux/wdcp/data
    chmod 600 /www/wdlinux/wdcp/data/db.inc.php
    chmod 600 /www/wdlinux/wdcp/data/dbr.inc.php
    /www/wdlinux/wdphp/bin/php /www/wdlinux/wdcp/task/wdcp_perm_check.php
    service wdapache restart
    service pureftpd restart
    touch $wdcp_inf
}

