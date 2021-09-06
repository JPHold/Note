[TOC]

[Get started with Docker Compose](https://docs.docker.com/compose/gettingstarted/)

python应用+redis，访问计数。
实验如下功能：
* 挂载卷
* 修复主机目录下的代码，无须重新构建和启动，即可完成程序重新部署

# 部署一个简单web应用

## 准备应用程序
```python
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
```

## 准备Dockerfile以制作镜像
```docker
# syntax=docker/dockerfile:1
FROM python:3.7-alpine
WORKDIR /code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask", "run"
```

## 准备docker-compose.yml以定义启动配置
```docker
version: "3.6"
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

### 注意
#### version的配置[[Docker重点]]
* **配置过高会提示错误**
```linux
ERROR: Version in "./docker-compose.yml" is unsupported. You might be seeing this error because you're using the wrong Compose file version. Either specify a supported version (e.g "2.2" or "3.3") and place your service definitions under the `services` key, or omit the `version` key and place your service definitions at the root of the file to use version 1.
For more on the Compose file format versions, see https://docs.docker.com/compose/compose-file/
```
[compose-file](https://docs.docker.com/compose/compose-file/)
version代表一种规范，也代表功能特性，相应地，对engine的要求也做了限制：
![[Pasted image 20210826233111.png]]

**但实际使用中，发现还跟compose版本有关，官方都没有给出对照表，因此导致我只能盲测，engine和compose版本如下[[Docker重点]]**
![[Pasted image 20210826233240.png]]
![[Pasted image 20210826233249.png]]
只能使用3.6的版本



## 启动
`docker-compose up`

* 日志
```linux
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Creating network "hello_default" with the default driver
Building web
Step 1/10 : FROM python:3.7-alpine
3.7-alpine: Pulling from library/python
540db60ca938: Pull complete
a7ad1a75a999: Pull complete
37ce6546d5dd: Pull complete
ec9e91bed5a2: Pull complete
767433e10bb0: Pull complete
Digest: sha256:56cb9e22b1ab2264251c111144f22a2bc83d2404ca30bf4237178f49703ebbb8
Status: Downloaded newer image for python:3.7-alpine
 ---> ec8ed031b5be
Step 2/10 : WORKDIR /code
 ---> Running in ac2473d87a0f
Removing intermediate container ac2473d87a0f
 ---> b6c41b2bb1a3
Step 3/10 : ENV FLASK_APP=app.py
 ---> Running in d039364d612e
Removing intermediate container d039364d612e
 ---> 19cc7e275e06
Step 4/10 : ENV FLASK_RUN_HOST=0.0.0.0
 ---> Running in ab6e94b99601
Removing intermediate container ab6e94b99601
 ---> faac8b1bf288
Step 5/10 : RUN apk add --no-cache gcc musl-dev linux-headers
 ---> Running in efb8e7e5e9f2
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/community/x86_64/APKINDEX.tar.gz
(1/13) Installing libgcc (10.2.1_pre1-r3)
(2/13) Installing libstdc++ (10.2.1_pre1-r3)
(3/13) Installing binutils (2.35.2-r1)
(4/13) Installing libgomp (10.2.1_pre1-r3)
(5/13) Installing libatomic (10.2.1_pre1-r3)
(6/13) Installing libgphobos (10.2.1_pre1-r3)
(7/13) Installing gmp (6.2.1-r0)
(8/13) Installing isl22 (0.22-r0)
(9/13) Installing mpfr4 (4.1.0-r0)
(10/13) Installing mpc1 (1.2.0-r0)
(11/13) Installing gcc (10.2.1_pre1-r3)
(12/13) Installing linux-headers (5.7.8-r0)
(13/13) Installing musl-dev (1.2.2-r0)
Executing busybox-1.32.1-r6.trigger
OK: 139 MiB in 48 packages
Removing intermediate container efb8e7e5e9f2
 ---> 5b4fb98cce61
Step 6/10 : COPY requirements.txt requirements.txt
 ---> f1a8073c6a70
Step 7/10 : RUN pip install -r requirements.txt
 ---> Running in e704b54a2ec5
Collecting flask
  Downloading Flask-1.1.2-py2.py3-none-any.whl (94 kB)
Collecting redis
  Downloading redis-3.5.3-py2.py3-none-any.whl (72 kB)
Collecting itsdangerous>=0.24
  Downloading itsdangerous-1.1.0-py2.py3-none-any.whl (16 kB)
Collecting Werkzeug>=0.15
  Downloading Werkzeug-1.0.1-py2.py3-none-any.whl (298 kB)
Collecting Jinja2>=2.10.1
  Downloading Jinja2-2.11.3-py2.py3-none-any.whl (125 kB)
Collecting click>=5.1
  Downloading click-7.1.2-py2.py3-none-any.whl (82 kB)
Collecting MarkupSafe>=0.23
  Downloading MarkupSafe-1.1.1.tar.gz (19 kB)
Building wheels for collected packages: MarkupSafe
  Building wheel for MarkupSafe (setup.py): started
  Building wheel for MarkupSafe (setup.py): finished with status 'done'
  Created wheel for MarkupSafe: filename=MarkupSafe-1.1.1-cp37-cp37m-linux_x86_64.whl size=17026 sha256=42d42830490762a6753af15887dbfff3e874b8c2b9d41885f6fbbd4a10b375b5
  Stored in directory: /root/.cache/pip/wheels/b9/d9/ae/63bf9056b0a22b13ade9f6b9e08187c1bb71c47ef21a8c9924
Successfully built MarkupSafe
Installing collected packages: MarkupSafe, Werkzeug, Jinja2, itsdangerous, click, redis, flask
Successfully installed Jinja2-2.11.3 MarkupSafe-1.1.1 Werkzeug-1.0.1 click-7.1.2 flask-1.1.2 itsdangerous-1.1.0 redis-3.5.3
WARNING: Running pip as root will break packages and permissions. You should install packages reliably by using venv: https://pip.pypa.io/warnings/venv
Removing intermediate container e704b54a2ec5
 ---> c9b7f28b3dcb
Step 8/10 : EXPOSE 5000
 ---> Running in a3565457473f
Removing intermediate container a3565457473f
 ---> 249f3008ea51
Step 9/10 : COPY . .
 ---> edf589355bc3
Step 10/10 : CMD ["flask", "run"]
 ---> Running in d08bbba9d864
Removing intermediate container d08bbba9d864
 ---> 5c9e24c5d67d

Successfully built 5c9e24c5d67d
Successfully tagged hello_web:latest
WARNING: Image for service web was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Pulling redis (redis:alpine)...
alpine: Pulling from library/redis
540db60ca938: Already exists
29712d301e8c: Pull complete
8173c12df40f: Pull complete
a77b7ddf4978: Pull complete
3f34a000c6b3: Pull complete
275dfaedaf41: Pull complete
Digest: sha256:f8f0e809a4281714c33edf86f6da6cc2d4058c8549e44d8c83303c28b3123072
Status: Downloaded newer image for redis:alpine
Creating hello_web_1   ... done
Creating hello_redis_1 ... done
Attaching to hello_redis_1, hello_web_1
redis_1  | 1:C 09 May 2021 04:58:10.845 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
redis_1  | 1:C 09 May 2021 04:58:10.845 # Redis version=6.2.3, bits=64, commit=00000000, modified=0, pid=1, just started
redis_1  | 1:C 09 May 2021 04:58:10.845 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis_1  | 1:M 09 May 2021 04:58:10.845 * monotonic clock: POSIX clock_gettime
redis_1  | 1:M 09 May 2021 04:58:10.846 * Running mode=standalone, port=6379.
redis_1  | 1:M 09 May 2021 04:58:10.846 # Server initialized
redis_1  | 1:M 09 May 2021 04:58:10.846 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
redis_1  | 1:M 09 May 2021 04:58:10.846 * Ready to accept connections
web_1    |  * Serving Flask app "app.py"
web_1    |  * Environment: production
web_1    |    WARNING: This is a development server. Do not use it in a production deployment.
web_1    |    Use a production WSGI server instead.
web_1    |  * Debug mode: off
web_1    |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
```

## 访问
`http://192.168.187.102:5000`
![[Pasted image 20210826233323.png]]

## 代码更新
**使用volumes**

* 修改docker-compose.yml
在web下增加如下：
```docker
    volumes:
      - .:/code
    environment:
      FLASK_ENV: development
```
![[Pasted image 20210826233402.png]]
`.:/code`是将主机的当前运行目录挂载到容器内部的code目录，**这样就操作主机目录，会同步到容器内部**

修改app.py，将打印语句改成：Hello form Docker
容器日志显示：监听到变更并重新加载
![[Pasted image 20210826233426.png]]

代码的自动更新，应该是环境变量设置导致：`FLASK_ENV: development`
![[Pasted image 20210826233710.png]]

# 其它命令
`docker-compose ps`
查看通过compose启动的容器列表

`docker-compose up -d`
后台启动

`docker-compose run web env`
**一次性启动命令，可理解为不会真实启动和绑定端口，但会创建容器**
![[Pasted image 20210826233753.png]]
这里用来查看web这个service有哪些环境变量
![[Pasted image 20210826233800.png]]

`docker-compose stop`
退出，并删除容器

`docker-compose down --volumes`
不仅是退出，而且是完全删除容器，这里是删除redis容器使用的数据量