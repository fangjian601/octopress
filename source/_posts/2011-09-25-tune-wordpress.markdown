---
layout: post
title: "优化Wordpress，提升访问速度"
date: 2011-09-25 19:20
comments: true
categories: [technology, linux, gentoo, wordpress]
---
最近对自己博客的访问速度很不满意，页面load需要十几秒才可以完成，由于只是采用了默认的配置，没有做优化，访问速度很慢。所以周末就琢磨着自己优化一下wordpress，经过一天多的工作，wordpress速度至少提升了3倍左右（后面会有测试数据），下面我就是来介绍我的优化工作，希望能给同样需要优化的朋友一点帮助。


###系统环境


我的服务器是Linode 1024的机器，下面是一些配置信息：

*   操作系统：GNU/Linux Gentoo i686
*   内核版本：2.6.39.1-linode34
*   CPU：Intel(R) Xeon(R) CPU L5520 @ 2.27GHz
*   内存：1G

注：后面所有的优化方案均是基于Gentoo，其他发行版包安装方法，配置文件位置会有不同，优化方案没有变化。

<!--more--> 

###优化方案

影响一个网站的速度因素主要是返回内容过大（返回图片，音视频，样式表等），后台逻辑复杂（动态生成页面频繁，数据IO太多等），因此我们的wordpress优化就是针对这几点来做的优化，主要包括了减少返回内容，减少后台运算逻辑，减少后台数据库和磁盘的请求量几个方面。下图是这次优化的总体方案图（不是很严谨，就是为了方便理解）：


{% img center /images/uploads/2011/09/TuneWordpress1.jpeg 332 281 "Wordpress Tune"%}

####Nginx

相信很多的wordpress服务器是Apache(httpd)，采用mod_php作为php服务。在许多方面，Apache和Nginx在网页处理性能上差别并不大。但是Nginx作为一个更加轻量级，并发性能好，处理静态资源强，占用系统资源少的的web server，对于小型站点来说更加有优势一些。我们采用Nginx作为默认的web server。而后面我们也可以看到，基于Nginx有的功能，我们针对Nginx做了一系列的配置，旨在让Nginx发挥更加出色的性能。


####php-fpm

Nginx需要使用cgi来处理php请求，常用的php cgi软件有[FastCGI](http://www.fastcgi.com/ "FastCGI")，[Spawn-FCGI]("http://redmine.lighttpd.net/projects/spawn-fcgi "Spawn-FCGI")，[PHP-FPM](http://php-fpm.org/ "PHP-FPM")，这里有一篇文章针对这三种cgi做了一个性能评测：[PHP BENCHMARKED: PHP-FPM vs Spawn-FCGI vs FastCGI](http://vpsbible.com/php/php-benchmarking-phpfpm-fastcgi-spawnfcgi/) 。根据文章结果，PHP-FPM性能略占优势，而且php-fpm目前已经被merge到了php官方版本中，用来作为cgi默认管理程序，所以我们就选择PHP-FPM作为我们的默认php cgi


####varnish

[varnish](https://www.varnish-cache.org/ "Varnish")作为[squid](http://www.squid-cache.org/ "Squid")的替代品，是网页缓存服务器，他可以加速网站的访问速度，减少了许多不必要的php文件的重复编译。选择varnish而不是squid，是因为varnish在内存管理上比squid要出色，而且稳定性也还不错，而且比squid配置灵活，扩展性很强，可以作为web server前面的load balancer使用。


####memcached/APC

[APC](http://pecl.php.net/package/APC "APC")是php自带的一个内存对象缓存服务，他的作用可以是可以加快php常用内存数据的访问速度，APC只能在单机环境下使用，而[memcached](http://memcached.org/ "Memcached")作为一个常用的分布式内存对象缓存服务，可以在多台服务器的情况使用，在单机上他跟APC的性能差别并不大，所以如果你是只有一台服务器的话，可以选择任意一个。


####Page Cache

Page Cache是把最近访问到的页面生成静态html并压缩，并设定一个过期时间，这段时间内对这个页面的访问只需要load这个静态html即可。这部分功能与varnish有重叠，但是为了保证varnish在miss掉某个缓存请求之后可以很快返回，我们再做一层cache，以保证响应速度。这部分功能是使用wordpress插件来完成的。


####JS/CSS/HTML Minify

JS/CSS/HTML几乎构成了web server返回内容的绝大部分内容，因此我们需要对几种东西进行压缩处理。首先做过web开发的人肯定知道CSS，JS和HTML都可以通过去掉空格，去掉重复代码来完成压缩，然后我们对网页进行gzip压缩后返回给浏览器，这样返回内容将更加小，这是我们减少页面返回内容的一个办法，这部分功能也是通过wordpress插件来完成


####Browser Cache

浏览器缓存是网站加速的一个很重要的策略，对于许多静态的，基本上不会变动的资源（比如：音视频，图片等），我们可以让浏览器在本地缓存下来，而不要反复请求，现在浏览器在协议层面上都支持缓存，因此我们只要给web服务器提供一套配置既可以完成browser cache


###优化过程

####nginx

首先我们安装Nginx，为了保证与Varnish还有wordpress插件正常使用，我们要包含下面几个nginx模块，你需要在`/etc/portage/package.use`文件中追加如下内容（没有则创建）：

{% codeblock lang:bash %}
www-servers/nginx nginx_modules_http_realip nginx_modules_http_gzip_static
{% endcodeblock %}

其中realip模块是为了让从varnish转发过来的请求中得到正确的ip地址（而不是127.0.0.1这样的内网地址），gzip_static是对html静态资源进行压缩的模块。现在安装nginx

{% codeblock lang:bash %}
$ emerge -av www-servers/nginx
{% endcodeblock %}

接下来我们来对nginx进行配置，这也是最为重要的部分
首先我们来创建一个配置目录`/etc/nginx/conf.d`

{% codeblock lang:bash %}
$ mkdir /etc/nginx/conf.d
{% endcodeblock %}

修改`/etc/nginx/nginx.conf`文件，部分重要内容如下：

{% codeblock lang:text %}
events {
	worker_connections 1024;
	use epoll;
	multi_accept on;
}

http {
	include /etc/nginx/conf.d/wordpress.conf;
	default_type application/octet-stream;

	client_header_timeout 10m;
	client_body_timeout 10m;
	send_timeout 10m;

	connection_pool_size 256;
	#这个尽量设大，因为wordpress WP Minify可能会不能正常工作
	client_header_buffer_size 4k;
	large_client_header_buffers 4 8k;
	request_pool_size 4k;
	#对一些静态资源进行gzip压缩，压缩级别是2，级别太高会导致CPU负载过重
	gzip on;
	gzip_min_length 1100;
	gzip_buffers 4 8k;
	gzip_comp_level 2;
	gzip_proxied any;
	gzip_disable "MSIE [1-6].(?!.*SV1)";
	gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;

	output_buffers 1 32k;
	postpone_output 1460;

	sendfile on;
	tcp_nopush off;
	tcp_nodelay on;
	#使用这个设置是可以得到正常的ip地址
	set_real_ip_from   127.0.0.1;
	real_ip_header     X-Forwarded-For;

	keepalive_timeout 75 20;
	#与php-fpm配合
	upstream php5-fpm-sock {
		server unix:/var/run/php5-fpm.sock;
	}
}
{% endcodeblock %}
完整文件内容见：[http://pastebin.com/p1ALkRvk](http://pastebin.com/p1ALkRvk)

我们刚才完成了nginx的基本配置，现在我们来配置wordpress相关的nginx部分，创建文件`/etc/conf.d/wordpress.conf`，文件内容如下：

{% codeblock lang:text %}
server {
	listen 8080;
	server_name your.server.name;

	access_log /var/log/nginx/your.server.name.access.log combined;
	error_log /var/log/nginx/your.server.name.error.log warn;
	access_log on;

	root /your/wordpress/path/;
	location ~* \.(htaccess)$ {
		deny  all;
	}
	location / {
		client_max_body_size    100m;
		client_body_buffer_size 128k
		#这个规则至关重要，如果没有会导致wordpress permlinks失败，而出现404错误
		try_files $uri $uri/ /index.php?$args;
	}
	location ~ .*.php$ {
		include /etc/nginx/fastcgi.conf;
		include /etc/nginx/fastcgi_params;
	}
	#这个部分是把常用的较大的图片，样式表做一个浏览器缓存
	location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
		expires 24h;
		log_not_found off;
	}
	#这个是WP Super Cache的配置，我们将在后面介绍
	#include /etc/nginx/conf.d/wsc.conf;
}
{% endcodeblock %}

其中`/etc/nginx/fastcgi.conf`文件部分内容如下：

{% codeblock lang:text %}
fastcgi_index index.php;
fastcgi_pass php5-fpm-sock;
fastcgi_intercept_errors        on;
fastcgi_ignore_client_abort     off;
fastcgi_connect_timeout 60;
fastcgi_send_timeout 180;
fastcgi_read_timeout 180;
fastcgi_buffer_size 128k;
fastcgi_buffers 4 256k;
fastcgi_busy_buffers_size 256k;
fastcgi_temp_file_write_size 256k;
{% endcodeblock %}

这里nginx部分基本配置完毕。


####php-fpm

如果需要用php-fpm，需要让dev-lang/php在编译时候包括这个模块，因此你需要在`/etc/portage/package.use`中添加如下一行：

{% codeblock lang:text %}
dev-lang/php fpm cgi force-cgi-redirect
{% endcodeblock %}

然后我们重新编译`dev-lang/php`

{% codeblock lang:bash %}
$ emerge -av dev-lang/php
{% endcodeblock %}

修改php-fpm配置文件`/etc/php/fpm-php5.3/php-fpm.conf`如下：

{% codeblock lang:text %}
error_log = /var/log/php-fpm.log
listen = /var/run/php5-fpm.sock
#使用nignx作为php-fpm的运行user
user = nginx
group = nginx
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
{% endcodeblock %}

注意：上面使用nginx这个用户作为php-fpm的运行user，所以你需要修改你的wordpress目录权限：

{% codeblock lang:bash %}
$ chmod -R 755 /your/wordpress/path
$ chown -R nginx:nginx /your/wordpress/path
{% endcodeblock %}

如果你需要修改php相关配置，可以修改`/etc/php/fpm-php5.3/php.ini`在这里就不再赘述。


####Varnish

首先安装varnish，gentoo现在稳定版的varnish是2.0.1，为了使用3.0.1，你需要在`/etc/portage/package.keywords`中添加一行：

{% codeblock lang:text %}
www-servers/varnish
{% endcodeblock %}

然后我们安装varnish：

{% codeblock lang:bash %}
$ emerge -av www-servers/varnish
{% endcodeblock %}

现在我们配置varnish，首先修改varnish启动参数，修改文件`/etc/conf.d/varnishd`

{% codeblock lang:text %}
VARNISHD_OPTS="-a :80 \
               -f /etc/varnish/wordpress.vcl \
	       -p sess_timeout=30 \
	       -p session_linger=50 \
	       -p thread_pool_add_delay=2 \
	       -p thread_pools=4 \
	       -p thread_pool_min=200 \
	       -p thread_pool_max=4000 \
	       -s file,/var/lib/varnish/$INSTANCE/varnish_storage.bin,1G"
VARNISHNCSA_ARGS="-c -a -w /var/log/varnish/access.log"
{% endcodeblock %}

这里我们让varnish监听80端口，代替nginx，nginx作为后端，现在我们来看`/etc/varnish/wordpress.vcl`文件的内容：

{% codeblock lang:text %}
backend default {
    #nginx服务
    .host = "127.0.0.1";
    .port = "8080";
}
acl purge {
        "localhost";
}
sub vcl_recv {
	#这部分是让后端可以得到真实的ip地址
	if (req.http.x-forwarded-for) {
		set req.http.X-Forwarded-For =
		req.http.X-Forwarded-For + ", " + client.ip;
	} else {
		set req.http.X-Forwarded-For = client.ip;
	}
        if (req.request == "PURGE") {
                if (!client.ip ~ purge) {
                        error 405 "Not allowed.";
                }
                return(lookup);
        }
        #忽略cookie
        if (req.url ~ "^/$") {
               unset req.http.cookie;
        }
}
sub vcl_hit {
        if (req.request == "PURGE") {
                set obj.ttl = 0s;
                error 200 "Purged.";
        }
}
sub vcl_miss {
        if (req.request == "PURGE") {
                error 404 "Not in cache.";
        }
        if (!(req.url ~ "wp-(login|admin)")) {
                unset req.http.cookie;
        }
        if (req.url ~ "^/[^?]+.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.|)$") {
                unset req.http.cookie;
                set req.url = regsub(req.url, "\?.$", "");
        }
        if (req.url ~ "^/$") {
                unset req.http.cookie;
        }
}

sub vcl_fetch {
        if (req.url ~ "^/$") {
                unset beresp.http.set-cookie;
        }
        if (!(req.url ~ "wp-(login|admin)")) {
                unset beresp.http.set-cookie;
        }
}
{% endcodeblock %}


####memcached/APC

安装APC之前你需要给`/etc/portage/package.use`添加如下一行：

{% codeblock lang:text %}
dev-php/pecl-apc mmap
{% endcodeblock %}

mmap这个USE Flag是让APC可以使用超过32MB的内存，现在安装APC：

{% codeblock lang:bash %}
$ emerge -av dev-php/pecl-apc
{% endcodeblock %}

安装完成之后我们需要修改APC的配置文件`/etc/php/fpm-php5.3/ext/apc.ini` 内容如下：

{% codeblock lang:text %}
extension=apc.so
apc.enabled="1"
apc.shm_segments="1"
apc.shm_size="128M"
apc.num_files_hint="1024"
apc.ttl="7200"
apc.user_ttl="7200"
apc.gc_ttl="3600"
apc.cache_by_default="1"
apc.slam_defense="0"
apc.file_update_protection="2"
apc.enable_cli="0"
apc.max_file_size="1M"
apc.stat="1"
apc.write_lock="1"
apc.report_autofilter="0"
apc.include_once_override="0"
apc.rfc1867="0"
apc.rfc1867_prefix="upload_"
apc.rfc1867_name="APC_UPLOAD_PROGRESS"
apc.rfc1867_freq="0"
apc.localcache="0"
apc.localcache.size="512"
apc.coredump_unmap="0"
{% endcodeblock %}

接下来我们安装memcached和php-memcache：

{% codeblock lang:bash %}
$ emerge -av net-misc/memcached dev-libs/libmemcache dev-libs/libmemcached dev-php/pecl-memcache
{% endcodeblock %}

修改memcached服务器配置文件`/etc/conf.d/memcached`

{% codeblock lang:text %}
MEMCACHED_BINARY="/usr/bin/memcached"
MEMUSAGE="256"
MEMCACHED_RUNAS="memcached"
MAXCONN="1024"
LISTENON="127.0.0.1"
PORT="11211"
UDPPORT="${PORT}"
PIDBASE="/var/run/memcached/memcached"
{% endcodeblock %}

这样memcached和APC均已经安装完成


####启动服务

首先我们把上面的服务加入启动脚本：

{% codeblock lang:bash %}
$ rc-update add nginx
$ rc-update add php-fpm
$ rc-update add varnishd
$ rc-update add memcached
{% endcodeblock %}

然后我们启动上述服务：

{% codeblock lang:bash %}
$ /etc/init.d/nginx start
$ /etc/init.d/php-fpm start
$ /etc/init.d/varnishd start
$ /etc/init.d/memcached start
{% endcodeblock %}

你可以去`/var/log`下查看各个服务的启动日志，如果有错误那里可以得到一些信息

现在你可以访问你的blog了，速度应该会有提升，我们下面将介绍wordpress的配置，以配合这套架构


####WP Super Cache插件

wordpress优化插件有很多，其中比较出名的是[WP Total Cache](http://wordpress.org/extend/plugins/w3-total-cache/ "WP Total Cache")和[WP Super Cache](http://wordpress.org/extend/plugins/wp-super-cache/ "WP Super Cache") 。其中前者功能较多，涵盖了优化很多方面，但是由于在使用过程中bug较多，因此就放弃了前者，而采用后者WP Super Cache。

首先我们去wordpress后台plugin-&gt;add new中安装WP Super Cache这个插件，安装好了之后激活他，然后进入WP Super Cache的配置页面

首先是Easy这个tab：

{% img center /images/uploads/2011/09/WP_Super_Cache_Easy.jpg 450 140 'WP Super Cache Easy' %}

选中caching on，然后update status

然后是Advanced这个tab：

{% img center /images/uploads/2011/09/WP_Super_Cache_Advanced.jpg 468 269 'WP Super Cache Advanced' %}

选中写了Recommended的内容，保存内容之后会有一个警告让你修改rewrite规则，WP Super Cache默认支持Apache，所以他给的是.htaccess的内容，Nginx无法使用这个内容，你需要修改/etc/nginx/conf.d/wsc.conf内容如下：

{% codeblock lang:text %}
gzip_static on;
set $supercacheuri "";
set $supercachefile "$document_root/wp-content/cache/supercache/${http_host}${uri}index.html";
if (-e $supercachefile) {
	set $supercacheuri "/wp-content/cache/supercache/${http_host}${uri}index.html";
}
if ($request_method = POST) {
	set $supercacheuri "";
}
if ($query_string) {
	set $supercacheuri "";
}
if ($http_cookie ~* comment_author_|wordpress_logged_in|wp-postpass_) {
	set $supercacheuri "";
}
if ($http_x_wap_profile) {
	set $supercacheuri "";
}

if ($http_profile) {
	set $supercacheuri "";
}

if ($http_user_agent ~* (2.0\ MMP|240x320|400X240|AvantGo|BlackBerry|Blazer|Cellphone|Danger|DoCoMo|Elaine/3.0|EudoraWeb|Googlebot-Mobile|hiptop|IEMobile|KYOCERA/WX310K|LG/U990|MIDP-2.|MMEF20|MOT-V|NetFront|Newt|Nintendo\ Wii|Nitro|Nokia|Opera\ Mini|Palm|PlayStation\ Portable|portalmmm|Proxinet|ProxiNet|SHARP-TQ-GX10|SHG-i900|Small|SonyEricsson|Symbian\ OS|SymbianOS|TS21i-10|UP.Browser|UP.Link|webOS|Windows\ CE|WinWAP|YahooSeeker/M1A1-R2D2|iPhone|iPod|Android|BlackBerry9530|LG-TU915\ Obigo|LGE\ VX|webOS|Nokia5800)) {
	set $supercacheuri "";
}
if ($supercacheuri) {
	rewrite [^/]$ $scheme://$host$uri/ permanent;
	rewrite ^ $supercacheuri break;
}
{% endcodeblock %}

**注：请把`/etc/nginx/conf.d/wordpress.conf`中这行的注释去掉**

{% codeblock lang:text %}
include /etc/nginx/conf.d/wsc.conf;
{% endcodeblock %}

然后我们重启nginx：

{% codeblock lang:bash %}
$ /etc/init.d/nginx restart
{% endcodeblock %}

这样WP Super Cache就配置完了，你可以去Content页面查看目前的Cache的信息：

{% img center /images/uploads/2011/09/WP_Super_Cache_Content.jpg 430 290 'WP Super Cache Content' %}


####WP Minify插件

[WP Minify](http://wordpress.org/extend/plugins/wp-minify/ "WP Minify")是压缩JS/CSS的一个插件，他会把你的JS/CSS合并成一个文件，然后缓存起来，过一段时间再更新，你可以去plugin add new页面搜索这个插件并且安装他，安装完成之后进入配置页面：

{% img center /images/uploads/2011/09/WP_Minify.jpg 562 465 'WP Minify' %}

其中show Advanced Options可以看到更多的选项，你可以在里面清掉JS/CSS/HTML的缓存，这个插件生效之后你每次获取的JS都是压缩过的。

**注：WP Minify可能会遇到400，503等错误，你可以按照这片文章：[Show minify errors through FirePHP来Debug](http://omninoggin.com/wordpress-posts/troubleshooting-wp-minify-with-firephp/)**


####APC Object Cache插件/Memcached Object Cache插件

如果你是使用APC作为Object Cache，你可以使用[APC Object Cache](http://wordpress.org/extend/plugins/apc/)这个插件；如果你是使用Memcached，则使用[Memcached Object Cache](http://wordpress.org/extend/plugins/memcached/)这个插件。安装完成之后**不用Activate**他，执行如下命令：

{% codeblock lang:bash %}
$ cp /your/wordpress/path/wp-content/plugins/apc/object-cache.php /your/wordpress/path/wp-content
{% endcodeblock %}

或者

{% codeblock lang:bash %}
$ cp /your/wordpress/path/wp-content/plugins/memcached/object-cache.php /your/wordpress/path/wp-content
{% endcodeblock %}

这样这个插件就可以使用了
经过上面的辛苦配置，wordpress优化过程完成，接下来我们来进行性能测试。


####WP SmushIt

<a href="http://wordpress.org/extend/plugins/wp-smushit/">WP SmushIt</a>是一个对图片处理的wordpress插件，安装完成之后可以对图片进行优化，使用方法我在这里先不介绍，可以Google

&nbsp;
<h3>三、性能测试</h3>
&nbsp;

[Apache Benchmark](http://httpd.apache.org/docs/2.0/programs/ab.html)是Apache测试HTTP Server性能的一个工具，被广泛使用在各个web服务器测试上，我们采用Apache BenchMark来进行测试。首先需要安装ab

{% codeblock lang:bash %}
$ emerge -av app-admin/apache-tools
{% endcodeblock %}

测试机器信息：
*   CPU：Intel(R) Xeon(R) CPU E5620 @ 2.40GHz
*   内存：24G

**优化前的结果**

{% codeblock lang:text %}
[root@localhost ~]# ab -k -c 32 -n 1000 http://blog.fangjian.me/archives/268
This is ApacheBench, Version 2.0.40-dev  apache-2.0
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Copyright 2006 The Apache Software Foundation, http://www.apache.org/

Benchmarking blog.fangjian.me (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Finished 1000 requests

Server Software:        nginx/1.0.4
Server Hostname:        blog.fangjian.me
Server Port:            80

Document Path:          /?p=268
Document Length:        148166 bytes

Concurrency Level:      32
Time taken for tests:   157.447206 seconds
Complete requests:      1000
Failed requests:        94
   (Connect: 0, Length: 94, Exceptions: 0)
Write errors:           0
Keep-Alive requests:    0
Total transferred:      148491810 bytes
HTML transferred:       148307626 bytes
Requests per second:    6.35 [#/sec] (mean)
Time per request:       5038.311 [ms] (mean)
Time per request:       157.447 [ms] (mean, across all concurrent requests)
Transfer rate:          921.01 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:      180  188   4.0    189     203
Processing:  2537 4781 757.3   4658   14338
Waiting:      510 2692 579.3   2644    5237
Total:       2733 4970 757.9   4845   14538

Percentage of the requests served within a certain time (ms)
  50%   4845
  66%   4971
  75%   5048
  80%   5103
  90%   5353
  95%   6813
  98%   7375
  99%   7664
 100%  14538 (longest request)
 {% endcodeblock %}


**优化后的结果**

{% codeblock lang:text %}
[root@localhost ~]# ab -k -c 32 -n 1000 http://blog.fangjian.me/archives/268
This is ApacheBench, Version 2.0.40-dev  apache-2.0
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Copyright 2006 The Apache Software Foundation, http://www.apache.org/

Benchmarking blog.fangjian.me (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Finished 1000 requests

Server Software:        nginx/1.0.4
Server Hostname:        blog.fangjian.me
Server Port:            80

Document Path:          /archives/268
Document Length:        124186 bytes

Concurrency Level:      32
Time taken for tests:   104.175509 seconds
Complete requests:      1000
Failed requests:        0
Write errors:           0
Keep-Alive requests:    0
Total transferred:      124866999 bytes
HTML transferred:       124523344 bytes
Requests per second:    9.60 [#/sec] (mean)
Time per request:       3333.616 [ms] (mean)
Time per request:       104.176 [ms] (mean, across all concurrent requests)
Transfer rate:          1170.52 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       95  422 905.6    153    9163
Processing:   782 2869 1769.9   2353   10396
Waiting:       95  232 243.7    159    1755
Total:        877 3291 1966.8   2629   13400

Percentage of the requests served within a certain time (ms)
  50%   2629
  66%   3765
  75%   4460
  80%   4892
  90%   5983
  95%   7297
  98%   8582
  99%   9119
 100%  13400 (longest request)
 {% endcodeblock %}
 
我们可以看到，总体响应时间快了3倍左右，waiting时间快了更多，返回大小没有减少多少，是因为这个测试URL图片很多，压缩空间有限，在图片少的页面上，我们的页面压缩效果很明显。

测试结果说明我们的优化起到作用了。


###问题

####WPTouch插件不能完全正常使用

[WPTouch](http://wordpress.org/extend/plugins/wptouch/)是插件是一个当用手持设备浏览wordpress时候，将wordpress变成手持设备方便浏览的主题，非常好的一个插件。理论上来说上文中的WP Super Cache应该可以WPTouch结合使用，但是我这边的页面是首页不能使用WPTouch主题，而其他页面都可以，暂时没有发现解决办法，如果你找到解决办法，希望告诉我。


###工具

####GTMetrix

GTMetrix是一个在线网站页面速度测试工具，他把[Google PageSpeed](http://pagespeed.googlelabs.com)和[Yahoo YSlow](http://developer.yahoo.com/yslow/)结合起来的一个工具，在那里可以看到详细的网站速度报告，并给出优化建议，如下图：

{% img center /images/uploads/2011/09/GTMetrix.jpg 593 409 'GTMetrix' %}


###总结

本次优化花费了我一天半的时间，效果还不错，如果你有其他的优化思路，或者优化过程中遇到了什么问题，欢迎留言讨论。


###参考文章

*   [Running WordPress with nginx, php-fpm, apc and varnish](http://blog.nas-admin.org/?p=25)

*   [Optimizing WordPress with Nginx, Varnish, APC, W3 Total Cache, and Amazon S3 (With Benchmarks)](http://danielmiessler.com/blog/optimizing-wordpress-with-nginx-varnish-w3-total-cache-amazon-s3-and-memcached)

*   [Configuring nginx, php5-fpm and user permissions](http://themesforge.com/performance/configuring-nginx-php5-fpm-and-user-permissions/)

*   [Nignx Configuration For Wordpress](http://codex.wordpress.org/Nginx)