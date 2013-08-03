#!/bin/bash
###
SCREEN_NAME="lanmp"
# screen_it service "command-line"
function screen_it {
    screen -S $SCREEN_NAME -X screen -t $1
    sleep 1.5
    screen -S $SCREEN_NAME -p $1 -X stuff "$2"
}
if [ $UID != 0 ]; then
    echo "You must be root to run the install script."
    exit
fi

if [ "$1" == "un" -o "$1" == "uninstall" ]; then
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
if type -p screen >/dev/null && screen -ls |grep -q "[0-9].$SCREEN_NAME"; then
    echo "To rejoin this session type 'screen -x $SCREEN_NAME'."
    echo "To destroy this session, type './lanmp.sh un'."
    exit 1
fi
if grep -qi ubuntu /etc/issue; then
    type -p screen >/dev/null || apt-get -y install screen
else
    type -p screen >/dev/null || yum -y install screen
fi
screen -d -m -S $SCREEN_NAME -t lanmpins -s /bin/bash
sleep 1.5
chmod 755 lanmp.sh
chmod 755 wdcp.sh
#./lanmp.sh | tee lanmp_ins.log
#./wdcp.sh | tee wdcp_ins.log
screen_it lanmpins "(./lanmp.sh|tee lanmp_ins.log);(./wdcp.sh|tee wdcp_ins.log)"
echo "enter screen session"
screen -r $SCREEN_NAME
