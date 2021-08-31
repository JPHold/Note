[TOC]

# 语法
在每个自定义service下，增加profiles属性，支持两种写法
```yaml
	profiles:
	  - debug
```

```yaml
	profiles:["debug"]
```

名称要满足：`[a-zA-Z0-9][a-zA-Z0-9_.-]+`

# 指定profile启动整个compose应用
* 单个profile
**命令形式**
`docker-compose --profile debug up`

**环境变量**
`COMPOSE_PROFILES=debug docker-compose ,debug docker-compose up`

# 隐式指定profile
## 运行带profile的服务，相当于默认指定profile，还会与depends_on产生联动[[重点]]
depends_on的联动是有规则的：
1. 依赖的服务没有profile或与

db-migrations服务依赖db服务，所以会先启动db服务

```yaml
version: "3.9"
services:
  backend:
    image: backend

  db:
    image: mysql

  db-migrations:
    image: backend
    command: myapp migrate
    depends_on:
      - db
    profiles:
      - tools
```

* 启动
`docker-compose run db-migrations`