[TOC]

# 多个Compose文件覆盖
* **通过-f指定多个Compose文件，并且以第一个-f指定的Compose文件为基础文件（记作a），后面-f指定的Compose文件的路径都相对于a** [[Docker重点]]
* **为何需要基础文件**
	因为覆盖Compose文件的内容，可以是不标准的Compose结构，可以是某个配置片段
* 默认覆盖是**docker-compose.yml**和**docker-compose.override.yml**，这种方式无须指定-f[[Docker重点]]

## 场景
### 不同环境采用不同服务或配置（如dev、release、prod）

#### 默认覆盖demo
**docker-compose.yml** ^b51795
```yaml
web:
  image: example/my_web_app:latest
  depends_on:
    - db
    - cache

db:
  image: postgres:latest

cache:
  image: redis:latest
```

**docker-compose.override.yml**
```yaml
web:
  build: .
  volumes:
    - '.:/code'
  ports:
    - 8883:80
  environment:
    DEBUG: 'true'

db:
  command: '-d'
  ports:
    - 5432:5432

cache:
  ports:
    - 6379:6379
```

* 启动`docker-compose up`，自动覆盖
 
#### 指定覆盖demo
以[[#^b51795]]为基础文件，将正式环境的配置片段覆盖进去
[正式环境编写Compose](https://docs.docker.com/compose/production/)
具体看我整理的[[10、生产环境使用Compose]]

**docker-compose.prod.yml**
```yaml
web:
  ports:
    - 80:80
  environment:
    PRODUCTION: 'true'

cache:
  environment:
    TTL: '500'
```

* 启动`docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

## 执行临时任务
**docker-compose.yml**
```yaml
web:
  image: example/my_web_app:latest
  depends_on:
    - db

db:
  image: postgres:latest
```

**docker-compose.admin.yml**
```yaml
    dbadmin:
      build: database_admin/
      depends_on:
        - db
```

* 启动`docker-compose -f docker-compose.yml -f docker-compose.admin.yml run dbadmin db-backup`


# 继承Compose
* extends，在Compose2.1之前支持，但在3.x中不支持[[Docker重点]]
* `volumes_from`和`depends_on`这两个属性不会被继承

### 采用共同配置
**common.yml **
```
services:
  app:
    build: .
    environment:
      CONFIG_FILE_PATH: /code/config
      API_KEY: xxxyyy
    cpu_shares: 5
```

**docker-compose.yml**
```
services:
  webapp:
    extends:
      file: common.yml
      service: app
    command: /code/run_web_app
    ports:
      - 8080:8080
    depends_on:
      - queue
      - db

  queue_worker:
    extends:
      file: common.yml
      service: app
    command: /code/run_worker
    depends_on:
      - queue
```

# 添加or覆盖的规则
## 单个值的属性，直接替换
### `image`
### `command`
### `mem_limit`

## 多个值的属性，合并交集
原始服务：
```
services:
  myservice:
    # ...
    expose:
      - "3000"
```

本地服务：
```
services:
  myservice:
    # ...
    expose:
      - "4000"
      - "5000"
```

结果：
```
services:
  myservice:
    # ...
    expose:
      - "3000"
      - "4000"
      - "5000"
```

### `ports`
### `expose`
### `external_links`
### `dns`
### `dns_search`
### `tmpfs`

## 内层key-value结构，本地定义优先，不替换

* 以本地服务的配置优先
原始服务：
```
services:
  myservice:
    # ...
    environment:
      - FOO=original
      - BAR=original
```

本地服务：
```
services:
  myservice:
    # ...
    environment:
      - BAR=local
      - BAZ=local
```

结果
```
services:
  myservice:
    # ...
    environment:
      - FOO=original
      - BAR=local
      - BAZ=local
```

* volume具备智能替换
原服务的`./original:/bar`和本地服务的`./local:/bar`。容器内部挂载目录都是bar，优先本地服务
原始服务：
```
services:
  myservice:
    # ...
    volumes:
      - ./original:/foo
      - ./original:/bar
```

本地服务：
```
services:
  myservice:
    # ...
    volumes:
      - ./local:/bar
      - ./local:/baz
```

结果：
```
services:
  myservice:
    # ...
    volumes:
      - ./original:/foo
      - ./local:/bar
      - ./local:/baz
```

### `environment`
### `labels`
### `volumes`
### `devices`