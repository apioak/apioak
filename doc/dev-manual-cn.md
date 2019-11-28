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
