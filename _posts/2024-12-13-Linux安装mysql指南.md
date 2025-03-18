---
title: "Linux安装mysql指南"
date: 2024-12-13
layout: post
tags: [linux, mysql]
category: 运维
author: XieChen
toc:  true
---



## 前言

本文的主要内容是在 Linux 上安装 MySQL，以下内容是源于 B站 - MySQL数据库入门到精通 整理而来。

## 一、概述

MySQL是一种关系型数据库管理系统，所使用的 SQL 语言是用于访问数据库的最常用标准化语言。MySQL 软件采用了双授权政策，分为社区版和商业版，由于其体积小、速度快、总体拥有成本低，尤其是开放源码这一特点，一般中小型和大型网站的开发都选择 MySQL 作为网站数据库。

社区版：免费，但是不提供任何技术支持
商业版：收费，可以试用30天，官方提供技术支持

## 二、下载

官网：https://www.mysql.com/

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/48b916007f7f31bae632ea1f6474ce51.png)

进入官网之后点击 **DOWNLOADS**

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/1f8cebeae353b07061f8cc1307458f0f.png)


进入页面

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/7b0bb3748acc64707d0b8003a6814a49.png)

这里选择 Downloads Archives

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/c130377daed29ed8cdea19c471898770.png)

进入页面，选择 MySQL Community Server

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/974d171adb06684c575df99e7295e3fd.png)


根据你服务器的配置选择，我服务器是 CentOS 7 所以 Operating System 选择 Red Hat Enterprise Linux / Oracle Linux ，OS Version 选择 Red Hat Enterprise Linux 7 / Oracle Linux 7 (x86,64-bit)，选择第一个点击 Download 下载。



----------------------------------------------------

以下我也提供了 MySQL 的安装包供大家使用：

网址：https://pan.baidu.com/s/1yCPRRaSJOMd72NWmSlAGwg

提取码：vf2q

----------------------------------------------------

## 三、安装

连上 Linux 服务器（这里的服务器我用的是云服务器），我先创建一个 mysql 的文件夹来存放安装包。

```
# 在 /soft 目录下创建一个空的文件夹 mysql
mkdir /soft/mysql

# 进入这个新建的文件夹下
cd /soft/mysql
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/1e5584c504d43973039459701566776c.png)

然后上传之前下载好的 Linux 下 MySQL 的安装包，使用 rz 命令（有些终端工具是可以直接上传文件的，比如 FinalShell）

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/ea54cb3cacdc8637198ff80baca90a0e.png)

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/c5e9c1e4e0bef1e5f339bafd6fe8b25a.png)

在该目录下再创建一个文件夹，并且将安装包解压到该文件夹中

```
# 在当前目录下（mysql）下创建一个 mysql-8.0.26 文件夹
mkdir mysql-8.0.26

# 解压安装包到该目录下
tar -xvf mysql-8.0.26-1.el7.x86_64.rpm-bundle.tar -C mysql-8.0.26

```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/60d87a64c287a37e58bdcc05a75d6d5e.png)

解压完成之后可以切换到 mysql-8.0.26 目录下查看解压后的文件

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/a2d36c1755c2c9614035400f007aeed8.png)


可以看到解压后的文件都是 rpm 文件，所以需要用到 rpm 包资源管理器相关的指令安装这些 rpm 的安装包

在安装执行 rpm 安装包之前先下载一些插件，因为 mysql 里面有些 rpm 的安装依赖于该插件。

```
yum install openssl-devel
# 和
yum -y install libaio perl net-tools
```


安装完该插件之后，依次执行以下命令安装这些 rpm 包

```
rpm -ivh mysql-community-common-8.0.26-1.el7.x86_64.rpm 

rpm -ivh mysql-community-client-plugins-8.0.26-1.el7.x86_64.rpm 

rpm -ivh mysql-community-libs-8.0.26-1.el7.x86_64.rpm

rpm -ivh mysql-community-libs-compat-8.0.26-1.el7.x86_64.rpm

rpm -ivh  mysql-community-devel-8.0.26-1.el7.x86_64.rpm

rpm -ivh mysql-community-client-8.0.26-1.el7.x86_64.rpm

rpm -ivh  mysql-community-server-8.0.26-1.el7.x86_64.rpm
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/74d42227197bd866373cdb5e63dc301b.png)

注意：安装 rpm 包时提示 依赖检测失败，请详见文件末尾 可能遇到的问题 寻求解决方案。

在 Linux 中 MySQL 安装好了之后系统会自动的注册一个服务，服务名称叫做 mysqld，所以可以通过以下命令操作 MySQL：

```
# 启动 MySQL 服务：
systemctl start mysqld

# 重启 MySQL 服务：
systemctl restart mysqld

# 关闭 MySQL 服务：
systemctl stop mysqld
```

这里先启动 MySQL 服务，启动需要一点时间，耐心等待一下

```
systemctl start mysqld
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/c703dff23dc6aa126317af02a058d488.png)

rpm 安装 MySQL 会自动生成一个随机密码，可在 /var/log/mysqld.log 这个文件中查找该密码

```
cat /var/log/mysqld.log
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/e6debe24f41d1bdeafadb121e6075b34.png)

A temporay password is generated for root@localhost: ****密码**** ，这里我安装的 MySQL 生成的临时密码是：JAgc=S-:4fGC，账号是 root，有了账号和密码之后就可以连接 MySQL 了。

```
# 连接 MySQL 
mysql -u root -p
```


到此 Linux 上安装 MySQL 基本结束。

## 四、卸载

卸载 MySQL 前需要先停止 MySQL

```
# 卸载MySQL命令
systemctl stop mysqld
```

停止 MySQL 之后查询 MySQL 的安装文件：rpm -qa | grep -i mysql

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/f746f6c9e46ffd99e81a6148af168d35.png)

卸载上述查询出来的所有的 MySQL 安装包

```
rpm -e mysql-community-client-plugins-8.0.26-1.el7.x86_64 --nodeps

rpm -e mysql-community-server-8.0.26-1.el7.x86_64 --nodeps

rpm -e mysql-community-common-8.0.26-1.el7.x86_64 --nodeps

rpm -e mysql-community-libs-8.0.26-1.el7.x86_64 --nodeps

rpm -e mysql-community-client-8.0.26-1.el7.x86_64 --nodeps

rpm -e mysql-community-libs-compat-8.0.26-1.el7.x86_64 --nodeps
```


删除MySQL的数据存放目录

```
rm -rf /var/lib/mysql/
```


删除MySQL的配置文件备份

```
rm -rf /etc/my.cnf.rpmsave
```

## 五、常用设置

**（1）修改 root 用户密码**

如果你觉得 MySQL 自动生成的密码太难记忆的话，可以连接 MySQL 之后进行修改密码

```
ALTER  USER  'root'@'localhost'  IDENTIFIED BY 'mike.8080';
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/83208986afed6b9267aa6ddd1684b4a6.png)

这里可能会提示 **Your password does not satisfy the current policy requirements**，意思是您的密码不符合当前规定的要求，你要么就把你的密码设置得复杂点，要么就去降低密码的校验规则。

在 Linux 上安装 MySQL 时会自动安装一个校验密码的插件，默认密码检查策略要求密码必须包含：大小写字母、数字和特殊符号，并且长度不能少于8位。修改密码时新密码是否符合当前的策略，不满足则会提示ERROR

官网(https://dev.mysql.com/doc/refman/8.0/en/)上能查到这个密码校验的规则，文档中搜索：**validate_password**

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/a24090eb3d7091591507056129efe56a.png)

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/ae36f4fd50cd5e2f8d25dc1901957ec6.png)

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/935fa6360eb327b9be98e58e08af865a.png)

所以可以将这个限制密码位数设小一点，复杂度类型调底一点

```
# 将密码复杂度校验调整简单类型
set global validate_password.policy = 0;

# 设置密码最少位数限制为 4 位
set global validate_password.length = 4;
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/0b5f1b62e7dd0b2c978080019297cc7c.png)

就可以设置较为简单的密码了。

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/c3e448350cbb86ee0baa49af81ff90b8.png)

**（2）创建用户与权限分配**

默认的 root 用户只能当前节点localhost访问，是无法远程访问的，我们还需要创建一个新的账户，用于远程访问

语法格式：

```
CREATE USER <用户名> [ IDENTIFIED ] BY [ PASSWORD ] <口令>

# mysql 8.0 以下
create user 'mike'@'%' IDENTIFIED BY 'mike8080';

# mysql 8.0
create user 'mike'@'%' IDENTIFIED WITH mysql_native_password BY 'mike8080';
```

**PS:** mysql8.0 的默认密码验证不再是 password 。所以在创建用户时，create user ‘username’@‘%’ identified by ‘password’; 客户端是无法连接服务的，所以在创建用户的时候需要加上 WITH mysql_native_password

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/2a27476c4eb1d860e4662c7f25e8d7bb.png)

创建完用户之后还需要给用户分配权限，这里我将 mike 这个用户分配了所有的权限

```
grant all on *.* to 'mike'@'%';
```

关于用户、权限关联这块的内容可参考博客：MySQL 高级 | 用户、权限与角色管理（https://blog.csdn.net/xhmico/article/details/138164322）

## 六、可能遇到的问题

**（1）启动 MySQL 时提示 Failed to start mysqld.service: Unit not found.**

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/8bd78f146ee92c5d3c05eff2324cb520.png)

如果看到这个提示的话说明 mysql 安装失败了，我的建议是卸载重新安装。

**（2）安装 rpm 包时提示 依赖检测失败**

情况一：因 mariadb 导致依赖检测失败

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/b8018de587526946f81c59f3f1cb4cc0.png)

解决办法：卸载mariadb-libs

```
rpm -e mariadb-libs --nodeps
```


再重新安装失败的那个 rpm 包

情况二：因 libcrypto.so.10.. 导致依赖检测失败

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/8e73e0ea79591b5355e0617efb0f4b11.png)

显示缺少了 libcrypto.. 相关的依赖，而 libcrypto.. 存在于 openssl 中，可以通过以下命令查看 openssl 是否安装

```
openssl version
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/b64ed5137e921e515a0c79e53a7a3379.png)

如果没有出现版本信息，则需要安装 openssl，命令如下：

```
yum install openssl
```

如果有版本信息，则查看版本是不是 OpenSSL 1.1.1，OpenSSL 1.1.1 有兼容性的问题，通过

```
ldconfig -p | grep libcrypto.so
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/8405de9ce5d2d4c5beede8bae2dfef0e.png)

或者

```
ls -l /usr/lib64/libcrypto.so
```

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/ddc21131c1c0d7fa93f866d292038159.png)

是能看到有 libcrypto 相关的命令的，只不过是 libcrypto.so.1.1 的

解决办法：compat-openssl10 提供与不支持使用 OpenSSL-1.1 编译的早期版本和软件的兼容性，安装 compat-openssl10

```
yum install compat-openssl10
```

再重新安装失败的那个 rpm 包

**（3）远程连接时出错**

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/e27176b7f4d9a8ffde67d27631bcc3a5.png)

这个错误提示出现的可能有很多，我就列举几个我能想到的吧

首先去检查你的 MySQL 是否关掉了，如果关了的话重启再连接
服务器上面的防火墙是否是开着的状态，或者 3306 的端口是否对外开放
如果你的服务器是云服务器的话，需要去云服务器上面开放 3306 的端口
第一种情况我就不赘述了，如果你的 MySQL 是安装在虚拟机上面的话，简单粗暴的方式是直接关闭防火墙

```
# 关闭防火墙
systemctl stop firewalld.service 

# 查看防火墙的状态
firewall-cmd --state 

# 禁止firewall开机启动
systemctl disable firewalld.service
```

或者为了安全，只开放特定的端口号，MySQL 默认端口是 3306

```
# 关闭防火墙
systemctl stop firewalld.service 

# 3306 端口对外开放
firewall-cmd --remove-port=3306/tcp --permanent 

# 重启防火墙
firewall-cmd --reload
```

但是，如果你 MySQL 并不是安装在虚拟机上的，而是放到云服务器上面，那你必须还得在云服务上面开放这几个端口

比方说我的 MySQL 是运行在 某某云 上面的，我就得做如下设置：

找到我的服务器，点击 更多，选择 管理

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/05ac9d9523ae24aefed3fb182b24b1f1.png)


进入下一个页面之后，选择 防火墙

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/e061f783b5014755e4b1c26799c12dd0.png)

添加 3306 端口对外开放

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/33038fd987ea45405ac7c24a26c42664.png)

测试连接

![在这里插入图片描述](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/15ee37d04984a8d4f4e0189dbf07c9ff.png)

**（4）yum安装镜像失败**

![image-20241213104610978](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20241213104610978.png)

解决方案：更新yum仓库地址

```
# 备份原配置文件
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base-Bak.repo

# 下载新店配置文件
wget -O /etc/yum.repos.d/CentOS-Base.repohttp://mirrors.aliyun.com/repo/Centos-7.repo

# 清除缓存
yum clean all

# 重新缓存配置
yum makecache
```



原文链接：https://blog.csdn.net/xhmico/article/details/125197747
