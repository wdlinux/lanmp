function make_clean {
    if [ $RE_INS == 1 ]; then
        make clean >/dev/null 2>&1
    fi
}

function wget_down {
    if [ $SOFT_DOWN == 1 ]; then
        echo "start down..."
        for i in $*; do
            [ $(wget -c $i) ] && exit
        done
    fi
}

function err_exit {
    echo 
    echo 
    echo "----Install Error: $1 -----------"
    echo
    echo
    exit
}

function error {
    echo "ERROR: $1"
    exit
}

function file_cp {
    [ -f $2 ] && mv $2 ${2}$(date +%Y%m%d%H)
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_cpv {
    cd $IN_PWD/conf
    [ -f $1 ] && cp -f $1 $2
}

function file_rm {
    [ -f $1 ] && rm -f $1
}

function file_bk {
    [ -f $1 ] && mv $1 ${1}_$(date +%Y%m%d%H)
}

function lanmp_in_finsh {
    echo
    echo
    echo
    echo "      Congratulations ,lanmp install is complete"
    echo "      visit http://ip"
    echo "      more infomation please visit http://www.wdlinux.cn"
    echo
}

function wdcp_in_finsh {
    echo
    echo
    echo
    echo "      configurations, wdcp install is complete"
    echo "      visit http://ip:8080"
    echo "      more infomation please visit http://www.wdlinux.cn"
    echo
}

