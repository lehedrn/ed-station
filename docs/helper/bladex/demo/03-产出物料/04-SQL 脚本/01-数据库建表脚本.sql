-- =============================================
-- 模块：政务服务事项管理系统
-- 表名：blade_affair (事项主表)
-- 创建时间：2026-04-02
-- =============================================

DROP TABLE IF EXISTS `blade_affair`;
CREATE TABLE `blade_affair` (
  `id` bigint NOT NULL COMMENT '主键 ID',
  `tenant_id` varchar(12) DEFAULT '000000' COMMENT '租户 ID',
  `affair_name` varchar(200) NOT NULL COMMENT '事项名称',
  `affair_short_name` varchar(100) DEFAULT NULL COMMENT '事项简称',
  `implement_code` varchar(50) NOT NULL COMMENT '实施编码 (系统自动生成)',
  `affair_type` varchar(10) NOT NULL COMMENT '事项类别 (字典 affair_type)',
  `legal_limit` int NOT NULL DEFAULT 0 COMMENT '法定时限 (工作日)',
  `promise_limit` int NOT NULL DEFAULT 0 COMMENT '承诺时限 (工作日，≤法定时限)',
  `handle_condition` text NOT NULL COMMENT '办理条件 (富文本 HTML)',
  `remark` text COMMENT '备注说明',
  `publish_time` datetime DEFAULT NULL COMMENT '发布时间',
  `status` int NOT NULL DEFAULT 2 COMMENT '状态 (1-正常 2-下架)',
  `create_user` bigint NOT NULL COMMENT '创建人 ID',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门 ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` bigint DEFAULT NULL COMMENT '更新人 ID',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识 (0-未删除 1-已删除)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_implement_code` (`implement_code`),
  KEY `idx_affair_type` (`affair_type`),
  KEY `idx_status` (`status`),
  KEY `idx_create_user` (`create_user`),
  KEY `idx_affair_name` (`affair_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='政务服务事项表';


-- =============================================
-- 模块：政务服务事项管理系统
-- 表名：blade_affair_material (材料关联表)
-- 创建时间：2026-04-02
-- =============================================

DROP TABLE IF EXISTS `blade_affair_material`;
CREATE TABLE `blade_affair_material` (
  `id` bigint NOT NULL COMMENT '主键 ID',
  `tenant_id` varchar(12) DEFAULT '000000' COMMENT '租户 ID',
  `affair_id` bigint NOT NULL COMMENT '事项 ID',
  `attach_id` bigint NOT NULL COMMENT '附件 ID (复用 blade_attach)',
  `material_name` varchar(200) NOT NULL COMMENT '材料名称',
  `material_type` varchar(10) NOT NULL COMMENT '材料类型 (字典 material_type)',
  `material_copies` int NOT NULL DEFAULT 1 COMMENT '份数要求',
  `material_remark` varchar(500) DEFAULT NULL COMMENT '材料说明',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `create_user` bigint NOT NULL COMMENT '创建人 ID',
  `create_dept` bigint DEFAULT NULL COMMENT '创建部门 ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` bigint DEFAULT NULL COMMENT '更新人 ID',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识 (0-未删除 1-已删除)',
  PRIMARY KEY (`id`),
  KEY `idx_affair_id` (`affair_id`),
  KEY `idx_attach_id` (`attach_id`),
  KEY `idx_sort` (`sort`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='政务服务事项材料关联表';
