[TOC]

# prometheus时间不对，跟当前时间差8个小时
使用docker没有指定时区，启动加上`-e TZ=Asia/Shanghai`

# 查询过慢怎么处理
1. 自定义记录规则，这种配置会提前统计好数据，然后放入持久化的时间序列
```yml
/etc/prometheus $ cat prometheus.rules.yml 
groups:
- name: cpu-node
  rules:
  - record: job_instance_mode:node_cpu_seconds:avg_rate5m
    expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```
**prometheus.yml引用规则文件**
```yml
rule_files:
  - 'prometheus.rules.yml
```

# 官方配置讲解，出现很多\<xxx\>，什么意思
[配置文件](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file)

![[Pasted image 20211025221109.png]]

# 官方哪里有配置demo
https://github.com/prometheus/prometheus/blob/release-2.30/config/testdata/conf.good.yml

# 规则文件该如何校验
用到promtool命令
```
promtool check rules /path/to/example.rules.yml
```

# 警报规则的动态参数有哪些
应该是取自${labels}
比如第一个alert的警报提示：标题为实例掉线，描述信息为实例掉线超过5分钟
第二个alert的警报提示：标题为实例存在高延迟，描述信息为延迟的中位线大于1秒
```
groups:
- name: example
  rules:

  # Alert for any instance that is unreachable for >5 minutes.
  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."

  # Alert for any instance that has a median request latency >1s.
  - alert: APIHighRequestLatency
    expr: api_http_request_latencies_second{quantile="0.5"} > 1
    for: 10m
    annotations:
      summary: "High request latency on {{ $labels.instance }}"
      description: "{{ $labels.instance }} has a median request latency above 1s (current value: {{ $value }}s)"
```

# 警报存在，但出于待定（没发出），可以去哪看
在prometheus界面上的Alerts选项卡，可以看到待定或已触发的警报

# 模板化的技术来源
[Go模板](https://golang.org/pkg/text/template/)

# 想测试写的规则是否能正确运行
[使用promtool test rules命令](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/)

# PromQL如何查找某个时间的时间序列值
使用offset位移量，回到过去某个时间，以process_resident_memory_bytes为例
查看1分钟前的数据
`process_resident_memory_bytes offset 1m`

# PromQL支持运算吗
https://prometheus.io/docs/prometheus/latest/querying/operators/

# PromQL支持调用方法吗
[内置了一些方法](https://prometheus.io/docs/prometheus/latest/querying/functions/)

# [时序数据如何存储](https://prometheus.io/docs/prometheus/latest/storage/)
[容器监控实践—Prometheus存储机制](https://www.jianshu.com/p/ef9879dfb9ef)

## [数据文件构成](https://github.com/prometheus/prometheus/blob/release-2.30/tsdb/docs/format/README.md)
![[Pasted image 20211028231419.png]]
* 每两个小时建立一个数据块
* 数据块包含chunks目录
* chunks目录包含时序数据、一个元文件、索引文件（存储时序数据的标签和名称的，快速 查找）
* 时序数据分成多个段文件，每个段文件最大为512MB


## 保存数据
1. 不会立马保存到数据块中，而是保存到内存
2. 同时无压缩保存到wal目录的128MB大小的段文件（称为预写日志文件）中
3. 一般至少保留三个这样的文件，至少保存两个小时的时序数据

## 删除数据
不会立马删除，而是存储到tombstone文件


## 时序数据是否永远存储
根据[存储-Compaction]得知会被定时删除(https://prometheus.io/docs/prometheus/latest/storage/#compaction)。
其中这么描述：存储压缩后的数据，会存在`--storage.tsdb.retention.time`的10%或31天，这两个值，以最小的为准

## 如何修改存储配置
| 参数                           | 描述                                                                                                                                                                               |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| --storage.tsdb.path            | 指定存储目录                                                                                                                                                                       |
| --storage.tsdb.retention.time  | 指定数据的保留时间，超过就删除，默认是15天                                                                                                                                         |
| --storage.tsdb.retention.size  | 每个数据块的最大大小，超过会删除最早的数据；并不影响wal目录和chunks_head                                                                                                           |
| --storage.tsdb.wal-compression | 启用wal（预写日志的压缩），**可能可以压缩一半，只需一点点cpu性能**；这个标志在2.11.0中引入，在2.20.0中默认启用。注意，一旦启用，将 Prometheus 降级到2.11.0以下版本，将需要删除 WAL |
|                                |                                                                                                                                                                                    |
**如果同时指定时间和大小，则是共存，谁先触发就使用哪个**

## 所需的存储大小如何预算
* 计算当前的存储大小
（wal+checkpoint）+chunks_head+chunks

* 根据时序数据规模，计算所需存储
所需大小 = 保留的时间 + 每秒产生个数 + 每个时序数据的字节大小

时序数据的字节大小，可以简单视为1~2个字节


## 如何释放存储空间
* 降低抓取频率
* 降低抓取的数量，比如减少抓取目标

## 存储损坏，如何修复
1. 先关闭prometheus
2. 删除整个存储目录，或只删除有问题的目录

**如果想保留更长，使用外部存储方案[[#外部存储方案]]**

## 外部存储方案
[远程存储集成(https://prometheus.io/docs/prometheus/latest/storage/#remote-storage-integrations)


# 目标发现的几种方案
## 静态配置发现
直接在prometheus.yml编写

## 文件发现
是JSON文件或YAML文件，然后在prometheus.yml引入即可
```yaml
 - job_name: 'node'
    file_sd_configs:
      - files:
        - targets/nodes/*.json
        refresh_interval: 5m
  - job_name: 'docker'
    file_sd_configs:
      - files:
        - targets/docker/*.yml
        refresh_interval: 5m
```

# [管理api](https://prometheus.io/docs/prometheus/latest/management_api/)
直接在prometheus地址上加上/-/xxxApi即可
**目前有四个api：**
-   [健康检查](https://prometheus.io/docs/prometheus/latest/management_api/#health-check)
-   [准备检查](https://prometheus.io/docs/prometheus/latest/management_api/#readiness-check)
-   [重新加载](https://prometheus.io/docs/prometheus/latest/management_api/#reload)
-   [退出](https://prometheus.io/docs/prometheus/latest/management_api/#quit)

以健康检查为例
http://192.168.31.178:9090/-/healthy
![[Pasted image 20211031125816.png]]

# 每个内置指标的含义

# 扩展和联合prometheus
https://www.robustperception.io/scaling-and-federating-prometheus
