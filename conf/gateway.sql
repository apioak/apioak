--
-- Table structure for table `alarms`
--
DROP TABLE IF EXISTS `alarms`;
CREATE TABLE `alarms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `project` varchar(20) NOT NULL DEFAULT '' COMMENT '项目',
  `method` varchar(10) NOT NULL DEFAULT '' COMMENT '请求方式',
  `path` varchar(100) NOT NULL DEFAULT '' COMMENT '请求地址',
  `request_ids` json DEFAULT NULL COMMENT '请求id',
  `type` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '1 500 2 耗时',
  `value` varchar(255) NOT NULL DEFAULT '' COMMENT '错误标识',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否解决',
  `alram_at` timestamp NOT NULL DEFAULT '2000-01-01 04:00:00' COMMENT '报警时间',
  `cancle_alarm_at` timestamp NOT NULL DEFAULT '2000-01-01 04:00:00' COMMENT '解除报警时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报警';

--
-- Table structure for table `api_cases`
--
DROP TABLE IF EXISTS `api_cases`;
CREATE TABLE `api_cases` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `api_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '接口id',
  `backend_name` varchar(50) NOT NULL DEFAULT '' COMMENT '后端服务',
  `version` varchar(10) NOT NULL DEFAULT 'v1' COMMENT '版本号',
  `path` varchar(100) NOT NULL DEFAULT '' COMMENT '路径',
  `name` varchar(100) NOT NULL COMMENT '收藏名称',
  `server_ip` varchar(20) NOT NULL DEFAULT '' COMMENT '后端服务ip',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `collect_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `env` varchar(10) NOT NULL DEFAULT '' COMMENT '环境 test beta prod',
  `method` varchar(20) NOT NULL COMMENT '请求方式',
  `request` json DEFAULT NULL COMMENT '请求header数据',
  `error` varchar(255) NOT NULL DEFAULT '' COMMENT '错误消息',
  `status` varchar(50) NOT NULL DEFAULT '' COMMENT '后端服务',
  `response` json DEFAULT NULL COMMENT '响应内容',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接口收藏表';


--
-- Table structure for table `apis`
--
DROP TABLE IF EXISTS `apis`;
CREATE TABLE `apis` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '接口名称',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父接口id',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '接口描述',
  `method` varchar(10) NOT NULL COMMENT '请求类型',
  `project_id` smallint(4) unsigned NOT NULL DEFAULT '1' COMMENT '项目id',
  `category_id` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '分类id',
  `path` varchar(100) NOT NULL COMMENT '网关地址',
  `server_path` varchar(100) NOT NULL COMMENT '后端路径',
  `is_sign` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1签名0 无需签名',
  `is_auth` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1认证0 不认证',
  `network` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1外网2 内网',
  `version` varchar(20) NOT NULL DEFAULT '' COMMENT '版本',
  `request` json DEFAULT NULL COMMENT '请求参数',
  `response_type` tinyint(1) unsigned DEFAULT '1' COMMENT '响应格式1json 2 html 3 透传',
  `response` json DEFAULT NULL COMMENT '响应',
  `response_code` json DEFAULT NULL COMMENT '错误码',
  `remark` text COMMENT '备注',
  `creator` int(11) unsigned NOT NULL DEFAULT '1' COMMENT '发布者',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '状态1 可用0 不可用',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '发布时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `test_api_id` int(10) unsigned DEFAULT '0' COMMENT '测试api_id',
  `beta_api_id` int(10) unsigned DEFAULT '0' COMMENT 'beta api id',
  `prod_api_id` int(10) unsigned DEFAULT '0' COMMENT '生产环境id',
  `response_text` json DEFAULT NULL COMMENT '响应json',
  `timeout` mediumint(8) unsigned DEFAULT '5' COMMENT '超时默认值',
  `is_cache` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1缓存0 不缓存',
  `try_times` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '重试次数',
  `upstream_url` varchar(100) NOT NULL DEFAULT '' COMMENT '自定义上游服务',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_api` (`project_id`,`path`,`method`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='api接口';

--
-- Table structure for table `apis_beta`
--
DROP TABLE IF EXISTS `apis_beta`;
CREATE TABLE `apis_beta` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `api_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'api_id',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `method` varchar(10) NOT NULL COMMENT '请求类型',
  `path` varchar(100) NOT NULL COMMENT '网关地址',
  `server_path` varchar(100) NOT NULL COMMENT '后端路径',
  `is_sign` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1签名2 无需签名',
  `is_auth` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1认证0 不认证',
  `network` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1外网2 内网',
  `version` varchar(20) NOT NULL DEFAULT '' COMMENT '版本',
  `request` json DEFAULT NULL COMMENT '请求参数',
  `response_type` tinyint(1) unsigned DEFAULT '1' COMMENT '响应格式1json 2 html 3 透传',
  `response` json DEFAULT NULL COMMENT '响应',
  `creator` int(11) unsigned NOT NULL DEFAULT '1' COMMENT '发布者',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '发布时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `timeout` tinyint(1) unsigned NOT NULL DEFAULT '2' COMMENT '超时时间',
  `is_cache` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1缓存0 不缓存',
  `try_times` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '重试次数',
  `upstream_url` varchar(100) NOT NULL DEFAULT '' COMMENT '自定义上游服务',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_api` (`project_id`,`path`,`method`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='api接口Beta环境';

--
-- Table structure for table `apis_prod`
--
DROP TABLE IF EXISTS `apis_prod`;
CREATE TABLE `apis_prod` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `api_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'api_id',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `method` varchar(10) NOT NULL COMMENT '请求类型',
  `path` varchar(100) NOT NULL COMMENT '网关地址',
  `server_path` varchar(100) NOT NULL COMMENT '后端路径',
  `is_sign` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1签名2 无需签名',
  `is_auth` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1认证0 不认证',
  `network` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1外网2 内网',
  `version` varchar(20) NOT NULL DEFAULT '' COMMENT '版本',
  `request` json DEFAULT NULL COMMENT '请求参数',
  `response_type` tinyint(1) unsigned DEFAULT '1' COMMENT '响应格式1json 2 html 3 透传',
  `response` json DEFAULT NULL COMMENT '响应',
  `creator` int(11) unsigned NOT NULL DEFAULT '1' COMMENT '发布者',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '发布时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `timeout` tinyint(1) unsigned NOT NULL DEFAULT '2' COMMENT '超时时间',
  `is_cache` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1缓存0 不缓存',
  `try_times` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '重试次数',
  `upstream_url` varchar(100) NOT NULL DEFAULT '' COMMENT '自定义上游服务',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_api` (`project_id`,`path`,`method`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='api接口生产环境';

--
-- Table structure for table `apis_test`
--
DROP TABLE IF EXISTS `apis_test`;
CREATE TABLE `apis_test` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `api_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'api_id',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `method` varchar(10) NOT NULL COMMENT '请求类型',
  `path` varchar(100) NOT NULL COMMENT '网关地址',
  `server_path` varchar(100) NOT NULL COMMENT '后端路径',
  `is_sign` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1签名2 无需签名',
  `is_auth` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1认证0 不认证',
  `network` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1外网2 内网',
  `version` varchar(20) NOT NULL DEFAULT '' COMMENT '版本',
  `request` json DEFAULT NULL COMMENT '请求参数',
  `response_type` tinyint(1) unsigned DEFAULT '1' COMMENT '响应格式1json 2 html 3 透传',
  `response` json DEFAULT NULL COMMENT '响应',
  `creator` int(11) unsigned NOT NULL DEFAULT '1' COMMENT '发布者',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '发布时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `timeout` tinyint(1) unsigned NOT NULL DEFAULT '2' COMMENT '超时时间',
  `is_cache` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1缓存0 不缓存',
  `try_times` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '重试次数',
  `upstream_url` varchar(100) NOT NULL DEFAULT '' COMMENT '自定义上游服务',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_api` (`project_id`,`path`,`method`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='api接口';

--
-- Table structure for table `audit_configs`
--
DROP TABLE IF EXISTS `audit_configs`;
CREATE TABLE `audit_configs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `project_id` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '产品线',
  `env` varchar(10) NOT NULL DEFAULT 'prod' COMMENT 'test beta prod',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '名称',
  `value` varchar(255) NOT NULL DEFAULT '' COMMENT '值',
  `versions` varchar(255) NOT NULL DEFAULT '' COMMENT '适用版本',
  `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '发布时间',
  `updated_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='app配置项';


--
-- Table structure for table `audit_projects`
--
DROP TABLE IF EXISTS `audit_projects`;
CREATE TABLE `audit_projects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '产品线标题',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '名称',
  `platform` varchar(10) NOT NULL DEFAULT '' COMMENT 'ios android',
  `env` varchar(10) NOT NULL DEFAULT '' COMMENT '环境test beta prod',
  `num` smallint(4) NOT NULL DEFAULT '0' COMMENT '配置数',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='app配置项产品线表';

--
-- Table structure for table `categories`
--
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT COMMENT '分类id',
  `project_id` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '分类名称',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '分类备注',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '添加时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '修改时间',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '分类状态(1正常,2删除)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='分类表';

--
-- Table structure for table `collect_sets`
--
DROP TABLE IF EXISTS `collect_sets`;
CREATE TABLE `collect_sets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '名称',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '描述',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试集合';


--
-- Table structure for table `follows`
--
DROP TABLE IF EXISTS `follows`;
CREATE TABLE `follows` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `uid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `api_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '接口id',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '关注时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_uid_api_id` (`uid`,`api_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接口关注';

--
-- Table structure for table `groups`
--
DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '分组名',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT '描述',
  `privilege` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1公开 2 私有',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '1 正常 0 删除',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp(1) NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for table `operation_logs`
--
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '操作者uid',
  `username` varchar(100) NOT NULL DEFAULT '' COMMENT '用户名',
  `operation_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '操作的id',
  `content` varchar(255) NOT NULL DEFAULT '' COMMENT '操作内容',
  `data` json DEFAULT NULL COMMENT '改动对比',
  `type` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '1接口2分类3 权限4 项目5分组',
  `type_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '项目或者分组id0 为系统',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '写入时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员操作日志';


--
-- Table structure for table `permissions`
--
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '用户id',
  `privilege_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '分组或者项目id',
  `project_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `role` varchar(10) NOT NULL DEFAULT '' COMMENT '角色  owner master   developer reporter guest',
  `type` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '1 分组 2 项目',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_uid_privilege_project` (`uid`,`privilege_id`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for table `projects`
--
DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '项目名称',
  `group_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '分组id',
  `backend_name` varchar(20) NOT NULL DEFAULT '' COMMENT '后端服务名称',
  `base_path` varchar(50) NOT NULL DEFAULT '/' COMMENT '基本路径',
  `desc` varchar(255) NOT NULL DEFAULT '' COMMENT '项目描述',
  `product_line` varchar(100) NOT NULL DEFAULT '' COMMENT '产品线多个逗号分隔',
  `test_servers` json DEFAULT NULL COMMENT '测试配置',
  `beta_servers` json DEFAULT NULL COMMENT 'Beta配置',
  `prod_servers` json DEFAULT NULL COMMENT 'Production配置',
  `project_type` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '项目属性(1公有,2私有)',
  `ding_robot` varchar(255) NOT NULL DEFAULT '' COMMENT '钉钉机器人',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '状态(1正常,2弃用)',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目表';

--
-- Table structure for table `rate_limiting_apis`
--
DROP TABLE IF EXISTS `rate_limiting_apis`;
CREATE TABLE `rate_limiting_apis` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `rate_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '限速id',
  `project_id` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '项目id',
  `api_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '接口id',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_api_id` (`api_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='限速接口关联';

--
-- Table structure for table `rate_limitings`
--
DROP TABLE IF EXISTS `rate_limitings`;
CREATE TABLE `rate_limitings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '策略名称',
  `period` varchar(5) NOT NULL DEFAULT '' COMMENT 's 秒m分 h小时 d天',
  `api_limit` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT 'api限速',
  `user_limit` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '客户端限速',
  `smooth_limit` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '平滑限速',
  `burst` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT '是否允许突发',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='限速规则';


--
-- Table structure for table `secrets`
--
DROP TABLE IF EXISTS `secrets`;
CREATE TABLE `secrets` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '秘钥名称',
  `platform` varchar(11) NOT NULL DEFAULT '' COMMENT '平台ios android',
  `app_key` varchar(100) NOT NULL DEFAULT '' COMMENT '应用key',
  `app_secret` varchar(100) NOT NULL COMMENT '应用密钥',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '状态(1正常,2冻结,3删除)',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_secret` (`app_secret`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='钥匙管理';


--
-- Table structure for table `users`
--
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `open_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '第三方用户id',
  `source` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '用户来源 register dingding',
  `avatar` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像',
  `is_admin` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1超级管理员0 普通',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `wafs`
--
DROP TABLE IF EXISTS `wafs`;
CREATE TABLE `wafs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL DEFAULT '' COMMENT '规则名称',
  `name` varchar(20) NOT NULL COMMENT '标识',
  `rules` json DEFAULT NULL COMMENT '过虑规则',
  `type` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '1 自定义规则 2 系统规则 ',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '状态1 正常0 禁用',
  `created_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT '1999-12-31 16:00:00' COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='防火墙规则表';


--
-- Table structure for jwts
--
DROP TABLE IF EXISTS `jwts`;
CREATE TABLE `jwts`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL DEFAULT 0 COMMENT '项目ID',
  `project_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '项目标识',
  `secret_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'JWT秘钥',
  `secret_alg` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'HS256' COMMENT 'JWT算法',
  `create_date` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_project`(`project_id`, `project_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'JWT秘钥表';

SET FOREIGN_KEY_CHECKS = 1;

-- init admin user
INSERT INTO `users`(`id`, `name`, `email`, `password`, `remember_token`, `created_at`, `updated_at`, `open_id`, `source`, `avatar`, `is_admin`) VALUES (1, 'admin', 'admin@admin.com', '$2y$10$juJ5o9zlMytDkQeLyblePuVNHaGge2.dlfFgf8dbpZhrWJZp00ij2', NULL, NULL, NULL, '', '', NULL, 1);
