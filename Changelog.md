2013-08-11
----------

1 升级php至5.3系列最后一个常规版本5.3.27

2 增强对debian系统的支持，修复在debian下安装可能出现的错误

2013-08-03
----------

1 安装时默认采用screen进行会话管理，远程断线不影响安装进度

2 修正CentOS6安装repoforge源版本错误的问题

3 修正ubuntu/debian安装基础软件包时可能存在无法安装完成的bug

4 执行安装前对安装环境进行强制清理，避免由于环境原因导致安装失败

2013-07-04
----------

1 更新php安装脚本，默认安装常用的mysqli、pdo-mysql、bcmath、exif拓展

2 更新pureftp启动控制脚本，修正status状态检测选项无法正常工作的bug

2013-06-14
----------

1 增加对php5.3的支持,安装时可自由选择php5.2或者php5.3版本

2 增强对ubuntu系统的支持,修正在ubuntu系统下安装可能出现无法添加系统账号的bug

3 nginx升级至1.2.9,apache升级至2.2.24,mysql升级至5.1.69,pureftp升级至1.0.36

4 安装脚本大量调整和优化

2012-06-25
----------

1 增加lamp,lnmp,lnamp可自由切换

2 增加升级脚本

3 增加RPM包快速安装

2012-05-28
----------

1 增加ubuntu系统的支持,测试版本为12.04

2 增加安装环境切换,可切换到lamp,lnmp,lnamp等

2012-03-10
----------

1 增加安装检测，避免安装中断重复安装

2 去掉mysql innodb的默认安装，需要用到innodb时，在安装目录下执行sh mysql_innodb_ins.sh即可

3 调整memcached安装脚本及安装完后启动并随系统自启动

4 更换探针程序

5 修正lamp,lnmp默认站点设置

2012-02-22
----------

1 更新了默认的mysql版本为5.1.61,也可使用mysql5.5

2 更新了http版本至2.2.22

3 更新了nginx版本至1.0.12

4 更新最新的wdcp_v2.2.1版本
5 更新了pureftpd至1.0.35

5 增加部分组件的可选安装，如memcache,mysqli,pdo_mysql,innodb等,具体的安装方法可见:

http://www.wdlinux.cn/bbs/thread-1356-1-1.html

2011-11-23
----------

1 修复CentOS 6,WdLinux 6系统64位版本下不能安装的问题

2 修复CentOS 6,WdLinux 6系统下FTP不能登录的问题

3 修复CentOS 6,WdLinux 6系统下httpd运行不稳定的问题

4 增加默认打开iptables防火墙上80，21端口的问题

5 增加可选卸载或重装

2011-11-19
----------

此次2.0版本的更新发布

1 增加了nginx+apache组合环境的应用，也即是nginx前端处理静态，图片等，apche处理后台php脚本程序。nginx在处理静态文件

上有着非常好的性能和稳定性，且省节点资源，但在处理php的应用上相对没那么稳定，而apache在处理php的应用上是非常稳定的，

也因此，目前比较流行的一个n+a的组合应用应运而生,只在WdLinux,CentOS,RedHat版本上测试通过，其它Linux版本尚未测试，

欢迎测试

2 将vsftpd服务端软件替换为pureftpd,pureftpd更适合做web服务器上应用的FTP软件，避免web在线生成文件与FTP不能互操作的

问题

3 同时也更新了最新版本的wdcp2.0，wdcp (WDlinux Control Panel)是一套Linux服务器/虚拟主机管理系统，可通过web界面对服

务器进行日常的管理和维护，省去通过终端输命令的烦琐操作和难度，更是降低了使用Linux做web服务器的门槛，让更多人的可以

轻松使用Linux做服务器。以及可以管理网站，FTP，数据库等，包括在线创建，删除，修改等操作，详细功能介绍可查看:

http://www.wdlinux.cn/wdcp

4 修复或增加多处安装检测，更易于安装


