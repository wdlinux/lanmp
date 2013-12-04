# Install basic packages
function install_basic_packages() {
    if is_debian_based; then
        apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
            libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
            libcurl4-openssl-dev libssl-dev patch libmcrypt-dev libmhash-dev \
            libncurses5-dev libreadline-dev bzip2 libcap-dev ntpdate \
            diffutils exim4 iptables unzip sudo
        if [[ $os_ARCH = x86_64 ]]; then
            ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
            ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
        else
            ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
            ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
        fi
    elif is_rhel_based; then
        rpm --import lanmp/RPM-GPG-KEY.dag.txt
        sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
        if [[ $os_DISTRO = rhel6 ]]; then
            el="el6"
            syslog=rsyslog
        else
            el="el5"
            syslog=sysklogd
        fi
        [ -f /etc/yum.repos.d/rpmforge.repo ] ||
            rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.$el.rf.$(uname -m).rpm --force
        yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
            freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel \
            curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
            libcap-devel ntp diffutils iptables unzip sendmail $syslog
        if [[ $os_ARCH = x86_64 ]]; then
            ln -sf /usr/lib64/libjpeg.so /usr/lib/
            ln -sf /usr/lib64/libpng.so /usr/lib/
        fi
    else
        err_exit "os not supported yet."
    fi
}
