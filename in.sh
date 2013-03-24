#!/bin/bash
###
if [ $UID != 0 ]; then
    echo "You must be root to run the install script."
    exit
fi

if [ $1 == "un" -o $1 == "uninstall" ]; then
    service httpd stop
    service nginxd stop
    service mysqld stop
    service pureftpd stop
    service wdapache stop
    mkdir /www/backup
    bf=$(date +%Y%m%d)
    tar zcvf /www/backup/mysqlbk_$bf.tar.gz /www/wdlinux/mysql/var
    rm -fr /www/wdlinux
    rm -f /tmp/*_ins.txt
    reboot
    exit
fi

chmod 755 lanmp.sh
chmod 755 wdcp_ins.sh
./lanmp.sh | tee lanmp_ins.log
./wdcp_ins.sh | tee wdcp_ins.log
