### OpenResty及系统依赖 (Centos 7)
```shell
# install epel, `luarocks` need it.
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -ivh epel-release-latest-7.noarch.rpm

# add openresty source
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo

# install openresty and some compilation tools
sudo yum install -y openresty openresty-resty curl git automake autoconf \
    gcc pcre-devel openssl-devel libtool gcc-c++ luarocks cmake3 lua-devel etcd

sudo ln -s /usr/bin/cmake3 /usr/bin/cmake

sodu systemctl start etcd
```

### 框架依赖
```shell
make dev
```

### 安装ETCD
```shell
yum -y install etcd
```

### 启动ETCD
```shell
systemctl start etcd
```

### 初始化项目
```shell
./bin/apioak init
```

### 初始化ETCD
```shell
./bin/apioak init_etcd
```

### 启动项目
```shell
./bin/apioak start
```
