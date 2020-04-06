## 0.4.0 
> Released on 2020.04.06

#### Feature

- Refactored gateway core modules.
- Refactored dashboard management panel (this version is powerful and easy to use, highly recommended).
- Refactored `Project`,` Routing` management `APIs`.
- Added `Account`,` User`, `Public Service` Management` APIs`.
- Configuration center was changed from `ETCD` to` MariaDB` database.
- New Added `Project` management.
    - Support project prefix for multi-tenant isolation.
    - Support multi-environment configuration, `Production Environment`,` Pre-launch Environment`, `Test Environment` completely isolated to meet the full life cycle management of `CI` and `CD`.
    - Support dynamic weighted `Round-Robin` load balancing.
    - Support dynamic consistency `Hash` load balancing.
    - Support dynamic node configuration, dynamic `Host` configuration.
    - Support upstream service `Connection`,` Send`, `Read` timeout setting.
    - Support plug-in hot plug, project plug-in can be inherited by all routes(APIs) under the project.
    - Support automatic generation of project documents.
    - Support project member management.
- New Added `Route` management.
    - Support front-end and back-end request routing mapping.
    - Support front-end and back-end request method mapping.
    - Support cross mapping of front and back request parameters.
    - Support request constant parameter definition.
    - Support custom response data and response data type.
    - Support plug-in hot swap.
    - Support `Mock` request, accelerate the development process of front and back end separation.
    - Supports automatic generation of routing (APIs) documents.
    - Support multi-environment routing (APIs) online and offline.
    - Support multi-environment routing (APIs) one-click replication.
- New Added `User` management.
    - Support users login and registration.
    - Support users to create, edit and delete.
    - Support users to disable globally.


#### Change

- Removed dependent library `lua-resty-template`.
- Remove dependent library `lua-resty-etcd`.
- Remove dependent library `lua-resty-ngxvar`.
- Remove dependent library `lua-resty-jit-uuid`.
- Removed `Service` module and related management APIs and documents in` 0.3.0` version.
- Removed `Plugin` module and related management APIs and documents in` 0.3.0` version.
- Removed the `Router` module and related management APIs and documentation in` 0.3.0` version.



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
