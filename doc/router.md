## Router

> Routing is the core of the API gateway and is responsible for forwarding, authentication, and authentication of all requests.

- [Data Structure](#Data-Structure)
- [Router Create](#Router-Create)
- [Router Update](#Router-Update)
- [Router Query](#Router-Query)
- [Router Remove](#Router-Remove)
- [Router Lists](#Router-Lists)
- [Router Env Push](#Router-Env-Push)
- [Router Env Remove](#Router-Env-Remove)


### Data Structure
|Name|type|Required|Description|
|---|---|---|---|
|name                              |string |Y| Router name, character length `1-60`.|
|path                              |string |Y| Front-end path address.|
|method                            |string |Y| Front-end request mode：`GET`、`POST`、`PUT`、`DELETE`、`HEAD`.|
|enable_cors                       |boolean|Y| Cross-domain support.|
|desc                              |string |N| Front-end router description.|
|request_params                    |array  |N| Front-end parameter list.|
|request_params[].name             |string |N| Front-end parameter name.|
|request_params[].position         |string |N| Front parameter position：`Header`、`Path`、`Query`.|
|request_params[].type             |string |N| Front-end parameter data type：`string`、`int`、`long`、`float`、`double`、`boolean`.|
|request_params[].default_val      |string |N| The default values of the front-end parameters.|
|request_params[].require          |boolean|N| Whether the front end parameters must be passed.|
|request_params[].desc             |string |N| Front-end parameter description.|
|service_path                      |string |N| Back end parameter path.|
|service_method                    |string |Y| Backend request mode：`GET`、`POST`、`PUT`、`DELETE`、`HEAD`.|
|timeout                           |integer|N| Backend timeout (seconds).|
|service_params                    |array  |N| Backend parameter list.|
|service_params[].service_name     |string |N| Backend parameter names.|
|service_params[].service_position |string |N| Backend parameter position：`Header`、`Path`、`Query`.|
|service_params[].name             |string |N| Corresponds to the front parameter name.|
|service_params[].position         |string |N| Corresponding to the parameter position of the front end.|
|service_params[].type             |string |N| Corresponding parameter data type：`string`、`int`、`long`、`float`、`double`、`boolean`.|
|service_params[].desc             |string |N| Corresponding front end parameter description.|
|constant_params                   |array  |N| Constant parameters.|
|constant_params[].name            |string |N| Constant parameter name.|
|constant_params[].position        |string |N| Constant parameter position：`Header`、`Path`、`Query`.|
|constant_params[].value           |string |N| Constant parameter value.|
|constant_params[].desc            |string |N| Constant parameter description.|
|response_type                     |string |Y| The return type：`JSON`、`HTML`、`TEXT`、`XML`、`BINARY`.|
|response_success                  |string |N| Successful return.|
|response_fail                     |string |N| Error return.|
|response_error_codes              |array  |N| Error code configuration.|
|response_error_codes[].code       |integer|N| Error code.|
|response_error_codes[].msg        |string |N| Error message.|
|response_error_codes[].desc       |string |N| Error note.|
|plugins                           |object |N| A collection of plug-in objects under the service.|
|plugins[plugin_key?]              |object |N| The associated parameter configuration is stored under the owning plug-in.|
|push_dev                          |object |N| Push environment，key is `prod`、 `beta`、 `dev`，value is `boolean`.|


### Router Create
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
    "name": "news list interface",
    "path": "/news",
    "method": "GET",
    "enable_cors": true,
    "desc":"Query the news list interface by time and column",
    "request_params": [
        {
            "name": "time",
            "position": "Query",
            "type": "string",
            "default_val": "2019-12-12",
            "require": false,
            "desc": ""
        }
    ],
    "service_path": "/api/v1/news",
    "service_method": "GET",
    "timeout": 5,
    "service_params": [
        {
            "service_name": "time",
            "service_position": "Query",
            "name": "time",
            "position": "Query",
            "type": "string",
            "desc": ""
        }
    ],
    "constant_params":[
        {
            "name": "gateway",
            "position": "Query",
            "value": "apioak",
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": 200,
            "msg": "OK",
            "desc": ""
        }
    ],
    "plugins":{
        "limit-conn": {
            "conn": 200,
            "burst": 100,
            "key": "http_x_real_ip",
            "default_conn_delay":1
        }
    }
}'
```

### Router Update
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{id} -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
    "name": "news list interface",
    "path": "/news",
    "method": "GET",
    "enable_cors": true,
    "desc":"Query the news list interface by time and column",
    "request_params": [
        {
            "name": "time",
            "position": "Query",
            "type": "string",
            "default_val": "2019-12-12",
            "require": false,
            "desc": ""
        }
    ],
    "service_path": "/api/v1/news",
    "service_method": "GET",
    "timeout": 5,
    "service_params": [
        {
            "service_name": "time",
            "service_position": "Query",
            "name": "time",
            "position": "Query",
            "type": "string",
            "desc": ""
        }
    ],
    "constant_params":[
        {
            "name": "gateway",
            "position": "Query",
            "value": "apioak",
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": 200,
            "msg": "OK",
            "desc": ""
        }
    ],
    "plugins":{
        "limit-conn": {
            "conn": 200,
            "burst": 100,
            "key": "http_x_real_ip",
            "default_conn_delay":1
        }
    }
}'
```


### Router Query
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id} -H "APIOAK-SERVICE-ID: {service_id}"
```


### Router Remove
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{router_id} -H "APIOAK-SERVICE-ID: {service_id}"
```


### Router Lists
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/routers -H "APIOAK-SERVICE-ID: {service_id}"
```


### Router Env Push
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id}/env/{env} -H "APIOAK-SERVICE-ID: {service_id}" -d '
```
> `env` variable is `prod`、`beta`、`dev`.


### Router Env Remove
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id}/env/{env} -H "APIOAK-SERVICE-ID: {service_id}" -d '
```
