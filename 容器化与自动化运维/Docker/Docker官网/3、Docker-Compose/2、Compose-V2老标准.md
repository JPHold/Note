[TOC]

# 注意
2021年8月25日 00:02:58
v2新版本如果要用在正式环境，得充分测试后才能放入[[Docker重点]]

* 跟v1版本有很多不同
1. compose命令纳入到docker cli中，不再是docker-compose命令
2. 使用[compose-spec](https://github.com/compose-spec)规范，与v1版本：docker-compose进行区分
3. 边界切换云平台的上下文，如[Amazon ECS](https://docs.docker.com/cloud/ecs-integration)和[Microsoft ACI](https://docs.docker.com/cloud/aci-integration)
4. 支持环境切换：profiles
5. 支持GPU
6. 支持苹果系统的Docker  Desktop：[Apple silicon](https://docs.docker.com/desktop/mac/apple-silicon/)