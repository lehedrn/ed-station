-- =============================================
-- 模块：政务服务事项管理系统
-- 变更内容：为 blade_affair_material 表添加 status 字段
-- 变更时间：2026-04-02
-- =============================================

-- 添加 status 字段（默认 1）
ALTER TABLE `blade_affair_material`
ADD COLUMN `status` int NOT NULL DEFAULT 1 COMMENT '状态' AFTER `is_deleted`;

-- 添加索引
ALTER TABLE `blade_affair_material`
ADD KEY `idx_status` (`status`);
