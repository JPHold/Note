[TOC]

* 如果只有一个worker节点处于active，某个服务设置副本数为5个，那么就会在该节点，创建5个任务，导致该节点资源耗尽，进而影响其他部署到该节点的应用
（待解决）[[2021-09(38)]]