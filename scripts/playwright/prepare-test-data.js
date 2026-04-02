/**
 * 政务服务事项管理 - 测试数据准备脚本
 *
 * 功能：
 * 1. 通过 API 清理旧的测试数据
 * 2. 创建新的测试数据
 *
 * 使用方法：
 * node prepare-test-data.js
 */

const http = require('http');

// 配置
const CONFIG = {
  baseURL: 'http://localhost:18080',
  tenantId: '000000',
  username: 'admin',
  password: 'admin',
  clientId: 'saber3',
  clientSecret: 'saber3_secret',
};

// 发送 HTTP 请求
function httpRequest(method, url, headers = {}, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      method,
      headers,
    };

    const req = http.request(url, options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: JSON.parse(responseData),
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: responseData,
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(data);
    }
    req.end();
  });
}

// SM2 加密（简化版本，实际需要 sm-crypto 库）
async function sm2Encrypt(password) {
  // 这里需要调用前端加密脚本
  const { exec } = require('child_process');
  return new Promise((resolve, reject) => {
    exec(`node -e "const {sm2}=require('sm-crypto');const pk='043aec366e561c8d159fb9996cb60506eff05760ba18f58446f8bfffae6b5082767fb8e542ef0cba1e032dd62d8e2cacaa07b798ec831b2b919eeedf88ba5d37ec';console.log(sm2.doEncrypt('${password}',pk,0));"`,
      { cwd: '/home/workspace/com/ed-station/ed-station-web' },
      (error, stdout, stderr) => {
        if (error) {
          reject(error);
        } else {
          resolve(stdout.trim());
        }
      }
    );
  });
}

// 获取 Token
async function getToken() {
  console.log('正在获取 Token...');

  try {
    // 加密密码
    const encryptedPassword = await sm2Encrypt(CONFIG.password);
    console.log('密码加密完成');

    const authHeader = 'Basic ' + Buffer.from(`${CONFIG.clientId}:${CONFIG.clientSecret}`).toString('base64');

    const response = await httpRequest('POST', `${CONFIG.baseURL}/blade-auth/oauth/token`, {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Tenant-Id': CONFIG.tenantId,
      'Authorization': authHeader,
    }, `tenantId=${CONFIG.tenantId}&username=${CONFIG.username}&password=${encryptedPassword}&grant_type=password&scope=all`);

    if (response.data.access_token) {
      console.log('Token 获取成功');
      return response.data.access_token;
    } else {
      console.error('Token 获取失败:', response.data);
      return null;
    }
  } catch (error) {
    console.error('获取 Token 出错:', error.message);
    return null;
  }
}

// 获取事项列表
async function getAffairList(token, page = 1, size = 100, params = {}) {
  const authHeader = 'Basic ' + Buffer.from(`${CONFIG.clientId}:${CONFIG.clientSecret}`).toString('base64');
  const queryParams = new URLSearchParams({
    current: page.toString(),
    size: size.toString(),
    ...params,
  }).toString();

  const response = await httpRequest(
    'GET',
    `${CONFIG.baseURL}/blade-affair/affair/list?${queryParams}`,
    {
      'Authorization': authHeader,
      'Blade-Auth': `bearer ${token}`,
      'Blade-Requested-With': 'BladeHttpRequest',
    }
  );

  return response.data;
}

// 删除事项
async function removeAffair(token, ids) {
  const authHeader = 'Basic ' + Buffer.from(`${CONFIG.clientId}:${CONFIG.clientSecret}`).toString('base64');

  const response = await httpRequest(
    'POST',
    `${CONFIG.baseURL}/blade-affair/affair/remove?ids=${ids}`,
    {
      'Authorization': authHeader,
      'Blade-Auth': `bearer ${token}`,
      'Blade-Requested-With': 'BladeHttpRequest',
      'Content-Type': 'application/x-www-form-urlencoded',
    }
  );

  return response.data;
}

// 创建测试事项
async function createAffair(token, affairData) {
  const authHeader = 'Basic ' + Buffer.from(`${CONFIG.clientId}:${CONFIG.clientSecret}`).toString('base64');

  const response = await httpRequest(
    'POST',
    `${CONFIG.baseURL}/blade-affair/affair/save`,
    {
      'Authorization': authHeader,
      'Blade-Auth': `bearer ${token}`,
      'Blade-Requested-With': 'BladeHttpRequest',
      'Content-Type': 'application/json',
    },
    JSON.stringify(affairData)
  );

  return response.data;
}

// 主函数
async function main() {
  console.log('========================================');
  console.log('  政务服务事项管理 - 测试数据准备');
  console.log('========================================\n');

  // 1. 获取 Token
  const token = await getToken();
  if (!token) {
    console.log('获取 Token 失败，退出');
    return;
  }

  // 2. 查询并清理旧的测试数据
  console.log('\n正在查询现有测试数据...');
  const listResult = await getAffairList(token, 1, 100, { affairName: '测试' });

  if (listResult.data && listResult.data.records) {
    const testAffairs = listResult.data.records.filter(item =>
      item.affairName && (item.affairName.includes('测试') || item.affairName.includes('UI 测试') || item.affairName.includes('API 测试'))
    );

    if (testAffairs.length > 0) {
      console.log(`发现 ${testAffairs.length} 条测试数据`);

      // 删除测试数据
      const idsToDelete = testAffairs.map(item => item.id).join(',');
      console.log(`正在删除测试数据：${idsToDelete}`);

      const deleteResult = await removeAffair(token, idsToDelete);
      if (deleteResult.success) {
        console.log('✓ 测试数据删除成功');
      } else {
        console.log('! 删除测试数据失败:', deleteResult.msg);
      }
    } else {
      console.log('没有发现需要清理的测试数据');
    }
  }

  // 3. 创建新的测试数据
  console.log('\n正在创建测试数据...');

  const testAffairs = [
    {
      affairName: '测试事项 1',
      affairShortName: '测试 1',
      affairType: '01',
      legalLimit: 20,
      promiseLimit: 10,
      handleCondition: '<p>这是办理条件内容 1</p>',
      remark: '备注说明 1',
    },
    {
      affairName: '测试事项 2',
      affairShortName: '测试 2',
      affairType: '01',
      legalLimit: 30,
      promiseLimit: 15,
      handleCondition: '<p>这是办理条件内容 2</p>',
      remark: '备注说明 2',
    },
    {
      affairName: '测试事项 3',
      affairShortName: '测试 3',
      affairType: '02',
      legalLimit: 25,
      promiseLimit: 12,
      handleCondition: '<p>这是办理条件内容 3</p>',
      remark: '备注说明 3',
      status: 2, // 下架状态
    },
  ];

  for (const affair of testAffairs) {
    const result = await createAffair(token, affair);
    if (result.success) {
      console.log(`✓ 创建成功：${affair.affairName}`);
    } else {
      console.log(`! 创建失败：${affair.affairName} - ${result.msg}`);
    }
  }

  console.log('\n========================================');
  console.log('  测试数据准备完成');
  console.log('========================================');
}

// 运行主函数
main().catch(console.error);
