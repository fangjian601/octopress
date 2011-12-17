---
layout: post
title: "Linode Gentoo主机安装PPTP和L2TP VPN"
date: 2011-01-12 00:40
comments: true
categories: [technology, linux, gentoo, Android]
---
{% img left /images/uploads/2011/01/linode.png 288 65 'linode.com' %}

由于之前Godaddy IP被block的原因，最近转到[linode](http://www.linode.com/ "linode.com") VPS上来了，作为优秀的VPS提供商，Linode给我们提供了高度的自由空间。这篇文章主要是用来介绍如何在Linode主机上搭建PPTP和L2TP VPN Server，由于我的主机是Gentoo系统，所以下面的内容都是基于Gentoo 2010的

###PPTP

[PPTP](http://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol "PPTP")又称点对点隧道协议，是一种主要用于VPN的传输层网络协议，我们知道Microsoft Windows是默认支持PPTP协议的。下面是Gentoo下按装PPTP的方法：

####安装程序

{% codeblock lang:bash %}
emerge -av ppp pptpd iptables
{% endcodeblock %}

**注意**：此处需要内核有PPP支持，Linode Gentoo默认是有的，如果没有，需要重新编译内核

<!--more-->

####配置

修改`/etc/ppp/options.pptpd`

{% codeblock lang:bash %}
vim /etc/ppp/options.pptpd
{% endcodeblock %}

把ms-dns前面的#删掉，并且把内容修改为

{% codeblock lang:text %}
ms-dns 8.8.8.8
ms-dns 8.8.8.4
{% endcodeblock %}

`8.8.8.8`和`8.8.8.4`这两个DNS服务器是Google的，速度比较快

修改`/etc/ppp/chap-secrets`

{% codeblock lang:bash %}
vim /etc/ppp/chap-secrets
{% endcodeblock %}

这个是存放VPN用户名，密码的文件，比如你可以如此设置：

{% codeblock lang:text %}
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
username * password *
{% endcodeblock %}

文件每行由四部分组成，第一个是用户名，第二个是server，你可以填写，pptp、l2tp等，星号可以针对所有协议，第三个是密码，第四个是允许那个类型的ip使用这个用户名密码，*表示所有

修改`/etc/pptpd.conf`

{% codeblock lang:bash %}
vim /etc/pptpd.conf
{% endcodeblock %}

注释掉下面这两行

{% codeblock lang:text %}
localip 192.168.0.1
remoteip 192.168.0.234-238,192.168.0.245
{% endcodeblock %}

这个localip是指，在VPN下，Server的ip地址，remoteip是指，来连接的客户端，可分配ip的范围，你可以把这个范围调整大  修改`/etc/sysctl.conf`

{% codeblock lang:text %}
net.ipv4.ip_forward = 1
{% endcodeblock %}

保存后，执行

{% codeblock lang:bash %}
sysctl -p
{% endcodeblock %}

建立iptables规则

{% codeblock lang:bash %}
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.0.0/24 -j MASQUERADE
/etc/init.d/iptables save
{% endcodeblock %}

这个命令意思是把所有在`192.168.0.*`这个ip上的请求转发到本地真实网卡上，这样就可以连接外面的网络了

####启动服务

首先启动iptables

{% codeblock lang:bash %}
/etc/init.d/iptables start
{% endcodeblock %}

然后启动pptpd

{% codeblock lang:bash %}
/etc/init.d/pptpd start
{% endcodeblock %}

这样之后你就可以，用客户端连接这个pptp服务器，你可以把这两个服务加到系统启动中去

{% codeblock lang:bash %}
rc-update add iptables default
rc-update add pptpd default
{% endcodeblock %}

如果你要查看连接信息，可以直接查看`/var/log/message`即可

{% codeblock lang:bash %}
tail -f /var/log/message
{% endcodeblock %}


###L2TP

[L2TP](http://en.wikipedia.org/wiki/Layer_2_Tunneling_Protocol "L2TP")又称第二层隧道协议，是VPN连接的另外一种协议，这种协议和IPSec一起广泛应用于VPN服务中。但是本文将不会介绍IPSec，只会介绍单独L2TP协议的安装

####安装软件

Gentoo emerge下可安装的l2tp服务器有xl2tp和rp-l2tp，本文将介绍xl2tp

通过emerge安装xl2tp

{% codeblock lang:bash %}
emerge -av xl2tp
{% endcodeblock %}

**注意**：此处需要内核有PPP支持

####配置

修改`/etc/xl2tpd/xl2tpd.conf`，如果没有请新建，下面是文件参考配置

{% codeblock lang:text %}
[global]

[lns default]
#客户端连接后，分配ip的范围
ip range = 10.10.10.2-10.10.10.254
#服务端机器ip
local ip = 10.10.10.1
#chap认证
require chap = yes
refuse pap = yes
require authentication = yes
#VPN名字
name = LinuxVPNserver
#输出debug信息
ppp debug = yes
#ppp配置文件
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
{% endcodeblock %}

修改`/etc/ppp/options.xl2tpd`，如果没有请新建

{% codeblock lang:text %}
ipcp-accept-local
ipcp-accept-remote
ms-dns  8.8.8.8
ms-wins 8.8.8.8
noccp
auth
crtscts
idle 1800
mtu 1410
mru 1410
defaultroute
debug
lock
proxyarp
connect-delay 5000
{% endcodeblock %}

修改`/etc/ppp/chap-secrets` 这个是存放VPN用户名，密码的文件，比如你可以如此设置：

{% codeblock lang:text %}
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
username * password *
{% endcodeblock %}

建立iptables规则

{% codeblock lang:bash %}
iptables -t nat -A POSTROUTING -o eth0 -s 10.10.0.0/24 -j MASQUERADE
/etc/init.d/iptables save
{% endcodeblock %}

####启动服务

分别启动iptables和xl2tpd服务

首先启动iptables

{% codeblock lang:bash %}
/etc/init.d/iptables start
{% endcodeblock %}

然后启动xl2tpd

{% codeblock lang:bash %}
/etc/init.d/xl2tpd start
{% endcodeblock %}

这样之后你就可以，用客户端连接这个xl2tpd服务器，你可以把这两个服务加到系统启动中去

{% codeblock lang:bash %}
rc-update add iptables default
rc-update add xl2tpd default
{% endcodeblock %}

如果你要查看连接信息，可以直接查看`/var/log/message`即可

{% codeblock lang:bash %}
tail -f /var/log/message
{% endcodeblock %}


###客户端连接

####Ubuntu

由于Ubuntu系统自带的VPN连接工具是PPTP的，所以下面基于PPTP的连接说明

1、点击网络连接图标：

{% img center /images/uploads/2011/01/network_settings.png 261 28 '网络设置' %}

2、然后选择VPN连接-&gt;配置VPN：

{% img center /images/uploads/2011/01/network_connect.png 281 232 '网络连接' %}

3、点击添加

{% img center /images/uploads/2011/01/select_protocol.png 346 172 '选择协议' %}

4、点击新建

{% img center /images/uploads/2011/01/editing_vpn_connection.png 323 346 '编辑VPN连接' %}

在Gateway上填上你的VPN服务器地址，user name和password分别连上你的用户名和密码

5、点击Advanced

{% img center /images/uploads/2011/01/pptp_advanced_options.png 228 347 'PPTP Advanced Options' %}

勾上Use Point-to-Point encryption (MPPE)，点击确定

6、然后保存配置，连接你刚才配置好的VPN即可


####Android

由于某些Android系统的原因，对MPPE 128支持不好，所以这里主要演示用Android连接L2TP VPN，演示机型是Samsung Galaxy S i9000

1、点击设置-&gt;无线和网络-&gt;VPN设置-&gt;添加VPN

{% img center /images/uploads/2011/01/CAP201101120013.jpg 184 307 '设置' %}

2、设置VPN

先选择，L2TP VPN，然后再填写VPN名称，VPN服务器，搜索域等，同时吧加密选项勾上，然后按menu，保存退出

{% img center /images/uploads/2011/01/CAP201101120015.jpg 184 307 '添加L2TP VPN"' %}

3、连接VPN

选择刚才添加的VPN连接，输入用户名和密码，这样就能手机使用VPN了

{% img center /images/uploads/2011/01/CAP2011011200171.jpg 184 307 '连接到VPN' %}


这里就介绍了完了如何在Linode VPS上创建VPN服务，并且如何使用，欢迎指正批评

###参考文章

1、[http://lifepeak.net/it-jishu/pptp-pptpd-vpn-gentoo.html](http://lifepeak.net/it-jishu/pptp-pptpd-vpn-gentoo.html)

2、[http://linuxexplore.wordpress.com/how-tos/l2tp-vpn-using-xl2tpd/](http://linuxexplore.wordpress.com/how-tos/l2tp-vpn-using-xl2tpd/)