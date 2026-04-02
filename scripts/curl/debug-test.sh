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
echo "加密后的密码：$ENCRYPTED_PASSWORD"

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
echo "Token: ${TOKEN:0:50}..."

BLADE_AUTH="Blade-Auth: bearer $TOKEN"
REQUESTED_WITH="Blade-Requested-With: BladeHttpRequest"

echo ""
echo "=== T01-02: 按事项名称筛选 ==="
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10&affairName=测试" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
echo "响应：$RESPONSE"

echo ""
echo "=== T05-01: 删除单条事项 ==="
# 先创建一个事项
DELETE_TEST_DATA='{"affairName":"调试删除测试","affairShortName":"调试","affairType":"01","legalLimit":20,"promiseLimit":10,"handleCondition":"<p>办理条件</p>"}'
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$DELETE_TEST_DATA")
echo "创建响应：$CREATE_RESPONSE"
DELETE_TEST_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data // empty')
echo "事项 ID: $DELETE_TEST_ID"

if [ -n "$DELETE_TEST_ID" ]; then
    REMOVE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/blade-affair/affair/remove?ids=$DELETE_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")
    echo "删除响应：$REMOVE_RESPONSE"
fi

echo ""
echo "=== T06-01: 发布事项 ==="
PUBLISH_TEST_DATA='{"affairName":"调试发布测试","affairShortName":"调试","affairType":"01","legalLimit":20,"promiseLimit":10,"handleCondition":"<p>办理条件</p>"}'
PUBLISH_CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$PUBLISH_TEST_DATA")
echo "创建响应：$PUBLISH_CREATE_RESPONSE"
PUBLISH_TEST_ID=$(echo "$PUBLISH_CREATE_RESPONSE" | jq -r '.data // empty')
echo "事项 ID: $PUBLISH_TEST_ID"

if [ -n "$PUBLISH_TEST_ID" ]; then
    PUBLISH_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/blade-affair/affair/publish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")
    echo "发布响应：$PUBLISH_RESPONSE"
fi

echo ""
echo "=== T07-01: 下架事项 ==="
if [ -n "$PUBLISH_TEST_ID" ]; then
    UNPUBLISH_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/blade-affair/affair/unpublish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")
    echo "下架响应：$UNPUBLISH_RESPONSE"
fi
