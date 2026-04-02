-- =============================================
-- 政务服务事项管理系统 - 菜单权限配置脚本
-- 创建时间：2026-04-02
-- 说明：使用雪花算法生成 ID (基于当前时间戳)
-- =============================================

-- 设置字符集，防止中文乱码
SET NAMES utf8mb4;
SET character_set_results = utf8mb4;

-- 开启事务
START TRANSACTION;

-- =============================================
-- 1. 一级菜单：政务服务事项管理（parent_id = 0）
-- =============================================

-- 作为一级菜单，parent_id = 0，直接挂载到系统主菜单下
INSERT INTO blade_menu (id, parent_id, code, name, alias, path, source, sort, category, action, is_open, component, remark, is_deleted)
VALUES
(165298986951905381, 0, 'affair', '政务服务事项管理', 'affair', '/affair', 'iconfont icon-gongzuotai', 1, 1, 0, 1, 'views/affair/index', NULL, 0);


-- =============================================
-- 2. 二级菜单：事项信息管理
-- =============================================

-- parent_id 指向一级菜单 ID (165298986951905381)
INSERT INTO blade_menu (id, parent_id, code, name, alias, path, source, sort, category, action, is_open, component, remark, is_deleted)
VALUES
(165298986951905382, 165298986951905381, 'affair_manage', '事项信息管理', 'affair_manage', '/affair/manage', 'iconfont icon-list', 1, 1, 0, 1, 'views/affair/manage/index', NULL, 0);


-- =============================================
-- 3. 按钮菜单（隶属于事项信息管理）
-- =============================================

-- parent_id 指向二级菜单 ID (165298986951905382)
INSERT INTO blade_menu (id, parent_id, code, name, alias, path, source, sort, category, action, is_open, component, remark, is_deleted)
VALUES
-- 新增按钮（工具栏，action=1）
(165298986951905391, 165298986951905382, 'affair_manage_add', '新增', 'add', '/affair/manage/add', 'plus', 1, 2, 1, 1, '', NULL, 0),

-- 修改按钮（操作栏，action=2）
(165298986951905392, 165298986951905382, 'affair_manage_edit', '修改', 'edit', '/affair/manage/edit', 'form', 2, 2, 2, 1, '', NULL, 0),

-- 删除按钮（工具操作栏，action=3）
(165298986951905393, 165298986951905382, 'affair_manage_delete', '删除', 'delete', '/api/blade-affair/affair/remove', 'delete', 3, 2, 3, 1, '', NULL, 0),

-- 查看按钮（操作栏，action=2）
(165298986951905394, 165298986951905382, 'affair_manage_view', '查看', 'view', '/affair/manage/detail', 'file-text', 4, 2, 2, 1, '', NULL, 0),

-- 发布按钮（工具操作栏，action=3）
(165298986951905395, 165298986951905382, 'affair_manage_publish', '发布', 'publish', '/api/blade-affair/affair/publish', 'circle-check', 5, 2, 3, 1, '', NULL, 0),

-- 下架按钮（工具操作栏，action=3）
(165298986951905396, 165298986951905382, 'affair_manage_unpublish', '下架', 'unpublish', '/api/blade-affair/affair/unpublish', 'circle-close', 6, 2, 3, 1, '', NULL, 0);

-- 提交事务
COMMIT;


-- =============================================
-- 4. 权限码对照表
-- =============================================

/*
| 权限码 | 说明 | Controller 注解 |
|--------|------|----------------|
| affair | 一级菜单访问权限 | @PreAuth("affair") |
| affair_manage | 二级菜单访问权限 | @PreAuth("affair_manage") |
| affair_manage_add | 新增权限 | @PreAuth("affair_manage_add") |
| affair_manage_edit | 修改权限 | @PreAuth("affair_manage_edit") |
| affair_manage_delete | 删除权限 | @PreAuth("affair_manage_delete") |
| affair_manage_view | 查看权限 | @PreAuth("affair_manage_view") |
| affair_manage_publish | 发布权限 | @PreAuth("affair_manage_publish") |
| affair_manage_unpublish | 下架权限 | @PreAuth("affair_manage_unpublish") |
*/


-- =============================================
-- 5. 菜单结构说明
-- =============================================

/*
政务服务事项管理 (id=165298986951905381, parent_id=0, 一级菜单)
└── 事项信息管理 (id=165298986951905382, parent_id=165298986951905381, 二级菜单)
    ├── 新增 (id=165298986951905391, parent_id=165298986951905382, action=1)
    ├── 修改 (id=165298986951905392, parent_id=165298986951905382, action=2)
    ├── 删除 (id=165298986951905393, parent_id=165298986951905382, action=3)
    ├── 查看 (id=165298986951905394, parent_id=165298986951905382, action=2)
    ├── 发布 (id=165298986951905395, parent_id=165298986951905382, action=3)
    └── 下架 (id=165298986951905396, parent_id=165298986951905382, action=3)
*/
