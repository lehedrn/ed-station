#!/bin/bash
# 检查数据库中的事项数据

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

echo "=== 数据库中的事项列表 ==="
curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=20" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" | jq '.data.records[] | {id, affairName, affairShortName, status}'
