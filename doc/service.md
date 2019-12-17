## Service

> The service can be understood as an abstraction of a set of APIs. In APIOAK, the service is the topmost dimension. All plug-ins, upstream nodes, and interfaces are all under the service. In actual business scenarios, services can be understood as projects.

- [Data Structure](#Data-Structure)
- [Create Service](#Create-Service)
- [Update Service](#Update-Service)
- [Query Service](#Query-Service)
- [Delete Service](#Delete-Service)
- [Service List](#Service-List)

### Data Structure
| Name | Required | Description |
|---|---|---|
|name                          |Y| Service name, character length `1-20`.|
|prefix                        |Y| Service request prefix, character length `1-20`.|
|desc                          |N| Service description, character length `1-50`.|
|upstreams                     |Y| A collection of upstream service nodes.|
|upstreams.prod                |N| Production environment node, at least one of `prod`,` beta`, and `beta` exists.|
|upstreams.prod.host           |Y| Upstream host address.|
|upstreams.prod.type           |Y| Load balancing algorithm `chash` or` roundrobin`.|
|upstreams.prod.nodes          |Y| The upstream node information can be multiple groups.|
|upstreams.prod.nodes[].port   |Y| Node port. The value ranges from 0 to 65535.|
|upstreams.prod.nodes[].ip     |Y| Node IP address.|
|upstreams.prod.nodes[].weight |Y| Node weight. The value ranges from 0 to 100.|
|upstreams.beta                |Y| Same as `upstreams.prod`.|
|upstreams.dev                 |Y| Same as `upstreams.prod`.|

### Create Service
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service -d '
{
    "name":"First APIOAK Project",
    "prefix":"/one",
    "desc":"this is a first apioak project",
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

### Update Service
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service/00000000000000010080 -d '
{
    "name":"First APIOAK Project",
    "prefix":"/one",
    "desc":"this is a first apioak project",
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

### Query Service
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/service/00000000000000010080
```

### Delete Service
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/service/00000000000000010080
```

### Service List
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/services
```

