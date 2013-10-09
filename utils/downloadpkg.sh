#!/bin/bash
. lib/common.conf
cd lanmp
for s in "$HTTPD_DU $NGINX_DU $TENGINE_DU $MYSQL_DU $PHP_DU $PHP53_DU $PUREFTP_DU $EACCELERATOR_DU $PHP_FPM_DU $PCRE_DU $LIBICONV_DU"; do
    wget -nc $s
done
