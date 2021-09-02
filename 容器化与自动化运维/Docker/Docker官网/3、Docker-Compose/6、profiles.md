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
记依赖的服务为a，被依赖的服务为b
**depends_on的联动是有规则的：**
1. b没有profile，或b与a同属相同profile

* db-migrations服务依赖db服务，加上db服务没有profile，所以会启动db服务
`docker-compose run db-migrations`
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


* mock-backend服务和phpmyadmin服务都依赖db服务，只有mock-backend服务与之同个profile
```yaml
version: "3.9"
services:
  web:
    image: web

  mock-backend:
    image: backend
    profiles: ["dev"]
    depends_on:
      - db

  db:
    image: mysql
    profiles: ["dev"]

  phpmyadmin:
    image: phpmyadmin
    profiles: ["debug"]
    depends_on:
      - db
```

`docker-compose up -d`
只会启动web服务

`docker-compose up -d mock-backend`
会先启动db服务，再启动mock-backend服务

`docker-compose up phpmyadmin`
启动报错，profile不同：一个是dev，一个是debug

**要解决这个问题，有两种方法**
1. 将db服务也纳入到debug这个profile
2. 利用隐式指定profile的特性，启动phpmyadmin服务，并手动指定另一个profile
`docker-compose --profile dev up phpmyadmin`
`COMPOSE_PROFILES=dev docker-compose up phpmyadmin`