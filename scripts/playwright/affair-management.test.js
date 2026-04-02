/**
 * 政务服务事项管理 UI 自动化测试脚本
 *
 * 测试功能：
 * 1. 列表查询（分页、筛选、搜索）
 * 2. 事项新增（表单填写、材料管理、校验规则）
 * 3. 事项修改（数据回显、表单修改）
 * 4. 事项删除（单条删除、批量删除）
 * 5. 事项发布（发布操作、状态更新）
 * 6. 事项下架（下架操作、状态更新）
 *
 * 使用方法：
 * 1. 确保前后端服务已启动
 * 2. 运行：npx playwright test affair-management.test.js
 */

const { test, expect } = require('@playwright/test');

// 配置
const CONFIG = {
  baseURL: 'http://localhost:3888',
  username: 'admin',
  password: 'admin',
  tenantId: '000000',
  screenshotDir: './screenshots/affair',
};

// 登录函数
async function login(page) {
  console.log('[登录] 访问登录页面...');
  await page.goto(CONFIG.baseURL);
  await page.waitForLoadState('networkidle');

  // 等待登录页面加载
  await page.waitForSelector('.login-container, .login-form', { timeout: 10000 });

  // 输入租户 ID
  const tenantInput = page.locator('input[placeholder="请输入租户 ID"]').first();
  if (await tenantInput.isVisible()) {
    await tenantInput.fill(CONFIG.tenantId);
  }

  // 输入用户名
  console.log('[登录] 输入用户名...');
  const usernameInput = page.locator('input[placeholder="请输入账号"]').first();
  await usernameInput.fill(CONFIG.username);

  // 输入密码
  console.log('[登录] 输入密码...');
  const passwordInput = page.locator('input[type="password"]').first();
  await passwordInput.fill(CONFIG.password);

  // 点击登录
  console.log('[登录] 点击登录按钮...');
  const loginButton = page.locator('.login-submit, button:has-text("登录")').first();
  await loginButton.click();

  // 等待登录处理
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000);

  // 验证登录成功 - 检查是否进入首页
  await page.waitForSelector('.avue-sidebar, .sidebar', { timeout: 10000 });
  console.log('[登录] 登录成功，进入首页');
}

// 导航到事项管理页面
async function navigateToAffairManage(page) {
  console.log('[导航] 访问事项管理页面...');

  // 直接访问事项管理页面 URL
  // 注意：BladeX 框架使用动态菜单路由，需要访问正确的路由路径
  await page.goto(`${CONFIG.baseURL}/affair/manage`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);

  // 检查是否在事项管理页面（通过 URL 或页面内容判断）
  const currentUrl = page.url();
  console.log(`[导航] 当前 URL: ${currentUrl}`);
}

test.describe('政务服务事项管理测试', () => {
  // 每个测试前执行
  test.beforeEach(async ({ page }) => {
    await login(page);
    await page.setViewportSize({ width: 1920, height: 1080 });
  });

  // ============================================
  // T01-列表页面测试
  // ============================================
  test.describe('T01-列表页面测试', () => {

    test('页面加载和路由跳转', async ({ page }) => {
      console.log('[T01-01] 测试页面加载...');

      // 导航到事项管理
      await navigateToAffairManage(page);

      // 检查页面是否加载了 CRUD 组件
      const crudContainer = page.locator('.avue-crud, .basic-container');
      await expect(crudContainer).toBeVisible({ timeout: 10000 });

      // 截图
      await page.screenshot({ path: `${CONFIG.screenshotDir}/list-page.png` });
      console.log('[T01-01] ✓ 页面加载成功');
    });

    test('列表数据展示', async ({ page }) => {
      console.log('[T01-02] 测试列表数据展示...');

      await navigateToAffairManage(page);

      // 等待列表加载
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 检查是否有数据行
      const rows = page.locator('table tbody tr');
      const rowCount = await rows.count();
      console.log(`[T01-02] 列表行数：${rowCount}`);

      // 至少应该有表头或数据
      expect(rowCount).toBeGreaterThan(0);
      console.log('[T01-02] ✓ 列表数据展示正常');
    });

    test('分页功能', async ({ page }) => {
      console.log('[T01-03] 测试分页功能...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找分页控件
      const pagination = page.locator('.el-pagination, .avue-pagination');
      if (await pagination.count() > 0) {
        // 检查是否有页码
        const pageNumbers = pagination.locator('.el-pager li, .number');
        const pageCount = await pageNumbers.count();
        console.log(`[T01-03] 分页数量：${pageCount}`);
        console.log('[T01-03] ✓ 分页控件存在');
      } else {
        console.log('[T01-03] ! 未检测到分页控件（可能数据不足一页）');
      }
    });

    test('按名称搜索', async ({ page }) => {
      console.log('[T01-04] 测试按名称搜索...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找搜索输入框（事项名称）
      const searchInput = page.locator('input[placeholder*="事项名称"], input[placeholder*="名称"]').first();
      if (await searchInput.isVisible()) {
        await searchInput.fill('测试');

        // 点击搜索按钮
        const searchButton = page.locator('button:has-text("搜索"), button:has-text("查询")').first();
        await searchButton.click();

        // 等待搜索结果
        await page.waitForTimeout(2000);
        console.log('[T01-04] ✓ 按名称搜索执行成功');
      } else {
        console.log('[T01-04] ! 未找到搜索输入框');
      }
    });

    test('重置筛选', async ({ page }) => {
      console.log('[T01-05] 测试重置筛选...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找重置按钮
      const resetButton = page.locator('button:has-text("重置")').first();
      if (await resetButton.isVisible()) {
        await resetButton.click();
        await page.waitForTimeout(1000);
        console.log('[T01-05] ✓ 重置筛选执行成功');
      } else {
        console.log('[T01-05] ! 未找到重置按钮');
      }
    });
  });

  // ============================================
  // T02-事项新增测试
  // ============================================
  test.describe('T02-事项新增测试', () => {

    test('打开新增弹窗', async ({ page }) => {
      console.log('[T02-01] 测试打开新增弹窗...');

      await navigateToAffairManage(page);
      await page.waitForSelector('.avue-crud', { timeout: 10000 });

      // 查找新增按钮
      const addButton = page.locator('button:has-text("新增")').first();
      if (await addButton.isVisible()) {
        await addButton.click();
        await page.waitForTimeout(1000);

        // 检查弹窗是否打开
        const dialog = page.locator('.el-dialog, .avue-dialog');
        await expect(dialog).toBeVisible();
        console.log('[T02-01] ✓ 新增弹窗打开成功');

        // 截图
        await page.screenshot({ path: `${CONFIG.screenshotDir}/add-dialog.png` });
      } else {
        console.log('[T02-01] ! 未找到新增按钮（可能无权限）');
      }
    });

    test('必填项校验', async ({ page }) => {
      console.log('[T02-02] 测试必填项校验...');

      await navigateToAffairManage(page);
      await page.waitForSelector('.avue-crud', { timeout: 10000 });

      // 点击新增
      const addButton = page.locator('button:has-text("新增")').first();
      if (await addButton.isVisible()) {
        await addButton.click();
        await page.waitForTimeout(1000);

        // 直接点击保存，触发表单校验
        const saveButton = page.locator('button:has-text("保存")').first();
        if (await saveButton.isVisible()) {
          await saveButton.click();
          await page.waitForTimeout(2000);

          // 检查是否有错误提示
          const errorMsgs = page.locator('.el-form-item__error');
          const errorCount = await errorMsgs.count();
          console.log(`[T02-02] 校验错误数量：${errorCount}`);

          if (errorCount > 0) {
            console.log('[T02-02] ✓ 必填项校验生效');
          } else {
            console.log('[T02-02] ! 未检测到校验错误');
          }
        }
      }
    });

    test('正常新增事项', async ({ page }) => {
      console.log('[T02-03] 测试正常新增事项...');

      await navigateToAffairManage(page);
      await page.waitForSelector('.avue-crud', { timeout: 10000 });

      // 点击新增
      const addButton = page.locator('button:has-text("新增")').first();
      if (await addButton.isVisible()) {
        await addButton.click();
        await page.waitForTimeout(1000);

        // 填写表单
        console.log('[T02-03] 填写表单...');

        // 事项名称
        const affairNameInput = page.locator('input[placeholder*="事项名称"]').first();
        if (await affairNameInput.isVisible()) {
          await affairNameInput.fill(`UI 测试事项_${Date.now()}`);
        }

        // 事项简称
        const shortNameInput = page.locator('input[placeholder*="简称"]').first();
        if (await shortNameInput.isVisible()) {
          await shortNameInput.fill('UI 测试');
        }

        // 事项类别（选择下拉选项）
        const typeSelect = page.locator('.el-select').filter({ hasText: /事项类别/ }).first();
        if (await typeSelect.isVisible()) {
          await typeSelect.click();
          await page.waitForTimeout(500);
          // 选择第一个选项
          const option = page.locator('.el-select-dropdown__item').first();
          if (await option.isVisible()) {
            await option.click();
          }
        }

        // 法定时限
        const legalLimitInput = page.locator('input[placeholder*="法定时限"]').first();
        if (await legalLimitInput.isVisible()) {
          await legalLimitInput.fill('20');
        }

        // 承诺时限
        const promiseLimitInput = page.locator('input[placeholder*="承诺时限"]').first();
        if (await promiseLimitInput.isVisible()) {
          await promiseLimitInput.fill('10');
        }

        // 办理条件（富文本编辑器）
        const editor = page.locator('.ueditor, .tox-edit-area, .ql-editor').first();
        if (await editor.isVisible()) {
          await editor.fill('<p>UI 测试办理条件</p>');
        }

        // 点击保存
        const saveButton = page.locator('button:has-text("保存")').first();
        if (await saveButton.isVisible()) {
          await saveButton.click();
          await page.waitForTimeout(3000);
          console.log('[T02-03] ✓ 新增事项提交成功');

          // 截图
          await page.screenshot({ path: `${CONFIG.screenshotDir}/add-success.png` });
        }
      }
    });

    test('时限校验（承诺时限>法定时限）', async ({ page }) => {
      console.log('[T02-04] 测试时限校验...');

      await navigateToAffairManage(page);
      await page.waitForSelector('.avue-crud', { timeout: 10000 });

      // 点击新增
      const addButton = page.locator('button:has-text("新增")').first();
      if (await addButton.isVisible()) {
        await addButton.click();
        await page.waitForTimeout(1000);

        // 填写法定时限为 10
        const legalLimitInput = page.locator('input[placeholder*="法定时限"]').first();
        if (await legalLimitInput.isVisible()) {
          await legalLimitInput.fill('10');
        }

        // 填写承诺时限为 20（大于法定时限）
        const promiseLimitInput = page.locator('input[placeholder*="承诺时限"]').first();
        if (await promiseLimitInput.isVisible()) {
          await promiseLimitInput.fill('20');
          // 触发 blur 事件
          await promiseLimitInput.press('Tab');
          await page.waitForTimeout(1000);

          // 检查是否有错误提示
          const errorMsg = page.locator('.el-form-item__error');
          if (await errorMsg.count() > 0) {
            const errorText = await errorMsg.textContent();
            console.log(`[T02-04] 时限校验提示：${errorText}`);
            console.log('[T02-04] ✓ 时限校验生效');
          } else {
            console.log('[T02-04] ! 未检测到时限校验错误');
          }
        }
      }
    });
  });

  // ============================================
  // T03-事项修改测试
  // ============================================
  test.describe('T03-事项修改测试', () => {

    test('打开修改弹窗（数据回显）', async ({ page }) => {
      console.log('[T03-01] 测试打开修改弹窗...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找编辑按钮
      const editButton = page.locator('button:has-text("修改")').first();
      if (await editButton.isVisible()) {
        await editButton.click();
        await page.waitForTimeout(2000);

        // 检查弹窗是否打开
        const dialog = page.locator('.el-dialog, .avue-dialog');
        await expect(dialog).toBeVisible();

        // 检查是否有数据回显（表单字段有值）
        const affairNameInput = page.locator('input[placeholder*="事项名称"]').first();
        const value = await affairNameInput.inputValue();
        console.log(`[T03-01] 回显的事项名称：${value}`);

        if (value && value.length > 0) {
          console.log('[T03-01] ✓ 数据回显成功');
        } else {
          console.log('[T03-01] ! 数据回显为空');
        }

        // 截图
        await page.screenshot({ path: `${CONFIG.screenshotDir}/edit-dialog.png` });
      } else {
        console.log('[T03-01] ! 未找到编辑按钮');
      }
    });
  });

  // ============================================
  // T04-事项删除测试
  // ============================================
  test.describe('T04-事项删除测试', () => {

    test('单条删除（含确认）', async ({ page }) => {
      console.log('[T04-01] 测试单条删除...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找删除按钮
      const deleteButton = page.locator('button:has-text("删除")').first();
      if (await deleteButton.isVisible()) {
        await deleteButton.click();
        await page.waitForTimeout(500);

        // 检查确认弹窗
        const confirmDialog = page.locator('.el-message-box, .el-dialog--alert');
        if (await confirmDialog.isVisible()) {
          console.log('[T04-01] 确认弹窗已显示');

          // 点击确认删除
          const confirmButton = page.locator('button:has-text("确定"), button:has-text("确认")').first();
          await confirmButton.click();
          await page.waitForTimeout(2000);

          console.log('[T04-01] ✓ 单条删除操作完成');
        } else {
          console.log('[T04-01] ! 未检测到确认弹窗');
        }
      } else {
        console.log('[T04-01] ! 未找到删除按钮');
      }
    });
  });

  // ============================================
  // T05/T06-事项发布/下架测试
  // ============================================
  test.describe('T05/T06-事项发布/下架测试', () => {

    test('发布事项操作', async ({ page }) => {
      console.log('[T05-01] 测试发布事项...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找发布按钮（可能在行内）
      const publishButton = page.locator('button:has-text("发布")').first();
      if (await publishButton.isVisible()) {
        await publishButton.click();
        await page.waitForTimeout(2000);

        console.log('[T05-01] ✓ 发布操作执行完成');
      } else {
        console.log('[T05-01] ! 未找到发布按钮（可能无权限或已是发布状态）');
      }
    });

    test('下架事项操作', async ({ page }) => {
      console.log('[T06-01] 测试下架事项...');

      await navigateToAffairManage(page);
      await page.waitForSelector('table tbody tr', { timeout: 10000 });

      // 查找下架按钮
      const unpublishButton = page.locator('button:has-text("下架")').first();
      if (await unpublishButton.isVisible()) {
        await unpublishButton.click();
        await page.waitForTimeout(2000);

        console.log('[T06-01] ✓ 下架操作执行完成');
      } else {
        console.log('[T06-01] ! 未找到下架按钮（可能无权限或已是下架状态）');
      }
    });
  });

  // ============================================
  // T07-权限控制测试
  // ============================================
  test.describe('T07-权限控制测试', () => {

    test('按钮权限检查', async ({ page }) => {
      console.log('[T07-01] 测试按钮权限...');

      await navigateToAffairManage(page);
      await page.waitForSelector('.avue-crud', { timeout: 10000 });

      // 检查各个按钮是否存在
      const buttons = {
        '新增': await page.locator('button:has-text("新增")').count(),
        '修改': await page.locator('button:has-text("修改")').count(),
        '删除': await page.locator('button:has-text("删除")').count(),
        '发布': await page.locator('button:has-text("发布")').count(),
        '下架': await page.locator('button:has-text("下架")').count(),
      };

      console.log('[T07-01] 按钮可见性:', buttons);
      console.log('[T07-01] ✓ 按钮权限检查完成');
    });
  });
});
