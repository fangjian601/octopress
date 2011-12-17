---
layout: post
title: "Windows和Linux下通过ISATAP连接清华IPv6"
date: 2011-04-05 17:54
comments: true
categories: [technology, linux]
---
之前写过一篇文章，讲如何在Mac下通过ISATAP连接清华IPv6网络，达到绕过学校脑残认证的文章

*文章地址* [&gt;&gt;请猛击这里&lt;&lt;](/posts/2011/03/10/connect-tsinghua-ipv6-via-isatap-on-osx)


下面我要介绍的是在Windows和Linux如何通过ISATAP连接清华IPv6


###Windows


*此方法适用于Windows XP/2003/Vsita/7*

<!--more-->

同时按下你电脑的Windows键和R键，会在左下角弹出一个运行的对话框（如果你是Mac机器上的Windows，按下Command+R）

{% img center /images/uploads/2011/04/run.png 349 175 'Windows下运行对话框' %} 

 
在这个对话框中输入cmd，然后回车，会弹出一个控制台窗口：

{% img center /images/uploads/2011/04/windows_console.png 491 320 'Windows控制台窗口' %}

 
在对话框内输入netsh，回车：

{% img center /images/uploads/2011/04/netsh1.png 472 310 'netsh' %}

 
在对话框内输入int，回车：

{% img center /images/uploads/2011/04/netsh2.png 470 312 'netsh' %}

 
在对话框内输入IPv6，回车：

{% img center /images/uploads/2011/04/netsh3.png 472 312 'netsh' %}

 
6、输入install，回车：

{% img center /images/uploads/2011/04/netsh4.png 474 313 'netsh' %}

 
输入ISATAP，回车：

{% img center /images/uploads/2011/04/netsh5.png 474 312 'netsh' %}

 
8、输入`set router 59.66.4.50`，回车：

{% img center /images/uploads/2011/04/netsh6.png 474 313 'netsh' %}

 
9、配置完成了，你输入exit，回车：
 
{% img center /images/uploads/2011/04/netsh7.png 473 314 'netsh exit' %}


10、Windows下配置也就完成了，你可以访问http://ipv6.tsinghua.edu.cn 如果没有登陆提示，说明配置成功了，如果还有问题，你可以到下面留言
 

###Linux


相对来说Linux下操作稍微麻烦一点，不过你要是熟悉Linux控制台操作其实一切都很简单

打开Linux终端，首先确保IPv6内核模块正常：

{% codeblock lang:bash %}
$ sudo modprobe ipv6
{% endcodeblock %}


如果上面正常，然后我们就可以开始下面的配置了：

{% codeblock lang:bash %}
$ local_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "{地址,addr}:" `
$ sudo ip tunnel add sit1 mode sit remote 59.66.4.50 local $local_ip
$ sudo ifconfig sit1 up
$ sudo ifconfig sit1 add 2001:da8:200:900e:0:5efe:$local_ip/64
$ sudo ip route add ::/0 via 2001:da8:200:900e::1 metric 1
{% endcodeblock %}

**Note：这里使用sit1，是因为sit0被占用了**

这样我们就可以正常访问ipv6网络了，你可以尝试去ping6一下ipv6.tsinghua.edu.cn，如果正常，说明配置正确


如果你希望在启动时候ipv6就配置好了：

你可以在`/etc/network/if-up.d/`下添加一个文件，把刚才的命令考过去，在文件开头写上#!/bin/bash，然后给该文件加上可执行权限。最后在`/etc/network/interfaces`里面加上一句

{% codeblock lang:bash %}
post-up /etc/network/if-up.d/sit1
{% endcodeblock %}

这样以后每次网卡重启都会帮你把ipv6配置好（这是Ubuntu下的方法，可能发行版不同有不同的策略）

好了我要介绍的配置过程完成了，要是有什么问题欢迎留言，如果你觉得这篇文章对你有帮助就帮忙分享一下，博主在这里谢过了