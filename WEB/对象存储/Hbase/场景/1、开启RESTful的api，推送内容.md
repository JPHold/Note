[TOC]

* 开启api
进入hbase目录，执行
`bin/hbase-daemon.sh start rest -p 18080`

* 推送内容
`http://192.168.0.30:18080/objectStorage/row1`
json格式
```json
{
    "Row": [
        {
            "key": "base64OfxxxKey",
            "Cell": [
                {
                    "column": "xxxFamily:xxxQualifier",
                    "$": "base64OfxxxMsg"
                }
            ]
        }
    ]
}
```
比如：
**xxxKey**为消息主键：1
**xxxFamily:xxxQualifier**为object:base64
**xxxMsg**为1
1转变成base64：MQ==
```json
{
    "Row": [
        {
            "key": "MQ==",
            "Cell": [
                {
                    "column": "b2JqZWN0OmJhc2U2NA==",
                    "$": "MQ=="
                }
            ]
        }
    ]
}
```

* 获取内容
`http://192.168.0.30:18080/objectStorage/xxxRowKey/xxxFamilyName:base64`
直接响应保存的内容
