## Plugin

> A plugin is an interface reserved for a custom gateway function, and can be extended for application scenarios through plugins.

- [Global Plugin Lists](#Global-Plugin-Lists)
- [Service Plugin Save](#Service-Plugin-Save)
- [Service Plugin Remove](#Service-Plugin-Remove)
- [Router Plugin Save](#Router-Plugin-Save)
- [Router Plugin Remove](#Router-Plugin-Remove)


### Global Plugin Lists
```shell
curl X GET http://127.0.0.1:10080/apioak/admin/plugins
```


### Service Plugin Save
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service/{service_id}/plugin -d '
{
	"key": "limit-conn",
	"config": {
		"conn": 200,
        "burst": 100,
        "key": "http_x_real_ip",
        "default_conn_delay":1
	}
}'
```


### Service Plugin Remove
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/service/{service_id}/plugin/{plugin_key}
```


### Router Plugin Save
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{router_id}/plugin -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
	"key": "limit-conn",
	"config": {
		"conn": 200,
        "burst": 100,
        "key": "http_x_real_ip",
        "default_conn_delay":1
	}
}'
```


### Router Plugin Remove
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{router_id}/plugin/{plugin_key} -H "APIOAK-SERVICE-ID: {service_id}"
```
