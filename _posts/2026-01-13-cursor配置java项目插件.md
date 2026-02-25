---
title: "cursor配置java项目插件"
layout: post
date: 2026-01-13
tags: [未知]
category: [未知]
author: XieChen
toc:  true
---

## 一、安装cursor，下载java扩展插件（必须）![img](https://wdcdn.qpic.cn/MTY4ODg1NzMzMjQ2MjAzNQ_16113_YtVqpPWlDD8-0zAz_1768296198?w=1021&h=490&type=image/png)

## 二、下载IDEA快捷键映射插件，方便快速适应新开发工具（可选）![img](https://wdcdn.qpic.cn/MTY4ODg1NzMzMjQ2MjAzNQ_187285_enNtQEYrIebEOgB3_1768296198?w=1004&h=206&type=image/png)

## 三、使用cursor打开项目，在.vscode目录下新建settings.json文件配置![img](https://wdcdn.qpic.cn/MTY4ODg1NzMzMjQ2MjAzNQ_859957_LmrilRZCW6ijfx4F_1768296311?w=1091&h=358&type=image/png)

{

​    // Maven 配置文件路径

​    "java.configuration.maven.globalSettings": "F:\\apache-maven-3.9.3\\conf\\settings.xml",

​    "java.configuration.maven.userSettings": "F:\\apache-maven-3.9.3\\conf\\settings.xml",

​    

​    // Maven 可执行文件路径（如果 Maven 不在系统 PATH 中，需要指定）

​    "maven.executable.path": "F:\\apache-maven-3.9.3\\bin\\mvn.cmd",

​    

​    // 全局 Java 调试 VM 参数（对所有 Java 项目生效）防止读取配置文件乱码启动失败

​    "java.debug.settings.vmArgs": "-Dfile.encoding=UTF-8",

​    // 构建失败不影响启动

​    "java.debug.settings.onBuildFailureProceed": true,

}

## 四、左侧maven插件刷新依赖包，和idea类似

## ![img](https://wdcdn.qpic.cn/MTY4ODg1NzMzMjQ2MjAzNQ_614356_ThqNdTSJzFlrU709_1768296468?w=324&h=451&type=image/png)

## 5、一键启动项目![img](https://wdcdn.qpic.cn/MTY4ODg1NzMzMjQ2MjAzNQ_493088_vZ3e_3YJSSnYAH1Z_1768296716?w=1305&h=655&type=image/png)
