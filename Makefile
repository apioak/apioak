.PHONY: dev
dev:
	luarocks install rockspec/apioak-master-0.rockspec --tree=deps --only-deps --local
