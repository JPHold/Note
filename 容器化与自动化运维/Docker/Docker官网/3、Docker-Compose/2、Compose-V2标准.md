[TOC]

# 注意
2021年8月25日 00:02:58
v2新版本如果要用在正式环境，得充分测试后才能放入（不过建议还是不要用）[[Docker重点]]

* v1版本依然还在维护和支持[[Docker重点]]

* 跟v1版本有很多不同
1. compose命令纳入到docker cli中，不再是docker-compose命令
2. 使用[compose-spec](https://github.com/compose-spec)规范，与v1版本：docker-compose进行区分
3. 边界切换云平台的上下文，如[Amazon ECS](https://docs.docker.com/cloud/ecs-integration)和[Microsoft ACI](https://docs.docker.com/cloud/aci-integration)
4. 支持环境切换：profiles
5. 支持GPU
6. 支持苹果系统的Docker  Desktop：[Apple silicon](https://docs.docker.com/desktop/mac/apple-silicon/)

# 安装

## Desktop（Mac、Windows）
Desktop安装包，自动安装Compose。
并且可以切换v1和v2版本

## Linux
只支持手动安装方式
1. 确保`~/.docker/cli-plugins/`目录存在
2. 下载源代码
3. 授予权限
比如
```
mkdir -p ~/.docker/cli-plugins/
 
curl -SL https://github.com/docker/compose-cli/releases/download/v2.0.0-rc.1/docker-compose-linux-amd64 -o ~/.docker/cli-plugins/docker-compose
 
chmod +x ~/.docker/cli-plugins/docker-compose
```

# Compose与docker-compose的兼容性
目前还有一些docker-compose的命令和参数，没有迁移到Compose，具体查看[Compose-CLI改造清单](https://github.com/docker/compose-cli/issues/1283) GitHub

## 尚未实现的参数
`compose build --memory`
buildkit还没支持，但有这个参数说明，但没有任何效果，所以被隐藏了

## 不会支持的参数或命令
1. `compose ps --filter KEY-VALUE` 
与service命令无关，且docker-compose没有该参数

2. `compose rm --all`
docker-compose已弃用

3. `compose scale`
docker-compose已弃用，使用`compose up --scale`替代