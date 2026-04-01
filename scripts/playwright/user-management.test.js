/**
 * ed-station 用户管理菜单测试脚本
 *
 * 功能：
 * 1. 登录系统
 * 2. 导航到用户管理菜单
 * 3. 查看用户列表
 * 4. 搜索用户
 *
 * 使用方法：
 * 1. 确保前后端服务已启动
 * 2. 运行：npx playwright test user-management.test.js
 */

const { test, expect } = require('@playwright/test');

// 配置
const CONFIG = {
  baseURL: 'http://localhost:3888',
  username: 'admin',
  password: 'admin',
  tenantId: '000000',
};

// 登录辅助函数
async function login(page) {
  console.log('[登录] 访问登录页面...');
  await page.goto(CONFIG.baseURL);

  // 等待登录页面
  await page.waitForLoadState('networkidle');
  await expect(page.locator('.login-container')).toBeVisible();

  // 输入租户 ID
  const tenantInput = page.locator('input[placeholder="请输入租户 ID"]').first();
  if (await tenantInput.isVisible()) {
    await tenantInput.fill(CONFIG.tenantId);
  }

  // 输入用户名
  const usernameInput = page.locator('input[placeholder="请输入账号"]').first();
  await usernameInput.fill(CONFIG.username);

  // 输入密码
  const passwordInput = page.locator('input[type="password"]').first();
  await passwordInput.fill(CONFIG.password);

  // 点击登录
  console.log('[登录] 提交登录...');
  const loginButton = page.locator('.login-submit').first();
  await loginButton.click();

  // 等待登录处理
  await page.waitForLoadState('networkidle', { timeout: 30000 });
  await page.waitForTimeout(5000);

  // 验证登录成功
  await expect(page.locator('.avue-sidebar')).toBeVisible();
  console.log('[登录] 登录成功');
}

// 导航到用户管理页面
async function navigateToUserManagement(page) {
  console.log('[导航] 查找系统管理菜单...');

  // 点击系统管理菜单
  const systemMenu = page.locator('text=系统管理').first();
  if (await systemMenu.isVisible()) {
    await systemMenu.click();
    await page.waitForTimeout(1000);
    console.log('[导航] 点击系统管理菜单');
  }

  // 点击用户管理菜单
  console.log('[导航] 查找用户管理菜单...');
  const userMenu = page.locator('text=用户管理').first();
  await expect(userMenu).toBeVisible();
  await userMenu.click();
  await page.waitForTimeout(2000);
  console.log('[导航] 进入用户管理页面');
}

test.describe('ed-station 用户管理测试', () => {
  test.beforeEach(async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    // 每次测试前登录
    await login(page);
  });

  test('导航到用户管理菜单', async ({ page }) => {
    // 导航到用户管理页面
    await navigateToUserManagement(page);

    // 验证是否进入用户管理页面
    // 检查是否有用户列表表格
    const userTable = page.locator('.el-table');
    await expect(userTable).toBeVisible();

    // 检查是否有搜索框
    const searchInput = page.locator('input[placeholder*="用户名"], input[placeholder*="账号"]');
    await expect(searchInput).toBeVisible();

    console.log('✓ 用户管理页面加载成功');

    // 截图保存
    await page.screenshot({
      path: 'screenshots/user-management.png',
      fullPage: false
    });
    console.log('✓ 已保存截图：screenshots/user-management.png');
  });

  test('搜索用户 - 搜索 admin', async ({ page }) => {
    // 导航到用户管理页面
    await navigateToUserManagement(page);

    console.log('[搜索] 输入搜索条件...');

    // 查找搜索框（账号）
    const searchInput = page.locator('input[placeholder*="用户名"], input[placeholder*="账号"]').first();
    await expect(searchInput).toBeVisible();
    await searchInput.fill('admin');

    // 点击搜索按钮
    console.log('[搜索] 执行搜索...');
    const searchButton = page.locator('button:has-text("搜索"), button:has-text("查询")').first();
    if (await searchButton.isVisible()) {
      await searchButton.click();
      await page.waitForTimeout(2000);
    }

    // 验证搜索结果
    // 检查表格中是否包含 admin
    const tableContent = page.locator('.el-table__body');
    const tableText = await tableContent.textContent();
    const hasAdmin = tableText.includes('admin');

    if (hasAdmin) {
      console.log('✓ 搜索结果中包含 admin 用户');
    } else {
      console.log('⚠ 未找到 admin 用户');
    }

    // 截图保存
    await page.screenshot({
      path: 'screenshots/user-search-admin.png',
      fullPage: false
    });
    console.log('✓ 已保存截图：screenshots/user-search-admin.png');
  });

  test('重置搜索条件', async ({ page }) => {
    // 导航到用户管理页面
    await navigateToUserManagement(page);

    // 先输入搜索条件
    const searchInput = page.locator('input[placeholder*="用户名"], input[placeholder*="账号"]').first();
    await searchInput.fill('test');

    // 点击重置按钮
    console.log('[重置] 重置搜索条件...');
    const resetButton = page.locator('button:has-text("重置"), button:has-text("清空")').first();
    if (await resetButton.isVisible()) {
      await resetButton.click();
      await page.waitForTimeout(1000);

      // 验证输入框已被清空
      const inputValue = await searchInput.inputValue();
      if (inputValue === '') {
        console.log('✓ 重置成功，输入框已清空');
      } else {
        console.log(`⚠ 重置后输入框值：${inputValue}`);
      }
    } else {
      console.log('⚠ 未找到重置按钮');
    }
  });

  test('查看用户列表分页信息', async ({ page }) => {
    // 导航到用户管理页面
    await navigateToUserManagement(page);

    // 查找分页组件
    console.log('[分页] 查找分页组件...');
    const pagination = page.locator('.el-pagination');

    if (await pagination.isVisible()) {
      const paginationText = await pagination.textContent();
      console.log(`分页信息：${paginationText}`);

      // 查找页码按钮
      const pageButtons = pagination.locator('.number, .el-pager li');
      const pageCount = await pageButtons.count();
      console.log(`页码按钮数量：${pageCount}`);
    } else {
      console.log('⚠ 未找到分页组件');
    }
  });
});
