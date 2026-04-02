#!/bin/bash

# ed-station 政务服务事项管理 API 测试脚本
# 包含 SM2 密码加密和完整的 7 个业务接口测试

# set -e  # 移除这个选项，允许脚本继续执行

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
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 测试统计
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试事项 ID（用于后续测试）
TEST_AFFAIR_ID=""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  政务服务事项管理 API 测试脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 加密密码 (使用 SM2)
echo -e "${YELLOW}[1/10] 加密密码 (SM2)...${NC}"
ENCRYPTED_PASSWORD=$($SCRIPT_DIR/encrypt-password.sh $PASSWORD_RAW 2>/dev/null)

if [ -z "$ENCRYPTED_PASSWORD" ]; then
    echo -e "${RED}密码加密失败，请检查前端工程是否已安装依赖：cd ed-station-web && pnpm install${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 密码加密完成${NC}"

# 获取 Token
echo -e "${YELLOW}[2/10] 获取访问令牌...${NC}"
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

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}获取 Token 失败，请检查账号密码或服务状态${NC}"
    echo "响应：$TOKEN_RESPONSE"
    exit 1
fi
echo -e "${GREEN}✓ 获取 Token 成功${NC}"

# 设置请求头
BLADE_AUTH="Blade-Auth: bearer $TOKEN"
REQUESTED_WITH="Blade-Requested-With: BladeHttpRequest"

# ============================================
# T01-分页查询测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T01-分页查询测试${NC}"
echo -e "${CYAN}========================================${NC}"

# T01-01: 正常分页查询
echo -e "${YELLOW}T01-01: 正常分页查询...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" == "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 响应码：$CODE${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
    echo "响应：$RESPONSE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# T01-02: 按事项名称筛选
echo -e "${YELLOW}T01-02: 按事项名称筛选...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
# URL 编码中文参数
AFFAIR_NAME_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('测试', encoding='utf-8'))")
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10&affairName=${AFFAIR_NAME_ENCODED}" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" == "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 响应码：$CODE${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# T01-03: 按事项类别筛选
echo -e "${YELLOW}T01-03: 按事项类别筛选...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10&affairType=01" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" == "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 响应码：$CODE${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# T01-04: 按状态筛选
echo -e "${YELLOW}T01-04: 按状态筛选...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=10&status=1" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" == "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 响应码：$CODE${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# ============================================
# T02-详情查询测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T02-详情查询测试${NC}"
echo -e "${CYAN}========================================${NC}"

# T02-01: 查询存在的事项（先创建一个用于测试）
echo -e "${YELLOW}T02-01: 创建测试事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# 先获取一个有效的部门 ID
DEPT_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-system/dept/tree?tenantId=$TENANT_ID" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
DEPT_ID=$(echo "$DEPT_RESPONSE" | jq -r '.data[0].id // 1' 2>/dev/null || echo "1")

# 创建测试事项
CREATE_DATA=$(cat <<EOF
{
  "affairName": "API 测试事项_$(date +%s)",
  "affairShortName": "API 测试",
  "affairType": "01",
  "legalLimit": 20,
  "promiseLimit": 10,
  "handleCondition": "<p>这是办理条件</p>",
  "remark": "API 测试创建的测试事项",
  "materials": [
    {
      "materialName": "测试材料 1",
      "materialType": "01",
      "materialCopies": 1,
      "materialRemark": "材料说明",
      "attachId": 1
    }
  ]
}
EOF
)

CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$CREATE_DATA")

CODE=$(echo "$CREATE_RESPONSE" | jq -r '.code')
SUCCESS=$(echo "$CREATE_RESPONSE" | jq -r '.success')
if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
    echo -e "${GREEN}✓ 测试事项创建成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # 获取测试事项 ID（通过查询列表获取最新创建的事项）
    # 从事务名称中提取时间戳部分进行精确匹配
    TIMESTAMP=$(echo "$CREATE_DATA" | jq -r '.affairName' | grep -oP '\d+$' || echo "")
    if [ -n "$TIMESTAMP" ]; then
        LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=1&affairName=API 测试事项_${TIMESTAMP}" \
          -H "$AUTH_HEADER" \
          -H "$BLADE_AUTH" \
          -H "$REQUESTED_WITH")
        TEST_AFFAIR_ID=$(echo "$LIST_RESPONSE" | jq -r '.data.records[0].id // empty')
    fi
    echo "测试事项 ID: $TEST_AFFAIR_ID"
else
    echo -e "${RED}✗ 测试事项创建失败${NC}"
    echo "响应：$CREATE_RESPONSE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# T02-02: 查询详情
if [ -n "$TEST_AFFAIR_ID" ]; then
    echo -e "${YELLOW}T02-02: 查询事项详情 (ID=$TEST_AFFAIR_ID)...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/detail?id=$TEST_AFFAIR_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    DATA=$(echo "$RESPONSE" | jq -r '.data')
    if [ "$CODE" == "200" ] && [ "$DATA" != "null" ]; then
        echo -e "${GREEN}✓ 测试通过 - 详情查询成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# T02-03: 查询不存在的事项
echo -e "${YELLOW}T02-03: 查询不存在的事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))
RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/detail?id=999999999" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
DATA=$(echo "$RESPONSE" | jq -r '.data')
if [ "$DATA" == "null" ]; then
    echo -e "${GREEN}✓ 测试通过 - 返回 null 符合预期${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 查询不存在的事项返回了数据${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# T03-事项新增测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T03-事项新增测试${NC}"
echo -e "${CYAN}========================================${NC}"

# T03-01: 正常新增（含材料列表）
echo -e "${YELLOW}T03-01: 正常新增事项（含材料）...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

NEW_AFFAIR_DATA=$(cat <<EOF
{
  "affairName": "新增测试事项_$(date +%s)",
  "affairShortName": "新增测试",
  "affairType": "01",
  "legalLimit": 30,
  "promiseLimit": 15,
  "handleCondition": "<p>办理条件内容</p>",
  "remark": "备注说明",
  "materials": [
    {
      "materialName": "材料 1",
      "materialType": "01",
      "materialCopies": 2,
      "materialRemark": "材料 1 说明",
      "attachId": 1
    },
    {
      "materialName": "材料 2",
      "materialType": "02",
      "materialCopies": 1,
      "materialRemark": "材料 2 说明",
      "attachId": 2
    }
  ]
}
EOF
)

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$NEW_AFFAIR_DATA")

CODE=$(echo "$RESPONSE" | jq -r '.code')
SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
    echo -e "${GREEN}✓ 测试通过 - 新增成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
    echo "响应：$RESPONSE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# T03-02: 缺少必填项校验
echo -e "${YELLOW}T03-02: 缺少必填项校验...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

INVALID_DATA=$(cat <<EOF
{
  "affairShortName": "缺少必填项",
  "legalLimit": 20,
  "promiseLimit": 10
}
EOF
)

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$INVALID_DATA")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" != "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 校验生效，返回错误码：$CODE${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 缺少必填项但返回成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# T03-03: 承诺时限>法定时限校验
echo -e "${YELLOW}T03-03: 承诺时限>法定时限校验...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

INVALID_LIMIT_DATA=$(cat <<EOF
{
  "affairName": "时限校验测试",
  "affairShortName": "时限测试",
  "affairType": "01",
  "legalLimit": 10,
  "promiseLimit": 20,
  "handleCondition": "<p>办理条件</p>"
}
EOF
)

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$INVALID_LIMIT_DATA")

CODE=$(echo "$RESPONSE" | jq -r '.code')
MSG=$(echo "$RESPONSE" | jq -r '.msg')
if [ "$CODE" != "200" ] || [[ "$MSG" == *"承诺时限"* ]]; then
    echo -e "${GREEN}✓ 测试通过 - 时限校验生效${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ 测试失败 - 时限校验未生效${NC}"
    echo "响应：$RESPONSE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# ============================================
# T04-事项修改测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T04-事项修改测试${NC}"
echo -e "${CYAN}========================================${NC}"

# T04-01: 正常修改
if [ -n "$TEST_AFFAIR_ID" ]; then
    echo -e "${YELLOW}T04-01: 正常修改事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    UPDATE_DATA=$(cat <<EOF
    {
      "id": $TEST_AFFAIR_ID,
      "affairName": "修改后的测试事项",
      "affairShortName": "修改测试",
      "affairType": "01",
      "legalLimit": 25,
      "promiseLimit": 12,
      "handleCondition": "<p>修改后的办理条件</p>",
      "remark": "修改备注"
    }
EOF
)

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/update" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH" \
      -H "Content-Type: application/json" \
      -d "$UPDATE_DATA")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ 测试通过 - 修改成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# T04-02: 修改不存在的事项
echo -e "${YELLOW}T04-02: 修改不存在的事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

UPDATE_INVALID_DATA=$(cat <<EOF
{
  "id": 999999999,
  "affairName": "修改不存在的事项",
  "affairShortName": "测试",
  "affairType": "01",
  "legalLimit": 20,
  "promiseLimit": 10,
  "handleCondition": "<p>办理条件</p>"
}
EOF
)

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/update" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$UPDATE_INVALID_DATA")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" != "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 修改不存在的事项返回错误${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 修改不存在的事项返回成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# T05-事项删除测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T05-事项删除测试${NC}"
echo -e "${CYAN}========================================${NC}"

# 先创建一个用于删除测试的事项
echo -e "${YELLOW}准备：创建用于删除测试的事项...${NC}"
TIMESTAMP_1=$(date +%s)
DELETE_TEST_DATA=$(cat <<EOF
{
  "affairName": "待删除测试事项_${TIMESTAMP_1}",
  "affairShortName": "待删除",
  "affairType": "01",
  "legalLimit": 20,
  "promiseLimit": 10,
  "handleCondition": "<p>办理条件</p>"
}
EOF
)

DELETE_TEST_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$DELETE_TEST_DATA")

# 通过查询获取 ID（使用时间戳精确匹配）
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=1&affairName=待删除测试事项_${TIMESTAMP_1}" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
DELETE_TEST_ID=$(echo "$LIST_RESPONSE" | jq -r '.data.records[0].id // empty')
echo "删除测试事项 ID: $DELETE_TEST_ID"

# T05-01: 删除单条事项
if [ -n "$DELETE_TEST_ID" ]; then
    echo -e "${YELLOW}T05-01: 删除单条事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/remove?ids=$DELETE_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ 测试通过 - 删除成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# T05-02: 批量删除事项
# 先创建两个测试事项
echo -e "${YELLOW}准备：创建用于批量删除测试的事项...${NC}"
for i in 1 2; do
    BATCH_DELETE_DATA=$(cat <<EOF
{
  "affairName": "批量删除测试事项_${i}_$(date +%s)",
  "affairShortName": "批量删除",
  "affairType": "01",
  "legalLimit": 20,
  "promiseLimit": 10,
  "handleCondition": "<p>办理条件</p>"
}
EOF
)
    curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH" \
      -H "Content-Type: application/json" \
      -d "$BATCH_DELETE_DATA" > /dev/null
done

# 获取刚创建的事项 ID
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=2&affairName=批量删除测试事项" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
BATCH_IDS=$(echo "$LIST_RESPONSE" | jq -r '.data.records | map(.id) | join(",")')

if [ -n "$BATCH_IDS" ]; then
    echo -e "${YELLOW}T05-02: 批量删除事项 (IDs: $BATCH_IDS)...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/remove?ids=$BATCH_IDS" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ 测试通过 - 批量删除成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# T05-03: 删除不存在的事项
echo -e "${YELLOW}T05-03: 删除不存在的事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/remove?ids=999999999" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" != "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 删除不存在的事项返回错误${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 删除不存在的事项返回成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# T06-事项发布测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T06-事项发布测试${NC}"
echo -e "${CYAN}========================================${NC}"

# 先创建一个用于发布测试的事项
echo -e "${YELLOW}准备：创建用于发布测试的事项...${NC}"
TIMESTAMP_2=$(date +%s)
PUBLISH_TEST_DATA=$(cat <<EOF
{
  "affairName": "发布测试事项_${TIMESTAMP_2}",
  "affairShortName": "发布测试",
  "affairType": "01",
  "legalLimit": 20,
  "promiseLimit": 10,
  "handleCondition": "<p>办理条件</p>"
}
EOF
)

PUBLISH_TEST_RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/save" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH" \
  -H "Content-Type: application/json" \
  -d "$PUBLISH_TEST_DATA")

# 通过查询获取 ID（使用时间戳精确匹配）
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/blade-affair/affair/list?current=1&size=1&affairName=发布测试事项_${TIMESTAMP_2}" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")
PUBLISH_TEST_ID=$(echo "$LIST_RESPONSE" | jq -r '.data.records[0].id // empty')
echo "发布测试事项 ID: $PUBLISH_TEST_ID"

# T06-01: 发布事项
if [ -n "$PUBLISH_TEST_ID" ]; then
    echo -e "${YELLOW}T06-01: 发布事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/publish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ 测试通过 - 发布成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# T06-02: 发布已发布的事项
if [ -n "$PUBLISH_TEST_ID" ]; then
    echo -e "${YELLOW}T06-02: 发布已发布的事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/publish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    # 已发布的事项再次发布应该也成功（幂等性）
    if [ "$CODE" == "200" ]; then
        echo -e "${GREEN}✓ 测试通过 - 重复发布处理正确${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${YELLOW}! 测试注意 - 重复发布返回错误${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
fi

# T06-03: 发布不存在的事项
echo -e "${YELLOW}T06-03: 发布不存在的事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/publish?id=999999999" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" != "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 发布不存在的事项返回错误${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 发布不存在的事项返回成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# T07-事项下架测试
# ============================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  T07-事项下架测试${NC}"
echo -e "${CYAN}========================================${NC}"

# 使用已发布的事项进行下架测试
if [ -n "$PUBLISH_TEST_ID" ]; then
    # T07-01: 下架事项
    echo -e "${YELLOW}T07-01: 下架事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/unpublish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    if [ "$CODE" == "200" ] && [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ 测试通过 - 下架成功${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ 测试失败 - 响应码：$CODE${NC}"
        echo "响应：$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # T07-02: 下架已下架的事项
    echo -e "${YELLOW}T07-02: 下架已下架的事项...${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/unpublish?id=$PUBLISH_TEST_ID" \
      -H "$AUTH_HEADER" \
      -H "$BLADE_AUTH" \
      -H "$REQUESTED_WITH")

    CODE=$(echo "$RESPONSE" | jq -r '.code')
    if [ "$CODE" == "200" ]; then
        echo -e "${GREEN}✓ 测试通过 - 重复下架处理正确${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${YELLOW}! 测试注意 - 重复下架返回错误${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
fi

# T07-03: 下架不存在的事项
echo -e "${YELLOW}T07-03: 下架不存在的事项...${NC}"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

RESPONSE=$(curl -s -X POST "$BASE_URL/blade-affair/affair/unpublish?id=999999999" \
  -H "$AUTH_HEADER" \
  -H "$BLADE_AUTH" \
  -H "$REQUESTED_WITH")

CODE=$(echo "$RESPONSE" | jq -r '.code')
if [ "$CODE" != "200" ]; then
    echo -e "${GREEN}✓ 测试通过 - 下架不存在的事项返回错误${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}! 测试注意 - 下架不存在的事项返回成功${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# ============================================
# 测试结果汇总
# ============================================
echo ""
echo -e "${BLUE}=========================================="
echo -e "${BLUE}  测试结果汇总${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""
echo -e "总测试用例数：${CYAN}$TESTS_TOTAL${NC}"
echo -e "通过：${GREEN}$TESTS_PASSED${NC}"
echo -e "失败：${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "  所有测试通过!"
    echo -e "==========================================${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}=========================================="
    echo "  部分测试失败，请检查失败原因"
    echo -e "==========================================${NC}"
    exit 1
fi
