# 安装依赖

* [CentOS 7](#centos-7)
* [Ubuntu 18](#ubuntu-18)

CentOS 7
========

> 安装 OpenResty 和其他必需的依赖项。

```shell
# 添加 OpenResty 镜像源。

sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo


# 安装 OpenResty 和依赖项。

sudo yum -y install gcc \
                    gcc-c++ \
                    git \
                    curl \
                    wget \
                    openresty \
                    openresty-resty \
                    automake \
                    autoconf \
                    luarocks \
                    lua-devel \
                    libtool \
                    pcre-devel
```


> 安装 Consul

```shell
# 直接配置Consul源，然后安装即可

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install consul


# 或者至直接到官方地址根据官方安装文档进行安装也可，或者直接下载对应的安装包直接安装

https://developer.hashicorp.com/consul/downloads


# 启动 Consul（以下启动为开发者模式启动。生产环境启动直接执行consul的可执行文件增加相应的参数即可）

sudo consul agent -dev


# consul安装后可直接访问 http://127.0.0.1:8500/ui 使用consul官方的dashboard
```


Ubuntu 18
==========

> 安装 OpenResty 和其他必需的依赖项。

```shell
# 添加 OpenResty 镜像源。

wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
sudo apt-get update


# 安装 OpenResty 和依赖项。

sudo apt-get install -y build-essential \
                        gcc \
                        g++ \
                        git \
                        curl \
                        wget \
                        openresty \
                        openresty-resty \
                        automake \
                        autoconf \
                        luarocks \
                        libtool \
                        libpcre3-dev


# 安装 OpenResty 成功后，会默认启动，此时先将其停止。

sudo openresty -s stop
```


> 安装 Consul

```shell
# 下载对应安装文件直接安装。

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install consul


# 启动 Consul

sudo consul agent -dev
```
