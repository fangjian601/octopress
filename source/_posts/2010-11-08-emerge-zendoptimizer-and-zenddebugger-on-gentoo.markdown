---
layout: post
title: "Gentoo下安装ZendOptimizer和ZendDebugger"
date: 2010-11-08 22:10
comments: true
categories: [technology, linux, gentoo]
---
由于开发需要，需要配置php，下午在gentoo下琢磨了一下怎么搭建php调试环境，我所使用的php开发环境是eclipse pdt，所以需要配置ZendDebugger（不知道eclipse pdt如何安装的可以参考这个官方文档[http://wiki.eclipse.org/PDT/Installation](http://wiki.eclipse.org/PDT/Installation)），而ZendOptimizer对Apache做一些优化，所以需要两个并存。我的配置过程如下：

####安装ZendOptimizer

{% codeblock lang:bash %}
emerge -av ZendOptimizer
{% endcodeblock %}

<!--more-->

这个安装可能需要把你的php-5.3降级为php-5.2，而且可能需要添加USE flag  中间安装有一个问题，说是需要你去从Zend官网上下载ZendOptimizer，然后放到`/usr/portage/distfles/`下

所以你需要去[http://www.zend.com/en/products/guard/downloads](http://www.zend.com/en/products/guard/downloads) 下载最新的ZendOptimizer，然后

{% codeblock lang:bash %}
cp /path/to/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz /usr/portage/distfiles
emerge -av ZendOptimizer
{% endcodeblock %}

这里的版本可能会有不同，执行命令的时候注意一下，这样以后ZendOptimizer就能够正常安装了

####安装ZendDebugger

去Zend官网上[http://www.zend.com/en/products/studio/downloads](http://www.zend.com/en/products/studio/downloads)下载Studio Web Debugger，选择你对应的Arch，然后解压

{% codeblock lang:bash %}
tar -xvvf ZendDebugger-20100729-linux-glibc23-x86_64.tar.gz
cd ZendDebugger-20100729-linux-glibc23-x86_64
cp 5_2_x_comp/ZendDebugger.so /usr/lib/php5/lib/extensions/no-debug-non-zts-20060613/
cp dummy.php /var/www/localhost/htdocs/
{% endcodeblock %}

这里假设的你的apache服务已经配置好，而且`/var/www/localhost/htdocs`为localhost默认root


####修改php配置文件

主要修改两个配置文件，/etc/php/apache2-php5/ext/ZendOptimizer.ini和/etc/php/cli-php5/ext/ZendOptimizer.ini，在这两个文件末尾添加如下内容：

{% codeblock lang:bash %}
zend_extension=/usr/lib64/php5/lib/extensions/no-debug-non-zts-20060613/ZendDebugger.so
zend_debugger.allow_hosts=127.0.0.1/32,10.18.138.0/24
zend_debugger.expose_remotely=always
{% endcodeblock %}

**NOTE: 上面的内容必须在ZendOptimizer后加载，所以要加到这个文件的末尾**

你可以把`10.18.138.0/24`替换成你的子网内容，例如你想让`192.168.0.x`下均可以调试，可以改成`192.168.0.0/24`


####重启apache server

{% codeblock lang:bash %}
/etc/init.d/apache2 restart
{% endcodeblock %}


####查看phpinfo

你可以通过php -v来查看，php信息，将看到如下信息：

{% codeblock lang:bash %}
# php -v
PHP 5.2.14-pl0-gentoo (cli) (built: Nov  8 2010 13:54:12)
Copyright (c) 1997-2010 The PHP Group
Zend Engine v2.2.0, Copyright (c) 1998-2010 Zend Technologies
    with Zend Optimizer v3.3.9, Copyright (c) 1998-2009, by Zend Technologies
    with Zend Debugger v5.3, Copyright (c) 1999-2010, by Zend Technologies

{% endcodeblock %}

或者你可以写一个php文件

{% codeblock lang:php %}
<?php
    phpinfo();
?>
{% endcodeblock %}

然后通过放到`/var/www/localhost/htdocs/`，在浏览器中查看
 
这样我们就成功在Gentoo上配置好了php调试环境