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

# 官方配置demo
https://github.com/prometheus/prometheus/blob/release-2.30/config/testdata/conf.good.yml