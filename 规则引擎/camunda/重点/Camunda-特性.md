[TOC]

1. 可以创建外部任务，支持java和JavaScript(node-js)
2. 如果某个外部任务没启动，playform有个队列记录机制，待外部任务启动后，会进行调用
![[Pasted image 20210822114932.png]]
3. service Task外部任务，支持定义局部变量，指向传入的参数，所以要注意指定，如果与传入参数名一样，则局部变量会覆盖传入参数，导致为null
![[Pasted image 20210822125151.png]]