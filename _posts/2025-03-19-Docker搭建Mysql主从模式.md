---
title: "Docker搭建Mysql主从模式"
layout: post
date: 2025-03-19
tags: [docker,mysql]
category: [运维]
author: XieChen
toc:  true
---

## Docker搭建Mysql主从模式

提示：按本教程操作需要有一定的docker基础，涉及到docker容器的拉取、启动、docker-compose容器编排

### 1 拉取MySQL镜像

```shell
docker pull mysql:5.7
```

### 2 创建挂载目录

#### 2.1 创建master容器挂载目录

创建一个目录作为master容器的挂载目录，conf目录挂载配置文件，data目录挂载数据，**新增不同端口的容器只需要在/data/docker/app/mysql目录下新增"容器名+端口号/{conf,data}"目录**，这样命名方便根据不同端口号的容器来查找对应的配置文件和数据

```shell
mkdir -p /data/docker/app/mysql/master-3307/{conf,data}
```

#### 2.2 创建slave容器挂载目录

```shell
mkdir -p /data/docker/app/mysql/slave-3308/{conf,data}
```

### 3 创建测试容器，拷贝并修改配置文件

#### 3.1 先启动个测试容器

```shell
docker run -itd -p 3307:3306 --name mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7
```

#### 3.2 将测试容器的配置文件拷贝到master容器的conf中

```
docker cp mysql:/etc/my.cnf /data/docker/app/mysql/master-3307/conf
```

#### 3.3 删掉刚启动的测试容器

```shell
docker rm -f mysql
```

#### 3.4 拷贝master容器的配置文件生成slave容器的配置文件

```shell
cp -r /data/docker/app/mysql/master-3307/conf/my.cnf /data/docker/app/mysql/slave-3308/conf/my.cnf
```

#### 3.5 修改配置文件

3.5.1 修改master容器的配置文件

```shell
vim /data/docker/app/mysql/master-3307/conf/my.cnf
```

3.5.2 

```properties


# 保持唯一
server_id=1
# 给log起个名字，可以随意，有意义就行
log-bin=master-bin
# 关闭只读模式，对于只读模式的解释看下文
read-only=0

# 配置需要忽略的库（也就是不需要同步），也可以配置多个
binlog-ignore-db=information_schema
binlog-ignore-db=mysql
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
```



### 4 编写docker-compose

提示：yml文件中的"x-配置项: $锚点名 配置内容"，表示自定义一段配置，定义后可用<<: *锚点名来引用该段配置内容

#### 4.1 编写master容器的docker-compose.yml

```yml
cat > /data/docker/app/mysql/master-3307/docker-compose.yml << 'EOF'
version: '3'

x-master-service: &master-config
  image: mysql:5.7
  container_name: mysql-master-3307
  ports:
    - "3307:3306"
  volumes:
    - /data/docker/app/mysql/master-3307/conf/my.cnf:/etc/my.cnf
    - /data/docker/app/mysql/master-3307/data:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - TZ=Asia/Shanghai
  privileged: true
  restart: always

services:
  mysql-master-3307:
    <<: *master-config
EOF
```

#### 4.2 编写slave容器的docker-compose.yml

```yml
cat > /data/docker/app/mysql/slave-3308/docker-compose.yml << 'EOF'
version: '3'

x-slave-service: &slave-config
  image: mysql:5.7
  container_name: mysql-slave-3308
  ports:
    - "3308:3306"
  volumes:
    - /data/docker/app/mysql/slave-3308/conf/my.cnf:/etc/my.cnf
    - /data/docker/app/mysql/slave-3308/data:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - TZ=Asia/Shanghai
  privileged: true
  restart: always

services:
  mysql-slave-3308:
    <<: *slave-config
EOF
```

