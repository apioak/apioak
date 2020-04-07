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


> 安装 MariaDB

```shell
# 添加 MariaDB 镜像源。

sudo cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = https://mirrors.aliyun.com/mariadb/yum/10.2/centos7-amd64/
gpgkey=https://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF


# 安装 MariaDB 服务器和客户端。

sudo yum -y install MariaDB-server MariaDB-client


# 启动 MariaDB 服务器。

sudo systemctl start mariadb


# 初始化 MariaDB 并设置 root 密码。

sudo mysql_secure_installation
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


> 安装 MariaDB

```shell
# 导入密钥并添加存储库。

sudo apt-get -y install software-properties-common
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.aliyun.com/mariadb/repo/10.2/ubuntu bionic main'
sudo apt update


# 初始化 MariaDB 并设置 root 密码（安装过程中会提示设置 root 密码）。

sudo apt-get -y install mariadb-server
```
