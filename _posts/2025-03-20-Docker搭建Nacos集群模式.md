---
title: "Docker搭建Nacos单节点以及集群模式"
layout: post
date: 2025-03-20
tags: [docker,nacos]
category: [运维]
author: XieChen
toc:  true
---

**前言：**该教程需要在有mysql服务的前提下进行，可以参考博主上一篇文章[Docker搭建Mysql主从模式](https://aka-poetcoder-xc.github.io/xc-blog/%E8%BF%90%E7%BB%B4/2025/03/19/Docker%E6%90%AD%E5%BB%BAMysql%E4%B8%BB%E4%BB%8E%E6%A8%A1%E5%BC%8F/)

## 1 导入nacos相关配置表

注意：nacos相关数据表可能会随着时间更新，如果后面启动容器失败且报sql异常，说明表结构更新了，请前往nacos的github官网查看[sql脚本](https://github.com/alibaba/nacos/blob/master/distribution/conf/mysql-schema.sql)

```mysql
/*
 * Copyright 1999-2018 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
/******************************************/
/*   数据库全名 = nacos_config   */
/*   表名称 = config_info   */
/******************************************/
CREATE DATABASE nacos_config;
USE nacos_config;

/******************************************/
/*   表名称 = config_info                  */
/******************************************/
CREATE TABLE `config_info` (
                               `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
                               `data_id` varchar(255) NOT NULL COMMENT 'data_id',
                               `group_id` varchar(128) DEFAULT NULL COMMENT 'group_id',
                               `content` longtext NOT NULL COMMENT 'content',
                               `md5` varchar(32) DEFAULT NULL COMMENT 'md5',
                               `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
                               `src_user` text COMMENT 'source user',
                               `src_ip` varchar(50) DEFAULT NULL COMMENT 'source ip',
                               `app_name` varchar(128) DEFAULT NULL COMMENT 'app_name',
                               `tenant_id` varchar(128) DEFAULT '' COMMENT '租户字段',
                               `c_desc` varchar(256) DEFAULT NULL COMMENT 'configuration description',
                               `c_use` varchar(64) DEFAULT NULL COMMENT 'configuration usage',
                               `effect` varchar(64) DEFAULT NULL COMMENT '配置生效的描述',
                               `type` varchar(64) DEFAULT NULL COMMENT '配置的类型',
                               `c_schema` text COMMENT '配置的模式',
                               `encrypted_data_key` varchar(1024) NOT NULL DEFAULT '' COMMENT '密钥',
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='config_info';

/******************************************/
/*   表名称 = config_info  since 2.5.0                */
/******************************************/
CREATE TABLE `config_info_gray` (
                                    `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
                                    `data_id` varchar(255) NOT NULL COMMENT 'data_id',
                                    `group_id` varchar(128) NOT NULL COMMENT 'group_id',
                                    `content` longtext NOT NULL COMMENT 'content',
                                    `md5` varchar(32) DEFAULT NULL COMMENT 'md5',
                                    `src_user` text COMMENT 'src_user',
                                    `src_ip` varchar(100) DEFAULT NULL COMMENT 'src_ip',
                                    `gmt_create` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_create',
                                    `gmt_modified` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_modified',
                                    `app_name` varchar(128) DEFAULT NULL COMMENT 'app_name',
                                    `tenant_id` varchar(128) DEFAULT '' COMMENT 'tenant_id',
                                    `gray_name` varchar(128) NOT NULL COMMENT 'gray_name',
                                    `gray_rule` text NOT NULL COMMENT 'gray_rule',
                                    `encrypted_data_key` varchar(256) NOT NULL DEFAULT '' COMMENT 'encrypted_data_key',
                                    PRIMARY KEY (`id`),
                                    UNIQUE KEY `uk_configinfogray_datagrouptenantgray` (`data_id`,`group_id`,`tenant_id`,`gray_name`),
                                    KEY `idx_dataid_gmt_modified` (`data_id`,`gmt_modified`),
                                    KEY `idx_gmt_modified` (`gmt_modified`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='config_info_gray';

/******************************************/
/*   表名称 = config_tags_relation         */
/******************************************/
CREATE TABLE `config_tags_relation` (
                                        `id` bigint(20) NOT NULL COMMENT 'id',
                                        `tag_name` varchar(128) NOT NULL COMMENT 'tag_name',
                                        `tag_type` varchar(64) DEFAULT NULL COMMENT 'tag_type',
                                        `data_id` varchar(255) NOT NULL COMMENT 'data_id',
                                        `group_id` varchar(128) NOT NULL COMMENT 'group_id',
                                        `tenant_id` varchar(128) DEFAULT '' COMMENT 'tenant_id',
                                        `nid` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增长标识',
                                        PRIMARY KEY (`nid`),
                                        UNIQUE KEY `uk_configtagrelation_configidtag` (`id`,`tag_name`,`tag_type`),
                                        KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='config_tag_relation';

/******************************************/
/*   表名称 = group_capacity               */
/******************************************/
CREATE TABLE `group_capacity` (
                                  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                                  `group_id` varchar(128) NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
                                  `quota` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
                                  `usage` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
                                  `max_size` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
                                  `max_aggr_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
                                  `max_aggr_size` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
                                  `max_history_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
                                  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
                                  PRIMARY KEY (`id`),
                                  UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='集群、各Group容量信息表';

/******************************************/
/*   表名称 = his_config_info              */
/******************************************/
CREATE TABLE `his_config_info` (
                                   `id` bigint(20) unsigned NOT NULL COMMENT 'id',
                                   `nid` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增标识',
                                   `data_id` varchar(255) NOT NULL COMMENT 'data_id',
                                   `group_id` varchar(128) NOT NULL COMMENT 'group_id',
                                   `app_name` varchar(128) DEFAULT NULL COMMENT 'app_name',
                                   `content` longtext NOT NULL COMMENT 'content',
                                   `md5` varchar(32) DEFAULT NULL COMMENT 'md5',
                                   `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
                                   `src_user` text COMMENT 'source user',
                                   `src_ip` varchar(50) DEFAULT NULL COMMENT 'source ip',
                                   `op_type` char(10) DEFAULT NULL COMMENT 'operation type',
                                   `tenant_id` varchar(128) DEFAULT '' COMMENT '租户字段',
                                   `encrypted_data_key` varchar(1024) NOT NULL DEFAULT '' COMMENT '密钥',
                                   `publish_type` varchar(50)  DEFAULT 'formal' COMMENT 'publish type gray or formal',
                                   `gray_name` varchar(50)  DEFAULT NULL COMMENT 'gray name',
                                   `ext_info`  longtext DEFAULT NULL COMMENT 'ext info',
                                   PRIMARY KEY (`nid`),
                                   KEY `idx_gmt_create` (`gmt_create`),
                                   KEY `idx_gmt_modified` (`gmt_modified`),
                                   KEY `idx_did` (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='多租户改造';


/******************************************/
/*   表名称 = tenant_capacity              */
/******************************************/
CREATE TABLE `tenant_capacity` (
                                   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                                   `tenant_id` varchar(128) NOT NULL DEFAULT '' COMMENT 'Tenant ID',
                                   `quota` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
                                   `usage` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
                                   `max_size` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
                                   `max_aggr_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
                                   `max_aggr_size` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
                                   `max_history_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
                                   `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
                                   PRIMARY KEY (`id`),
                                   UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='租户容量信息表';


CREATE TABLE `tenant_info` (
                               `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
                               `kp` varchar(128) NOT NULL COMMENT 'kp',
                               `tenant_id` varchar(128) default '' COMMENT 'tenant_id',
                               `tenant_name` varchar(128) default '' COMMENT 'tenant_name',
                               `tenant_desc` varchar(256) DEFAULT NULL COMMENT 'tenant_desc',
                               `create_source` varchar(32) DEFAULT NULL COMMENT 'create_source',
                               `gmt_create` bigint(20) NOT NULL COMMENT '创建时间',
                               `gmt_modified` bigint(20) NOT NULL COMMENT '修改时间',
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`,`tenant_id`),
                               KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='tenant_info';

CREATE TABLE `users` (
                         `username` varchar(50) NOT NULL PRIMARY KEY COMMENT 'username',
                         `password` varchar(500) NOT NULL COMMENT 'password',
                         `enabled` boolean NOT NULL COMMENT 'enabled'
);

CREATE TABLE `roles` (
                         `username` varchar(50) NOT NULL COMMENT 'username',
                         `role` varchar(50) NOT NULL COMMENT 'role',
                         UNIQUE INDEX `idx_user_role` (`username` ASC, `role` ASC) USING BTREE
);

CREATE TABLE `permissions` (
                               `role` varchar(50) NOT NULL COMMENT 'role',
                               `resource` varchar(128) NOT NULL COMMENT 'resource',
                               `action` varchar(8) NOT NULL COMMENT 'action',
                               UNIQUE INDEX `uk_role_permission` (`role`,`resource`,`action`) USING BTREE
);
```

## 2 搭建nacos单节点

### 2.1 拉取nacos镜像

```shell
## 如果是Linux系统拉取nacos/nacos-server镜像
docker pull nacos/nacos-server
## 如果是macOS系统拉取zhusaidong/nacos-server-m1:2.0.3镜像
docker pull zhusaidong/nacos-server-m1:2.0.3
```

### 2.2 创建nacos单节点启动的docker-compose.yml

#### 2.2.1 创建一个目录用于存放nacos容器的相关配置

```
mkdir -p /data/docker/app/nacos/nacos-standalone-8842
```

#### 2.2.2 创建并编写docker-compose.yml

```shell
cat > /data/docker/app/nacos/nacos-standalone-8842/docker-compose.yml << 'EOF'
version: '3'

services:
  nacos-standalone-8842:
    image: nacos/nacos-server
    container_name: nacos-standalone-8842
    environment:
      - PREFER_HOST_MODE=ip # 是否支持hostname，值为：hostname / ip，默认为：ip
      - MODE=standalone # 部署模式，值为：cluster / standalone，默认为：cluster
      - SPRING_DATASOURCE_PLATFORM=mysql # 所用数据库类型
      - MYSQL_SERVICE_HOST=172.26.240.140 # 数据库ip
      - MYSQL_SERVICE_DB_NAME=nacos_config # 数据库名称
      - MYSQL_SERVICE_PORT=3307 # 数据库端口号
      - MYSQL_SERVICE_USER=root # 数据库登录用户
      - MYSQL_SERVICE_PASSWORD=root # 数据库登录密码
      - JVM_XMS=256m
      - JVM_XMX=256m
      - JVM_XMN=256m
    ports:
      - "8842:8848"
    privileged: true
    restart: always
EOF

```

#### 2.2.3 启动单机nacos节点

```
# 前台启动，方便查看日志，观察容器是否启动成功
docker-compose -f /data/docker/app/nacos/nacos-standalone-8842/docker-compose.yml up
# 后台启动
docker-compose -f /data/docker/app/nacos/nacos-standalone-8842/docker-compose.yml up -d
```

## 3 搭建nacos多主机多节点集群

nacos多节点可以是一个主机用docker启动多个节点，也可以是多个主机，每个主机用docker启动多个节点，以下操作以一个主机启动多个docker节点为例，多个主机只需要重复以下操作，更改对应的主机ip即可

### 3.1 为每个节点创建单独目录

在主机上为当前主机的每个容器创建一个单独的文件夹存放对应配置文件以及数据，名称以对外开放的端口号区分

```
mkdir -p /data/docker/app/nacos/{nacos-cluster-8844,nacos-cluster-8846,nacos-cluster-8848}
```

### 3.2 配置每个节点的docker-compose.yml

**注意：端口号的配置一定不能有重复的，如果NACOS_APPLICATION_PORT的=默认端口号8848-n，则ports:下面配置的所有端口号都必须是对应的默认端口号-n，默认端口号可参考[nacos-docker](https://github.com/nacos-group/nacos-docker/blob/master/example/cluster-ip.yaml)的github，目前的四个默认端口号是8848（主服务端口），9848（集群通信端口），9849（gRPC 通信端口），7848（RPC 通信端口 ）**

#### 3.2.2 第一个节点

```shell
cat > /data/docker/app/nacos/nacos-cluster-8844/docker-compose.yml << 'EOF'
services:
  nacos-cluster-8844:
    image: nacos/nacos-server # 所用镜像
    container_name: nacos-cluster-8844 # 节点（容器）名称
    ports:
      - "7844:7844"
      - "8844:8844"
      - "9844:9844"
      - "9845:9845"
    restart: on-failure
    environment:
      - NACOS_SERVER_IP=172.26.240.140 # 主机ip
      - NACOS_APPLICATION_PORT=8844 # nacos主服务端口
      - NACOS_SERVERS=172.26.240.140:8844 172.26.240.140:8846 172.26.240.140:8848 # 集群服务列表
      - SPRING_DATASOURCE_PLATFORM=mysql # 所用数据库类型
      - MYSQL_SERVICE_HOST=172.26.240.140 # 数据库ip
      - MYSQL_SERVICE_DB_NAME=nacos_config # 数据库名称
      - MYSQL_SERVICE_PORT=3307 # 数据库端口号
      - MYSQL_SERVICE_USER=root # 数据库登录用户
      - MYSQL_SERVICE_PASSWORD=root # 数据库登录密码
      - JVM_XMS=128m
      - JVM_XMX=128m
      - JVM_XMN=128m
      - NACOS_AUTH_ENABLE=true #开启鉴权认证
      - NACOS_AUTH_IDENTITY_KEY=nacos #账号
      - NACOS_AUTH_IDENTITY_VALUE=123456 #密码
      - NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789
EOF
```

#### 3.2.3 第二个节点

```shell
cat > /data/docker/app/nacos/nacos-cluster-8846/docker-compose.yml << 'EOF'
services:
  nacos-cluster-8846:
    image: nacos/nacos-server # 所用镜像
    container_name: nacos-cluster-8846 # 节点（容器）名称
    ports:
      - "7846:7846"
      - "8846:8846"
      - "9846:9846"
      - "9847:9847"
    restart: on-failure
    environment:
      - NACOS_SERVER_IP=172.26.240.140 # 主机ip
      - NACOS_APPLICATION_PORT=8846 # nacos主服务端口
      - NACOS_SERVERS=172.26.240.140:8844 172.26.240.140:8846 172.26.240.140:8848 # 集群服务列表
      - SPRING_DATASOURCE_PLATFORM=mysql # 所用数据库类型
      - MYSQL_SERVICE_HOST=172.26.240.140 # 数据库ip
      - MYSQL_SERVICE_DB_NAME=nacos_config # 数据库名称
      - MYSQL_SERVICE_PORT=3307 # 数据库端口号
      - MYSQL_SERVICE_USER=root # 数据库登录用户
      - MYSQL_SERVICE_PASSWORD=root # 数据库登录密码
      - JVM_XMS=128m
      - JVM_XMX=128m
      - JVM_XMN=128m
      - NACOS_AUTH_ENABLE=true #开启鉴权认证
      - NACOS_AUTH_IDENTITY_KEY=nacos #账号
      - NACOS_AUTH_IDENTITY_VALUE=123456 #密码
      - NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789
EOF
```

#### 3.2.4 第三个节点

```shell
cat > /data/docker/app/nacos/nacos-cluster-8848/docker-compose.yml << 'EOF'
services:
  nacos-cluster-8848:
    image: nacos/nacos-server # 所用镜像
    container_name: nacos-cluster-8848 # 节点（容器）名称
    ports:
      - "7848:7848"
      - "8848:8848"
      - "9848:9848"
      - "9849:9849"
    restart: on-failure
    environment:
      - NACOS_SERVER_IP=172.26.240.140 # 主机ip
      - NACOS_APPLICATION_PORT=8848 # nacos主服务端口
      - NACOS_SERVERS=172.26.240.140:8844 172.26.240.140:8846 172.26.240.140:8848 # 集群服务列表
      - SPRING_DATASOURCE_PLATFORM=mysql # 所用数据库类型
      - MYSQL_SERVICE_HOST=172.26.240.140 # 数据库ip
      - MYSQL_SERVICE_DB_NAME=nacos_config # 数据库名称
      - MYSQL_SERVICE_PORT=3307 # 数据库端口号
      - MYSQL_SERVICE_USER=root # 数据库登录用户
      - MYSQL_SERVICE_PASSWORD=root # 数据库登录密码
      - JVM_XMS=128m
      - JVM_XMX=128m
      - JVM_XMN=128m
      - NACOS_AUTH_ENABLE=true #开启鉴权认证
      - NACOS_AUTH_IDENTITY_KEY=nacos #账号
      - NACOS_AUTH_IDENTITY_VALUE=123456 #密码
      - NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789
EOF
```

### 3.3 配置全局的docker-compose.yml

备注：如果没有可以自己建立一个全局的docker-compose.yml用于管理需要一起启动的节点

```shell
# 创建全局docker-compose.yml文件
cat > /data/docker/app/nacos/docker-compose.yml << 'EOF'
services:
  nacos-cluster-8844:
    extends:
      file: /data/docker/app/nacos/nacos-cluster-8844/docker-compose.yml
      service: nacos-cluster-8844
  nacos-cluster-8846:
    extends:
      file: /data/docker/app/nacos/nacos-cluster-8846/docker-compose.yml
      service: nacos-cluster-8846
  nacos-cluster-8848:
    extends:
      file: /data/docker/app/nacos/nacos-cluster-8848/docker-compose.yml
      service: nacos-cluster-8848
EOF
```

## 4 在全局配置管理中启动所有的节点

```shell
docker-compose -f /data/docker/app/nacos/docker-compose.yml up -d
```

## 5 验证是否启动成功

访问ip:port/nacos

![image-20250323131930035](D:\project-xc\xc-blog\img\image-20250323131930035.png)
