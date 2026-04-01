# BladeX 模块开发指南

> 基于源码分析的标准化开发流程

---

## 一、项目结构

### 1.1 技术栈

| 项目 | 技术栈 |
|------|--------|
| 后端 | Spring Boot 3.2.10 + BladeX 4.8.0 + MyBatis-Plus |
| 前端 | Vue 3 + Vite + Element Plus + Avue 3.7 |
| 数据库 | MySQL 8.0 + Redis |
| 认证授权 | OAuth2 + JWT |

### 1.2 源码结构

```
ed-station/
├── ed-station-boot/              # 后端工程
│   └── src/main/java/org/springblade/modules/
│       ├── desk/                 # 工作台模块
│       ├── system/               # 系统管理模块
│       ├── auth/                 # 认证授权模块
│       └── resource/             # 资源管理模块
│
├── ed-station-web/               # 前端工程
│   └── src/
│       ├── api/                  # API 接口
│       │   ├── desk/
│       │   ├── system/
│       │   └── resource/
│       └── views/                # 页面组件
│           ├── desk/
│           ├── system/
│           └── resource/
│
└── docs/bladex-tool/             # BladeX 核心源码
    ├── blade-core-tool/          # 核心工具类
    ├── blade-starter-mybatis/    # MyBatis 封装
    └── blade-starter-tenant/     # 多租户封装
```

---

## 二、核心基类

### 2.1 后端实体类继承体系

```
BaseEntity (blade-starter-mybatis)
    ├── id (bigint, 雪花算法)
    ├── createUser (bigint)
    ├── createDept (bigint)
    ├── createTime (datetime)
    ├── updateUser (bigint)
    ├── updateTime (datetime)
    ├── status (int, 默认 1)
    └── isDeleted (int, 0=未删除，1=已删除)

TenantEntity (blade-starter-tenant)
    └── 继承 BaseEntity
        └── tenantId (varchar)
```

**实体类示例**：
```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("blade_inner_message")
@Schema(description = "内部消息实体类")
public class InnerMessage extends TenantEntity {
    @Schema(description = "标题")
    private String title;
    
    @Schema(description = "消息类型")
    private Integer messageType;
    
    // 自动继承：id, tenantId, createUser, createDept, createTime, 
    // updateUser, updateTime, status, isDeleted
}
```

### 2.2 VO 包装类继承体系

**BaseEntityWrapper** (`blade-starter-mybatis`):
```java
public abstract class BaseEntityWrapper<E, V> {
    // 单个实体类包装
    public abstract V entityVO(E entity);
    
    // 实体类集合包装
    public List<V> listVO(List<E> list) { ... }
    
    // 分页实体类集合包装
    public IPage<V> pageVO(IPage<E> pages) { ... }
}
```

**Wrapper 示例**：
```java
public class InnerMessageWrapper extends BaseEntityWrapper<InnerMessage, InnerMessageVO> {
    public static InnerMessageWrapper build() {
        return new InnerMessageWrapper();
    }

    @Override
    public InnerMessageVO entityVO(InnerMessage innerMessage) {
        InnerMessageVO vo = BeanUtil.copyProperties(innerMessage, InnerMessageVO.class);
        // 字典值转换
        String typeName = DictCache.getValue(DictEnum.MESSAGE_TYPE, vo.getMessageType());
        vo.setMessageTypeName(typeName);
        return vo;
    }
}
```

### 2.3 Service 继承体系

```java
// Service 接口
public interface IInnerMessageService extends BaseService<InnerMessage> {
}

// Service 实现
public class InnerMessageServiceImpl 
    extends BaseServiceImpl<InnerMessageMapper, InnerMessage> 
    implements IInnerMessageService {
}
```

---

## 三、接口规范

### 3.1 统一响应格式 R<T>

**源码**: `blade-core-tool/api/R.java`

```json
{
  "code": 200,
  "success": true,
  "data": { ... },
  "msg": "操作成功"
}
```

**常用方法**：
| 方法 | 说明 | 使用场景 |
|------|------|---------|
| `R.data(T)` | 返回业务数据 | 查询接口 |
| `R.status(boolean)` | 返回操作状态 | 增删改接口 |
| `R.success()` | 返回成功 | 无数据成功 |
| `R.fail(String)` | 返回失败 | 业务失败 |

### 3.2 分页参数 Query

**源码**: `blade-starter-mybatis/support/Query.java`

```java
@Data
public class Query {
    private Integer current;  // 当前页（默认 1）
    private Integer size;     // 每页条数（默认 10）
    private String ascs;      // 正排序字段
    private String descs;     // 倒排序字段
}
```

### 3.3 查询条件构造器 Condition

**源码**: `blade-starter-mybatis/support/Condition.java`

**核心方法**：
- `getPage(Query query)` → MyBatis-Plus Page
- `getQueryWrapper(Map query, Class clazz)` → QueryWrapper

**查询后缀对照表**：
| 后缀 | 说明 | SQL 示例 | 参数示例 |
|------|------|---------|---------|
| `_equal` | 等于 | `field = ?` | `messageType_equal=1` |
| `_like` | 模糊 | `field LIKE %?%` | `title_like=测试` |
| `_ge` / `_le` | 大于/小于等于 | `field >= ?` | `age_ge=18` |
| `_datege` / `_datelt` | 日期大于/小于等于 | `field >= ?` | `createTime_datege=2026-01-01` |
| `_null` / `_notnull` | 为空/不为空 | `field IS NULL` | `remark_null=true` |
| `_ignore` | 忽略此条件 | - | `temp_ignore=true` |

---

## 四、标准 CRUD 接口

### 4.1 Controller 模板

```java
@TenantDS
@RestController
@AllArgsConstructor
@PreAuth(menu = "xxx")
@RequestMapping(AppConstant.APPLICATION_xxx_NAME + "/xxx")
@Tag(name = "模块名称", description = "接口描述")
public class XxxController {
    private final IXxxService xxxService;

    @GetMapping("/detail")
    @ApiOperationSupport(order = 1)
    @Operation(summary = "详情")
    public R<XxxVO> detail(XxxEntity entity) {
        XxxEntity detail = xxxService.getOne(Condition.getQueryWrapper(entity));
        return R.data(XxxWrapper.build().entityVO(detail));
    }

    @GetMapping("/list")
    @ApiOperationSupport(order = 2)
    @Operation(summary = "分页")
    public R<IPage<XxxVO>> list(@RequestParam Map<String, Object> entity, Query query) {
        IPage<XxxEntity> pages = xxxService.page(
            Condition.getPage(query), 
            Condition.getQueryWrapper(entity, XxxEntity.class)
        );
        return R.data(XxxWrapper.build().pageVO(pages));
    }

    @PostMapping("/save")
    @ApiOperationSupport(order = 4)
    @Operation(summary = "新增")
    public R save(@RequestBody XxxEntity entity) {
        return R.status(xxxService.save(entity));
    }

    @PostMapping("/update")
    @ApiOperationSupport(order = 5)
    @Operation(summary = "修改")
    public R update(@RequestBody XxxEntity entity) {
        return R.status(xxxService.updateById(entity));
    }

    @PostMapping("/submit")
    @XssIgnore
    @ApiOperationSupport(order = 6)
    @Operation(summary = "新增或修改")
    public R submit(@RequestBody XxxEntity entity) {
        return R.status(xxxService.saveOrUpdate(entity));
    }

    @PostMapping("/remove")
    @ApiOperationSupport(order = 7)
    @Operation(summary = "删除")
    public R remove(@RequestParam String ids) {
        return R.status(xxxService.deleteLogic(Func.toLongList(ids)));
    }
}
```

### 4.2 接口清单

| 功能 | URL | 方法 | 参数 | 响应 |
|------|-----|------|------|------|
| 详情 | `/detail` | GET | 实体对象 | `R<VO>` |
| 分页 | `/list` | GET | Query + Map | `R<IPage<VO>>` |
| 新增 | `/save` | POST | Entity (Body) | `R` |
| 修改 | `/update` | POST | Entity (Body) | `R` |
| 新增或修改 | `/submit` | POST | Entity (Body) | `R` |
| 删除 | `/remove` | POST | ids (String) | `R` |

---

## 五、前端 API 封装

### 5.1 标准 API 模块

```javascript
import request from '@/axios';

// 分页查询
export const getList = (current, size, params) => {
  return request({
    url: '/blade-xxx/xxx/list',
    method: 'get',
    params: { ...params, current, size },
  });
};

// 详情
export const getDetail = id => {
  return request({
    url: '/blade-xxx/xxx/detail',
    method: 'get',
    params: { id },
  });
};

// 删除
export const remove = ids => {
  return request({
    url: '/blade-xxx/xxx/remove',
    method: 'post',
    params: { ids },
  });
};

// 新增/修改
export const add = row => {
  return request({
    url: '/blade-xxx/xxx/submit',
    method: 'post',
    data: row,
  });
};

export const update = row => {
  return request({
    url: '/blade-xxx/xxx/submit',
    method: 'post',
    data: row,
  });
};
```

### 5.2 请求配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `url` | string | - | 请求地址（自动添加 `/api` 前缀） |
| `method` | string | 'get' | 请求方法 |
| `params` | object | - | URL 查询参数 |
| `data` | object | - | 请求体 |
| `cryptoToken` | boolean | false | 是否加密 Token |
| `cryptoData` | boolean | false | 是否加密数据 |

---

## 六、Avue 页面组件

### 6.1 模板结构

```vue
<template>
  <basic-container>
    <avue-crud
      :option="option"
      :table-loading="loading"
      :data="data"
      v-model:page="page"
      ref="crud"
      :permission="permissionList"
      @row-save="rowSave"
      @row-update="rowUpdate"
      @row-del="rowDel"
      @search-change="searchChange"
      @on-load="onLoad"
    >
      <!-- 自定义列 -->
      <template #messageType="{ row }">
        <el-tag>{{ row.messageTypeName }}</el-tag>
      </template>
    </avue-crud>
  </basic-container>
</template>
```

### 6.2 Avue 配置要点

```javascript
option: {
  height: 'auto',
  calcHeight: 32,
  dialogWidth: 950,
  searchShow: true,
  border: true,
  index: true,
  selection: true,
  excelBtn: true,
  column: [
    {
      label: '标题',
      prop: 'title',
      search: true,
      rules: [{ required: true, message: '请输入标题', trigger: 'blur' }],
    },
    {
      label: '消息类型',
      type: 'select',
      dicUrl: '/blade-system/dict/dictionary?code=message_type',
      props: { label: 'dictValue', value: 'dictKey' },
      dataType: 'number',
      prop: 'messageType',
    },
    {
      label: '发布时间',
      prop: 'releaseTime',
      type: 'date',
      format: 'YYYY-MM-DD HH:mm:ss',
      valueFormat: 'YYYY-MM-DD HH:mm:ss',
    },
  ],
}
```

### 6.3 日期范围查询处理

```javascript
onLoad(page, params = {}) {
  const { releaseTimeRange } = this.query;
  let values = { ...params, ...this.query };
  
  if (releaseTimeRange) {
    values = {
      ...values,
      releaseTime_datege: releaseTimeRange[0],  // 大于等于
      releaseTime_datelt: releaseTimeRange[1],  // 小于等于
    };
    values.releaseTimeRange = null;
  }
  
  getList(page.currentPage, page.pageSize, values).then(res => {
    const data = res.data.data;
    this.page.total = data.total;
    this.data = data.records;
  });
}
```

---

## 七、字典配置

### 7.1 blade_dict 表结构

| 字段名 | 说明 | 示例 |
|--------|------|------|
| `id` | 主键（雪花算法） | 100001 |
| `parent_id` | 父主键（顶级为 0，子级指向父级 id） | 0 / 100001 |
| `code` | 字典编码 | 'message_type' |
| `dict_key` | 字典键值（**顶级固定为 -1**） | -1 / 1 / 2 / 3 |
| `dict_value` | 字典显示名称 | '消息类型' / '通知' |
| `sort` | 排序 | 1, 2, 3... |
| `is_sealed` | 是否封存（0: 否，1: 是） | 0 |
| `status` | 状态（默认 1） | 1 |
| `is_deleted` | 是否删除（0: 否，1: 是） | 0 |

### 7.2 字典 SQL 示例

```sql
-- 1. 插入字典类型（父级，dict_key = -1）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted) 
VALUES (100001, 0, 'message_type', '-1', '消息类型', 1, NULL, 0, 1, 0);

-- 2. 插入字典值（子级）
INSERT INTO blade_dict (id, parent_id, code, dict_key, dict_value, sort, remark, is_sealed, status, is_deleted) 
VALUES 
(100002, 100001, 'message_type', '1', '通知', 1, NULL, 0, 1, 0),
(100003, 100001, 'message_type', '2', '公告', 2, NULL, 0, 1, 0),
(100004, 100001, 'message_type', '3', '待办', 3, NULL, 0, 1, 0);
```

### 7.3 后端字典枚举

```java
public enum DictEnum {
    MESSAGE_TYPE("message_type"),
    // ... 其他字典
}
```

---

## 八、菜单权限配置

### 8.1 blade_menu 表结构

| 字段名 | 说明 | 示例 |
|--------|------|------|
| `id` | 主键（雪花算法） | 200001 |
| `parent_id` | 父主键 | 0 / 1123598815738675201 |
| `code` | 菜单编号（权限码） | 'innermessage' |
| `name` | 菜单名称 | '内部消息' |
| `alias` | 菜单别名 | 'menu' / 'add' |
| `path` | 请求地址 | '/desk/innermessage' |
| `source` | 图标 | 'iconfont iconicon_sms' |
| `sort` | 排序 | 1, 2, 3... |
| `category` | 菜单类型 | 1=一级菜单，2=按钮菜单 |
| `action` | 操作类型 | 1=工具栏，2=操作栏，3=工具操作栏 |
| `is_open` | 是否打开新页面 | 1 |
| `is_deleted` | 是否删除 | 0 |

### 8.2 菜单层级关系

```
顶级菜单 (parent_id = 0)
  └── 一级菜单 (parent_id = 顶级菜单 ID, category=1)
      └── 按钮菜单 (parent_id = 一级菜单 ID, category=2)
```

### 8.3 菜单 SQL 示例

```sql
-- 1. 插入一级菜单
INSERT INTO blade_menu (id, parent_id, code, name, alias, path, source, sort, category, action, is_open, is_deleted)
VALUES 
(200001, 1123598815738675201, 'innermessage', '内部消息', 'menu', '/desk/innermessage', 'iconfont iconicon_sms', 3, 1, 0, 1, 0);

-- 2. 插入按钮菜单
INSERT INTO blade_menu (id, parent_id, code, name, alias, path, source, sort, category, action, is_open, is_deleted)
VALUES 
(200002, 200001, 'innermessage_add', '新增', 'add', '/desk/innermessage/add', 'plus', 1, 2, 1, 1, 0),
(200003, 200001, 'innermessage_edit', '修改', 'edit', '/desk/innermessage/edit', 'form', 2, 2, 2, 1, 0),
(200004, 200001, 'innermessage_delete', '删除', 'delete', '/api/blade-desk/innermessage/remove', 'delete', 3, 2, 3, 1, 0),
(200005, 200001, 'innermessage_view', '查看', 'view', '/desk/innermessage/view', 'file-text', 4, 2, 2, 1, 0);
```

---

## 九、权限码对照表

| 权限码 | 说明 | 前端变量 | Controller 注解 |
|--------|------|----------|----------------|
| `xxx` | 菜单访问权限 | - | `@PreAuth(menu = "xxx")` |
| `xxx_add` | 新增权限 | `permission.xxx_add` | - |
| `xxx_edit` | 修改权限 | `permission.xxx_edit` | - |
| `xxx_delete` | 删除权限 | `permission.xxx_delete` | - |
| `xxx_view` | 查看权限 | `permission.xxx_view` | - |

---

## 十、开发步骤

### 10.1 数据库设计

1. 设计表结构（继承 `BaseEntity` 或 `TenantEntity`）
2. 生成建表 SQL

### 10.2 配置字典和权限

1. 生成字典 SQL（如需要）
2. 生成菜单权限 SQL
3. 执行 SQL 并重启服务（刷新缓存）

### 10.3 后端开发

1. Entity 实体类（继承 `TenantEntity`）
2. VO 视图对象（继承 Entity）
3. Mapper 接口（继承 `BaseMapper`）
4. Service 接口（继承 `BaseService`）
5. ServiceImpl 实现（继承 `BaseServiceImpl`）
6. Wrapper 包装类（继承 `BaseEntityWrapper`）
7. Controller 控制器（添加 `@PreAuth` 注解）

### 10.4 前端开发

1. API 接口封装（`src/api/模块/xxx.js`）
2. Vue 页面组件（`src/views/模块/xxx.vue`）
3. 配置 Avue column
4. 配置权限按钮

---

## 🔗 参考源码路径

| 类名 | 路径 |
|------|------|
| `R.java` | `blade-core-tool/src/main/java/org/springblade/core/tool/api/R.java` |
| `ResultCode.java` | `blade-core-tool/src/main/java/org/springblade/core/tool/api/ResultCode.java` |
| `Query.java` | `blade-starter-mybatis/src/main/java/org/springblade/core/mp/support/Query.java` |
| `Condition.java` | `blade-starter-mybatis/src/main/java/org/springblade/core/mp/support/Condition.java` |
| `SqlKeyword.java` | `blade-starter-mybatis/src/main/java/org/springblade/core/mp/support/SqlKeyword.java` |
| `BaseEntity.java` | `blade-starter-mybatis/src/main/java/org/springblade/core/mp/base/BaseEntity.java` |
| `TenantEntity.java` | `blade-starter-tenant/src/main/java/org/springblade/core/tenant/mp/TenantEntity.java` |
| `BaseEntityWrapper.java` | `blade-starter-mybatis/src/main/java/org/springblade/core/mp/support/BaseEntityWrapper.java` |
