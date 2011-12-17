---
layout: post
title: "Gentoo下emerge安装byaccj"
date: 2010-11-08 22:42
comments: true
categories: [technology, linux, gentoo]
---
由于作业的原因需要用到java yacc，所以需要安装byaccj，eix看了一下在最新的源里面已经没有了byaccj，所以希望通过下载 源码来安装byaccj，但是下载下源码之后，编译有问题，所以想去找byaccj.ebuild这样的文件，运气好的是刚好之前版本的gentoo有这个ebuild，所以在这里分享一下安装方法：


####配置自己的portage目录

我们知道默认的portage目录是`/usr/portage` ，我们也可以指定自己的portage目录来添加第三方的应用程序，方法如下：

<!--more-->

{% codeblock lang:bash %}
echo 'PORTDIR_OVERLAY="/usr/local/portage"' >> /etc/make.conf
mkdir -p /usr/local/portage/dev-java/byaccj/
{% endcodeblock %}


####添加byaccj-1.14.ebuild

{% codeblock lang:bash %}
cd /usr/local/portage/dev-java/byaccj/
vim byaccj-1.14.ebuild
{% endcodeblock %}

文件内容如下：

{% codeblock lang:bash %}
# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A java extension of BSD YACC-compatible parser generator"
HOMEPAGE="http://byaccj.sourceforge.net/"
MY_P="${PN}${PV}_src"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_compile() {
        make -C src linux || die "failed too build"
}

src_install() {
        newbin src/yacc.linux "${PN}"  || die "missing bin"
        #newman src/yacc.1 "${PN}.1" // would need to rewrite the not talk about yacc
        dodoc docs/ACKNOWLEDGEMEN || die
}
{% endcodeblock %}


####构建manifest

{% codeblock lang:bash %}
ebuild byaccj-1.14.ebuild manifest
{% endcodeblock %}


####更新eix

{% codeblock lang:bash %}
eix-update
{% endcodeblock %}


####unmask掉byaccj

{% codeblock lang:bash %}
echo '&gt;=dev-java/byaccj-1.14 **' >>/etc/portage/package.keywords
{% endcodeblock %}


####安装byaccj

{% codeblock lang:bash %}
emerge -av byaccj
{% endcodeblock %}

这样不出问题的话byaccj就装好了：）