# ed-station Playwright 自动化测试指南

> 更新时间：2026-04-01

本文档介绍如何使用 Playwright 对 ed-station 前端进行自动化测试。

---

## 目录

1. [环境准备](#环境准备)
2. [安装依赖](#安装依赖)
3. [测试脚本说明](#测试脚本说明)
4. [运行测试](#运行测试)
5. [测试结果](#测试结果)
6. [自定义测试](#自定义测试)
7. [常见问题](#常见问题)

---

## 环境准备

### 系统要求

- Node.js 16+ 
- 前后端服务已启动
- 前端服务运行在 `http://localhost:3888`

### 服务检查

在运行测试前，请确保服务已启动：

```bash
# 检查前端服务
curl -I http://localhost:3888

# 检查后端服务
curl -I http://localhost:18080
```

---

## 安装依赖

### 1. 安装 Playwright

```bash
cd /home/workspace/com/ed-station/ed-station-web
npm install -D @playwright/test
```

### 2. 安装浏览器

```bash
npx playwright install chromium
```

### 3. 验证安装

```bash
npx playwright --version
```

---

## 测试脚本说明

### 目录结构

```
scripts/playwright/
├── playwright.config.js      # Playwright 配置文件
├── login.test.js             # 登录测试脚本
├── user-management.test.js   # 用户管理测试脚本
├── screenshots/              # 截图保存目录
└── README.md                 # 本说明文档
```

### 测试脚本清单

| 脚本文件 | 功能描述 |
|---------|---------|
| `login.test.js` | 登录功能测试（成功登录、空用户名、错误密码） |
| `user-management.test.js` | 用户管理菜单测试（导航、搜索、重置、分页） |

---

## 运行测试

### 运行所有测试

```bash
cd /home/workspace/com/ed-station/scripts/playwright
npx playwright test
```

### 运行单个测试文件

```bash
# 运行登录测试
npx playwright test login.test.js

# 运行用户管理测试
npx playwright test user-management.test.js
```

### 运行特定测试用例

```bash
# 运行登录测试
npx playwright test login.test.js -g "成功登录"

# 运行用户管理搜索测试
npx playwright test user-management.test.js -g "搜索用户"
```

### 有头模式（显示浏览器界面）

```bash
npx playwright test --headed
```

### 调试模式

```bash
npx playwright test --debug
```

### 生成测试报告

```bash
npx playwright test
npx playwright show-report
```

---

## 测试结果

### 截图位置

测试截图保存在 `screenshots/` 目录：

- `login-success.png` - 登录成功后的首页
- `user-management.png` - 用户管理页面
- `user-search-admin.png` - 搜索 admin 用户的结果

### 测试报告

HTML 测试报告保存在 `playwright-report/` 目录：

```bash
# 查看测试报告
npx playwright show-report ../playwright-report
```

---

## 自定义测试

### 添加新的测试用例

在 `user-management.test.js` 中添加新的 `test()` 函数：

```javascript
test('新增用户测试', async ({ page }) => {
  // 1. 登录（由 beforeEach 自动完成）
  
  // 2. 导航到用户管理页面
  const userMenu = page.locator('text=用户管理').first();
  await userMenu.click();
  await page.waitForTimeout(2000);
  
  // 3. 点击新增按钮
  const addButton = page.locator('button:has-text("新增")').first();
  await addButton.click();
  
  // 4. 填写表单
  // ...
  
  // 5. 提交表单
  // ...
  
  // 6. 验证结果
  // ...
});
```

### 常用定位器示例

```javascript
// 按文本定位
page.locator('text=用户管理')
page.locator('text=系统管理')

// 按 CSS 类定位
page.locator('.el-button--primary')
page.locator('.el-input__inner')

// 按属性定位
page.locator('input[placeholder="请输入用户名"]')
page.locator('button[type="submit"]')

// 按角色定位
page.locator('button:has-text("搜索")')
page.locator('a[href="/wel/index"]')
```

### 常用断言示例

```javascript
// 检查元素可见
await expect(page.locator('.login-form')).toBeVisible();

// 检查元素存在
await expect(page.locator('.user-table')).toBeAttached();

// 检查 URL
expect(page.url()).toContain('/wel/index');

// 检查文本内容
const text = await page.locator('.user-name').textContent();
expect(text).toContain('admin');

// 检查数量
const rows = page.locator('table tr');
expect(await rows.count()).toBeGreaterThan(0);
```

---

## 配置说明

### playwright.config.js 配置项

```javascript
{
  timeout: 60000,              // 测试超时时间（毫秒）
  retries: 0,                  // 失败重试次数
  workers: 1,                  // 并行工作线程数
  
  use: {
    baseURL: 'http://localhost:3888',  // 基础 URL
    viewport: { width: 1920, height: 1080 },  // 视口大小
    locale: 'zh-CN',           // 语言设置
    timezoneId: 'Asia/Shanghai',  // 时区设置
  },
  
  projects: [
    {
      name: 'chromium',        // 浏览器类型
      use: { ...devices['Desktop Chrome'] },
    },
  ],
}
```

---

## 常见问题

### Q1: 测试超时

**现象**: 测试执行时提示 timeout

**原因**: 
- 服务未启动
- 网络请求慢
- 页面加载慢

**解决方法**:
```bash
# 检查服务状态
curl http://localhost:3888

# 增加超时时间（在 playwright.config.js 中修改）
timeout: 120000
```

### Q2: 找不到元素

**现象**: `Error: locator.click: Target element not found`

**原因**:
- 页面未完全加载
- 元素定位器不正确
- 需要登录才能访问

**解决方法**:
```javascript
// 添加等待
await expect(page.locator('.target-element')).toBeVisible();

// 使用更具体的定位器
page.locator('text=精确文本').first()

// 确保已登录（在 beforeEach 中调用登录函数）
```

### Q3: 登录后页面未跳转

**现象**: 点击登录后仍停留在登录页

**原因**:
- 密码错误
- 后端服务异常
- 网络请求失败

**解决方法**:
```javascript
// 检查登录后的页面状态
console.log('当前 URL:', page.url());

// 检查是否有错误提示
const errorMsg = page.locator('.el-message--error');
if (await errorMsg.isVisible()) {
  const text = await errorMsg.textContent();
  console.log('错误:', text);
}
```

### Q4: 截图无法保存

**现象**: 测试完成后没有截图文件

**原因**:
- 目录不存在
- 权限问题

**解决方法**:
```bash
# 创建截图目录
mkdir -p /home/workspace/com/ed-station/scripts/playwright/screenshots

# 检查权限
chmod 755 /home/workspace/com/ed-station/scripts/playwright/screenshots
```

---

## 参考资料

- [Playwright 官方文档](https://playwright.dev/)
- [Playwright Test 介绍](https://playwright.dev/docs/test-intro)
- [Playwright 定位器](https://playwright.dev/docs/locators)
- [Playwright 断言](https://playwright.dev/docs/test-assertions)

---

## 附录：测试脚本模板

```javascript
const { test, expect } = require('@playwright/test');

const CONFIG = {
  baseURL: 'http://localhost:3888',
  username: 'admin',
  password: 'admin',
};

async function login(page) {
  await page.goto(CONFIG.baseURL);
  await page.locator('input[placeholder*="用户名"]').fill(CONFIG.username);
  await page.locator('input[type="password"]').fill(CONFIG.password);
  await page.locator('.login-submit').click();
  await page.waitForLoadState('networkidle');
}

test.describe('我的测试', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('测试功能', async ({ page }) => {
    // 测试代码
  });
});
```
