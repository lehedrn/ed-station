#!/bin/bash

BASE_URL="http://localhost:18080"
CLIENT_ID="saber3"
CLIENT_SECRET="saber3_secret"
TENANT_ID="000000"
USERNAME="admin"
PASSWORD_RAW="admin"
SCRIPT_DIR="/home/workspace/com/ed-station/scripts"

# 加密密码
ENCRYPTED_PASSWORD=$($SCRIPT_DIR/encrypt-password.sh $PASSWORD_RAW 2>/dev/null)

# 获取 Token
AUTH_HEADER="Authorization: Basic $(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)"
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-auth/oauth/token" \
  -H "Tenant-Id: $TENANT_ID" \
  -H "$AUTH_HEADER" \
  -d "tenantId=$TENANT_ID" \
  -d "username=$USERNAME" \
  -d "password=$ENCRYPTED_PASSWORD" \
  -d "grant_type=password" \
  -d "scope=all")

TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
BLADE_AUTH="Blade-Auth: bearer $TOKEN"
REQUESTED_WITH="Blade-Requested-With: BladeHttpRequest"

echo "=== 调试 T01-02: 中文参数编码问题 ==="
# URL 编码中文
AFFAIR_NAME_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('测试', encoding='utf-8'))")
echo "编码后的中文：$AFFAIR_NAME_ENCODED"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10&affairName=${AFFAIR_NAME_ENCODED}" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "响应：$RESPONSE"

echo ""
echo "=== 调试：查看事项列表实际数据 ==="
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "列表响应："
echo "$LIST_RESPONSE" | jq '.'

echo ""
echo "=== 调试：新增事项返回结构 ==="
NEW_DATA='{"affairName":"调试新增测试_'$(date +%s)'","affairShortName":"调试","affairType":"01","legalLimit":20,"promiseLimit":10,"handleCondition":"<p>办理条件</p>"}'
NEW_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$NEW_DATA")
echo "新增响应："
echo "$NEW_RESPONSE" | jq '.'

# 查看返回的 ID 格式
DATA_ID=$(echo "$NEW_RESPONSE" | jq -r '.data')
echo "data 字段原始值：$DATA_ID"
