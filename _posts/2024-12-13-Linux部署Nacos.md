---
title: "Linux部署Nacos"
date: 2024-12-13
layout: post
tags: [linux, nacos]
category: 运维
author: XieChen
toc:  true
---

学习链接：https://blog.csdn.net/xhmico/article/details/136647509

**注意：Nacos部署需要开放以下四个端口以确保其正常运行**

主端口：默认为8848，用于客户端、控制台及OpenAPI的HTTP通信。
客户端gRPC请求服务端端口：默认为9848，用于客户端向服务端发起gRPC连接和请求。
服务端gRPC请求服务端端口：默认为9849，用于服务间的数据同步和其他服务端之间的通信。
Jraft请求服务端端口：默认为7848，用于处理服务端间的Raft相关请求，比如集群管理中的选主和日志复制等。
在实际部署环境中，至少需要确保主端口（8848）和客户端gRPC端口（9848）对外开放，并且根据实际需求和网络配置，可能也需要开放服务端gRPC请求服务端端口（9849）和Jraft请求服务端端口（7848）。同时，为了保障安全，应当采取相应的安全措施，比如使用防火墙控制访问、启用身份验证和授权、以及加密通信等。

