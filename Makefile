UNAME            ?= $(shell uname)
INSTALL          ?= install
REMOVE           ?= rm -rf
INST_OAK_PRODIR  ?= /usr/local/apioak
INST_OAK_BINDIR  ?= /usr/bin
LUTJIT_DIR       ?= $(shell ${OR_EXEC} -V 2>&1 | grep prefix | grep -Eo 'prefix=(.*?)/nginx' | grep -Eo '/.*/')luajit
LUAROCKS_VER     ?= $(shell luarocks --version | grep -E -o  "luarocks [0-9]+.")


.PHONY: deps
deps:
ifeq ($(UNAME),Darwin)
	luarocks install --lua-dir=$(LUTJIT_DIR) rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
else ifneq ($(LUAROCKS_VER),'luarocks 3.')
	luarocks install rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
else
	luarocks install --lua-dir=/usr/local/openresty/luajit rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
endif


.PHONY: install
install:
	$(INSTALL) -d $(INST_OAK_PRODIR)/bin
	$(INSTALL) -d $(INST_OAK_PRODIR)/logs
	$(INSTALL) -d $(INST_OAK_PRODIR)/conf
	$(INSTALL) -d $(INST_OAK_PRODIR)/dashboard
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/sys
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/pdk
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/admin
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin

	git submodule update --init --recursive && \
	cp -r dashboard/* $(INST_OAK_PRODIR)/dashboard

	$(INSTALL) apioak/apioak.lua             $(INST_OAK_PRODIR)/apioak/apioak.lua
	$(INSTALL) apioak/admin.lua              $(INST_OAK_PRODIR)/apioak/admin.lua
	$(INSTALL) apioak/pdk.lua                $(INST_OAK_PRODIR)/apioak/pdk.lua
	$(INSTALL) apioak/sys.lua                $(INST_OAK_PRODIR)/apioak/sys.lua
	$(INSTALL) apioak/sys/admin.lua          $(INST_OAK_PRODIR)/apioak/sys/admin.lua
	$(INSTALL) apioak/sys/balancer.lua       $(INST_OAK_PRODIR)/apioak/sys/balancer.lua
	$(INSTALL) apioak/sys/meta.lua           $(INST_OAK_PRODIR)/apioak/sys/meta.lua
	$(INSTALL) apioak/sys/plugin.lua         $(INST_OAK_PRODIR)/apioak/sys/plugin.lua
	$(INSTALL) apioak/sys/router.lua         $(INST_OAK_PRODIR)/apioak/sys/router.lua
	$(INSTALL) apioak/pdk/admin.lua          $(INST_OAK_PRODIR)/apioak/pdk/admin.lua
	$(INSTALL) apioak/pdk/config.lua         $(INST_OAK_PRODIR)/apioak/pdk/config.lua
	$(INSTALL) apioak/pdk/const.lua          $(INST_OAK_PRODIR)/apioak/pdk/const.lua
	$(INSTALL) apioak/pdk/ctx.lua            $(INST_OAK_PRODIR)/apioak/pdk/ctx.lua
	$(INSTALL) apioak/pdk/etcd.lua           $(INST_OAK_PRODIR)/apioak/pdk/etcd.lua
	$(INSTALL) apioak/pdk/json.lua           $(INST_OAK_PRODIR)/apioak/pdk/json.lua
	$(INSTALL) apioak/pdk/log.lua            $(INST_OAK_PRODIR)/apioak/pdk/log.lua
	$(INSTALL) apioak/pdk/plugin.lua         $(INST_OAK_PRODIR)/apioak/pdk/plugin.lua
	$(INSTALL) apioak/pdk/request.lua        $(INST_OAK_PRODIR)/apioak/pdk/request.lua
	$(INSTALL) apioak/pdk/response.lua       $(INST_OAK_PRODIR)/apioak/pdk/response.lua
	$(INSTALL) apioak/pdk/schema.lua         $(INST_OAK_PRODIR)/apioak/pdk/schema.lua
	$(INSTALL) apioak/pdk/shared.lua         $(INST_OAK_PRODIR)/apioak/pdk/shared.lua
	$(INSTALL) apioak/pdk/string.lua         $(INST_OAK_PRODIR)/apioak/pdk/string.lua
	$(INSTALL) apioak/pdk/table.lua          $(INST_OAK_PRODIR)/apioak/pdk/table.lua
	$(INSTALL) apioak/pdk/tablepool.lua      $(INST_OAK_PRODIR)/apioak/pdk/tablepool.lua
	$(INSTALL) apioak/admin/plugin.lua       $(INST_OAK_PRODIR)/apioak/admin/plugin.lua
	$(INSTALL) apioak/admin/router.lua       $(INST_OAK_PRODIR)/apioak/admin/router.lua
	$(INSTALL) apioak/admin/service.lua      $(INST_OAK_PRODIR)/apioak/admin/service.lua
	$(INSTALL) apioak/plugin/limit-conn.lua  $(INST_OAK_PRODIR)/apioak/plugin/limit-conn.lua
	$(INSTALL) apioak/plugin/limit-count.lua $(INST_OAK_PRODIR)/apioak/plugin/limit-count.lua
	$(INSTALL) apioak/plugin/limit-req.lua   $(INST_OAK_PRODIR)/apioak/plugin/limit-req.lua
	$(INSTALL) apioak/plugin/key-auth.lua    $(INST_OAK_PRODIR)/apioak/plugin/key-auth.lua
	$(INSTALL) conf/mime.types               $(INST_OAK_PRODIR)/conf/mime.types
	$(INSTALL) conf/apioak.yaml              $(INST_OAK_PRODIR)/conf/apioak.yaml
	$(INSTALL) conf/nginx.conf               $(INST_OAK_PRODIR)/conf/nginx.conf
	$(INSTALL) bin/apioak                    $(INST_OAK_PRODIR)/bin/apioak
	$(INSTALL) bin/apioak                    $(INST_OAK_BINDIR)/apioak
	$(INSTALL) README.md                     $(INST_OAK_PRODIR)/README.md
	$(INSTALL) COPYRIGHT                     $(INST_OAK_PRODIR)/COPYRIGHT


.PHONY: uninstall
uninstall:
	$(REMOVE) $(INST_OAK_PRODIR)
	$(REMOVE) $(INST_OAK_BINDIR)/apioak
