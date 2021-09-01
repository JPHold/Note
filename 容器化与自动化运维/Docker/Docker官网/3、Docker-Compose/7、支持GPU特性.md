[TOC]

# 前提条件
[安装NVIDIA GPU](https://docs.docker.com/config/containers/resource_constraints/#gpu)

gpu的出现，减少显卡对cpu的依赖，并可以进行原本cpu的工作，估计是将性能利用到极致，compose支持gpu启动应用[[Docker特性]]

# 配置使用gpu
## compose版本>=1.27，<1.28。使用runtime指定，但无法更精细控制gpu
```yaml
services:
  test:
    image: nvidia/cuda:10.2-base
    command: nvidia-smi
    runtime: nvidia
```

## compose版本>1.28，精细控制gpu
### 文档
文档在：[Compose Specification 中deploy章节](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#devices)

| 参数 | 说明 | demo |
| ---- | ---- | ---- |
| [capabilities](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#capabilities) |值指定为字符串列表（例如。`capabilities: [gpu]`）。必须在撰写文件中设置此字段。否则，它会在服务部署时返回错误。|  |
| [count](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#count)  |指定为`int`值或`all`，表示要使用多少个 GPU 设备（假设主机拥有该数量的 GPU）。`all`代表全部都使用|  |
| [device_ids](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#device_ids) |`nvidia-smi`列出主机上所有GPU设备 。指定使用主机中某个 GPU 设备。可指定多个|  |
| [driver](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#driver) |指定使用哪种驱动，例如`driver: 'nvidia'`）|  |
| [options](https://github.com/compose-spec/compose-spec/blob/master/deploy.md#options) |表示驱动程序的选项|  |

#### 注意
##### `count`与`device_ids`是互斥的

##### 没指定`count`与`device_ids`，则默认使用所有gpu

### compose文件配置例子
```yaml
services:
  test:
    image: nvidia/cuda:10.2-base
    command: nvidia-smi
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu, utility]
```

更多例子：[启用 GPU 访问服务容器](https://docs.docker.com/compose/gpu-support/#enabling-gpu-access-to-service-containers)