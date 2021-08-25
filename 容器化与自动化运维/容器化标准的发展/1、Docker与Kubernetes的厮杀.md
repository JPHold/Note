[TOC]
1. [K8s宣布弃用Docker，千万别慌！](https://mp.weixin.qq.com/s/GHjvvTJ8ZerIyCqXB1BSUQ)
2. [docker概念很乱？来替你理一下！](https://mp.weixin.qq.com/s/gJBdJ8-XDHCMeVCoA3Bl6A)

Docker包含docker-cli、dockered、containerd(包含run组件（shim、runc、docker容器实例）、ctr（containerd的cli）)
![[Pasted image 20210825094848.png]] ^0e0318

1. Docker一开始就包含了containerd，后来像kubernetes这样云技术，拉了一群公司组件联盟：CNCF，迫于压力，Docker为了融入他们，将containerd开源
2. Docker遵循的是自己标准：OCI（Open Container Initiative）。K8s遵循的是自己标准：CRI（Container Runtime Interface），一开始k8s为了兼容Docker标准，将整个docker技术栈纳入（[[#^0e0318]]），添加了dockershim组件跟docker通信：用于将CRI的API转换成docker cli，然后。
3. 后来k8s发现引入多一个组件，就多一份安全问题；将docker整个纳入，但其实用到的只是containerd组件，其它没用到的，反而会增加一份安全问题。下图圈住部分，就是k8s所需
![[Pasted image 20210825095827.png]]
4. 前面说过，k8s诱骗docker将containerd开源，现在已经属于CNCF，实现了CRI标准，所以现在的平衡局面是这样
![[Pasted image 20210825100724.png]]
5. 容器运行时有两个方式：containerd和CRI-O
6. 弃用Docker，只是个文字游戏，放弃的只是dockershim组件；依然使用containerd和docker构建容器[[重点]]