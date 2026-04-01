#!/bin/bash

# ed-station 完整 API 测试脚本
# 包含 SM2 密码加密和完整的请求头

set -e

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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ed-station API 完整测试脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 加密密码 (使用 SM2)
echo -e "${YELLOW}[1/8] 加密密码 (SM2)...${NC}"
ENCRYPTED_PASSWORD=$($SCRIPT_DIR/encrypt-password.sh $PASSWORD_RAW 2>/dev/null)

if [ -z "$ENCRYPTED_PASSWORD" ]; then
    echo -e "${RED}密码加密失败，请检查前端工程是否已安装依赖：cd ed-station-web && pnpm install${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 密码加密完成: ${ENCRYPTED_PASSWORD:0:20}...${NC}"

# 获取 Token
echo -e "${YELLOW}[2/8] 获取访问令牌...${NC}"
AUTH_HEADER="Authorization: Basic $(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)"

TOKEN=$(curl -s -X POST "$BASE_URL/blade-auth/oauth/token" \
  -H "Tenant-Id: $TENANT_ID" \
  -H "$AUTH_HEADER" \
  -d "tenantId=$TENANT_ID" \
  -d "username=$USERNAME" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all" | jq -r '.access_token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}获取 Token 失败，请检查账号密码或服务状态${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 获取 Token 成功: ${TOKEN:0:30}...${NC}"

# 设置请求头
BLADE_AUTH="Blade-Auth: bearer $TOKEN"
REQUESTED_WITH="Blade-Requested-With: BladeHttpRequest"

# 测试获取用户列表
echo -e "${YELLOW}[3/8] 测试获取用户列表...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/page?current=1&size=10" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg, (.data | length)'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 用户列表获取成功${NC}"
else
    echo -e "${RED}✗ 用户列表获取失败${NC}"
fi

# 测试获取用户详情
echo -e "${YELLOW}[4/8] 测试获取用户详情 (ID=1)...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/detail?id=1" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg, .data.realName'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 用户详情获取成功${NC}"
else
    echo -e "${RED}✗ 用户详情获取失败${NC}"
fi

# 测试获取当前用户信息
echo -e "${YELLOW}[5/8] 测试获取当前用户信息...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/user/info" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg, .data.account'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 当前用户信息获取成功${NC}"
else
    echo -e "${RED}✗ 当前用户信息获取失败${NC}"
fi

# 测试获取菜单树
echo -e "${YELLOW}[6/8] 测试获取菜单树...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/menu/tree?tenantId=$TENANT_ID" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 菜单树获取成功${NC}"
else
    echo -e "${RED}✗ 菜单树获取失败${NC}"
fi

# 测试获取按钮权限
echo -e "${YELLOW}[7/8] 测试获取按钮权限...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/menu/buttons" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 按钮权限获取成功${NC}"
else
    echo -e "${RED}✗ 按钮权限获取失败${NC}"
fi

# 测试获取角色列表
echo -e "${YELLOW}[8/8] 测试获取角色列表...${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/search/role" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "$RESPONSE" | jq '.code, .msg, (.data | length)'
if [ "$(echo "$RESPONSE" | jq -r '.code')" == "200" ]; then
    echo -e "${GREEN}✓ 角色列表获取成功${NC}"
else
    echo -e "${RED}✗ 角色列表获取失败${NC}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  所有测试通过!"
echo "==========================================${NC}"
