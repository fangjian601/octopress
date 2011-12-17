---
layout: post
title: "CentOS 5.5 SELinux环境下配置Ruby Enterprise Edition，Phusion Passenger和Apache"
date: 2011-09-20 00:02
comments: true
categories: [linux, technology, centos]
---
由于工作的关系，写了一个Rails程序需要在服务器上跑起来，而公司的服务器全是CentOS的，所以经过一番摸索，总结出了如何在CentOS 5.5下配置Rails环境。虽然SELinux给配置过程造成了许多麻烦，但是为了安全起见，还是在不关闭SELinux的情况下配置<a title="Ruby Enterprise Edition" href="http://www.rubyenterpriseedition.com/" target="_blank">REE（Ruby Enterprise Edition）</a>

###安装Ruby Enterprise Edtion

*下载REE*

{% codeblock lang:bash %}
$ wget http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz
{% endcodeblock %}

<!--more--> 

*安装依赖包*

{% codeblock lang:bash %}
$ yum install autoconf automake binutils gcc gcc-c++ zlib-devel openssl-devel readline-devel
{% endcodeblock %}


*解压安装REE*

{% codeblock lang:bash %}
$ tar -xvvf ruby-enterprise-1.8.7-2011.03.tar.gz
$ cd ruby-enterprise-1.8.7-2011.03
$ ./installer
{% endcodeblock %}

然后按回车，如果有依赖不满足，REE会告诉你如何去安装依赖包，接下来是指定REE安装到何处，我们采用默认的`/opt/ruby-enterprise-1.8.7-2011.03`
接下来你就只需要等待他编译安装完成。


*修改PATH环境变量*

创建`/etc/profile.d/ree.sh`，文件内容如下：

{% codeblock lang:bash %}
#!/bin/bash
export PATH=/opt/ruby-enterprise-1.8.7-2011.03/bin:$PATH
{% endcodeblock %}


*重新登陆你的用户session即可以使用REE了*


###安装Phusion Passenger

Phusion Passenger可以通过多种方式安装（gem，yum，源码编译），我们采用最为简单的gem安装


*安装passenger*

{% codeblock lang:bash %}
$ gem install passenger
{% endcodeblock %}


*安装passenger apache模块*

{% codeblock lang:bash %}
$ passenger-install-apache2-module
{% endcodeblock %}

**可能首先需要安装依赖模块**

{% codeblock lang:bash %}
$ yum install curl-devel httpd-devel apr-devel apr-util-devel
{% endcodeblock %}


上面安装完成之后，默认的passenger root是在`/opt/ruby-enterprise-1.8.7-2011.03/lib/ruby/gems/1.8/gems/passenger-3.0.9`


###配置Apache

*添加`/etc/httpd/conf.d/passenger.conf`文件内容如下*

{% codeblock lang:bash %}
LoadModule passenger_module /opt/ruby-enterprise-1.8.7-2011.03/lib/ruby/gems/1.8/gems/passenger-3.0.9/ext/apache2/mod_passenger.so
PassengerRoot /opt/ruby-enterprise-1.8.7-2011.03/lib/ruby/gems/1.8/gems/passenger-3.0.9
PassengerRuby /opt/ruby-enterprise-1.8.7-2011.03/bin/ruby
PassengerTempDir /var/lib/passenger/work
{% endcodeblock %}


*配置网站访问*

在`/etc/httpd/conf/httpd.conf`中添加如下内容：

{% codeblock lang:bash %}
<VirtualHost *:80>
	DocumentRoot /your/rails/app/path/public
</VirtualHost>
{% endcodeblock %}

DocumentRoot处是Rails程序的路径，记得后面一定要带上public，更加详细的配置文档[可以见这里](http://www.modrails.com/documentation/Users%20guide%20Apache.html)


###配置REE SELinux相关

**首先确保SELinux启动**，也就是`/etc/selinux/config`文件里面：

{% codeblock lang:bash %}
SELINUX=enforcing
{% endcodeblock %}

*导入环境变量*

{% codeblock lang:bash %}
$ export RE_HOME=/opt/ruby-enterprise-1.8.7-2011.03
$ export PP_HOME=${RE_HOME}/lib/ruby/gems/1.8/gems/passenger-3.0.9
$ export PP_WORK=/var/lib/passenger/work
$ export APACHE_USER=apache
{% endcodeblock %}

这几个环境变量根据你安装REE和Passenger的情况而定修改，apache运行时候的user在某些系统下是www-data


*修改REE安装目录访问权限*

{% codeblock lang:bash %}
$ chown -R root:root ${RE_HOME}
$ chmod -R u=rw,g=r,o=r ${RE_HOME}
$ chmod -R a+X ${RE_HOME}
$ chcon -R -u system_u -t usr_t ${RE_HOME}
{% endcodeblock %}

最后一条命令是selinux相关的，如果遇到`chcon: can't apply partial context to unlabeled file`错误，则把最后一条命令换成：

{% codeblock lang:bash %}
$ chcon -R -h system_u:object_r:usr_t ${RE_HOME}
{% endcodeblock %}


*修改REE Library权限*

{% codeblock lang:bash %}
$ find -P ${RE_HOME} -type f -name "*.so*" -exec chmod a+x {} \;
$ find -P ${RE_HOME} -type f -name "*.so*" -exec chcon -t lib_t {} \;
$ find -P ${RE_HOME} -type f -name "*.a" -exec chmod a+x {} \;
$ find -P ${RE_HOME} -type f -name "*.a" -exec chcon -t lib_t {} \;
{% endcodeblock %}


*修改REE binary权限*

{% codeblock lang:bash %}
$ find -P ${RE_HOME} -type d -name "bin" -exec chmod -R a+x {} \;
$ find -P ${RE_HOME} -type d -name "bin" -exec chcon -R -t bin_t {} \;
{% endcodeblock %}


*修改REE modules权限*

{% codeblock lang:bash %}
$ chmod a+x ${PP_HOME}/agents/PassengerLoggingAgent
$ chcon -t bin_t ${PP_HOME}/agents/PassengerLoggingAgent
$ chmod a+x ${PP_HOME}/agents/PassengerWatchdog
$ chcon -t bin_t ${PP_HOME}/agents/PassengerWatchdog
$ chmod a+x ${PP_HOME}/agents/apache2/PassengerHelperAgent
$ chcon -t bin_t ${PP_HOME}/agents/apache2/PassengerHelperAgent
$ chmod a+x ${PP_HOME}/ext/apache2/mod_passenger.so
$ chcon -t httpd_modules_t ${PP_HOME}/ext/apache2/mod_passenger.so
{% endcodeblock %}

**注意上面modules权限修改适用于Passenger 3.x版本，如果你是Passenger 2.x，则如下修改：**

{% codeblock lang:bash %}
$ chmod a+x ${PP_HOME}/ext/apache2/ApplicationPoolServerExecutable
$ chcon -t bin_t ${PP_HOME}/ext/apache2/ApplicationPoolServerExecutable
$ chmod a+x ${PP_HOME}/ext/apache2/mod_passenger.so
$ chcon -t httpd_modules_t ${PP_HOME}/ext/apache2/mod_passenger.so
{% endcodeblock %}


*修改Passenger temp权限*

{% codeblock lang:bash %}
$ mkdir -p ${PP_WORK}
$ chown -R ${APACHE_USER}:${APACHE_USER} ${PP_WORK}
$ chmod -R u=rwX,g=rX,o-rwx ${PP_WORK}
$ chcon -R -u system_u -t httpd_tmpfs_t ${PP_WORK}{% endcodeblock %}
如果遇到chcon: can't apply partial context to unlabeled file错误，则把最后一条命令换成：
{% codeblock lang:bash %}$ chcon -R -h system_u:object_r:httpd_tmpfs_t ${PP_WORK}
{% endcodeblock %}


###Rails程序SELinux配置

*导入环境变量*

{% codeblock lang:bash %}
$ export RM_HOME=/your/rails/app/path
$ export APACHE_USER=apache{% endcodeblock %}

*修改rails程序目录权限*

{% codeblock lang:bash %}
$ chown -R ${APACHE_USER}:${APACHE_USER} ${RM_HOME}
$ chmod -R u=rw,g=r,o-rwx ${RM_HOME}
$ chmod -R ug+X ${RM_HOME}
$ chcon -R -u system_u -t httpd_sys_content_t ${RM_HOME}
{% endcodeblock %}

如果出现`chcon: can't apply partial context to unlabeled file`错误，则把最后一句话替换成：

{% codeblock lang:bash %}
$ chcon -R -h system_u:object_r:httpd_sys_content_t /root/DataProxyAdminWeb/
{% endcodeblock %}


*修改特定目录权限*

{% codeblock lang:bash %}
$ chcon -R -t httpd_log_t ${RM_HOME}/log
$ chcon -R -t httpd_tmpfs_t ${RM_HOME}/tmp
{% endcodeblock %}


###启动apache

经过上面的配置，我们可以启动apache了

{% codeblock lang:bash %}
$ /etc/init.d/httpd restart
{% endcodeblock %}


###问题

**出现403 Forbidden**

*   可能原因是selinux权限配置问题，可以通过查看/var/log/audit/audit.log来跟踪selinux信息，如果出现denied字样则要注意
*   可能是passenger没有正确读取rails app目录，这个原因可能是rails目录不完整，读写权限有问题等导致


**passenger报错**

这个情况可以跟踪rails app目录下的`log/${RAILS_ENV}.log`来跟踪

如果是与selinux相关的错误，先查看是模块出现问题，比如：

{% codeblock lang:text %}
type=AVC msg=audit(1316438225.847:187678): avc:  denied  { name_connect } for  pid=1170 comm="ruby" dest=12345 scontext=root:system_r:httpd_t:s0 tcontext=system_u:object_r:port_t:s0 tclass=tcp_socket
{% endcodeblock %}


这个问题是ruby无法创建socket，那么我们可以这样解决这个错误：

{% codeblock lang:bash %}
$ grep "ruby" -r /var/log/audit/audit.log | audit2allow -M ruby
$ semodule -i ruby.pp
{% endcodeblock %}


然后重启httpd就可以解决上面的问题


###总结

上面我们完整描述了如何在CentOS 5.5 SELinux下环境下配置Ruby Enterprise Edition，Phusion Passenger和Apache，也许你会遇到其他的问题，欢迎在博客后面留言指出，我将与你一同探讨


###参考文献：

*   [http://www.redmine.org/projects/redmine/wiki/RedmineAndSELinuxOnCentOS](http://www.redmine.org/projects/redmine/wiki/RedmineAndSELinuxOnCentOS "Redmine And SELinux Configuration")

*   [http://amitava1.blogspot.com/2010/08/ruby-on-rails-on-centos-55-with.html](http://amitava1.blogspot.com/2010/08/ruby-on-rails-on-centos-55-with.html "Ruby On Rails on centos 5.5")