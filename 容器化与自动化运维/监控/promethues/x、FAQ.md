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