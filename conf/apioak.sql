DROP TABLE IF EXISTS `oak_plugins`;

CREATE TABLE `oak_plugins`
(
  `id`          int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`        varchar(20)               DEFAULT NULL COMMENT '插件名称',
  `type`        varchar(20)               DEFAULT NULL COMMENT '插件类型',
  `description` text COMMENT '插件描述',
  `config`      json                      DEFAULT NULL COMMENT '插件配置',
  `res_id`      int(10) unsigned NOT NULL DEFAULT '0' COMMENT '资源ID',
  `res_type`    varchar(20)               DEFAULT NULL COMMENT '资源类型（PROJECT/ROUTER）',
  `created_at`  timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_RESOURCES` (`name`, `res_id`, `res_type`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='插件表';



DROP TABLE IF EXISTS `oak_projects`;

CREATE TABLE `oak_projects`
(
  `id`          int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`        varchar(50)               DEFAULT NULL COMMENT '项目名称',
  `description` text COMMENT '项目描述',
  `path`        varchar(50)               DEFAULT NULL COMMENT '项目前缀',
  `created_at`  timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_PATH` (`path`) USING BTREE,
  KEY `IDX_NAME` (`name`),
  KEY `IDX_UPDATED_AT` (`updated_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='项目表';



DROP TABLE IF EXISTS `oak_roles`;

CREATE TABLE `oak_roles`
(
  `id`         int(10) unsigned    NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` int(10) unsigned    NOT NULL DEFAULT '0' COMMENT '项目ID',
  `user_id`    int(10) unsigned    NOT NULL DEFAULT '0' COMMENT '用户ID',
  `is_admin`   tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '组管理员',
  `created_at` timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp           NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_PROJECT_USER` (`project_id`, `user_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='角色表';



DROP TABLE IF EXISTS `oak_routers`;

CREATE TABLE `oak_routers`
(
  `id`               int(10) unsigned    NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`             varchar(50)                  DEFAULT NULL COMMENT '接口名称',
  `enable_cors`      tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '开启跨域',
  `description`      text COMMENT '接口描述',
  `request_path`     varchar(100)                 DEFAULT NULL COMMENT '请求路径',
  `request_method`   varchar(10)                  DEFAULT NULL COMMENT '请求方式',
  `request_params`   json                         DEFAULT NULL COMMENT '请求参数',
  `backend_path`     varchar(100)                 DEFAULT NULL COMMENT '后端请求路径',
  `backend_method`   varchar(10)                  DEFAULT NULL COMMENT '后端请求方式',
  `backend_params`   json                         DEFAULT NULL COMMENT '后端参数',
  `constant_params`  json                         DEFAULT NULL COMMENT '常量参数',
  `response_type`    varchar(50)                  DEFAULT NULL COMMENT '响应类型',
  `response_success` text COMMENT '响应成功消息',
  `response_failure` text COMMENT '响应失败消息',
  `response_codes`   json                         DEFAULT NULL COMMENT '响应错误码',
  `response_schema`  json                         DEFAULT NULL COMMENT '响应描述',
  `env_prod_config`  json                         DEFAULT NULL COMMENT '生产环境配置',
  `env_beta_config`  json                         DEFAULT NULL COMMENT '预发环境配置',
  `env_test_config`  json                         DEFAULT NULL COMMENT '测试环境配置',
  `project_id`       int(10) unsigned    NOT NULL DEFAULT '0' COMMENT '项目ID',
  `created_at`       timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`       timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_REQUEST_PATH` (`request_path`, `request_method`, `project_id`) USING BTREE,
  KEY `IDX_UPDATED_AT` (`updated_at`),
  KEY `IDX_NAME` (`name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='路由表';



DROP TABLE IF EXISTS `oak_tokens`;

CREATE TABLE `oak_tokens`
(
  `id`         int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `token`      char(32)                  DEFAULT NULL COMMENT '登录令牌',
  `user_id`    int(11)          NOT NULL DEFAULT '0' COMMENT '用户ID',
  `updated_at` timestamp        NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_at` timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expired_at` timestamp        NULL     DEFAULT NULL COMMENT '超时时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_USER` (`user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='令牌表';



DROP TABLE IF EXISTS `oak_upstreams`;

CREATE TABLE `oak_upstreams`
(
  `id`         int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `env`        varchar(10)               DEFAULT NULL COMMENT '发布环境',
  `host`       varchar(50)               DEFAULT NULL COMMENT '主机地址',
  `type`       varchar(10)               DEFAULT NULL COMMENT '负载均衡算法',
  `timeouts`   json                      DEFAULT NULL COMMENT '超时时间',
  `nodes`      json                      DEFAULT NULL COMMENT '服务节点',
  `project_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '项目ID',
  `created_at` timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_ENV_PROJECT` (`env`, `project_id`),
  KEY `IDX_UPDATED_AT` (`updated_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='服务节点表';



DROP TABLE IF EXISTS `oak_users`;

CREATE TABLE `oak_users`
(
  `id`         int(10) unsigned    NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`       varchar(50)                  DEFAULT NULL COMMENT '用户名',
  `password`   char(32)                     DEFAULT NULL COMMENT '密码',
  `email`      varchar(50)                  DEFAULT NULL COMMENT '邮箱',
  `is_owner`   tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '超级管理员',
  `is_enable`  tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '是否启用',
  `created_at` timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_EMAIL` (`email`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户表';
