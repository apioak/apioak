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
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/admin
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/db
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/pdk
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/plugin
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/schema
	$(INSTALL) -d $(INST_OAK_PRODIR)/apioak/sys
	$(INSTALL) -d $(INST_OAK_PRODIR)/conf
	$(INSTALL) -d $(INST_OAK_PRODIR)/bin
	$(INSTALL) -d $(INST_OAK_PRODIR)/logs

	$(INSTALL) apioak/*.lua        $(INST_OAK_PRODIR)/apioak/
	$(INSTALL) apioak/admin/*.lua  $(INST_OAK_PRODIR)/apioak/admin/
	$(INSTALL) apioak/db/*.lua     $(INST_OAK_PRODIR)/apioak/db/
	$(INSTALL) apioak/pdk/*.lua    $(INST_OAK_PRODIR)/apioak/pdk/
	$(INSTALL) apioak/plugin/*.lua $(INST_OAK_PRODIR)/apioak/plugin/
	$(INSTALL) apioak/schema/*.lua $(INST_OAK_PRODIR)/apioak/schema/
	$(INSTALL) apioak/sys/*.lua    $(INST_OAK_PRODIR)/apioak/sys/

	$(INSTALL) conf/mime.types     $(INST_OAK_PRODIR)/conf/mime.types
	$(INSTALL) conf/apioak.yaml    $(INST_OAK_PRODIR)/conf/apioak.yaml
	$(INSTALL) conf/apioak.sql     $(INST_OAK_PRODIR)/conf/apioak.sql
	$(INSTALL) conf/nginx.conf     $(INST_OAK_PRODIR)/conf/nginx.conf

	$(INSTALL) bin/apioak          $(INST_OAK_PRODIR)/bin/apioak
	$(INSTALL) bin/apioak          $(INST_OAK_BINDIR)/apioak

	$(INSTALL) README.md           $(INST_OAK_PRODIR)/README.md
	$(INSTALL) README_CN.md        $(INST_OAK_PRODIR)/README_CN.md
	$(INSTALL) COPYRIGHT           $(INST_OAK_PRODIR)/COPYRIGHT

	$(DOWNLOAD) https://github.com/apioak/dashboard/releases/download/v0.4.0/dashboard-0.4.0.tar.gz
	$(UNTAG)    dashboard-0.4.0.tar.gz -C $(INST_OAK_PRODIR)
	$(REMOVE)   dashboard-0.4.0.tar.gz


.PHONY: uninstall
uninstall:
	$(REMOVE) $(INST_OAK_PRODIR)
	$(REMOVE) $(INST_OAK_BINDIR)/apioak
