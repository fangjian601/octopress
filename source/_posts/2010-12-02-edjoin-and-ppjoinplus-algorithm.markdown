---
layout: post
title: "字符串近似连接算法——Ed-Join & PPJoin+"
date: 2010-12-02 22:02
comments: true
categories: [technology, algorithm]
---
**什么是字符串近似连接(Similarity Join)**

在说明什么是字符串近似连接之前，首先看看这个例子。我们在使用Google的时候，常常一不小心输错了关键词，这个时候Google会提示我们是不是要找那个关键字，就像下图：

{% img center /images/uploads/2010/12/Selection_030.png 568 239 "Google Did you mean" %}

Google这个“您是不是要找”就是字符串近似连接的一个例子

<!--more-->

另外一个例子，我们在搜索某个东西的时候，经常会有许多网页内容是差不多的，或者说都是从一个网站内容上转载过来的，但是这些内容由于不在一个网站上，因此搜索结果中经常有大量的重复信息，比如下面这个例子：

{% img center /images/uploads/2010/12/Selection_031.png 570 299 'Google Similarity Page' %}

我们看到最后Google把一些重复的结果给省略了，这些省略的结果内容其实是差不多，这个也是字符串连接的一个例子

所谓字符串近似连接就是指：有一个字符串或者文档集合S，我们需要找出这个集合里面满足相似性条件(Edit Distance , Jaccard, Dice, Cosine etc.. 满足某一个域值)的字符串对(String Pair)或者文档对(Document Pair)

本篇文章介绍的两个算法Ed-Join和PPJoin+就是分别用来解决这两个问题的

####Ed-Join


对于上面说的问题，我们有一个很自然的想法就是我枚举所有的字符串对，然后每一个计算[Edit Distance (Levenshtein Distance)](http://www.merriampark.com/ld.htm "Levenshtein Distance")但是这个做法将会导致算法的复杂度为O(n^2)，对于Google或者数据库这种数据集很大应用场景来说基本不可取，所以我们需要对这个算法进行优化，Ed-Join就是基于以下几个方面做的优化：

1. 使用q-gram建立反向链表(Inverted List)

q-gram是一个字符串切分方法，详细资料可以参考[这篇paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.88.1102&amp;rep=rep1&amp;type=pdf "q-gram") 简单说来是这样的：

假如有一个字符串abcde，现在做一个q=2的q-gram切分，将生成一个q-gram集合(ab,bc,cd,de)，也就是把字符串按照字符串的顺序切分成长度为q的子字符串。采用q-gram切分我们可以控制比较粒度，这样对于不同场景灵活性更强，特别是针对不同语言用户来说

那么如何建立反向链表呢？

比如和我有一个字符串集合如：(abcd, abcde, abxy)，首先对每一个元素进行q-gram切分，如q=2时候，这时候我们将有((ab,bc,cd), (ab,bc,cd,de), (ab,bx,xy))，对于每一个gram我们将有一个反向链表：

{% codeblock lang:text %}
ab --> 0,1,2
bc --> 0,1
cd --> 0,1
de --> 1
bx --> 2
xy --> 2
{% endcodeblock %}

也就是说链表里面的元素是每一个出现过该子字符串的字符串id

这么做的好处在哪里？好处在于当我们要查询某个字符串某个部分在那些其他的字符串中出现的时候将会很有效率，这样的话我们就可以通过这种反向链表来评估两个字符串是否是一个可以认为相似的字符串，我们在这里用空间换取了时间上的效率。

其实反向链表的思想已经被应用于许多搜索引擎了，比如[倒排索引](http://zh.wikipedia.org/zh/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95 "倒排索引")就是一个例子


2. 采用前缀过滤(Prefix Filtering)

前缀过滤的想法是这么来的，比如我们想找编辑距离(Edit Distance)小于等于1的字符串对，那么我只需要将这两个字符串按照特定顺序排好序之后，比较前面若干个字符串就可以了，比如：

abxyz和cdwxy这两个字符串，我们只要比较前两个字符串，就可以判断这个字符串必然不满足Edit Distance为1的情况，因为前面两个字符没有任何交集

在这个想法的基础之上，Ed-Join使用了前缀过滤来进行剪枝，算法的核心问题是如何计算前缀长度，算法的伪代码如下：

{% img center /images/uploads/2010/12/Selection_024.png 445 203 'Calculate prefix length' %}

**注：这里left和right分别是Prefix Length的上下界**

{% img center /images/uploads/2010/12/Selection_023.png 442 170 'Min Edit Error' %}

**注：MinEditErrors这个算法是确定对于一个q-gram集合，我们最少可以使用多少次操作将其全部改变(Destroy)**


3. 采用内容过滤(Content Filtering)

内容过滤的想法是用一个窗口(window)去取两个字符串中的子串，然后比较两个子串的L1Distance来确定是不是一个Candidate

L1Distance是这么计算的：

{% img center /images/uploads/2010/12/Selection_027.png 440 102 'L1Distance' %}

也就是对字符串中每一个字符计算其频率直方图，然后求所有字符串频率差的和，比如aab和acd，在第一个字符串中`Fa = 2` `Fb = 1`其余为0，第二个字符串中`Fa = 1` `Fc = 1` `Fd =1`，其余为0 ，这样这两个字符串的L1Distance为`|2-1|+|1-0|+|0-1|+|0-1|=4`

我们不难发现L1Distance有一个性质就是，一个编辑操作最多引起L1Distance变化2，所以L1Distance/2&gt;=thresold也就是我们的域值

所以在上面那个思想的基础之上，我们有了Content Filter

{% img center /images/uploads/2010/12/Selection_026.png 444 310 'Content Filter' %}

这里有一个SumRightErrs就是我们下面要介绍的Suffix Filtering


4. 采用后缀过滤(Suffix Filtering)

Suffix Filtering其实是前缀过滤的一个反向算法，也就是从右至左去取一定数量的子串来进行比较，我们只需要把上面说的前缀过滤算法反过来执行就行了，所以在这里不再赘述

在这里我们就可以得到完整的Ed-Join算法了

{% img center /images/uploads/2010/12/Selection_022.png 445 314 'All-Pairs-Ed' %}

**注：这里应该将第5行替换成CalcPrefixLen**

{% img center /images/uploads/2010/12/Selection_028.png 446 322 'Verify' %}

{% img center /images/uploads/2010/12/Selection_029.png 447 647 'Compare Q-Gram' %}


####PPJoin+

PPJoin+主要是用来刚才说的第二类问题，也就是对于多个文档，我们要找到近似文档

PPJoin+算法的优化策略跟Ed-Join上有很大的相似，都是在反向链表，前缀过滤和后缀过滤的基础之上进行算法优化，只不过PPJoin+针对前缀和后缀的计算方法跟Ed-Join有区别，下面是ppjoin算法的伪代码：

{% img center /images/uploads/2010/12/Selection_016.png 438 454 'ppjoin' %}

**注：把上面的12行替换成下面的部分就变成了PPJoin+算法了：**

{% img center /images/uploads/2010/12/Selection_021.png 433 170 'Replacement of Algorithm 1' %}

{% img center /images/uploads/2010/12/Selection_021.png 'Hamming Distance' %}


下面是Verify函数：

{% img center /images/uploads/2010/12/Selection_018.png 437 328 'verify function for ppjoin+' %}

下面是后缀过滤(Suffix Filtering)函数：

{% img center /images/uploads/2010/12/Selection_019.png 434 354 'Suffix Filter for PPJoin+' %}

Partition函数：

{% img center /images/uploads/2010/12/Selection_020.png 434 354 'Partition Function For PPJoin+' %}


####算法实现
关于这两个算法我做了一个C++ 实现，下载地址[在这里](/downloads/code/2010/12/SimJoin.7z "Ed-Join PPJoin+实现")

使用方法

解压之后执行

{% codeblock lang:bash %}
$ make
{% endcodeblock %}

对于Ed-Join：

{% codeblock lang:bash %}
$ bin/sj path/to/inputfile path/to/outputfile ed num_of_thresold num_of_qgram
{% endcodeblock %}

例如：

{% codeblock lang:bash %}
bin/sj test/input/ed_input.txt test/output/ed_output.txt 1 2
{% endcodeblock %}

对于PPJoin+：

{% codeblock lang:bash %}
$ bin/sj path/to/inputfile path/to/outputfile jc num_of_thresold
{% endcodeblock %}

例如：

{% codeblock lang:bash %}
bin/sj test/input/jc_input.txt test/output/jc_output_0.7.txt 0.7
{% endcodeblock %}

同样的我的包里面提供了测试case，放在`test/input`目录下面

上面的实现只是一个初步的版本，如果有更好的方案欢迎讨论