#!/bin/bash
#
# Web Server Install Script
# Created by wdlinux QQ:12571192
# Url:http://www.wdlinux.cn
# Last Updated 2010.11.19
# 


PS_SERVER=`ps ax | grep nginx.conf | grep -v "grep"`
if [[ $PS_SERVER ]];then
	SERVER="nginx"
else
	SERVER="apache"
fi

conf_dir="/www/wdlinux/$SERVER/conf/vhost"
log_dir="/www/wdlinux/$SERVER/logs"
web_dir="/www/web"

function dis_info {
	clear
	echo 
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Add Virtual Host for wdlinux or lanmp,Written by wdlinux"
	echo "---------------------------------------------------------------"
	echo "Wdlinux is a customized version of CentOS based, for quick, easy to install web server system"
	echo "lanmp is a tool to auto-compile & install lamp or lnmp on linux"
	echo "This script is a tool add virtual host for wdlinux"
	echo "For more information please visit http://www.wdlinux.cn"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo
	echo "The server is running $SERVER"
	echo "----------------------------------------------------------------"
	echo
}
dis_info;

echo "Pleast input domain:"
read -p "(Default or Example domain:www.wdlinux.cn):" domain
if [[ $domain == "" ]];then
	domain="www.wdlinux.cn"
fi
echo 
echo "domain:$domain"
echo "-----------------------------------------"
echo
sdomain=${domain#www.}
if [[ -f "$conf_dir/$domain.conf" ]];then
	echo "$conf_dir/$domain.conf is exists!"
	exit
fi

echo "Do you want to add more domain name? (y/n)"
read more_domain
if [[ $more_domain == "y" || $more_domain == "Y" ]];then
	echo "Input domain name,example(bbs.wdlinux.cn blog.wdlinux.cn):"
	read domain_a
	domain_alias=${sdomain}" "${domain_a}
else
	domain_alias=$sdomain;
fi
echo
echo "domain alias:$domain_alias"
echo "-----------------------------------------"
echo

echo "Allow access_log? (y/n)"
read access_log
if [[ $access_log == "y" || $access_log == "Y" ]];then
	nginx_log="log_format  $domain  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
               '\$status \$body_bytes_sent \"\$http_referer\" '
               '\"\$http_user_agent\" \$http_x_forwarded_for';
	    access_log  logs/$domain.log  $domain;"
	apache_log="    ErrorLog \"logs/$domain-error_log\"
    CustomLog \"logs/$domain-access_log\" common"
	echo
	echo "access_log dir:"$log_dir/$domain.log
	echo "------------------------------------------"
	echo
else
	nginx_log="access_log off;"
	apache_log=""
fi

echo "Do you want to add ftp Account? (y/n)"
read ftp_account
if [[ $ftp_account == "y" || $ftp_account == "Y" ]];then
	read -p "ftp user name:" ftp_user
	read -p "ftp user password:" ftp_pass
	useradd -d $web_dir/$domain -s /sbin/nologin $ftp_user
	echo "$ftp_pass" | passwd --stdin $ftp_user
	chmod 755 $web_dir/$domain
	echo
else
	echo "Create virtual host directory."
	mkdir -p $web_dir/$domain
	chown -R www.www $web_dir/$domain
fi

if [[ $SERVER == "nginx" ]];then
cat > $conf_dir/$domain.conf<<eof
server {
        listen       80;
        server_name $domain $domain_alias;
        root $web_dir/$domain;
        index  index.html index.php index.htm wdlinux.html;

        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            include fcgi.conf;
        }
        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
                expires      1d;
        }

        location ~ .*\.(js|css)?$ {
                expires      12h;
        }
	$nginx_log
    }
eof
else
cat > $conf_dir/$domain.conf<<eof
<VirtualHost *:80>
    DocumentRoot "$web_dir/$domain"
    ServerName $domain
    ServerAlias $domain_alias
$apache_log
</VirtualHost>
eof
fi

cat > $web_dir/$domain/index.html<<eof
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>test page</title>
</head>

<body>
<div align="center">
  <h1>test page of $domain  </h1>
  <p>Create by vhost.sh of <a href="http://www.wdlinux.cn" target="_blank">www.wdlinux.cn</a> </p>
</div>
</body>
</html>
eof
if [[ $ftp_account == "y" || $ftp_account == "Y" ]];then
	chown $ftp_user $web_dir/$domain/index.html
fi

if [[ $SERVER == "nginx" ]];then
	service nginxd restart
else
	service httpd restart
fi

echo
echo
echo
echo "web site infomations:"
echo "========================================"
echo "domain list:$domain $domain_alias"
echo "----------------------------------------"
echo "website dir:$web_dir/$domain"
echo "----------------------------------------"
echo "conf file:$conf_dir/$domain.conf"
echo "----------------------------------------"
if [[ $access_log == "y" || $access_log == "Y" ]];then
	echo "access_log:$log_dir/$domain.log"
	echo "----------------------------------------"
fi
if [[ $ftp_account == "y" || $access_log == "Y" ]];then
	echo "ftp user:$ftp_user password:$ftp_pass";
	echo "----------------------------------------"
fi
echo "web site is OK"
echo "For more information please visit http://www.wdlinux.cn"
echo "========================================"
