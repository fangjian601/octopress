---
layout: post
title: "什么是ifttt"
date: 2011-06-29 13:46
comments: true
categories: [web2.0, sns]
---
这两天一个网站成了推特中文圈的热门话题—— [ifttt.com](http://ifttt.com/ "ifttt")

{% img center /images/uploads/2011/06/ifttt_twitter4.png" 130 130 'ifttt logo'%}


众多推友加入了ifttt task创建大军，同时由于ifttt没有公开注册，必须邀请，所以许多推友也在苦苦求ifttt的邀请码，那么ifttt到底是什么东西呢？下面我将简单介绍一下什么是ifttt，如何使用和一些好玩的ifttt task idea。


###ifttt是什么

**ifttt = if this then that**，翻译成中文就是”如果满足某个条件就做某个事情“，写过程序的人应该知道if语句，ifttt实际上就是一种if语句在现实场景中的延伸。ifttt有如下几个概念：*Task，Triggers，Actions，Channel*。

####Task：

每一个ifttt（if this then that）就是一个task，在电脑面前我们要完成许多的task，而很多task可以用这样的ifttt模式来表现。所以ifttt实际上是一种互联网使用动作的”宏语言“，从很高的抽象层面上对事务做了归纳

<!--more--> 

####Triggers：

Triggers对应了ifttt中的this，也就是”触发条件“，比如某个人在fb上圈了你下，比如有人给你在twitter上发了一个私信，这些都叫做一个trigger

####Actions：

Actions对应了ifttt中的that，是指要完成的事情，比如在fb上发布一条状态，在twitter上更新一条tweet，这些都是action

####Channel：
不管是Triggers，还是Actions，他都是需要Channel作为载体的，比如”某人在fb上圈了你“这个是需要fb平台支持的，这时候fb就是一个channel，同理，”你发布一条新的tweet“是需要twitter这个平台支持的，这时候twitter就是一个channel。ifttt为我们提供了许许多多的channel，这些channel包括了互联网中常用的平台，根据这些channel可以创建出无数个task


###ifttt是如何使用

首先我们来看[ifttt的首页dashboard](http://ifttt.com "ifttt dashboard")：

{% img center /images/uploads/2011/06/ifttt_dashboard.png 477 319 'ifttt dashboard' %}


ifttt [Channel页面](http://ifttt.com/channels "ifttt channels")：

{% img center /images/uploads/2011/06/ifttt_channels.png 472 328 'ifttt channel' %}

其中灰色图标是未被激活的channel，你可以点击任意一个图表进行激活，比如foursquare：

{% img center /images/uploads/2011/06/ifttt_foursquare_channel.png 476 268 'ifttt foursquare channel' %}

某个channel激活以后，会对应了一些triggers和action，比如下面google talk这个channel对应的：

{% img center /images/uploads/2011/06/ifttt_gtalk_channel.png 474 314 'ifttt triggers and actions in google talk channel' %}

也就说Google Talk这个channel，包括的触发事件有：向ifttt的bot发送一个chat，或者带标签的chat，动作则有：收到一个chat（向我发送一个chat），通过这个可以构建许多有意思的task，后面我们会介绍一些。


###如何创建task

下面我们来看如何创建一个task，点击Create可以开始创建task了（*总共分为七步*）：


*首先醒目的是”This“，ifttt旨在强调this这个概念，你只需要点击这个this即可，实际上这是在创建一个channel：*

{% img center /images/uploads/2011/06/ifttt_create_trigger.png 472 144 'ifttt create trigger' %}

*然后我们选取一个channel，这里我们用：如果我发布了一个fb状态，就把这个状态作为tweet发到twitter上，这个task作为我们的例子：*

{% img center /images/uploads/2011/06/ifttt_choose_trigger_channel.png 471 311 'ifttt choose trigger channel' %}

*我们选择facebook这个trigger channel，然后我们要选择trigger：*

{% img center /images/uploads/2011/06/ifttt_choose_trigger.png 470 244 'ifttt choose a trigger' %}

*我们选择New status message by you这个trigger：*

{% img center /images/uploads/2011/06/ifttt_create_trigger_fields.png 470 153 'ifttt create trigger fields' %}

*然后我们要定义action了，也就是that：*

{% img center /images/uploads/2011/06/ifttt_chat.png 445 97 'ifttt chat' %}

*选择action的channel：*

{% img center /images/uploads/2011/06/ifttt_action_channel.png 471 314 'ifttt choose action channel' %}

*我们选择twitter channel，进入action选择：*

{% img center /images/uploads/2011/06/ifttt_choose_twitter_action.png 470 128 'ifttt choose action on twitter channel' %}

*我们选择post a new tweet作为我们的action：*

{% img center /images/uploads/2011/06/ifttt_complete_action_fields.png 477 239 'ifttt complete action fields' %}

*我们需要完成action fields的定义，这里我们可以定义这个tweet的格式，add-ins就是可以添加的一些fields，这些完成之后我们可以点击create action：*

{% img center /images/uploads/2011/06/ifttt_create_task.png 476 258 'ifttt create task' %}

*最后我们只需要create和activate这个task即可，你可以给这个task加一个描述，加上#表示为标签，最后可以通过task面板看到你的task了：*

{% img center /images/uploads/2011/06/ifttt_task_dashboard.png 472 204 'ifttt task dashboard' %}


###有趣的Task Idea

通过上面的流程我们知道了如何在ifttt上创建一个task，由于ifttt上的channel众多，而且有开放API的计划，这么一来的话，第三方应用通过API都可以接入ifttt的channel，所以我们可以把在网上需要做的事情通过ifttt定义自动完成，这是一个很cool的东西。

**下面我将分享一些推友好玩的task idea**

{% blockquote @4everlove http://twitter.com/4everlove/status/85926230452477952 %}
if fav的推里面有链接 then 发送到Instapaper，太适合我这种破手机党了 #ifttt
{% endblockquote %}


{% blockquote @Beichen http://twitter.com/Beichen/status/85921184323084288 %}
ifttt非常实用的一个应用：New fav tweets to evernote
{% endblockquote %}


{% blockquote @Beichen http://twitter.com/Beichen/status/85913271806332928 %}
if某女谈论「失恋」、「男友+讨厌」、「伤心」、「难过」，then 发送一条短信。泡妞必备...
{% endblockquote %}


{% blockquote @guangzhui http://twitter.com/guangzhui/status/85911725643280384 %}
#ifttt 是什么，就是某一天的某一时刻，你朋友喝醉了，在youtube上骂你是sb，然后你就会收到一条推，一条短信，一封邮件，告诉你你是sb，四方会告诉你骂你是sb的人在哪里，calendar会记录这一重要时刻，stocks会告诉你你变成sb后世界股市有什么变化～
{% endblockquote %}


{% blockquote @mranti http://twitter.com/mranti/status/85925246376493056 %}
真实ifttt应用举例：if 在Flickr上，有大家fav的新图，then 立刻把图片下载到我的dropbox里面去。
{% endblockquote %}


{% blockquote @mranti http://twitter.com/mranti/status/85910961856319490 %}
ifttt应用举例：if 某男A和某女B同时check in同一个地方，then 短信我的手机：“A和B有奸情，而且正在进行"。八卦利器啊！
{% endblockquote %}


{% blockquote @hecaitou http://twitter.com/hecaitou/status/85927850749857792 %}
理想状态下的ifttt应用场景：一旦老婆的推上出现“加班”字样，立即激活一条手机短信通知。同时，自动检测谷歌日历，找出几个今晚没有事情的老友。随后，在FB上新建一个活动“今晚喝大酒”，一旦超过3人同意，触发一条订餐消息给餐厅。餐厅查询Evernote，找到这群人最喜欢的菜和酒。
{% endblockquote %}


{% blockquote @laoyang945 http://twitter.com/laoyang945/status/85934348628525058 %}
国宝：自从有了ifttt，再也不用翻墙然后手动汇总打印推文了！
{% endblockquote %}


{% blockquote @DorisCafe http://twitter.com/Doriscafe/status/85955278822051840 %}
ifttt应用举例：if 有人推特上mention 我约会，我发了#OK，then自动在我的google calendar上标记约会～
{% endblockquote %}


{% blockquote @hecaitou http://twitter.com/hecaitou/status/85958225618403328 %}
ifttt里面，如果在Channel之上，提供一个Task的自由市场。让各种Geek做出各种奇奇怪怪的Task来，用户添加Task而不是点选Channel，那就连盈利的问题都解决了。
{% endblockquote %}


{% blockquote @wuyagege http://twitter.com/wuyagege/status/86043032910180352 %}
ifttt寂寞宅男玩法：给自己虚拟出一个恋人。她每天给你发短信，发邮件，还会在twitter上@你，有时候还给你看一些美丽的照片，分享一些有趣的图书音乐。（这想法真变态）
{% endblockquote %}


{% blockquote @boatman http://twitter.com/boatman/status/85964040995741696 %}
ifttt神就神在即使被墙，只要设置好this和that的关联性，墙并无法阻止this触发that，除非GFW把所有的channel全部封锁才有可能抑制ifttt，但当ifttt支持自定义channel时，就是神也难救方滨兴。
{% endblockquote %}


{% blockquote @mranti http://twitter.com/mranti/status/85974845216665600 %}
在ifttt的世界里面，各位姑娘小心了，什么恋爱短信啊、花啊、DM关怀啊、贴心礼品啊，都可能是程序的Task算出来的。而且ifttt的世界中，一个人死了，他对一个女生的关心也可以一直持续下去，仿佛天天都在。
{% endblockquote %}


{% blockquote @mranti http://twitter.com/mranti/status/85971398463459328 %}
没人写个短篇小说？假设ifttt成功了，这个世界会变成什么样子？if 有女网友在自曝 and 好看度>1 and 没男友 then 京东360下单买玫瑰送给她 and 短信她“你老漂亮了”。
{% endblockquote %}


###总结

ifttt这样的模式建立在的是国外互联网良好的基础设施之上（各大平台的开放，标准的服务接口等等），所以如果国内需要复制的话，将会有较高的门槛，因为众所周知的是国内的各大平台的开放程度都很差，而且标准不一，所以ifttt很难在国内山寨成功。目前ifttt只能同时激活10个task，这应该是其服务器能力所限，相信后面通过提升服务能力应该可以提供更多的task支持，同时也希望ifttt的api尽快出来，这样的话，其引爆的将是互联网世界中一场”宏语言“革命，本人非常看好之。如果你们有什么好的task idea，我会补充到博文中去：）
