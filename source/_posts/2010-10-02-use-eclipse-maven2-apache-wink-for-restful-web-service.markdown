---
layout: post
title: "用Eclipse+Maven2+Apache Wink实现RESTful WebService"
date: 2010-10-02 15:27
comments: true
categories: [technology, SOA, linux]
---
由于SOA的作业是实现一个简单的WebService，所以借着这次机会把Eclipse开发SOA的流程走通了。下面在将介绍一下SOA开发的整体流程，不过在开始看这篇文章之前，请首先注意以下几点：

**NOTE：**

1. 本篇文章采用的Eclipse作为开发环境。由于[MyEclipse](http://www.myeclipseide.com "MyEclipse")提供很好的SOA部署功能，如果想要使用MyEclipse的童鞋此文意义不大。（因为本人不希望自己的电脑上出现非开源软件，所以硬着头皮上了）*MyEclipse下载需翻墙*
 
2. 本文所有的测试环境为*Ubuntu 10.04*，后面的内容可能没有考虑Windows系统的情况，但是基本上差别不大
 
好，那么现在开始介绍如何部署。
 
<!--more--> 

###环境准备
 
####下载Eclipse

下载地址为[http://www.eclipse.org/downloads/](http://www.eclipse.org/downloads/ "Eclipse Download Here") 请注意下载*Eclipse IDE for Java EE Developers* 。下载完成后解压至任意目录，会有一个Eclipse文件夹，双击里面的Eclipse可执行文件打开Eclipse
 

####安装相关插件 

*插件安装方法*：

打开Eclipse==&gt;Help==&gt;Install New Software 如下图
 
{% img center /images/uploads/2010/10/Install-_001.png 522 467 'Install New Software' %}
 
可以在type or select site框里面选择要安装的软件的url，如果要新添加url，点击add，如下图：

{% img center /images/uploads/2010/10/Add-Repository-_002.png 384 141 'Add Repository' %}
 
在location里面输入相应的url即可  不过在安装插件之前我们还需要做一件事情，给Eclipse配置代理，由于教育网无法访问国外网，而大部分Eclipse的插件服务器在国外，所以我们需要用代理才能下载。
 
*设置代理*：

Window==&gt;Preferences==&gt;General==&gt;NetWork Connections

{% img center /images/uploads/2010/10/Preferences-_003.png 522 485 'Eclipse Proxy Settings' %} 

{% img center /images/uploads/2010/10/Preferences-_003.png %}

选择一种协议，点击Edit，填入代理服务器，然后把Active Provider设为Manual，设置好后如下图：

{% img center /images/uploads/2010/10/Preferences-_004.png 524 486 'Finish setting proxy' %} 

在这里推荐两个代理：

服务器:edu6.zzzcn.info 端口:2012 (需要支持IPv6，可翻墙，支持HTTPS)

服务器:58.240.237.32   端口:80 (IPv4，不可翻墙，不支持HTTPS，可出国)


*安装相应插件*：

Subclipse：


Subclipse是Eclipse下的版本管理插件，支持SVN，CVS，GIT等多种版本管理系统，我们后面用到的Maven2需要用到Subclipse，安装方法如下：

{% codeblock lang:text %}
Update Site：http://subclipse.tigris.org/update_1.6.x
{% endcodeblock %}

添加site：

{% img center /images/uploads/2010/10/Add-Repository-_005.png 384 141 'Add Subclipse Site' %}

Pending后把三个都选上（这里如果不配置代理可能不能正常工作）：

{% img center /images/uploads/2010/10/Install-_006.png 536 480 'Install Subclipse' %} 

{% img center /images/uploads/2010/10/Install-_006.png %}

然后一路Next（Calculating Requirement and Dependencies可能需要一点时间），注意中间有一个License需要Agree，然后点击Finish

{% img center /images/uploads/2010/10/Installing-Software-_007.png 429 189 'Installing Subclipse' %}

安装完成会问你需不需要Restart，restart即可：

{% img center /images/uploads/2010/10/Software-Updates-_008.png 429 122 'Need Restart Eclipse' %}

重启之后，我们安装下一个插件：


m2eclipse——Maven2 for Eclipse

尽管 Ant 对于构建 Java 程序而言是事实上的标准工具，但这个工具在许多方面都不胜任项目管理任务。相反，Ant 提供的东西，[Maven](http://maven.apache.org/ "Maven")（出自 Apache Jakarta 项目的高级项目管理工具）都能提供，而且更多.
 
m2eclipse是Maven的Eclipse插件，安装方法如下：

{% codeblock lang:text %}
Update Site: http://m2eclipse.sonatype.org/sites/m2e
{% endcodeblock %}
 
这里跟安装Subclipse一样，先Add Site，然后在Pending出来里面选择Maven Integration for Eclipse，然后一路Next下去  同样我们需要安装Maven Optional的组件：

{% codeblock lang:text %}
Update Site： http://m2eclipse.sonatype.org/sites/m2e-extras
{% endcodeblock %}
 
在Pending出来的对话框中选择：Maven SCM Handler for subclipse  然后重启Eclipse，  我们的插件系统就装好了，你可以通过About Eclipse来查看你装的插件
 

####安装Tomcat
 
Ubuntu下安装Tomcat服务器很简单，采用apt-get即可，命令如下：

{% codeblock lang:bash %}
sudo apt-get install tomcat6 tomcat6-*
{% endcodeblock %}

安装完成后需要对Tomcat的管理员密码进行配置，打开`/etc/tomcat6/tomcat-users.xml`，添加你想要的用户名和密码

{% codeblock lang:xml %}
<?xml version='1.0' encoding='utf-8'?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<tomcat-users>

 <role rolename="tomcat"/>
 <role rolename="role1"/>
 <role rolename="admin"/>
 <role rolename="manager"/>
<!--
 <user username="tomcat" password="tomcat" roles="tomcat"/>
 <user username="both" password="tomcat" roles="tomcat,role1"/>
 <user username="role1" password="tomcat" roles="role1"/>
-->
 <user username="admin" password="admin" roles="admin,manager"/>
</tomcat-users>
{% endcodeblock %}

这里添加了两个roles，一个是admin，一个是manager，这两个在后面我们将会用到。同时添加了一个admin，密码为admin  配置好之后，重启tomcat

{% codeblock lang:bash %}
sudo /etc/init.d/tomcat6 restart
{% endcodeblock %}

这样Tomcat就配置好了，你可以访问[http://localhost:8080/](http://localhost:8080/) 来验证是否安装好，如果安装好，会出现It Works!


####安装Maven2 

Maven2 For Linux  Ubuntu下可以通过源来安装，安装命令如下：

{% codeblock lang:bash %}
sudo apt-get maven2
{% endcodeblock %}

安装好之后你可以通过`man mvn`来查看相应的命令参数
 
 
 
####配置Maven 

新建一个xml于`~/.m2/settings.xml`（如果已有则不用新建）添加如下内容：

{% codeblock lang:xml %}
<settings>
 <proxies>
 <proxy>
 <active>true</active>
 <protocol>http</protocol>
 <host>58.240.237.32</host>
 <port>80</port>
 </proxy>
 <proxy>
 <active>true</active>
 <protocol>https</protocol>
 <host>edu6.zzzcn.info</host>
 <port>2012</port>
 </proxy>
 </proxies>
 <servers>
 <server>
 <id>tomcat-localhost</id>
 <username>admin</username>
 <password>admin</password>
 </server>
 </servers>
</settings>
{% endcodeblock %}

其中Proxy是让Maven走Http proxy来下载依赖包，server配置事告诉Maven，tomcat的管理密码是多少
 
好，现在我们的开发环境已经配好，接下来我们来看看怎么实现RESTful程序
 
 
 
###RESTful WebService 实例——Hello World
  
首先打开Eclipse==&gt;File==&gt;New==&gt;Project... 在弹出来的对话框里面选择Maven Project

{% img center /images/uploads/2010/10/New-Project-_009.png 429 350 'New Maven Project' %} 


选择Next，会有Maven Project向导，点击Next，然后可以看到如下：

{% img center /images/uploads/2010/10/New-Maven-Project-_010.png 525 429 'New Maven Project' %} 

出现这个界面需要等一段时间，因为需要从Web上更新Index，如果前面的proxy配置对了就没有问题  然后Next，填写一些必要的信息：

{% img center /images/uploads/2010/10/New-Maven-Project-_011.png 533 436 'New Maven Project' %} 

Project生成后我们可以在Project Explorer上看到我们的项目：

{% img center /images/uploads/2010/10/project_explorer.png 258 381 'Project Explorer' %}

接下来我们要做的是一些修改，双击`pom.xml`，我们可以看到在Editor视图中出现了一个配置窗口

{% img center /images/uploads/2010/10/pom_xml.png 554 304 'pom.xml' %} 

由于我们需要用Apache Wink实现RESTful，所以我们在Dependencies里面需要添加这个  点击Dependencies选项卡，添加如下几个包：

{% img center /images/uploads/2010/10/Select-Dependency-_014.png 377 315 'Select Dependency For Wink Comman' %} 

最后添加效果如下：

{% img center /images/uploads/2010/10/dependencies.png 557 300 'Dependencies' %} 

接下来我们要添加Plugins，用来Build我们的项目  我们需要添加maven-compiler-plugin 、tomcat-maven-plugin和maven-surefire-plugin  这三个插件分别是用来build项目，deploy项目和package项目的

{% img center /images/uploads/2010/10/select_016.png 574 295 %}

我们还需要手动修改一下`pom.xml`，点击最后一个选项卡`pom.xml`，我们要给插件加一些配置

{% codeblock lang:xml %}
<plugin>
 <groupId>org.apache.maven.plugins</groupId>
 <artifactId>maven-compiler-plugin</artifactId>
 <version>2.3.2</version>
 <configuration>
 <source>1.6</source>
 <target>1.6</target>
 </configuration>
 </plugin>
<plugin>
 <groupId>org.apache.maven.plugins</groupId>
 <artifactId>maven-surefire-plugin</artifactId>
 <configuration>
 <additionalClasspathElements>
 <additionalClasspathElement>${basedir}/src/main/webapp/WEB-INF</additionalClasspathElement>
 </additionalClasspathElements>
 </configuration>
 </plugin>
<plugin>
 <groupId>org.codehaus.mojo</groupId>
 <artifactId>tomcat-maven-plugin</artifactId>
 <version>1.0</version>
 <configuration>
 <server>tomcat-localhost</server>
 </configuration>
 </plugin>
<packaging>war</packaging>
{% endcodeblock %}

这里我们看到surefire在用来打包的时候，有一个`webapp/WEB-INF`目录，我们需要新建这个目录，同时还需要新建两个文件，`application`和`web.xml`，如下图所示

{% img center /images/uploads/2010/10/select_018.png 257 610 'Creating web.xml and application file' %}

application文件内容如下：

{% codeblock lang:text %}
me.fangjian.helloworld.HelloWorldApp
{% endcodeblock %}

`web.xml`文件内容下：

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app>
 <display-name>HelloWorld</display-name>
 <description>WebServices of HelloWorld</description>

 <servlet>
 <servlet-name>restSdkService</servlet-name>
 <servlet-class>org.apache.wink.server.internal.servlet.RestServlet</servlet-class>
 <init-param>
 <param-name>applicationConfigLocation</param-name>
 <param-value>/WEB-INF/application</param-value>
 </init-param>
 </servlet>

 <servlet-mapping>
 <servlet-name>restSdkService</servlet-name>
 <url-pattern>/rest/*</url-pattern>
 </servlet-mapping>
</web-app>
{% endcodeblock %}

这两个文件是用来打成war包，以便告诉tomcat如何执行这个包，application告诉tomcat去执行`HelloWorldApp`这个类（后面我们去写），然后告诉tomcat这个Service是依赖`restSdkService`的
 
接下来我们把自动生成的`App.java`删除，新建一个`HelloWorldApp.java`，如下：

{% img center /images/uploads/2010/10/New-Java-Class-_019.png 373 439 'New Java Class' %}

我们开始写我们的`HelloWorldApp`这个类：
 
在写REST时候我们发现有一个错误如下：

{% codeblock lang:text %} 
Multiple markers at this line - Path cannot be resolved to a type - The attribute value is undefined for the annotation type Path - Syntax error, annotations are only available if source level is 1.5  <a href="http://blog.fangjian.me/wp-content/uploads/2010/10/截取选区_020.png"><img class="aligncenter size-full wp-image-78" title="REST error" src="http://blog.fangjian.me/wp-content/uploads/2010/10/截取选区_020.png" alt="" width="552" height="110" /></a> 点击红色的地方，eclipse会自动帮你解决这个问题
{% endcodeblock %}

{% codeblock lang:java %}
package me.fangjian.helloworld;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/hello/{name}")
public class HelloWorldApp {
 /**
 * via http GET
 * return a xml
 * @param name
 * @return HelloWorldResponse
 */
 @GET
 @Produces(MediaType.APPLICATION_XML)
 public HelloWorldResponse getResponse(@PathParam("name")String name){
 return new HelloWorldResponse(name);
 }
}
{% endcodeblock %}

这里我们让后HTTP GET请求返回一个xml，而这个xml由`HelloWorldResponse`这个类定义，这个类代码如下：

{% codeblock lang:java %}
package me.fangjian.helloworld;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "hello")
@XmlAccessorType(XmlAccessType.FIELD)
public class HelloWorldResponse {
 @XmlElement(name = "name")
 private String name;
 @XmlElement(name = "greeting")
 private String greeting;

 public HelloWorldResponse(){}
 public HelloWorldResponse(String name){
 this.name = name;
 this.greeting = "Hello "+name+"!";
 }
 public String getName() {
 return name;
 }
 public void setName(String name) {
 this.name = name;
 }
 public String getGreeting() {
 return greeting;
 }
 public void setGreeting(String greeting) {
 this.greeting = greeting;
 }
}
{% endcodeblock %}

这里我们采用了[JAXB](http://www.oracle.com/technetwork/articles/javase/index-140168.html)来进行XML绑定，具体JAXB的语法我可以Google之，这里就不再赘述
 
**NOTE**：  

JAXB对一个类进行XML绑定 的时候，类必须有一个参数为空的构造函数，如`public HelloWorldResponse()`
 
好，我们的代码写完了，接下来要进行编译，我们不使用m2eclipse提供的编译工具，而是用Terminal进行编译，在Ubuntu终端下我们如下操作：

{% codeblock lang:bash %}
cd ~/workspace/HelloWorld
mvn package
mvn tomcat:deploy
{% endcodeblock %}

第一个命令是进入project，第二个是对project进行打包，第三个是在tomcat上部署  当部署成功后我们可以在浏览器或者采用curl工具看到如下输出：

{% codeblock lang:bash %}
curl -X GET http://localhost:8080/helloworld/rest/hello/fangjian
{% endcodeblock %}

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<hello>
 <name>fangjian</name>
 <greeting>Hello fangjian!</greeting>
</hello>
{% endcodeblock %}

这样我们的HelloWorld WebService就部署完毕了，是不是很容易呢？

###参考资料

1、 [http://www.ibm.com/developerworks/cn/web/wa-useapachewink/?ca=drs-tp4608](http://www.ibm.com/developerworks/cn/web/wa-useapachewink/?ca=drs-tp4608)