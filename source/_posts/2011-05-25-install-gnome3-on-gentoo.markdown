---
layout: post
title: "Gentoo下安装Gnome 3桌面环境"
date: 2011-05-25 22:10
comments: true
categories: [technology, linux, gentoo]
---
{% img left /images/uploads/2011/05/gnome-logo.png 250 100 'Gnome 3 Logo' %}

[Gnome 3](http://gnome3.org "Gnome 3")已经于4月6日正式发布了（[Release Notes](http://library.gnome.org/misc/release-notes/3.0 "Gnome 3 Release Notes")），由于在2的基础之上做了许多的改变，所以一直被很多人所期待。

同时我们也知道Fedora 和openSUSE都将在未来的版本中支持Gnome 3。作为一个Gentoo使用者，当然不能等官方来支持之后再去尝试，于是自愿当起了小白鼠，决定在Gentoo上编译Gnome 3，尝试这个全新的桌面环境。

###机器环境

{% codeblock lang:text %}
GCC：4.4.5 x86_64-pc-linux-gnu
Kernel：Linux frankpc-gentoo 2.6.39-gentoo #1 SMP x86_64
Desktop：Kde-4.6.3
emerge info: http://pastebin.com/8r8CvyQr
{% endcodeblock %}


###添加第三方源

由于Gnome 3并没有进入官方源，所以我们必须要通过第三方源才能够进行安装，而Gentoo下通过layman，提供了一套很好的第三方源管理方案，关于layman的使用，可以[&gt;&gt;参考这里&lt;&lt;](http://www.gentoo.org/proj/en/overlays/userguide.xml "gentoo layman user guide")

显示可用的layman
{% codeblock lang:bash %}
$ layman -L
{% endcodeblock %}

<!--more--> 

我们现在添加安装Gnome 3的layman

{% codeblock lang:bash %}
$ layman --add gnome
$ layman --add keruspe
$ layman --add suka
$ layman --add rubenqba
{% endcodeblock %}


然后再往`/etc/make.conf`里面添加layman信息

{% codeblock lang:bash %}
$ echo "source /var/lib/layman/make.conf" >> /etc/make.conf
{% endcodeblock %}


这时候Gnome 3的第三方源就已经添加成功了，如果你安装了eix，可以如下更新：

{% codeblock lang:bash %}
$ eix-update
{% endcodeblock %}


通过eix我们可以查到gnome 3的信息

{% codeblock lang:bash %}
$ eix gnome-base/gnome
[I] gnome-base/gnome
     Available versions:  (2.0) 2.30.2 2.30.2-r1 2.32.1 (~)3.0.0{tbz2}[1]
        {accessibility (+)cdr cups dvdr +extras +fallback ldap mono policykit}
     Installed versions:  3.0.0(2.0){tbz2}[1](10时29分55秒 2011年05月25日)(cdr cups extras fallback)
     Homepage:            http://www.gnome.org/
     Description:         Meta package for GNOME 3
{% endcodeblock %}

我们可以看到上面的3.0.0是被默认mask了的，所以下面我们需要修改如下一些文件，保证gnome 3可以安装


###修改mask，unmask和use flag

添加`/etc/portage/profile/gnome`文件，文件内容如下：

{% codeblock lang:text %}
-gtk3
-introspection
{% endcodeblock %}


添加`/etc/portage/package.unmask/gnome`文件，文件内容如下

（**如果你的`/etc/portage/package.unmask`不是文件夹而是一个文件的话，直接在末尾添加下面内容**）：

{% codeblock lang:text %}
<=gnome-base/gdm-2.26
x11-wm/metacity
x11-misc/notification-daemon
x11-libs/wxGTK
{% endcodeblock %}


添加`/etc/portage/package.keywords/gnome`文件

文件内容见[&gt;&gt;这里&lt;&lt;](http://pastebin.com/BHF5qPDP "/etc/portage/package.keywords/gnome")（**如果你的`/etc/portage/package.keywords`不是文件夹而是一个文件的话，直接在末尾添加链接内容**）


添加`/etc/portage/package.use/gnome`文件，

文件内容如下：

（**如果你的`/etc/portage/package.use`不是文件夹而是一个文件的话，直接在末尾添加下面内容**）：

{% codeblock lang:text %}
gnome-base/gvfs gdu
net-libs/gtk-vnc gtk3
dev-db/sqlite unlock-notify
media-libs/libpng apng
gnome-extra/nm-applet bluetooth
dev-cpp/atkmm -doc
media-video/cheese -doc
gnome-base/gdm gnome-keyring
net-libs/glib-networking -libproxy
{% endcodeblock %}


**Note:**

`net-libs/glib-networking`如果不把libproxy USE flag去掉可能会导致kde启动不正常，这里有两个官方的bug

[Bug 365637](http://bugs.gentoo.org/show_bug.cgi?id=365637) - KDE 4.6.2 not starting whenever net-libs/glib-networking is installed

[Bug 365479](http://bugs.gentoo.org/show_bug.cgi?id=365479) - net-libs/glib-networking causes polkitd to fail acquiring name, and KDE 4.6.2 not starting

我这边表现出来的症状是这样的(`/var/log/kdm.log`)：

{% codeblock lang:text %}
klauncher(30374) kdemain: No DBUS session-bus found. Check if you have started the DBUS server.
kdeinit4: Communication error with launcher. Exiting!
kdmgreet(30368)/kdecore (K*TimeZone*): KSystemTimeZones: ktimezoned initialize() D-Bus call failed:  "Not connected to D-Bus server"
{% endcodeblock %}


###安装Gnome

为了保证编译正常，我们首先update一下整个系统

{% codeblock lang:bash %}
$ emerge --sync
$ emerge -av --newuse --update --deep world
{% endcodeblock %}


安装gnome

{% codeblock lang:bash %}
$ emerge -av gnome
{% endcodeblock %}

整个编译过程可能需要很长的时间，所以耐心等待吧，中间要是有编译错误欢迎留言告诉我，你也可以自行Google

**Note:** 

如果还是遇到比如某些包被mask或者缺少use flag，在`/etc/portage/package.keywords/gnome`和`/etc/portage/package.use/gnome`中添加相应的东西即可


安装配置文件

{% codeblock lang:bash %}
$ dispatch-conf
{% endcodeblock %}


###启动Gnome

如果你想要GDM作为显示管理器的话，修改`/etc/conf.d/xdm`这个文件，修改如下内容为：

{% codeblock lang:text %}
DISPLAYMANAGER="gdm"
{% endcodeblock %}

重启电脑，然后选择gnome进入即可。


Gnome 3就安装好了，下面是若干运行截图：


*程序选择：*

{% img center /images/uploads/2011/05/program_select.png 650 378 'Gnome 3程序选择' %}


*窗口选择*

{% img center /images/uploads/2011/05/window_select.png 605 378 'Gnome 3窗口选择' %}


*任务栏和Gnome Terminal：*

{% img center /images/uploads/2011/05/system_bar.png 'Gnome 3 任务栏' %}


###若干问题

####empathy不能添加GTalk账户

解决办法：需要安装如下的包

{% codeblock lang:bash %}
$ emerge -av net-voip/telepathy-gabble net-voip/telepathy-salut net-irc/telepathy-idle
{% endcodeblock %}


####chromium的switchy插件不能使用autoswitch mode

解决办法：确保chromium的use flag包括了gnome和gnome-keyring

不过好像还是支持不够好


####chromuim对Gnome 3的支持不好（比如程序选择的时候有问题）


也许还有一些问题，待我慢慢发现后再更新，你要是遇到什么问题欢迎来讨论