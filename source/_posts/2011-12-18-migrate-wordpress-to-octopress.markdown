---
layout: post
title: "从wordpress到octopress"
date: 2011-12-18 13:41
comments: true
categories: [technology,wordpress,octopress]
---
[octopress](http://octopress.org/ "octopress")最近很火，twitter上诸多geek都在谈论这个，octopress最为吸引我的地方就是其静态网页的方式，所以在这个诱因驱使之下，决定尝试一把octopress。尝试之后，发现octopress吸引我的地方远不止静态网页这些方式，经过仔细对比，octopress比wordpress更加的适合我


###Wordpress Sucks

wordpress在某种意义上来说很“强大”，庞大的用户群和社区，无数的第三方开发者，许多主机提供商对wordpress的支持等等，对于许多人来说，wordpress几乎可以涵盖各个方面的需求。但是于我来说，wordpress有诸多的不舒服的地方：

<!--more-->

*   **Over Featured** wordpress目标是成为一个内容提供网站快速建站的模板，因此在设计上需要考虑各种各样的需求。对于个人博客来说，许多的设计都是多余而且无意义的。比如用户管理模块，这个对个人博客来说，是一个完全没有必要的东西

*   **速度慢** 对于一般访问量很低的博客来说，wordpress还可以撑住。但是对于一些突发访问很高的情况，wordpress基本上无法撑住。我们也经常可以看到一篇博文被广泛转载之后，主机因为访问过高而无法响应。对于这个问题，我曾经写过一篇wordpress调优的文章：[优化Wordpress，提升访问速度](http://blog.fangjian.me/posts/2011/09/25/tune-wordpress/ "优化Wordpress，提升访问速度")，经过调优之后效果也还不错，但是也还没有发挥出主机的最佳性能。

*   **过度依赖数据库** 个人博客真的需要数据库么？答案是不需要，文章内容可以通过文件管理，用户评论可以使用[Disqus](http://disqus.com "Disqus")，统计数据有[Google Analytics](http://analytics.google.com "Google Analytics")，用户管理？上面说过了，这个模块对于个人博客来说真的不需要。因此wordpress把大量的请求时间放到了不必要的数据库请求上，可谓得不偿失。

*   **可控性较差** wordpress的过于庞大，让你需要个人定制的时候需要花费很多的学习成本，虽然wordpress有插件系统，但是对于很多程序员来说，一些需求是要自己去实现的，但是面对wordpress这个庞大的系统，很难找到一个可以下手的地方，优化的门槛也很高

*   **容错性差** 这个也是跟wordpress过度依赖数据库有关，我在使用wordpress时候最为担心的问题就是，如果数据库挂掉了，我的文章内容是不是都丢失了。因此我利用crontab每天导出数据库的内容来进行备份，wordpress一旦丢失数据库内容，将会是一无所有。。

* **迁移成本高** 你如果换了一个主机，需要迁移wordpress，你会发现是一个很头疼的问题，需要搭建很多环境，需要导数据库，需要修改配置等等，对于一般非技术人来说，迁移成本实在是太高了


###Why Octopress

{% blockquote Octopress http://octopress.org/ %}
A blogging framework for hackers
{% endblockquote %}

那，为什么要选择octopress呢？

*   **纯静态** 这是octopress最大的亮点，没有任何后台操作，只是html+javascript+css，不需要因为后台逻辑过多进行优化。对于Nginx或者Apache来说，每秒处理上万次的html请求，这还是很轻松的事情，所以，就算有突发的访问，octopress是可以很好的保证响应时间的

*   **版本化管理** octopress的操作流程是，先在本地写好一篇博文，然后用octopress提供的工具生成页面，然后通过rsync上传到服务器。因此，你可以把octopress提交到[github](http://github.com "github")上去作为你的一个项目，每次增加博文就是一次commit source的操作，更改也是如此，这样一来有几个好处，你可以查看博文的历史版本，不用担心自己的数据丢失（github帮你保存了数据）

*   **可控性强** octopress本身提供的是一个生成博客的工具+博客的模板，而博客模板代码十分清晰，你可以很容易去定制自己的博客，去掉不必要的东西，增加新的东西。当然这得要求你有编码基础

*   **迁移成本低** octopress几乎没有迁移成本，首先因为是纯html，因此不需要搭建额外的环境，再一个是，octopress的rsync功能，可以让你一键把你的博客同步到任何你想要的服务器上去

* **简洁的Ruby框架** Ruby的gem，rake这些框架使得octopress的操作变得十分容易上手，而且因为ruby语言的诸多优良特性，使得octopress的框架十分的轻便容易

* **Markdown语法** octopress另一个大亮点是，博客使用[Markdown](http://daringfireball.net/projects/markdown/  "Markdown")作为源文件语言。Markdown语言由于其简单，易读和清晰的脉络结构的特点，被许多网站采用，比如[Github](http://github.com "Github")，[Google Code](http://googlecode.com/ "Google Code")，[StackOverflow](http://stackoverflow.com "StackOverflow")，他是一个很好的文档语言，可以写出很漂亮的文档出来


###For Whom

虽然octopress拥有许多令人兴奋的特性，但是他并不是一个大众化的东西，octopress是有其特定的适用人群的：

*   有一定的编码基础，特别是能够理解html，javascript和css，如果有ruby基础那将更好
*   console fans，如果你都没有使用过console的经历，octopress显然不适合你
*   文章内容以plain text居多，少量的图片，如果你是一个需要富媒体体验的人，octopress对于你来说有点简洁
*   使用过git或者hg版本系统的人，将会在octopress上有更好的体验


###How To

下面的内容我将主要介绍如何从wordpress迁移到octopress，希望能够帮到有兴趣迁移的朋友

####初始化设置

这里[官方文档](http://octopress.org/docs/setup/ "Octopress Setup")有很详细的说明，我在这里就不赘述，你可以按照官方文档的内容step by step，如果遇到什么问题欢迎来讨论

####部署设置

[官方文档](http://octopress.org/docs/deploying/ "Octopress Deploying") 介绍了Github Pages、Heroku，Rsync三种部署方法，对于拥有VPS或者共享主机的人来说，应该采用Rsync方法，Rsync的文档见[这里](http://octopress.org/docs/deploying/rsync/ "Octopress Deploying via Rsync")

####版本管理

你可以先去github上新建一个空的Repo（最好是private的，否则可能会被其他人拿到你的source），拿到repo的url，然后到octopress目录下执行下面这些操作：

{% codeblock lang:bash %}
# 因为你是从octopress github上clone的，所以你需要把origin这个branch换一个名字
git remote rename origin octopress
git remote add origin (your github url)
# 把你的github branch作为默认的branch
git config branch.master.remote origin
# 把你的octopress导入到github上去
git push -u origin master
{% endcodeblock %}

如果你新增加了博客或者修改了某些内容，你可以把你的改动commit到github上去：

{% codeblock lang:bash %}
git add source
git commit -a -m 'new blog or edit some blog'
git push -u origin master
{% endcodeblock %}

如果octopress有更新，你可以直接pull octopress这个branch进行更新即可

{% codeblock lang:bash %}
git pull octopress master
git push -u origin master
{% endcodeblock %}


####迁移

这一部分也是我要详细说明的部分，这里需要花费你大量的时间。

#####导出Wordpress内容

JekyII的[Github Wiki](https://github.com/mojombo/jekyll/wiki/blog-migrations "Mirations for wordpress")上介绍了通过数据库导出数据的方法，但是，本文还是更加推荐xml导出的方式

去你博客的 `http://blog.example.com/export.php`页面选择导出内容，你可以只选择导出博文，你会得到一个xml文件

#####转换xml

假如你得到的xml文件是wordpress.xml，我们现在开始转换这个xml，下面有几种方法供你选择

_**Jekyll的导出脚本**_

{% codeblock lang:bash %}
cd ~/octopress/source
mkdir _import
gem install open_gem jekyll sequel
cd ~/.rvm/gems/ruby-1.9.2-p290/gems/jekyll-0.11.0/lib/jekyll/migrators
cp wordpressdotcom.rb csv.rb ~/octopress/source/_import/
cd ~/octopress/source
ruby -r './_import/wordpressdotcom.rb' -e 'Jekyll::WordpressDotCom.process("wordpress.xml")'
{% endcodeblock %}

上面内容执行完成之后会在你的_posts下面生成转换好的html文件，但是这些文件是不可以直接拿过来用的，需要修改（后面再讲）

这个导出脚本的不好的地方就是，导出的内容是纯html，不是markdown语法

_**某个导出脚本**_

你可以去[https://gist.github.com/1274521](https://gist.github.com/1274521 "Migration for wordpress")这里下载这个导出脚本，把下载的文件解压之后重命名成wordpress.rb，然后执行下面操作：

{% codeblock lang:bash %}
mkdir ~/octopress/source/_import
mv wordpress.rb ~/octopress/source/_import
cd ~/octopress/source
ruby _import/wordpress.rb wordpress.xml
{% endcodeblock %}

这个脚本会把生成的文件放到_posts下，文件名采用的是日期+wordpress_id的方式（上面的是日期+title），脚本生成的文件是markdown语法的文件。但是你同样不能够直接去使用它


#####修改转换内容

这一步是最为耗时的过程，你首先需要对基本的Markdown语法有一定的了解，中文Markdown语法文档见[这里](http://markdown.tw "Markdown Chinese")，你需要认真阅读以下这个文档

接下来，就是要修改内容。

_**修改博文链接**_

首先你需要修改的是那些博文中指向你其他博文的链接，因为permlinks的改变，使得这些链接可能全部失效，比如，以前的wordpress链接可能是：

{% codeblock lang:text %}
http://blog.example.com/?id=123
{% endcodeblock %}

或者

{% codeblock lang:text %}
http://blog.example.com/archives/123
{% endcodeblock %}

而octopress的permlinks都采用日期+标题的方式，比如本文的链接就是：

{% codeblock lang:text %}
http://blog.fangjian.me/posts/2011/12/18/migrate-wordpress-to-octopress/
{% endcodeblock %}

所以你需要在有这样链接的文章内容处进行修改


_**修改上传的图片路径**_

在wordpress中，你如果插了一张图片，会有这样的路径：

{% codeblock lang:text %}
http://blog.example.com/wp-content/uploads/2011/12/xxx.png
{% endcodeblock %}

这样的话你需要首先把这些上传的内容拷贝到octopress中去：

{% codeblock lang:bash %}
cp -r ~/wordpress/wp-content/uploads ~/octopress/source/
{% endcodeblock %}

如果是跟上面一样的拷贝的话，那么图片链接需要变成：

{% codeblock lang:text %}
http://blog.example.com/uploads/2011/12/xxx.png
{% endcodeblock %}


_**修改代码高亮部分**_

如果你在wordpress中采用了代码高亮的工具，那么你就需要对这部分进行转换。wordpress常见的代码高亮格式是：

{% codeblock lang:xml %}
<pre class="brush:bash">
echo "hello world"
</pre>
{% endcodeblock %}

或者：

{% codeblock lang:xml %}
<pre lang="bash">
echo "hello world"
</pre>
{% endcodeblock %}

octopress原生支持代码高亮，你可以把上面的代码转换为：

{% codeblock lang:text %}
{% raw %}
{% codeblock lang:bash %}
echo "hello world"
{% endcodeblock %}
{% endraw %}
{% endcodeblock %}

更详细的文档，[请见此](http://octopress.org/docs/blogging/code/ "Octopress Code Block")


_**修改wordpress插件代码**_

如果你的wordpress博客中插入了一些只能通过wordpress插件才能解析的代码，你需要将这部分代码改掉或者删除，否则octopress将无法正确解析这些代码


_**Optional: 尽量采用Markdown语法**_

Markdown文档中是可以包含一些html tag的，所以wordpress一些文章中的tag例如&lt;a&gt;、&lt;img&gt;、&lt;strong&gt;、&lt;p&gt;、&lt;span&gt;等等这些都可以被正确解析，但是我在这里建议如果可以使用markdown语法的尽量使用markdown语法，这样源文件变得非常的可读，美观，比如：

将：

{% codeblock lang:html %}
<a href="http://example.com" title="Hello">
Hello World
</a>
{% endcodeblock %}

替换成：

{% codeblock lang:text %}
{% raw %}
[Hello World](http://example.com, "Hello")
{% endraw %}
{% endcodeblock %}

把:

{% codeblock lang:html %}
<img src="/a/b/c/d.jpg"  class= "aligncenter" width=100 height=100 title="Haha" alt="" />
{% endcodeblock %}

替换成：

{% codeblock lang:text %}
{% raw %}
{% img center /a/b/c/d.png 100 100 "Haha" "" %}
{% endraw %}
{% endcodeblock %}

这是Octopress支持的Image Tag方式，详细文档可以见[这里](http://octopress.org/docs/plugins/image-tag/ "Image Tag")


#####完成迁移

如果你把上面说的这些转换工作完成了，那么你基本上就完成了从wordpress到octopress的迁移，你接下来只需要generate和deploy即可：

{% codeblock lang:bash %}
rake generate
rake deploy
{% endcodeblock %}

在deploy之前你也可以在使用`rake preview`在`localhost:4000`上查看预览结果


####修改页面配置

如果你需要修改页面配置，增加导航栏链接，修改header和footer等等，你可以参考[这篇文档](http://octopress.org/docs/theme/template/ "Theming Custom")和[这篇文档](http://octopress.org/docs/theme/styles/ "Changing Styles")，里面会告诉你一些如果修改页面样式的方法。

如果你需要对生成进行配置，你需要修改`_config.yml`文件，可以参考[这个文档](http://octopress.org/docs/configuring/ "Configuring")


####一些问题

_**之前的链接失效**_

从wordpress迁移过来之后，之前的`/?id=123`或者`/archives/123`这样的链接会失效，这样如果别人是通过搜索引擎到你的博客上去的话，就无法访问这些链接了，所以你需要针对这个情况进行特殊处理，可以使用Apache或者Nginx的rewrite方法，我以Nginx作为例子，你可以在`/etc/nginx.conf`里面进行如下配置：

{% codeblock lang:text %}
rewrite /archives/382 http://blog.fangjian.me/posts/2011/10/18/how-to-beat-the-cap-theorem/ permanent;
rewrite /archives/321 http://blog.fangjian.me/posts/2011/09/25/tune-wordpress/ permanent;
{% endcodeblock %}

这是我博客的例子，你可以根据你的url改变来增加这样的规则。rewrite permanent是使用HTTP 302的方式进行跳转，这样搜索引擎会把你新地址记下来，下次搜索的时候地址就会变成现在的地址，所以一段时间后你可以把这个配置去除掉。


_**优化Nginx配置**_

虽然是静态网页，不用刻意优化，但是为了让nginx达到比较好的性能，可以对他进行简单优化，主要是在页面压缩和浏览器缓存上。

*页面压缩*——在`/etc/nginx.conf`的http这个section增加如下配置：

{% codeblock lang:text %}
gzip on;
gzip_min_length 1100;
gzip_buffers 4 8k;
gzip_comp_level 2;
gzip_proxied any;
gzip_disable "MSIE [1-6].(?!.*SV1)";
gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;
{% endcodeblock %}

*浏览器缓存*——在`/etc/nginx.conf`的server这个section中增加如下配置：

{% codeblock lang:text %}
location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
		expires 30d;
		log_not_found off;
}
{% endcodeblock %}

这样的话，你的网站将会达到一个不错的性能


_**Minify Javascript和CSS**_

octopress生成的javascript和css有一些是没有进行minify的，经过minify后的js和css大小将减少很多，这样浏览器加载页面的时间会缩短，所以，你最好是在deploy之前把js和css压缩一下

我采用的是[YUI Compressor](http://developer.yahoo.com/yui/compressor/ "YUI Compressor")，也就是yahoo的开发者工具，你可以去[这里下载
](http://yuilibrary.com/download/yuicompressor/ "YUI Compressor")，下载完成后执行如下操作：

{% codeblock lang:bash %}
unzip yuicompressor-x.y.z.zip
mkdir ~/.tools
cp yuicompressor-x.y.z/build/yuicompressor-x.y.z.jar ~/.tools
mkdir ~/octopress/scripts
touch ~/octopress/scripts/minify.sh
{% endcodeblock %}

上面`~/octopress/scripts/minify.sh`的内容是：

{% codeblock lang:bash %}
#!/bin/bash
old_pwd=`pwd`
base_dir=`dirname $0`/..
base=`cd $base_dir; pwd`
cd $old_pwd
find $base/public -iname "*.js" | while read file
do
    echo "minifying $file"
    java -jar $HOME/.tools/yuicompressor-x.y.z.jar --type js -o $file $file
done
find $base/public -iname "*.css" | while read file
do
    echo "minifying $file"
    java -jar $HOME/.tools/yuicompressor-x.y.z.jar --type css -o $file $file
done
{% endcodeblock %}

**Note：**把脚本中的x,y,z替换成你的YUI Compressor版本号即可

每次deploy之前执行`sh scripts/minify.sh`即可


###性能评测

整个Octopress部署完成之后，我对octopress进行了一个简单的性能测试，使用[Apache Benchmark(ab)](http://httpd.apache.org/docs/2.0/programs/ab.html "Apache Benchmark")。

服务器的一些信息是：

*   基本信息：Linode JP 1024
*   操作系统：GNU/Linux Gentoo i686
*   内核版本：2.6.39.1-linode34
*   CPU：Intel(R) Xeon(R) CPU L5520 @ 2.27GHz
*   内存：1G

测试命令：

{% codeblock lang:bash %}
ab -c 128 -n 3200 http://blog.fangjian.me/
{% endcodeblock %}

测试结果：

{% codeblock lang:text %}
Server Software:        nginx/1.0.6
Server Hostname:        blog.fangjian.me
Server Port:            80

Document Path:          /
Document Length:        24596 bytes

Concurrency Level:      128
Time taken for tests:   20.244840 seconds
Complete requests:      3200
Failed requests:        0
Write errors:           0
Total transferred:      79652104 bytes
HTML transferred:       78970736 bytes
Requests per second:    158.06 [#/sec] (mean)
Time per request:       809.794 [ms] (mean)
Time per request:       6.327 [ms] (mean, across all concurrent requests)
Transfer rate:          3842.21 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:      179  204 217.9    190    3191
Processing:   539  589 130.0    573    2653
Waiting:      179  190  14.7    190     792
Total:        718  794 252.2    763    3765

Percentage of the requests served within a certain time (ms)
  50%    763
  66%    776
  75%    778
  80%    785
  90%    799
  95%    810
  98%   1504
  99%   1615
 100%   3765 (longest request)
{% endcodeblock %}

从上面结果可以看到，95%的请求都是在800ms左右就返回了，这是一个很不错的速度了。

同样的我使用[Google PageSpeed](http://pagespeed.googlelabs.com/ "Google PageSpeed") 进行了测试，网站得分是92分（100分制），对于个人博客来说这个分数已经很不错了。


###Byword

最后推荐一款Mac下很不错的支持Markdown文本的编辑器——[Byword](http://bywordapp.com/ "Byword")，这个编辑器界面优雅，美观，字体漂亮，而且支持markdown文本预览，是一个很不错的编辑器。

App Store[下载地址](http://bywordapp.com/mas "App Store")


###结语

作为Octopress实验小白鼠，这篇文章实际上是一篇实验报告，经过抉择之后，今后我会一直留在Octopress这个社区中，也许我会做一些插件和主题什么的，现在Octopress社区还在发展中，希望能有更多的Hacker们加入这个社区，同时也希望我这篇文章能够帮到你。
