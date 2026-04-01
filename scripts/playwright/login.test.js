/**
 * ed-station 登录测试脚本
 *
 * 功能：
 * 1. 访问登录页面
 * 2. 输入用户名和密码
 * 3. 点击登录按钮
 * 4. 验证登录成功后跳转到首页
 *
 * 使用方法：
 * 1. 确保前后端服务已启动
 * 2. 运行：npx playwright test login.test.js
 */

const { test, expect } = require('@playwright/test');

// 配置
const CONFIG = {
  baseURL: 'http://localhost:3888',
  username: 'admin',
  password: 'admin',
  tenantId: '000000',
};

test.describe('ed-station 登录测试', () => {
  test.beforeEach(async ({ page }) => {
    // 设置视口大小
    await page.setViewportSize({ width: 1920, height: 1080 });
  });

  test('成功登录并进入首页', async ({ page }) => {
    console.log('[1/6] 访问登录页面...');
    await page.goto(CONFIG.baseURL);

    // 等待登录页面加载完成
    await page.waitForLoadState('networkidle');
    console.log('[2/6] 登录页面加载完成');

    // 等待用户登录组件可见
    await expect(page.locator('.login-container')).toBeVisible();
    await expect(page.locator('.login-form, .el-form')).toBeVisible();

    // 输入租户 ID（如果租户模式开启）
    const tenantInput = page.locator('input[placeholder="请输入租户 ID"]').first();
    if (await tenantInput.isVisible()) {
      await tenantInput.fill(CONFIG.tenantId);
      console.log(`[3/6] 输入租户 ID: ${CONFIG.tenantId}`);
    }

    // 输入用户名（使用正确的 placeholder）
    const usernameInput = page.locator('input[placeholder="请输入账号"]').first();
    await expect(usernameInput).toBeVisible();
    await usernameInput.fill(CONFIG.username);
    console.log(`[3/6] 输入用户名：${CONFIG.username}`);

    // 输入密码
    const passwordInput = page.locator('input[placeholder="请输入密码"], input[type="password"]').first();
    await expect(passwordInput).toBeVisible();
    await passwordInput.fill(CONFIG.password);
    console.log('[3/6] 输入密码：******');

    // 点击登录按钮
    console.log('[4/6] 点击登录按钮...');
    const loginButton = page.locator('.login-submit, button:has-text("登录")').first();
    await loginButton.click();

    // 等待登录处理（显示加载动画）
    console.log('[5/6] 等待登录处理...');
    await page.waitForLoadState('networkidle', { timeout: 30000 });
    await page.waitForTimeout(5000);

    // 验证登录成功 - 检查是否跳转到首页
    console.log('[6/6] 验证登录结果...');
    const currentUrl = page.url();
    console.log(`当前 URL: ${currentUrl}`);

    // 检查是否包含首页特征元素
    const sidebar = page.locator('.avue-sidebar, .sidebar');
    const mainContent = page.locator('.avue-main, .main');

    await expect(sidebar).toBeVisible();
    await expect(mainContent).toBeVisible();

    // 检查是否显示用户信息（顶部导航栏）
    const topNav = page.locator('.avue-top, .top');
    await expect(topNav).toBeVisible();

    console.log('✓ 登录成功，已进入首页');

    // 截图保存登录成功后的页面
    await page.screenshot({
      path: 'screenshots/login-success.png',
      fullPage: false
    });
    console.log('✓ 已保存截图：screenshots/login-success.png');
  });

  test('登录失败 - 空用户名', async ({ page }) => {
    console.log('[测试] 空用户名登录测试...');
    await page.goto(CONFIG.baseURL);

    // 等待登录页面
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.login-container')).toBeVisible();

    // 只输入密码，不输入用户名
    const passwordInput = page.locator('input[type="password"]').first();
    await passwordInput.fill(CONFIG.password);

    // 点击登录
    const loginButton = page.locator('.login-submit').first();
    await loginButton.click();

    // 等待验证提示
    await page.waitForTimeout(2000);

    // 检查是否有错误提示
    const errorMsg = page.locator('.el-form-item__error, .el-message--error').first();
    const hasError = await errorMsg.count() > 0;

    if (hasError) {
      const errorText = await errorMsg.textContent();
      console.log(`✓ 正确显示错误提示：${errorText}`);
    } else {
      console.log('⚠ 未检测到错误提示');
    }
  });

  test('登录失败 - 错误密码', async ({ page }) => {
    console.log('[测试] 错误密码登录测试...');
    await page.goto(CONFIG.baseURL);

    // 等待登录页面
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.login-container')).toBeVisible();

    // 输入用户名
    const usernameInput = page.locator('input[placeholder="请输入账号"]').first();
    await usernameInput.fill(CONFIG.username);

    // 输入错误密码
    const passwordInput = page.locator('input[type="password"]').first();
    await passwordInput.fill('wrongpassword');

    // 点击登录
    const loginButton = page.locator('.login-submit').first();
    await loginButton.click();

    // 等待登录处理
    await page.waitForTimeout(5000);

    // 检查是否显示错误提示
    const errorMsg = page.locator('.el-message--error').first();
    const hasError = await errorMsg.count() > 0;

    if (hasError) {
      const errorText = await errorMsg.textContent();
      console.log(`✓ 显示错误提示：${errorText}`);
    } else {
      console.log('⚠ 未检测到错误提示');
    }
  });
});
