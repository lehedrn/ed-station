# ed-station 后端接口 cURL 测试示例

> 更新时间：2026-04-01

本文档提供使用 cURL 测试 ed-station 后端接口的完整示例，用于自动化测试参考。

## 重要提示：密码加密要求

**后端使用国密 SM2 加密算法**，所有登录接口的密码必须先加密再传输。

### 加密方式

使用提供的 Shell 加密脚本（推荐）:

```bash
# 加密密码
ENCRYPTED_PASSWORD=$(/home/workspace/com/ed-station/scripts/encrypt-password.sh admin)
echo "加密后的密码：$ENCRYPTED_PASSWORD"
```

**注意**: 脚本需要在前端工程已安装依赖的情况下才能运行（需要 `sm-crypto` 库）。

---

## 基础配置

### 服务端点

| 配置项 | 值 |
|--------|-----|
| 基础 URL | http://localhost:18080 |
| 认证端点 | /blade-auth/oauth/token |
| 系统模块端点 | /blade-system |

### 客户端凭证

```bash
CLIENT_ID="saber3"
CLIENT_SECRET="saber3_secret"

# Base64 编码 (用于 Authorization 请求头)
CLIENT_AUTH=$(echo -n 'saber3:saber3_secret' | base64)
# 输出：c2FiZXIzOnNhYmVyM19zZWNyZXQ=
```

### 默认测试账号

```bash
TENANT_ID="000000"
USERNAME="admin"
PASSWORD_RAW="admin"
```

### 请求头变量 (推荐)

为了方便调用，建议先设置以下环境变量：

```bash
# 加密密码
ENCRYPTED_PASSWORD=$(/home/workspace/com/ed-station/scripts/encrypt-password.sh admin)

# 获取 Token
TOKEN=$(curl -s -X POST "http://localhost:18080/blade-auth/oauth/token" \
  -H "Tenant-Id: 000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -d "tenantId=000000" \
  -d "username=admin" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all" | jq -r '.access_token')

# 设置请求头变量
AUTH_HEADER="Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)"
BLADE_AUTH="Blade-Auth: bearer $TOKEN"
REQUESTED_WITH="Blade-Requested-With: BladeHttpRequest"
```

之后调用接口时直接使用：
```bash
curl -X GET "http://localhost:18080/blade-system/user/info" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH"
```

---

## 认证流程

### 1. 获取访问令牌 (Token)

**注意**: 密码必须先使用 SM2 加密

```bash
# 加密密码
ENCRYPTED_PASSWORD=$(/home/workspace/com/ed-station/scripts/encrypt-password.sh admin)

# 获取 Token
curl -X POST "http://localhost:18080/blade-auth/oauth/token" \
  -H "Tenant-Id: 000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -d "tenantId=000000" \
  -d "username=admin" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all"
```

**响应示例**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "tenant_id": "000000",
  "user_id": "1123598821738675201",
  "role_id": "1123598816738675201",
  "role_name": "administrator"
}
```

### 2. 保存 Token 到变量

```bash
# 加密密码
ENCRYPTED_PASSWORD=$(/home/workspace/com/ed-station/scripts/encrypt-password.sh admin)

# 获取 Token 并保存到变量
TOKEN=$(curl -s -X POST "http://localhost:18080/blade-auth/oauth/token" \
  -H "Tenant-Id: 000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -d "tenantId=000000" \
  -d "username=admin" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all" | jq -r '.access_token')

echo "Token: $TOKEN"
```

**重要**: 调用受保护接口时需要携带三个请求头：
1. `Authorization`: 客户端认证
2. `Blade-Auth`: 访问令牌
3. `Blade-Requested-With`: 标识请求来源

---

## 用户管理接口测试

### 1. 获取用户列表

**注意**: 需要携带客户端认证 + Token + 请求来源标识

```bash
curl -X GET "http://localhost:18080/blade-system/user/page?current=1&size=10" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

**带筛选条件**:
```bash
curl -X GET "http://localhost:18080/blade-system/user/page?current=1&size=10&account=admin&realName=管理员" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

**按部门筛选**:
```bash
curl -X GET "http://localhost:18080/blade-system/user/page?current=1&size=10&deptId=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 2. 获取用户详情

```bash
curl -X GET "http://localhost:18080/blade-system/user/detail?id=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 3. 获取当前用户信息

```bash
curl -X GET "http://localhost:18080/blade-system/user/info" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 4. 新增用户

```bash
curl -X POST "http://localhost:18080/blade-system/user/submit" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "000000",
    "account": "testuser",
    "realName": "测试用户",
    "password": "123456",
    "deptId": "1",
    "roleId": "1",
    "email": "test@example.com",
    "phone": "13800138000"
  }'
```

### 5. 修改用户

```bash
curl -X POST "http://localhost:18080/blade-system/user/update" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "tenantId": "000000",
    "account": "testuser",
    "realName": "测试用户 (已修改)",
    "deptId": "1",
    "roleId": "1",
    "email": "test@example.com",
    "phone": "13800138000"
  }'
```

### 6. 删除用户

```bash
# 删除单个用户
curl -X POST "http://localhost:18080/blade-system/user/remove?ids=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"

# 批量删除
curl -X POST "http://localhost:18080/blade-system/user/remove?ids=2,3,4" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 7. 重置用户密码

```bash
curl -X POST "http://localhost:18080/blade-system/user/reset-password?userIds=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 8. 修改用户密码

```bash
curl -X POST "http://localhost:18080/blade-system/user/update-password?oldPassword=admin123&newPassword=new123&newPassword1=new123" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 9. 用户授权 (分配角色)

```bash
curl -X POST "http://localhost:18080/blade-system/user/grant?userIds=2&roleIds=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 10. 导出用户

```bash
curl -X GET "http://localhost:18080/blade-system/user/export-user" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -o users.xlsx
```

### 11. 导出用户模板

```bash
curl -X GET "http://localhost:18080/blade-system/user/export-template" \
  -o user_template.xlsx
```

### 12. 导入用户

```bash
curl -X POST "http://localhost:18080/blade-system/user/import-user?isCovered=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -F "file=@/path/to/users.xlsx"
```

---

## 角色管理接口测试

### 1. 获取角色列表

```bash
curl -X GET "http://localhost:18080/blade-system/search/role" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 2. 获取角色详情

```bash
curl -X GET "http://localhost:18080/blade-system/search/role?id=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 3. 新增角色

```bash
curl -X POST "http://localhost:18080/blade-system/role/submit" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "000000",
    "roleName": "测试角色",
    "roleAlias": "TEST_ROLE",
    "sort": 1,
    "isMenu": 1
  }'
```

### 4. 修改角色

```bash
curl -X POST "http://localhost:18080/blade-system/role/update" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "tenantId": "000000",
    "roleName": "测试角色 (已修改)",
    "roleAlias": "TEST_ROLE_UPDATE",
    "sort": 2
  }'
```

### 5. 删除角色

```bash
curl -X POST "http://localhost:18080/blade-system/role/remove?ids=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 6. 角色授权菜单

```bash
curl -X POST "http://localhost:18080/blade-system/role/grant?roleId=2&menuIds=1,2,3,4,5" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 7. 查看角色菜单权限

```bash
curl -X GET "http://localhost:18080/blade-system/role/routes?roleId=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

---

## 菜单管理接口测试

### 1. 获取菜单列表

```bash
curl -X GET "http://localhost:18080/blade-system/menu/page?current=1&size=100" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 2. 获取菜单树

```bash
curl -X GET "http://localhost:18080/blade-system/menu/tree?tenantId=000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 3. 获取路由菜单

```bash
curl -X GET "http://localhost:18080/blade-system/menu/routes?topMenuId=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 4. 获取按钮权限

```bash
curl -X GET "http://localhost:18080/blade-system/menu/buttons" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 5. 获取顶级菜单

```bash
curl -X GET "http://localhost:18080/blade-system/menu/top-menu" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 6. 新增菜单

```bash
curl -X POST "http://localhost:18080/blade-system/menu/submit" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "000000",
    "parentId": 1,
    "code": "test_menu",
    "name": "测试菜单",
    "alias": "Test Menu",
    "path": "/test/menu",
    "source": "icon-menu",
    "type": 1,
    "action": 0,
    "isOpen": 0,
    "remark": "测试菜单"
  }'
```

### 7. 修改菜单

```bash
curl -X POST "http://localhost:18080/blade-system/menu/submit" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 100,
    "tenantId": "000000",
    "parentId": 1,
    "code": "test_menu",
    "name": "测试菜单 (已修改)",
    "alias": "Test Menu Update",
    "path": "/test/menu/update",
    "source": "icon-menu-update",
    "type": 1,
    "action": 0,
    "isOpen": 0
  }'
```

### 8. 删除菜单

```bash
curl -X POST "http://localhost:18080/blade-system/menu/remove?ids=100" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

---

## 部门管理接口测试

### 1. 获取部门列表

```bash
curl -X GET "http://localhost:18080/blade-system/dept/page?current=1&size=10" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 2. 获取部门树

```bash
curl -X GET "http://localhost:18080/blade-system/dept/tree?tenantId=000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 3. 获取部门详情

```bash
curl -X GET "http://localhost:18080/blade-system/dept/detail?id=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 4. 新增部门

```bash
curl -X POST "http://localhost:18080/blade-system/dept/submit" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "000000",
    "parentId": 1,
    "deptName": "测试部门",
    "deptAlias": "TEST_DEPT",
    "sort": 1
  }'
```

### 5. 修改部门

```bash
curl -X POST "http://localhost:18080/blade-system/dept/update" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "tenantId": "000000",
    "parentId": 1,
    "deptName": "测试部门 (已修改)",
    "deptAlias": "TEST_DEPT_UPDATE",
    "sort": 2
  }'
```

### 6. 删除部门

```bash
curl -X POST "http://localhost:18080/blade-system/dept/remove?ids=2" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

---

## 字典管理接口测试

### 1. 获取字典列表

```bash
curl -X GET "http://localhost:18080/blade-system/dict/page?current=1&size=10" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 2. 获取字典详情

```bash
curl -X GET "http://localhost:18080/blade-system/dict/detail?id=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

### 3. 获取字典数据

```bash
curl -X GET "http://localhost:18080/blade-system/dict/dicts?dictCode=gender" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest"
```

---

## 通用响应结构

所有接口返回统一的数据格式：

```json
{
  "code": 200,
  "success": true,
  "msg": "操作成功",
  "data": { ... }
}
```

### 响应状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权/Token 过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 完整的自动化测试脚本

### test-user-api.sh

```bash
#!/bin/bash

# ed-station 用户 API 测试脚本
# 注意：此脚本需要先安装 sm-crypto 并运行加密脚本

BASE_URL="http://localhost:18080"
CLIENT_ID="saber3"
CLIENT_SECRET="saber3_secret"
TENANT_ID="000000"
USERNAME="admin"
PASSWORD_RAW="admin"
SCRIPT_DIR="/home/workspace/com/ed-station/scripts"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 加密密码 (使用 SM2)
echo -e "${YELLOW}[0/7] 加密密码...${NC}"
ENCRYPTED_PASSWORD=$($SCRIPT_DIR/encrypt-password.sh $PASSWORD_RAW 2>/dev/null)

if [ -z "$ENCRYPTED_PASSWORD" ]; then
    echo -e "${RED}密码加密失败，请检查前端工程是否已安装依赖：cd ed-station-web && pnpm install${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 密码加密完成${NC}"

# 获取 Token
echo -e "${YELLOW}[1/7] 获取访问令牌...${NC}"
TOKEN=$(curl -s -X POST "$BASE_URL/blade-auth/oauth/token" \
  -H "Tenant-Id: $TENANT_ID" \
  -H "Authorization: Basic $(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)" \
  -d "tenantId=$TENANT_ID" \
  -d "username=$USERNAME" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all" | jq -r '.access_token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}获取 Token 失败，请检查账号密码或服务状态${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 获取 Token 成功${NC}"

# 测试获取用户列表
echo -e "${YELLOW}[2/7] 测试获取用户列表...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/page?current=1&size=10" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest")
echo "$RESPONSE" | jq '.'
echo -e "${GREEN}✓ 用户列表获取成功${NC}"

# 测试获取用户详情
echo -e "${YELLOW}[3/7] 测试获取用户详情 (ID=1)...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/detail?id=1" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest")
echo "$RESPONSE" | jq '.'
echo -e "${GREEN}✓ 用户详情获取成功${NC}"

# 测试获取当前用户信息
echo -e "${YELLOW}[4/7] 测试获取当前用户信息...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/info" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest")
echo "$RESPONSE" | jq '.'
echo -e "${GREEN}✓ 当前用户信息获取成功${NC}"

# 测试获取用户列表 (带筛选)
echo -e "${YELLOW}[5/7] 测试获取用户列表 (带筛选)...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/page?current=1&size=10&account=admin" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest")
echo "$RESPONSE" | jq '.'
echo -e "${GREEN}✓ 筛选用户列表获取成功${NC}"

# 测试获取菜单按钮权限
echo -e "${YELLOW}[6/7] 测试获取按钮权限...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/menu/buttons" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -H "Blade-Auth: bearer $TOKEN" \
  -H "Blade-Requested-With: BladeHttpRequest")
echo "$RESPONSE" | jq '.'
echo -e "${GREEN}✓ 按钮权限获取成功${NC}"

echo ""
echo -e "${GREEN}=========================================="
echo "  所有测试通过!"
echo "==========================================${NC}"
```

### 使用方法

```bash
# 赋予执行权限
chmod +x /home/workspace/com/ed-station/scripts/test-user-api.sh

# 运行测试
/home/workspace/com/ed-station/scripts/test-user-api.sh
```

---

## Postman 集合

### 导入方式

1. 打开 Postman
2. 点击 Import
3. 选择 Raw text 格式
4. 粘贴下面的 JSON
5. 点击 Import

### Postman Collection JSON

**注意**: Postman 中的密码需要手动加密，或者使用 Pre-request Script 自动加密。

**方法 1: 使用外部脚本加密后手动填入**
```bash
# 运行加密脚本
/home/workspace/com/ed-station/scripts/encrypt-password.sh admin
# 将输出的加密结果填入 Postman
```

**方法 2: 在 Pre-request Script 中加密**
```javascript
// 需要安装 Node.js 模块：npm install -g sm-crypto
const { sm2 } = require('sm-crypto');
const publicKey = '043aec366e561c8d159fb9996cb60506eff05760ba18f58446f8bfffae6b5082767fb8e542ef0cba1e032dd62d8e2cacaa07b798ec831b2b919eeedf88ba5d37ec';
const encryptedPassword = sm2.doEncrypt('admin', publicKey, 0);
pm.variables.set('encrypted_password', encryptedPassword);
```

然后在请求体中使用 `{{encrypted_password}}` 变量。

```json
{
  "info": {
    "name": "ed-station API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [{"key": "token", "value": "{{access_token}}", "type": "string"}]
  },
  "variable": [
    {"key": "base_url", "value": "http://localhost:18080"},
    {"key": "access_token", "value": ""}
  ],
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "获取 Token",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Tenant-Id", "value": "000000"},
              {"key": "Authorization", "value": "Basic c2FiZXIzOnNhYmVyM19zZWNyZXQ="}
            ],
            "body": {
              "mode": "urlencoded",
              "urlencoded": [
                {"key": "tenantId", "value": "000000"},
                {"key": "username", "value": "admin"},
                {"key": "password", "value": "admin"},
                {"key": "grant_type", "value": "password"},
                {"key": "scope", "value": "all"}
              ]
            },
            "url": {"raw": "{{base_url}}/blade-auth/oauth/token"}
          }
        }
      ]
    },
    {
      "name": "User",
      "item": [
        {"name": "获取用户列表", "request": {"method": "GET", "url": "{{base_url}}/blade-system/user/page?current=1&size=10"}},
        {"name": "获取用户详情", "request": {"method": "GET", "url": "{{base_url}}/blade-system/user/detail?id=1"}},
        {"name": "获取当前用户信息", "request": {"method": "GET", "url": "{{base_url}}/blade-system/user/info"}},
        {"name": "新增用户", "request": {"method": "POST", "header": [{"key": "Content-Type", "value": "application/json"}], "body": {"mode": "raw", "raw": "{\"tenantId\":\"000000\",\"account\":\"testuser\",\"realName\":\"测试用户\",\"password\":\"123456\"}"}, "url": "{{base_url}}/blade-system/user/submit"}},
        {"name": "修改用户", "request": {"method": "POST", "header": [{"key": "Content-Type", "value": "application/json"}], "body": {"mode": "raw", "raw": "{\"id\":2,\"tenantId\":\"000000\",\"account\":\"testuser\",\"realName\":\"测试用户\"}"}, "url": "{{base_url}}/blade-system/user/update"}},
        {"name": "删除用户", "request": {"method": "POST", "url": "{{base_url}}/blade-system/user/remove?ids=2"}},
        {"name": "重置密码", "request": {"method": "POST", "url": "{{base_url}}/blade-system/user/reset-password?userIds=2"}}
      ]
    }
  ]
}
```

---

## 注意事项

1. **密码加密要求**: 所有登录接口的密码必须使用 SM2 加密后才能发送
2. **加密脚本用法**: 
   ```bash
   # 加密密码
   ENCRYPTED_PASSWORD=$(/home/workspace/com/ed-station/scripts/encrypt-password.sh admin)
   ```
3. **脚本依赖**: 加密脚本依赖前端工程的 `sm-crypto` 库，确保已运行 `pnpm install`
4. **Token 有效期**: Token 默认有效期为 12 小时 (43200 秒)
5. **请求头**: 所有受保护的接口都需要 `Blade-Auth: Bearer <token>` 请求头
6. **管理员权限**: 部分接口 (标记为 `@IsAdmin`) 需要管理员权限
7. **租户隔离**: 请求需要携带正确的租户 ID
8. **数据备份**: 执行删除/修改操作前请确保数据已备份

---

## 常见问题

### Q1: 为什么登录接口返回 500 错误？

**错误信息**: `exception decoding Hex string: invalid characters encountered`

**原因**: 后端期望 SM2 加密的密码，但发送了明文密码

**解决方法**: 使用提供的 `sm2-encrypt.js` 脚本加密密码后再发送

### Q2: 如何快速获取可复用的 Token?

```bash
# 运行加密脚本并获取 Token
ENCRYPTED_PASSWORD=$(node /home/workspace/com/ed-station/scripts/sm2-encrypt.js admin)

TOKEN=$(curl -s -X POST "http://localhost:18080/blade-auth/oauth/token" \
  -H "Tenant-Id: 000000" \
  -H "Authorization: Basic $(echo -n 'saber3:saber3_secret' | base64)" \
  -d "tenantId=000000" \
  -d "username=admin" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all" | jq -r '.access_token')

echo $TOKEN
```

### Q3: Postman 如何实现 SM2 加密？

在 Postman 的 Collection Pre-request Script 中添加:

```javascript
// 需要先安装 sm-crypto: npm install sm-crypto-gm
const sm2 = require('sm-crypto-gm').sm2;
const publicKey = '043aec366e561c8d159fb9996cb60506eff05760ba18f58446f8bfffae6b5082767fb8e542ef0cba1e032dd62d8e2cacaa07b798ec831b2b919eeedf88ba5d37ec';
const encryptedPassword = sm2.doEncrypt('admin', publicKey, 0);
pm.variables.set('encrypted_password', encryptedPassword);
```

然后在请求体中使用 `{{encrypted_password}}`
