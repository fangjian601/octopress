---
layout: post
title: "Linux inode相关知识"
date: 2010-10-21 00:48
comments: true
categories: [linux, technology]
---
这篇文章主要讲一下Linux底下inode相关的一些知识，同时介绍一下，文件系统上的inode数目是如何计算，如何管理的。

###什么是inode？

inode是文件系统（File System）上的一个概念，是文件系统上用来保存文件信息的一种结构。

从根本上讲， inode 中包含有关文件的所有信息（除了文件的实际名称以及实际数据内容之外），inode包含了如下基本信息（只列出了常用的）：

*   inode 编号——用来识别文件类型， 以及用于 stat C 函数的模式信息
*   文件的链接数目
*   属主的 UID
*   属主的组 ID (GID)
*   文件的大小
*   文件所使用的磁盘块的实际数目
*   最近一次修改的时间
*   最近一次访问的时间
*   最近一次更改的时间

<!--more-->

下图为inode的结构图： 

{% img center /images/uploads/2010/10/inode.jpg 557 501 'inode structure' %}


###Linux下对inode进行查看的方式


df命令查看剩余inode数量

{% codeblock lang:text %}
root@frank-laptop:~$ df -i -h
文件系统            Inode (I)已用 (I)可用 (I)已用% 挂载点
/dev/sda6               3.6M    346K    3.3M   10% /
none                    212K     914    211K    1% /dev
none                    214K      10    214K    1% /dev/shm
none                    214K      78    214K    1% /var/run
none                    214K       4    214K    1% /var/lock
none                    214K       1    214K    1% /lib/init/rw
/dev/sda7               4.8M    301K    4.5M    7% /home
{% endcodeblock %}

这个命令-i的意思是列出inode数目，-h是以一种人们易于理解的方式呈现结果，我们通过这个命令可以看到各个分区inode数目的使用情况。有一个你必须要清楚的是，一旦inode用完，你的文件系统将无法创建任何内容，就算有剩余的空间。这点我相信应该道理很清楚


stat命令查看指定文件信息

{% codeblock lang:text %}
root@frank-laptop:~$ stat /bin/bash
  File: "/bin/bash"
  Size: 818232    	Blocks: 1600       IO Block: 4096   普通文件
Device: 806h/2054d	Inode: 131084      Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2010-10-20 10:22:38.041508828 +0800
Modify: 2010-04-19 09:51:35.000000000 +0800
Change: 2010-05-15 20:06:53.468309411 +0800
{% endcodeblock %}

使用这个命令，我们可以找到特定文件的索引编号，以及其他的 inode 项目，如权限、文件类型、UID、GID、链接的数目（非符号链接）、文件大小和最近一次更新、最近一次修改以及最近一次访问的时间戳。


ls命令

在我们的日常工作中总会碰到这样的情况，难以删除或者管理某些文件，因为这些文件的文件名中使用了短横线或者其他特殊字符、或者其文件名完全不正确。这很可能是有人对该文件进行了错误命名。

因为 UNIX 中的大多数命令，包括开关或者选项在内，都是以连字符 (-) 或者双连字符 (--) 开头的，很难使用诸如 rm、mv 和 cp 之类常用的命令来操作这些文件。幸运的是，某些命令提供了一些选项，以用来显示相关文件所关联的 inode 的索引编号。ls 命令就提供了一个这样的选项：

{% codeblock lang:text %}
root@frank-laptop:~$ ls -i
4456450 examples.desktop  4589605 workspace  4456466 图片  4456460 桌面
 267055 lyrics            4456463 公共的     4456464 文档
4721446 Tencent Files     4456462 模板       4456461 下载
 132716 Ubuntu One        4456467 视频       4456465 音乐
{% endcodeblock %}


find命令

使用 UNIX find 命令，我们可以完成使用 ls 命令所开始的工作。对于要进行操作的文件，您已经知道了它们的索引编号，那么就可以开始进行相应的操作了！

要删除看似无名的文件，我们只需要使用 find 和 -inum 开关对索引编号和文件进行定位。然后，在找到该文件之后，使用 find 和 -exec 开关删除该文件：

{% codeblock lang:text %}
root@frank-laptop:~$ find . -inum 38988 -exec rm {} \;
{% endcodeblock %}

要对该文件进行重命名，可以再次进行相同的操作，但这一次使用 mv 而不是 rm：

{% codeblock lang:text %}
root@frank-laptop:~$ find . -inum 38989 -exec mv {} fileM \;
{% endcodeblock %}


fsck命令

不幸的是，硬件设备不可能一直使用下去，系统可能会在使用多年后出现故障。当发生这种情况，以及由于电源故障或者某些其他问题而导致操作系统异常关闭的时候，您可能会在还原系统备份时碰到一些在崩溃期间处于打开状态的文件，并且现在需要对其加以处理。此时，您可能会碰到一些需要修复 inode 或者存在错误的消息。如果发生这种状况，那么 fsck 命令可以用来救急！您可以使用 fsck 来修复文件系统或者修正受损的 inode ，而不是还原系统、或者甚至重新构建操作系统。

{% codeblock lang:text %}
root@frank-laptop:~$ fsck -t ext4 /dev/sda6 -a
{% endcodeblock %}

fsck时候需要用-t来指定分区文件系统的类型，-a是自动修复，没有这个选项，你可以手动更改inode信息


###如何计算inode

当我们在格式化一个文件系统的时候，格式化程序mkfs会根据blocks数目和每个inode所占的字节数来计算inode数目，具体如何计算的，现在让我们来做一个实验，我们用dd命令创建一个1G大小的磁盘img

{% codeblock lang:text %}
root@frank-laptop:/tmp$ dd if=/dev/zero of=/test.img bs=1M count=1024
记录了1024+0 的读入
记录了1024+0 的写出
1073741824字节(1.1 GB)已复制，17.0225 秒，63.1 MB/秒{% endcodeblock %}
上面这个命令中bs的意思是指blocksize，为1MB，block数目为1024块，总共加起来是1GB
好我们现在用mkfs来创建一个ext3的文件系统，我们可以用-N来指定inode数目，我们可以指定一个很大的值
{% codeblock lang:text %}root@frank-laptop:/tmp$ mkfs.ext3 -N 21420000 test.img
mke2fs 1.41.11 (14-Mar-2010)
test.img is not a block special device.
无论如何也要继续? (y,n) y
mkfs.ext3: inode_size (256) * inodes_count (21420000) too big for a
	filesystem with 262144 blocks, specify higher inode_ratio (-i)
	or lower inode count (-N).
{% endcodeblock %}

我们可以看到提示我们指定的inode数目过于大，使得无法创建文件系统。其中有一个重要信息是inode_size是256，也就是说inode数目最大值应该为：硬盘大小/inode_size。这个inode_size我们可以用-i这个选项来指定，ext3文件系统默认使用256，最小值为128，那么我们来计算一下我们的inode值最大为多少:

{% codeblock lang:text %}
1024x1024x1024/256=4194304
{% endcodeblock %}

理论上来说我们可以指定这么多inode，但是用于文件系统同时需要super block所以我们不可能create这么多inode，不过可以不指定super block试试：

{% codeblock lang:text %}
root@frank-laptop:/tmp$ mkfs.ext3 -m 0 -n -N 4194303 test.img
mke2fs 1.41.11 (14-Mar-2010)
test.img is not a block special device.
无论如何也要继续? (y,n) y
test.img: Cannot create filesystem with requested number of inodes while setting up superblock
{% endcodeblock %}

失败，那么我们把inode值改为最大的一半，再试试

{% codeblock lang:text %}
root@frank-laptop:/tmp$ mkfs.ext3 -N 2097152 test.img
mke2fs 1.41.11 (14-Mar-2010)
test.img is not a block special device.
无论如何也要继续? (y,n) y
文件系统标签=
操作系统:Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
2097152 inodes, 262144 blocks
13107 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=268953600
64 block groups
4120 blocks per group, 4120 fragments per group
32768 inodes per group
Superblock backups stored on blocks:
	4120, 12360, 20600, 28840, 37080, 103000, 111240, 201880

正在写入inode表: 完成
Creating journal (8192 blocks): 完成
Writing superblocks and filesystem accounting information: 完成
This filesystem will be automatically checked every 22 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
{% endcodeblock %}

从上面的输出信息我们可以看出ext3文件系统的块大小为4096，总共262144个块，其中13107为超级块，64个块组，每个块组有4120个块，然后我们可以看到super block是位于哪些块上。

我们挂载这个img之后可以看到还剩下410.3MB的剩余空间，这个我们可以知道inode有一个部分需要存储文件信息，所以剩下够用的空间就只有一部分，所以在inode数目上我们应该有一个权衡，毕竟inode数目太多，可能能够利用的空间就小了

###参考文献

1、[http://www.ibm.com/developerworks/cn/aix/library/au-speakingunix14/](http://www.ibm.com/developerworks/cn/aix/library/au-speakingunix14/)

2、[http://hi.baidu.com/meizhe/blog/item/f1d67aecea47b4d72e2e211b.html](http://hi.baidu.com/meizhe/blog/item/f1d67aecea47b4d72e2e211b.html)