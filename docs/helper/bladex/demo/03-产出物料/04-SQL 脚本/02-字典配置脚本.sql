-- =============================================
-- 政务服务事项管理系统 - 字典初始化脚本
-- 创建时间：2026-04-02
-- 说明：使用雪花算法生成 ID (基于当前时间戳)
-- =============================================

-- 设置字符集，防止中文乱码
SET NAMES utf8mb4;
SET character_set_results = utf8mb4;

-- 开启事务
START TRANSACTION;

-- =============================================
-- 1. 事项类别字典 (affair_type)
-- =============================================

-- 1.1 插入字典类型（父级，dict_key = -1）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES (165298986951905281, 0, 'affair_type', '-1', '事项类别', 1, NULL, 0, 1, 0);

-- 1.2 插入字典值（子级）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES
(165298986951905291, 165298986951905281, 'affair_type', '01', '行政许可', 1, NULL, 0, 1, 0),
(165298986951905292, 165298986951905281, 'affair_type', '02', '行政确认', 2, NULL, 0, 1, 0),
(165298986951905293, 165298986951905281, 'affair_type', '03', '行政裁决', 3, NULL, 0, 1, 0),
(165298986951905294, 165298986951905281, 'affair_type', '04', '行政给付', 4, NULL, 0, 1, 0),
(165298986951905295, 165298986951905281, 'affair_type', '05', '公共服务', 5, NULL, 0, 1, 0),
(165298986951905296, 165298986951905281, 'affair_type', '06', '其他', 6, NULL, 0, 1, 0);


-- =============================================
-- 2. 材料类型字典 (material_type)
-- =============================================

-- 2.1 插入字典类型（父级，dict_key = -1）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES (165298986951905282, 0, 'material_type', '-1', '材料类型', 1, NULL, 0, 1, 0);

-- 2.2 插入字典值（子级）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES
(165298986951905301, 165298986951905282, 'material_type', '01', '原件', 1, NULL, 0, 1, 0),
(165298986951905302, 165298986951905282, 'material_type', '02', '复印件', 2, NULL, 0, 1, 0),
(165298986951905303, 165298986951905282, 'material_type', '03', '电子文件', 3, NULL, 0, 1, 0),
(165298986951905304, 165298986951905282, 'material_type', '04', '其他', 4, NULL, 0, 1, 0);


-- =============================================
-- 3. 事项状态字典 (affair_status)
-- =============================================

-- 3.1 插入字典类型（父级，dict_key = -1）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES (165298986951905283, 0, 'affair_status', '-1', '事项状态', 1, NULL, 0, 1, 0);

-- 3.2 插入字典值（子级）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted)
VALUES
(165298986951905311, 165298986951905283, 'affair_status', '1', '正常', 1, NULL, 0, 1, 0),
(165298986951905312, 165298986951905283, 'affair_status', '2', '下架', 2, NULL, 0, 1, 0),
(165298986951905313, 165298986951905283, 'affair_status', '3', '删除', 3, NULL, 0, 1, 0);

-- 提交事务
COMMIT;
