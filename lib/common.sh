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

# Determine OS Vendor, Release and Update
# Returns results in global variables:
# os_VENDOR - vendor name
# os_RELEASE - release
# os_UPDATE - update
# os_PACKAGE - package type
# os_CODENAME - vendor's codename for release
# os_DISTRO - os distro name
# os_ARCH - arch type
function GetOSVersion() {
    # Figure out which vendor we are
    if [[ -x $(which lsb_release 2>/dev/null) ]]; then
        os_VENDOR=$(lsb_release -i -s)
        os_RELEASE=$(lsb_release -r -s)
        os_UPDATE=""
        os_PACKAGE="rpm"
        if [[ "Debian,Ubuntu" =~ $os_VENDOR ]]; then
            os_PACKAGE="deb"
        elif [[ $os_VENDOR =~ Red.*Hat ]]; then
            os_VENDOR="Red Hat"
        fi
        os_CODENAME=$(lsb_release -c -s)
    elif [[ -r /etc/redhat-release ]]; then
        # Red Hat Enterprise Linux Server release 5.5 (Tikanga)
        # CentOS release 5.5 (Final)
        # CentOS Linux release 6.0 (Final)
        os_CODENAME=""
        for r in "Red Hat" "CentOS"; do
            os_VENDOR=$r
            if [[ -n "`grep \"$r\" /etc/redhat-release`" ]]; then
                ver=`sed -e 's/^.* \(.*\) (\(.*\)).*$/\1\|\2/' /etc/redhat-release`
                os_CODENAME=${ver#*|}
                os_RELEASE=${ver%|*}
                os_UPDATE=${os_RELEASE##*.}
                os_RELEASE=${os_RELEASE%.*}
                break
            fi
            os_VENDOR=""
        done
        os_PACKAGE="rpm"
    # If lsb_release is not installed, we should be able to detect Debian OS
    elif [[ -f /etc/debian_version ]] && [[ $(cat /proc/version) =~ "Debian" ]]; then
        os_VENDOR="Debian"
        os_PACKAGE="deb"
        os_RELEASE=$(cat /etc/debian_version)
        if [[ $os_RELEASE =~ 6.* ]]; then
            os_CODENAME="squeeze"
        elif [[ $os_RELEASE =~ 7.* ]]; then
            os_CODENAME="wheezy"
        else
            os_RELEASE=$(awk '/VERSION_ID=/' /etc/os-release | sed 's/VERSION_ID=//' | sed 's/\"//g')
            os_CODENAME=$(awk '/VERSION=/' /etc/os-release | sed 's/VERSION=//' | sed -r 's/\"|\(|\)//g' | awk '{print $2}')
        fi
    fi
    # get os distro name
    if [[ "$os_VENDOR" =~ (Ubuntu) || "$os_VENDOR" =~ (Debian) ]]; then
        # 'Everyone' refers to Ubuntu / Debian releases by the code name adjective
        os_DISTRO=$os_CODENAME
    elif [[ "$os_VENDOR" =~ (Red Hat) || "$os_VENDOR" =~ (CentOS) ]]; then
        # Drop the . release as we assume it's compatible
        os_DISTRO="rhel${os_RELEASE::1}"
    else
        # Catch-all for now is Vendor + Release + Update
        os_DISTRO="$os_VENDOR-$os_RELEASE.$os_UPDATE"
    fi
    # get os arch type
    os_ARCH=$(uname -m)
    export os_VENDOR os_RELEASE os_UPDATE os_PACKAGE os_CODENAME os_DISTRO os_ARCH
}

