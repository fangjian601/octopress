---
layout: post
title: "Mac OSX通过ISATAP连接清华IPv6"
date: 2011-03-10 00:41
comments: true
categories: [technology, osx]
---
由于学校IPv6突然添加了认证系统，而且认证系统极其无比的烂，在忍受很久经常连接不上的痛苦之后，决定用ISATAP方式连接IPv6，因为目前学校这种方式是没有认证的。下面将介绍如何在Mac OSX下使用ISATAP

1、下载ISATAP client for Mac OS X

地址：[http://www.momose.org/macosx/isatap.html](http://www.momose.org/macosx/isatap.html "ISATAP client for Mac OSX")


2、解压ISATAP client

{% codeblock lang:bash %}
% cd /usr/local
% sudo tar xfz ~/Downloads/macosx-isatap-*.tar.gz
{% endcodeblock %}

<!--more-->

3、更改权限

{% codeblock lang:bash %}
% sudo chown -R root:wheel /usr/local/isatap
% sudo chmod -R 644 /usr/local/isatap/isatap.kext
{% endcodeblock %}


4、配置ISATAP

4.1 配置ist0和得到IPv4地址（你需要制定现在使用的网卡，比如en0）

**注：config-ist.sh有一行需要更改以适应清华ipv6，将第50行改为：**

{% codeblock lang:bash %}
${ifconfig} ist0 inet6 2001:da8:200:900e:0:5efe:${v4addr} prefixlen 64
{% endcodeblock %}

然后再执行：

{% codeblock lang:bash %}
% sudo ./config-ist.sh en0
{% endcodeblock %}

4.2 指定ISATAP router

{% codeblock lang:bash %}
% sudo ./ifconfig ist0 isataprtr 59.66.4.50
% sudo ./rtsold.sh &amp;
{% endcodeblock %}

4.3 设置路由表

{% codeblock lang:bash %}
% sudo route delete -inet6 default
{% endcodeblock %}

*注：在执行上面命令之前可以用`netstat -r`查看ipv6路由表上是否有default这一项，没有则不用执行上面命令*

{% codeblock lang:bash %}
% sudo route add -inet6 default -interface ist0
{% endcodeblock %}

4.4 启动IPv6

{% codeblock lang:bash %}
% sudo ifconfig ist0 up
{% endcodeblock %}


5、关闭IPv6

{% codeblock lang:bash %}
% sudo ifconfig ist0 down
{% endcodeblock %}

这样ISATAP就配置好了，而且不用认证，很爽！！