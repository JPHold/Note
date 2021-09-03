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