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


> Install MariaDB

```shell
# Addition `MariaDB` Repo.

sudo cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF


# Install `MariaDB` Server and Client.

sudo yum -y install MariaDB-server MariaDB-client


# Start `MariaDB` Server.

sudo systemctl start mariadb


# Initialize `MariaDB` and set root password.

sudo mysql_secure_installation
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


> Install MariaDB

```shell
# Key is imported and the repository added.

sudo apt-get -y install software-properties-common
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.hosting90.cz/mariadb/repo/10.2/ubuntu bionic main'
sudo apt update


# Install `MariaDB` and set root password (After installation, set the root password according to the system prompt).

sudo apt-get -y install mariadb-server
```
