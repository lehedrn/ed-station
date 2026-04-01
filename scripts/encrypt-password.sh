#!/bin/bash

# ed-station SM2 密码加密脚本
# 用于 cURL 接口测试时加密密码
#
# 用法:
#   ./encrypt-password.sh <password>
#
# 示例:
#   ./encrypt-password.sh admin
#   ./encrypt-password.sh 123456

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WEB_DIR="$PROJECT_ROOT/ed-station-web"

# SM2 公钥 (来自 website.js)
PUBLIC_KEY="043aec366e561c8d159fb9996cb60506eff05760ba18f58446f8bfffae6b5082767fb8e542ef0cba1e032dd62d8e2cacaa07b798ec831b2b919eeedf88ba5d37ec"

# 检查参数
if [ -z "$1" ]; then
    echo "错误：请提供密码参数"
    echo "用法：$0 <password>"
    exit 1
fi

PASSWORD="$1"

# 在前端工程目录下执行 Node.js 脚本
cd "$WEB_DIR"

node -e "
const { sm2 } = require('sm-crypto');
const publicKey = '$PUBLIC_KEY';
const password = '$PASSWORD';
try {
    const encrypted = sm2.doEncrypt(password, publicKey, 0);
    console.log(encrypted);
} catch (error) {
    console.error('加密失败:', error.message);
    process.exit(1);
}
"
