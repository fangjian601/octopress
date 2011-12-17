---
layout: post
title: "Gentoo 下安装 PAC Manager"
date: 2010-12-21 22:12
comments: true
categories: [technology, linux, gentoo]
---
{% img left /images/uploads/2010/12/pacmanager.png 32 32 'PAC Manager' %}
[PAC Manager](http://sites.google.com/site/davidtv/ "PAC Manager") 是一款不错的带有 GUI 界面的 SSH 链接管理器，可帮助你管理大量的远程 SSH 主机。PAC Manager 采用 Perl/GTK2 实现。由于官方只提供Deb包，所以在Gentoo下如果想用使用PAC Manager 需要从源代码手动安装，本文将介绍在Gentoo下如何安装PAC Manager

####下载

从SourceForge主页上下载pac manager最新的源码包，地址为
 
[http://sourceforge.net/projects/pacmanager/files/pac-2.0/](http://sourceforge.net/projects/pacmanager/files/pac-2.0/)
 
选择`pac-*-all.tar.gz`下载即可
 
或者从svn上直接checkout出最新的代码：

{% codeblock lang:bash %}
$ svn co https://pacmanager.svn.sourceforge.net/svnroot/pacmanager pacmanager
{% endcodeblock %}

<!--more-->

####安装依赖包

由于PAC Manager是perl程序，所以有一些perl的包需要安装，经过试验，发现下面这些包可以通过emerge来安装
 
在安装perl插件之前:
 
*确保你的`dev-lang/perl`的USE flag包括了ithreads*，如果没有请执行：

{% codeblock lang:bash %}
$ sudo USE=ithreads emerge -av dev-lang/perl
{% endcodeblock %}

然后再执行：

{% codeblock lang:bash %}
$ sudo emerge -av dev-perl/glib-perl dev-perl/yaml dev-perl/gtk2-perl dev-perl/Gtk2-Ex-Simple-List dev-perl/gtk2-gladexml dev-perl/crypt-cbc dev-perl/Expect dev-perl/Pango dev-perl/Cairo dev-perl/Crypt-Blowfish dev-perl/IO-Tty dev-perl/gnome2-gconf
{% endcodeblock %}

不过还有两个包无法用emerge安装，一个是Net-ARP，另一个是Gnome2-Vte
 
这两个包可以从[cpan的官网](http://search.cpan.org/ 'CPAN')上去下载，下面给出这两个包的下载地址：
 
[Net-ARP](http://search.cpan.org/CPAN/authors/id/C/CR/CRAZYDJ/Net-ARP-1.0.6.tgz "Net-ARP")
 
[Gnome2-vte](http://search.cpan.org/CPAN/authors/id/T/TS/TSCH/Gnome2-Vte-0.09.tar.gz "Gnome2-vte")
 
下载完成后解压两个包，分别cd进入两个包中执行：

{% codeblock lang:bash %}
$ perl Makefile.PL
$ make
$ sudo make install
{% endcodeblock %}

*可选包 IO-Stty*，这个包可以装，也可以不装，不会影响执行，下载地址[IO-Stty](http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/IO-Stty-0.03.tar.gz "IO-Stty") 下载完成后，解压，cd进入：

{% codeblock lang:bash %}
$ perl Build.PL
$ ./Build
$ sudo cp blib/lib/IO/Stty.pm /usr/lib/perl5/5.12.2/IO/
{% endcodeblock %}

上面这些步骤做完的话，依赖包就安装完成了。但是我启动的时候遇到了一个问题，就是PAC Manager无法识别jpeg图片，经过分析发现是因为libgtk+不支持jpeg，所以：

*请确保你的`x11-libs/gtk+的USE flag`包括了jpeg*，如果没有请执行：

{% codeblock lang:bash %}
$ sudo USE=jpeg emerge -av gtk+
{% endcodeblock %}

####安装PAC Manager

把下载下来的`pac-*-all.tar.gz`解压，并cd进入解压后目录，执行：

{% codeblock lang:bash %}
$ mkdir ~/.pac
$ mv res/pac.yml ~/.pac
$ ./pac
{% endcodeblock %}

这样的话就可以启动pac了，但是为了跟方便我们在菜单栏上启动，下面我们将一些文件放到系统指定的地方

{% codeblock lang:bash %}
$ sudo cp res/pac.desktop /usr/share/applications
$ sudo cp res/pac.1 /usr/share/man/man1/
$ sudo cp res/pac*x*.png /usr/share/pixmaps
$ sudo mkdir /opt/pac
$ sudo cp -R lib LICENSE pac README res /opt/pac
$ sudo ln -s /opt/pac/pac /usr/bin/pac
{% endcodeblock %}

这样的话，你就可以在你的菜单栏的Internet分栏中看到pac的启动项了，我们就可以正常运行PAC Manager了

下面是几张截图

{% img center /images/uploads/2010/12/PAC-v2.5.4.1_036.png 516 309 'PAC' %}

{% img center /images/uploads/2010/12/PAC-v2.5.4.1_037.png 516 309 'PAC' %}