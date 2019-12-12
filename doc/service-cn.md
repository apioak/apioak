## 服务

> 服务的可以理解为一组API的抽象，在APIOAK中服务是最顶层维度，所有的插件、上游节点、接口全部是在服务之下的，在实际的业务场景中可以把服务理解为项目。

- [结构解析](#结构解析)
- [创建服务](#创建服务)
- [更新服务](#更新服务)
- [查询服务](#查询服务)
- [删除服务](#删除服务)
- [服务列表](#服务列表)

### 结构解析
|名称|必选|说明|
|---|---|---|
|name                          |是| 服务名称，字符长度 `1-20`。|
|prefix                        |是| 服务请求前缀，字符长度 `1-20`。|
|desc                          |否| 服务说明，字符长度 `1-50`。|
|upstreams                     |是| 上游服务节点集合。|
|upstreams.prod                |否| 生产环境节点，`prod`、`beta`、`beta` 至少存在一个。|
|upstreams.prod.host           |是| 上游主机地址。|
|upstreams.prod.type           |是| 负载均衡算法 `chash` 或 `roundrobin`。|
|upstreams.prod.nodes          |是| 上游节点信息，可以为多组。|
|upstreams.prod.nodes[].port   |是| 节点端口，取值范围 `0-65535`。|
|upstreams.prod.nodes[].ip     |是| 节点IP地址。|
|upstreams.prod.nodes[].weight |是| 节点权重，取值范围 `0-100`。|
|upstreams.beta                |是| 同 `upstreams.prod`。|
|upstreams.dev                 |是| 同 `upstreams.prod`。|

### 创建服务
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service -d '
{
    "name":"First APIOAK Project",
    "prefix":"/one",
    "desc":"this is a first apioak project"
    "upstreams":{
        "prod":{
            "host":"prod.apioak.com",
            "type":"chash",
            "nodes":[
                {
                    "port":10111,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10222,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        },
        "dev":{
            "host":"dev.apioak.com",
            "type":"roundrobin",
            "nodes":[
                {
                    "port":10333,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10444,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        },
        "beta":{
            "host":"beta.apioak.com",
            "type":"chash",
            "nodes":[
                {
                    "port":10555,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10666,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        }
    },
}'
```

### 更新服务
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service/00000000000000010080 -d '
{
    "name":"First APIOAK Project",
    "prefix":"/one",
    "desc":"this is a first apioak project"
    "upstreams":{
        "prod":{
            "host":"prod.apioak.com",
            "chash":"chash",
            "nodes":[
                {
                    "port":10111,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10222,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        },
        "dev":{
            "host":"dev.apioak.com",
            "chash":"roundrobin",
            "nodes":[
                {
                    "port":10333,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10444,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        },
        "beta":{
            "host":"beta.apioak.com",
            "chash":"chash",
            "nodes":[
                {
                    "port":10555,
                    "ip":"127.0.0.1",
                    "weight":50
                },
                {
                    "port":10666,
                    "ip":"127.0.0.1",
                    "weight":50
                }
            ]
        }
    },
}'
```

### 查询服务
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/service/00000000000000010080
```

### 删除服务
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/service/00000000000000010080
```

### 服务列表
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/services
```
