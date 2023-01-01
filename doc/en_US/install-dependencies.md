# Install Dependencies

* [CentOS 7](#centos-7)
* [Ubuntu 18](#ubuntu-18)

CentOS 7
========

> Install OpenResty and other required dependencies.

```shell
# Addition OpenResty Repo.

sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo


# Install OpenResty and Dependencies.

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


> Install Consul

```shell
# Configure the Consul source directly, and then install it

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install consul


# Or go directly to the official address to install according to the official installation document, or directly download the corresponding installation package and install it directly

https://developer.hashicorp.com/consul/downloads


# Start Consul (the following startup is started in developer mode. The production environment can directly execute the executable file of consul and add the corresponding parameters)

sudo consul agent -dev


# After consul is installed, you can directly access http://127.0.0.1:8500/ui to use consul's official dashboard
```


Ubuntu 18
==========

> Install OpenResty and other required dependencies.

```shell
# Addition `OpenResty` Repo.

wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
sudo apt-get update


# Install OpenResty and Dependencies.

sudo apt-get -y install build-essential \
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


# After successful installation of OpenResty, it will start by default, first shut him down.

sudo openresty -s stop
```


> Install Consul

```shell
# Download the corresponding installation file and install it directly.

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install consul


# Start Consul

sudo consul agent -dev
```
