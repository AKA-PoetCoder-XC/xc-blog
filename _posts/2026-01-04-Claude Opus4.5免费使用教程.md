---

title: "Claude Opus4.5免费使用教程"
layout: post
date: 2026-01-04
tags: [薅羊毛]
category: [未知]
author: XieChen
toc:  true
---

## 一、注册AWS主账号

### 1、注册主账号选择免费计划，获得100$抵扣金

https://signin.aws.amazon.com/signin?redirect_uri=https%3A%2F%2Fus-east-1.console.aws.amazon.com%2Famazonq%2Fdeveloper%2Fhome%3Fca-oauth-flow-id%3De6df%26hashArgs%3D%2523%26isauthcode%3Dtrue%26oauthStart%3D1767492829798%26region%3Dus-east-1%26state%3DhashArgsFromTB_us-east-1_448a272658e62b6e&client_id=arn%3Aaws%3Asignin%3A%3A%3Aconsole%2Fcodewhisperer&forceMobileApp=0&code_challenge=b8_vLFOBjB71cVgA3SENRV3k-I2elulanzEDMMXYkms&code_challenge_method=SHA-256

![image-20260104101427099](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104101427099.png)
![image-20260104101556853](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104101556853.png)

### 2、完成任务获得额外的100$抵扣金，每完成一个任务需要删除任务中创建的云服务，防止继续消耗抵扣金

![image-20260104101832690](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104101832690.png)

## 二、注册IAM子账号

### 1、进入IAM控制台，https://us-east-1.console.aws.amazon.com/singlesignon/home?region=us-east-1

### 2、左侧点击用户，右侧点添加用户

![image-20260104102453477](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102453477.png)

### 3、填写基础信息和邮箱（后续需要邮箱激活子账号)，然后一直点下一步就行了

![image-20260104102742832](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102742832.png)

![image-20260104102757625](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102757625.png)

![image-20260104102815583](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102815583.png)

### 4、添加完成后，列表里会多一个子账号，点进详情可以看到账号未验证

![image-20260104102857640](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102857640.png)

![image-20260104103022079](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104103022079.png)

### 5、进入邮箱点击链接激活账号并设置密码，激活后子账号详细会显示已验证

![image-20260104103923586](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104104929.png)
![img](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/9e5af3fa-84b6-447c-9189-78a8056ff1b5.jpg)

![image-20260104102942465](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102942465.png)

## 三、为子账号开通kiro pro或kiro pro+

### 1、左上角搜索kiro，进入kiro控制台，点击右侧User&Groups，点击左侧Add User添加子账号，选择kiro pro或者kiro pro+

![image-20260104102045378](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102045378.png)
![image-20260104102219135](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102219135.png)
![image-20260104102317967](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104102317967.png)

### 2、这里能搜到刚才注册的子账号，选择子账号并确认

![image-20260104104208934](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104208934.png)
![image-20260104104301170](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104301170.png)

### 四、下载安装kiro并登录子账号

### 1、下载地址：https://kiro.dev/

### 2、安装后打开kiro，选择Sign in with you organization identity

![image-20260104104605456](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104605456.png)


### 3、填写登录地址并继续登录（登录地址在上一步中kiro控制台这里）

![image-20260104104743800](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104743800.png)

![image-20260104104906241](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104104906241.png)


### 4、点击继续后会自动打开一个web页面，填写账号密码进行登录并授权

![image-20260104105015042](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104105015042.png)
![image-20260104105102777](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104105102777.png)

### 5、登录成功后可以在kiro左下角选择claude opus4.5模型，这里能看到自己kiro pro这个月剩余的使用额度，1000不够用就开通kiro pro+

![image-20260104105245420](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104105245420.png)


![image-20260104105329516](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20260104105329516.png)
