[TOC]

* **调用为何不使用http，而是使用RPC**
1. 两者不是同个东西，前者是通信协议，后者是一种设计：为了屏蔽底层通信协议，简化使用，无须写通信代码，而且支持http等协议
2. RPC的全称是 `Remote Procedure Call`，远程调用就像调用本地方法一样
[何为RPC](https://github.com/Snailclimb/JavaGuide/blob/main/docs/distributed-system/rpc/dubbo.md#%E4%BD%95%E4%B8%BA-rpc)

* **客户端与服务端，入参和响应参数不同情况，是否报错和重新部署？**
[约束](https://dubbo.apache.org/zh/docs/references/protocols/dubbo/#%E7%BA%A6%E6%9D%9F)
![[Pasted image 20220214164347.png]]