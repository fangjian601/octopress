---
layout: post
title: "Gentoo下自动生成package.keywords和package.unmask"
date: 2010-11-08 21:33
comments: true
categories: [technology, linux, gentoo]
---
今天在用装一个被mask的包时候，一不小心`echo "xxxx" < /etc/portage/package.keywords`了，这样把之前辛辛苦苦添加的内容给覆盖了，很是郁闷。如果这个文件不对可能导致更新时候的问题，所以想了一个办法让他根据已经安装的软件包自动生成package.keywords和package.unmask

想到equery可以查询已经安装的软件包的情况，在被masked的软件包前都会显示一个~，利用这个思路，于是写了一个脚本，代码如下：

<!--more-->

{% codeblock lang:bash %}
#!/bin/sh
KEYWORDS="/etc/portage/package.keywords"
UNMASK="/etc/portage/package.unmask"

mv ${KEYWORDS} ${KEYWORDS}~
mv ${UNMASK} ${UNMASK}~

echo "Rewriting package.keywords"
equery -N l -i | sed -nre '/(M~|M | ~)/ s/(^.+\] | \(.+$)//gp' | sed -re 's/^/=/g' >> ${KEYWORDS}

echo "Rewriting package.unmask"
ALL=$(wc -l ${KEYWORDS} | awk '{print $1}')
COUNT=0
while read KEYWORD; do
	COUNT=$[$COUNT + 1]
	echo -ne " $[${COUNT} * 100 / ${ALL}]% finished\r"
	emerge -pv ${KEYWORD} | grep "package.mask" &>/dev/null && echo ${KEYWORD} >> ${UNMASK}
done < ${KEYWORDS}
echo "                                               "
echo "Done"
{% endcodeblock %}

这个小脚本的大致意思如下：用equery输出所有安装了软件包信息，同时查找前面被标记了~的，然后替换成`<=xxx/xxx-version`模式

然后利用`emerge -pv`来检查每个软件包是否需要写入`package.mask`

这里还有其他一个脚本，是用来更新这两个文件的，从Gentoo的Wiki上看来的，功能比较完善，值得参考

{% codeblock lang:bash %}
#!/bin/bash

function help {

  echo "Syntax: keyword-file-regen [options]"
  echo "   --update-reg		Update your keywords file"
  echo "   --update-local	Update your portage overlay"
  echo "   --update-masked	Update masked packages"
  echo "   --update-all		Update all of the keywords file"
  exit

}

function start {
	k="/etc/portage/package.keywords"
	if [ -f $k ]
	  then
	    rm $k
	fi
}
function update_reg {
	emerge -puON world |
	grep UD |
	sed -e "s/\[ebuild  *UD\] //g" -e "s/-[0-9].*//" >> $k
}
function update_local {
	emerge -puON world |
	grep "[1]" |
	sed -e "s/\[ebuild  *UD\] //g" -e "s/-[0-9].*//" |
	grep -v "ebuild" |
	sed 's/ /\n/g' >> $k
}
function update_masked {
	b=`emerge -pv world | grep -n exist | sed "s/:.*//"`
	b=$(expr $b + 1)
	emerge -pv world | sed -e "${b}!d" -e 's/ /\n/g' >> $k
	while echo `emerge -pD world` | grep "masked"; do
		emerge -pD world |
		sed -e '/\!\!\!/!d' |
		sed -n '1p' |
		sed -e 's/" .*$//' -e 's/!.*"//' -e "s/-[0-9].*//" -e 's/[=,~,<,>]//' -e 's/[=]//' >> $k
	done
}
function sort_file {
	sort $k -o $k
}

#Options:
if [ ! "$1" ];
  then
    help
fi

while [ "$1" ]; do

  case "$1" in

    --update-reg)
      start
      update_reg
      sort_file;;

    --update-local)
      start
      update_local
      update_reg
      sort_file;;

    --update-masked)
      start
      update_masked
      update_reg
      sort_file;;

    --update-all)
      start
      update_reg
      update_local
      update_masked
      sort_file;;

  esac
  shift

done
{% endcodeblock %}

这个脚本提供了四种功能，更新`package.keywords`，更新`package.mask`，更新`package.use`，全部更新，方法也很简单直接用emerge进行查询

这里还有一个脚本，如果那些unstable的软件变成了stable了，那么package.keywords这样的文件里面有些内容就会过时，如果你要一个一个手动去改的话可能比较麻烦，所以有一个人写了一个自动clean 那些过时脚本的程序，如下：

{% codeblock lang:bash %}
#!/bin/bash

echo "## Showing useless entries in package.keywords..."
while read line; do
        # skip empty or commented out lines
        if [[ $(echo $line | grep ^[^\#$]) == "" ]]; then
                continue
        fi

        # parse the entry from the file
        category=`echo $line | cut -d" " -f1 | sed -e 's/^[<>=]*//' -e 's/\/.*//'`
        package=`echo $line | cut -d" " -f1 | sed  -e 's/^[<>=]*[a-z]*\-[a-z]*\///' -e 's/\-[0-9].*$//'`
        # parse the output of eix
        installed_version=`eix --format '{installedversions}{else}none{}' -C $category -e $package | head -n 1`
        available_versions=`eix --format '' -C $category -e $package | head -n 1`

        if [[ "$installed_version" == "" ]]; then
                echo "$category/$package: Package does not exist (or a problem occured)"
                continue
        fi

        if [[ "$installed_version" == "none" ]]; then
                echo "$category/$package: Package is not installed"
                continue
        fi

        if [[ $(echo $available_versions | grep -P "$installed_version(\s|\[)") == "" ]]; then
                echo "$category/$package: $installed_version is no longer in Portage"
        fi

        if [[ $(echo $available_versions | grep -P "\s$installed_version(\s|\[)") != "" ]]; then
                echo "$category/$package has become stable"
        fi

done < /etc/portage/package.keywords

echo -e "\n## Showing useless entries in package.unmask..."

while read line; do
        if [[ $(echo $line | grep ^[^\#$]) == "" ]]; then
                continue
        fi

        category=`echo $line | cut -d" " -f1 | sed -e 's/^[<>=]*//' -e 's/\/.*//'`
        package=`echo $line | cut -d" " -f1 | sed  -e 's/^[<>=]*[a-z]*\-[a-z]*\///' -e 's/\-[0-9].*$//'`
        installed_version=`eix --format '{installedversions}{else}none{}' -C $category -e $package | head -n 1`
        available_versions=`eix --format '' -C $category -e $package | head -n 1`

        if [[ "$installed_version" == "" ]]; then
                echo "$category/$package: Package does not exist (or a problem occured)"
                continue
        fi

        if [[ "$installed_version" == "none" ]]; then
                echo "$category/$package: Package is not installed"
                continue
        fi

        if [[ $(echo $available_versions | grep -P "$installed_version(\s|\[)") == "" ]]; then
                echo "$category/$package: $installed_version is no longer in portage"
                continue
        fi

        if [[  $(echo $available_versions | grep -P "\[M\]$installed_version(\s|\[)") == "" ]]; then
                echo "$category/$package is no longer masked"
        fi                                                                                                                  

done < /etc/portage/package.unmask
{% endcodeblock %}

具体的做法是用eix去检查每一个keywords里面的内容，如果发现已经变成stable了就自动移除

最后想说的是bash很强大


####参看文献：

[http://www.gentoo-wiki.info/TIP_Easy_cleaning_of_package.keywords](http://www.gentoo-wiki.info/TIP_Easy_cleaning_of_package.keywords)

[http://www.gentoo-wiki.info/ERROR_Invalid_atom_in_/etc/portage/package.keywords#Generate_package.keywords_from_installed_packages](http://www.gentoo-wiki.info/ERROR_Invalid_atom_in_/etc/portage/package.keywords#Generate_package.keywords_from_installed_packages)