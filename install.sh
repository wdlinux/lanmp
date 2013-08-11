#!/bin/bash
###
SCREEN_NAME="lanmp"
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
    tar zcf /www/backup/mysqlbk_$bf.tar.gz /www/wdlinux/mysql/var
    rm -fr /www/wdlinux
    rm -f /tmp/*_ins.txt
    reboot
    exit
fi

if type -p screen >/dev/null && screen -ls |grep -q "[0-9].$SCREEN_NAME"; then
    echo "Seems another lanmp install session is taken place."
    echo "Rejoin this session plz type: 'screen -r $SCREEN_NAME'."
    exit 1
fi

if grep -qi 'debian\|ubuntu' /etc/issue; then
    type -p screen >/dev/null || apt-get -y install screen
else
    type -p screen >/dev/null || yum -y install screen
fi
chmod 755 lanmp.sh
chmod 755 wdcp.sh
# prepare screen session for install
if type -p screen >/dev/null; then
    screen -d -m -S $SCREEN_NAME -t lanmp -s /bin/bash
    sleep 1.5
    if [ -z "$SCREEN_HARDSTATUS" ]; then
        SCREEN_HARDSTATUS='%{= .} %-Lw%{= .}%> %n%f %t*%{= .}%+Lw%< %-=%{g}(%{d}%H/%l%{g})'
    fi
    screen -r $SCREEN_NAME -X hardstatus alwayslastline "$SCREEN_HARDSTATUS"
    NL=$(echo -ne '\015')
    screen -S $SCREEN_NAME -p lanmp -X stuff \
        "(./lanmp.sh|tee lanmp_ins.log);(./wdcp.sh|tee wdcp_ins.log)$NL"
    screen -r $SCREEN_NAME
else
    echo "Cannot find 'screen' command,install without screen(default yes)?"
    sleep 0.1
    read -p "(Yes/No): " i
    case $i in
        no|No|NO|n|N)
            echo "Please install 'screen' before install lanmp."
            echo "for ubuntu/debian: apt-get update && apt-get install screen"
            echo "for CentOS/RHEL: yum update && yum install screen"
            exit
            ;;
        *)
            ./lanmp.sh|tee lanmp_ins.log
            ./wdcp.sh|tee wdcp_ins.log
            ;;
    esac
fi
