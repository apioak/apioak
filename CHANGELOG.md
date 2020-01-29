## 0.3.0 
> Released on 2020.01.29

#### Feature

- Added management `Dashboard` panel.
- Added `Balancer` health check.
- Added `Jwt Auth` plugin parameter validation structure.
- Added `Key Auth` plugin parameter validation structure.
- Added `Limit Conn` plugin parameter validation structure.
- Added `Limit Count` plugin parameter validation structure.
- Added `Limit Req` plugin parameter validation structure.


#### FIX

- Fixed `Jwt Auth` plugin unit test bug.


#### Change

- Changed `Limit Count` plugin config field.
- Changed plugin list api parameter descriptive information.
- Remove redundant test files.



## 0.2.0
> Released on 2020.01.12

#### Feature

- Added `JWT` plugin.
- Added CentOS `RPM` install package.
- Added Ubuntu `DEB` install package.
- Added test case basic request module.
- Added upstream `uri` rewrite function.
- Added `admin.plugin` test case.
- Added `admin.router` test case.
- Added `admin.service` test case.
- Added `pdk.admin` test case.
- Added `pdk.config` test case.
- Added `pdk.const` test case.
- Added `pdk.etcd` test case.
- Added `pdk.json` test case.
- Added `pdk.log` test case.
- Added `pdk.table` test case.
- Added `plugin.jwt-auth` test case.
- Added `plugin.key-auth` test case.
- Added `plugin.limit-conn` test case.
- Added `plugin.limit-count` test case.
- Added `plugin.limit-req` test case.


#### FIX

- Fixed `key-auth` authentication plugin logic error.
- Fixed `README.md` spelling error.


#### Change

- Changed `key-auth` authentication plugin configuration to read from` etcd` to `oak_ctx`.
- Updated sponsored links.


#### Document

- Added `How to participate in contributing` documentation.



## 0.1.0
> Released on 2020.01.01

#### Feature

- Added Basic framework.
- Added `service`,`router`,`plugin` and `upstream` management functions.
- Added Dynamic Load Balancing functions.
- Added Hash-based Load Balancing functions.
- Added Multi-environment routing publishing functions.
- Added Mock Request functions.
- Added Command line management script.
- Added `Makefile` automatic` install` and `uninstall` functions.
- Added Basic Test Framework `TEST-NGINX`.
- Added `key-auth` Authentication plugin.
- Added `limit-conn` Traffic Control plugin.
- Added `limit-count` Traffic Control plugin.
- Added `limit-req` Traffic Control plugin.
- Added `PDKs` Development Kit.
- Added request rewrite and parameter conversion functions.
- Added API verification parameter framework `JSON-SCHEMA`.


#### Document

- Added `service` management document.
- Added `router` management document.
- Added `plugin` management document.
- Added `system dependencies` document.
