UNAME            ?= $(shell uname)
INSTALL          ?= install
REMOVE           ?= rm -rf
COPY             ?= cp -rf
CHMOD            ?= chmod -R
DOWNLOAD         ?= wget
UNTAG            ?= tar -zxvf
INST_OAK_PRODIR  ?= /usr/local/apioak
INST_OAK_BINDIR  ?= /usr/bin
LUTJIT_DIR       ?= $(shell ${OR_EXEC} -V 2>&1 | grep prefix | grep -Eo 'prefix=(.*?)/nginx' | grep -Eo '/.*/')luajit
LUAROCKS_VER     ?= $(shell luarocks --version | grep -E -o  "luarocks [0-9]+.")

RELY_PATH ?= ./rockspec/src/
RELYS := net-url-1.1-1.src.rock
RELYS += lrexlib-pcre-2.9.1-1.src.rock
RELYS += jsonschema-0.9.8-0.src.rock
RELYS += lua-resty-balancer-0.02rc5-0.src.rock
RELYS += lua-tinyyaml-0.1-0.src.rock
RELYS += luafilesystem-1.7.0-2.src.rock
RELYS += penlight-1.5.4-1.src.rock
RELYS += lua-resty-http-0.15-0.src.rock
RELYS += lua-resty-consul-0.3-2.src.rock
RELYS += lua-resty-worker-events-2.0.1-1.src.rock
RELYS += lua-resty-jwt-0.2.0-0.src.rock
RELYS += lua-resty-oakrouting-0.2.0-1.src.rock
RELYS += lua-resty-lrucache-0.09-2.src.rock
RELYS += luasocket-3.0rc1-2.src.rock
RELYS += multipart-0.5.5-1.src.rock
RELYS += lua-resty-jit-uuid-0.0.7-2.src.rock
RELYS += lua-resty-dns-0.21-1.src.rock

.PHONY: deps
deps:
	$(foreach rely, $(RELYS), luarocks install $(RELY_PATH)$(rely) --tree=deps;)

#ifeq ($(UNAME),Darwin)
#	luarocks install --lua-dir=$(LUTJIT_DIR) rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
#else ifneq ($(LUAROCKS_VER),'luarocks 3.')
#	luarocks install rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
#else
#	luarocks install --lua-dir=/usr/local/openresty/luajit rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
#endif


.PHONY: install
install:
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/admin
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/admin/dao
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/admin/schema
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/cmd
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/cmd/utils
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/pdk
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/cors
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/jwt-auth
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/key-auth
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/limit-conn
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/limit-count
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/limit-req
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin/mock
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/sys
	$(INSTALL) -d $(INST_OAK_PRODIR)/bin
	$(INSTALL) -d $(INST_OAK_PRODIR)/conf
	$(INSTALL) -d $(INST_OAK_PRODIR)/conf/cert
	$(INSTALL) -d $(INST_OAK_PRODIR)/logs
	$(INSTALL) -d $(INST_OAK_PRODIR)/deps

	$(INSTALL) apioak/*.lua        			   $(INST_OAK_PRODIR)/apioak/
	$(INSTALL) apioak/admin/*.lua  			   $(INST_OAK_PRODIR)/apioak/admin/
	$(INSTALL) apioak/admin/dao/*.lua 		   $(INST_OAK_PRODIR)/apioak/admin/dao/
	$(INSTALL) apioak/admin/schema/*.lua 	   $(INST_OAK_PRODIR)/apioak/admin/schema/
	$(INSTALL) apioak/cmd/*.lua 			   $(INST_OAK_PRODIR)/apioak/cmd/
	$(INSTALL) apioak/cmd/utils/*.lua 		   $(INST_OAK_PRODIR)/apioak/cmd/utils/
	$(INSTALL) apioak/pdk/*.lua    			   $(INST_OAK_PRODIR)/apioak/pdk/
	$(INSTALL) apioak/plugin/*.lua 			   $(INST_OAK_PRODIR)/apioak/plugin/
	$(INSTALL) apioak/plugin/cors/*.lua 	   $(INST_OAK_PRODIR)/apioak/plugin/cors/
	$(INSTALL) apioak/plugin/jwt-auth/*.lua    $(INST_OAK_PRODIR)/apioak/plugin/jwt-auth/
	$(INSTALL) apioak/plugin/key-auth/*.lua    $(INST_OAK_PRODIR)/apioak/plugin/key-auth/
	$(INSTALL) apioak/plugin/limit-conn/*.lua  $(INST_OAK_PRODIR)/apioak/plugin/limit-conn/
	$(INSTALL) apioak/plugin/limit-count/*.lua $(INST_OAK_PRODIR)/apioak/plugin/limit-count/
	$(INSTALL) apioak/plugin/limit-req/*.lua   $(INST_OAK_PRODIR)/apioak/plugin/limit-req/
	$(INSTALL) apioak/plugin/mock/*.lua 	   $(INST_OAK_PRODIR)/apioak/plugin/mock/
	$(INSTALL) apioak/sys/*.lua    			   $(INST_OAK_PRODIR)/apioak/sys/

	$(INSTALL) bin/apioak $(INST_OAK_PRODIR)/bin/apioak
	$(INSTALL) bin/apioak $(INST_OAK_BINDIR)/apioak

	$(INSTALL) conf/mime.types  $(INST_OAK_PRODIR)/conf/mime.types
	$(INSTALL) conf/apioak.yaml $(INST_OAK_PRODIR)/conf/apioak.yaml
	$(INSTALL) conf/nginx.conf  $(INST_OAK_PRODIR)/conf/nginx.conf

	$(INSTALL) conf/cert/apioak.crt $(INST_OAK_PRODIR)/conf/cert/apioak.crt
	$(INSTALL) conf/cert/apioak.key $(INST_OAK_PRODIR)/conf/cert/apioak.key

	$(INSTALL) README.md    $(INST_OAK_PRODIR)/README.md
	$(INSTALL) README_CN.md $(INST_OAK_PRODIR)/README_CN.md
	$(INSTALL) COPYRIGHT    $(INST_OAK_PRODIR)/COPYRIGHT
	$(COPY) deps/*        	$(INST_OAK_PRODIR)/deps/

.PHONY: uninstall
uninstall:
	$(REMOVE) $(INST_OAK_PRODIR)
	$(REMOVE) $(INST_OAK_BINDIR)/apioak
