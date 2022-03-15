# demo测试
* 启动测试容器；tomcat
`docker run --name test-log-clean -d --restart always tomcat`

* 设置每个文件最大为8k，最多三个文件，总共上限为24k
```json
{
    "log-driver": "json-file",
    "log-opts": {
       "max-size": "8k",
       "max-file": "3" 
     }
}
```

* 分别执行三次restart容器，观察日志变化
> 查看日志文件路径：`docker inspect test-log-clean --format '{{ .LogPath }}'`
> 
> 有点奇怪，会挪动4k内容到下一个文件（大的index），并且第三次的总大小并不是24k
1. 第一次
![[Pasted image 20220315104816.png]]

2. 第二次
![[Pasted image 20220315104821.png]]

3. 第三次
![[Pasted image 20220315104826.png]]