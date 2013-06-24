#!/bin/bash
. lib/common.conf
cd lanmp
for s in "$HTTPD_DU $NGINX_DU $MYSQL_DU $PHP53_DU $PUREFTP_DU"; do
    wget -nc $s
done
