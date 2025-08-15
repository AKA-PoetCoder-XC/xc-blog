---
title: "Docker搭建Mysql主从模式"
layout: post
date: 2025-03-19
tags: [docker,mysql]
category: [运维]
author: XieChen
toc:  true
---

**前言**：按本教程操作需要有一定的docker基础，涉及到docker节点的拉取、启动、docker-compose节点编排

### 1 拉取MySQL镜像

```shell
docker pull mysql:8.0.41
```

### 2 创建挂载目录

#### 2.1 创建master节点挂载目录

创建一个目录作为master节点的挂载目录，conf目录挂载配置文件，data目录挂载数据，**新增不同端口的节点只需要在/data/docker/app/mysql目录下新增"节点名+端口号/{conf,data}"目录**，这样命名方便根据不同端口号的节点来查找对应的配置文件和数据

```shell
mkdir -p /data/docker/app/mysql/mysql-master-3307/{conf,data}
```

#### 2.2 创建slave节点挂载目录

```shell
mkdir -p /data/docker/app/mysql/mysql-slave-3308/{conf,data}
```

### 3 创建测试节点，拷贝并修改配置文件

#### 3.1 先启动个测试节点

```shell
docker run -itd -p 3307:3306 --name mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:8.0.41
```

#### 3.2 将测试节点的配置文件拷贝到master节点的conf中

```shell
docker cp mysql:/etc/my.cnf /data/docker/app/mysql/mysql-master-3307/conf
```

#### 3.3 删掉刚启动的测试节点

```shell
docker rm -f mysql
```

#### 3.4 拷贝master节点的配置文件生成slave节点的配置文件

```shell
cp -r /data/docker/app/mysql/mysql-master-3307/conf/my.cnf /data/docker/app/mysql/mysql-slave-3308/conf/my.cnf
```

#### 3.5 修改配置文件

##### 3.5.1 修改master节点的配置文件

```shell
## 修改master配置
vim /data/docker/app/mysql/mysql-master-3307/conf/my.cnf
```

```properties
# 以下配置必须写在[mysqld]下面，不能写在[client]下，否则失效
# 给个唯一id
server_id=1
# log名称，随便取
log-bin=master-bin
# 关闭只读模式
read-only=0
# 配置不需要同步到slave节点的库
binlog-ignore-db=information_schema
binlog-ignore-db=mysql
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
```

##### 3.5.2 修改slave节点的配置文件

```shell
## 修改slave配置
vim /data/docker/app/mysql/mysql-slave-3308/conf/my.cnf
```

```properties
# 以下配置必须写在[mysqld]下面，不能写在[client]下，否则失效
# 保持唯一
server_id=2
# 开启只读模式
read-only=1
# log名称，随便取
log-bin=slave-bin
```

### 4 编写docker-compose

提示：yml文件中的"x-配置项: $锚点名 配置内容"，表示自定义一段配置，定义后可用<<: *锚点名来引用该段配置内容

#### 4.1 编写master节点的docker-compose.yml

```yml
cat > /data/docker/app/mysql/mysql-master-3307/docker-compose.yml << 'EOF'
x-master-service: &master-config
  image: mysql:8.0.41
  container_name: mysql-master-3307
  ports:
    - "3307:3306"
  volumes:
    - /data/docker/app/mysql/mysql-master-3307/conf/my.cnf:/etc/my.cnf
    - /data/docker/app/mysql/mysql-master-3307/data:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - TZ=Asia/Shanghai
  # 如果已经在my.cnf中配置了以下参数，则可以不用在command中配置
  # command: [
  #   "--server_id=1",
  #   "--log-bin=mysql-bin",
  #   "--binlog-format=ROW",
  #   "--binlog-ignore-db=information_schema",
  #   "--binlog-ignore-db=mysql",
  #   "--binlog-ignore-db=performance_schema",
  #   "--binlog-ignore-db=sys"
  # ]
  privileged: true
  restart: always

services:
  mysql-master-3307:
    <<: *master-config
EOF
```

#### 4.2 编写slave节点的docker-compose.yml

```yml
cat > /data/docker/app/mysql/mysql-slave-3308/docker-compose.yml << 'EOF'
x-slave-service: &slave-config
  image: mysql:8.0.41
  container_name: mysql-slave-3308
  ports:
    - "3308:3306"
  volumes:
    - /data/docker/app/mysql/mysql-slave-3308/conf/my.cnf:/etc/my.cnf
    - /data/docker/app/mysql/mysql-slave-3308/data:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - TZ=Asia/Shanghai
  # 如果已经在my.cnf中配置了以下参数，则可以不用在command中配置
  # command: [
  #   "--server_id=2",
  #   "--read-only=1",
  #   "--log-bin=slave-bin"
  # ]
  privileged: true
  restart: always

services:
  mysql-slave-3308:
    <<: *slave-config
EOF
```

#### 4.3 编写全局docker-compose.yml

```yml
# 创建全局docker-compose.yml文件
cat > /data/docker/app/mysql/docker-compose.yml << 'EOF'
services:
  mysql-master-3307:
    extends:
      file: /data/docker/app/mysql/mysql-master-3307/docker-compose.yml
      service: mysql-master-3307
  mysql-slave-3308:
    extends:
      file: /data/docker/app/mysql/mysql-slave-3308/docker-compose.yml
      service: mysql-slave-3308
      
EOF
```

### 5 docker-compose启动主从节点

```shell
# 进入全局管理目录
cd /data/docker/app/mysql
```

```shell
# 启动节点(-d:后台启动)
docker-compose up -d
```

### 6 在master节点中创建数据同步用户

```shell
# 先进入master节点节点中
docker exec -it mysql-master-3307 bash
```

```shell
# 登录到mysql
mysql -uroot -proot
```

```shell
# 创建一个同步用户slave
create user 'slave'@'%' identified with mysql_native_password by '123456';
```

```shell
# 给这个用户授权
grant replication slave on *.* to 'slave'@'%';
```

```shell
# 刷新访问权限
flush privileges;
```

```shell
# 查看数据库的状态，记录file和position的值，后续要用
show master status;
```

![image-20250319193635074](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20250319193635074.png)

如图所示，**File = master-bin.000004, Position = 749**

```shell
# 退出mysql
exit
# 退出节点
exit
```

### 7 配置slave节点

```shell
# 1.先进入slave节点节点中
docker exec -it mysql-slave-3308 bash
```

```shell
# 2.登录到mysql
mysql -uroot -proot
```

```shell
# 3.设置如下配置
change master to
master_host='172.22.48.227',
master_port=3307,
master_user='slave',
master_password='123456',
get_master_public_key=1,
master_log_file='master-bin.000004',
master_log_pos=749;
```

```shell
# 4.启动slave节点
start slave;
```

```shell
# 5.查看slave的状态
show slave status\G;
```

**注意：**

1 master_host表示master节点的ip

2 master_port表示master节点的端口号，如果上面的ip用的是docker节点的ip，则端口号为3306，如果用的是主机ip，且端口做了映射，则用映射的ip

3 master_user 是前面在master节点中mysql里创建的用于同步数据的用户slave，master_password同理，是slave用户的密码

4 **get_master_public_key=1 这个配置在mysql5.+中不需要，只有在mysql8.+才需要**

5 **master_log_file**是在master节点中进入mysql用show master status命令查出来的File值，**master_log_pos**是该命令查出来对应的Position值，如下图所示：

![image-20250319193635074](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/image-20250319193635074.png)
