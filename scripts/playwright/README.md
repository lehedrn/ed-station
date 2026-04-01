# Playwright 测试快速入门

## 一、安装依赖

```bash
# 进入前端工程目录
cd /home/workspace/com/ed-station/ed-station-web

# 安装 Playwright
npm install -D @playwright/test

# 安装 Chromium 浏览器
npx playwright install chromium
```

## 二、启动服务

```bash
# 启动前后端服务
/home/workspace/com/ed-station/scripts/start.sh
```

## 三、运行测试

```bash
# 进入测试目录
cd /home/workspace/com/ed-station/scripts/playwright

# 运行所有测试
npx playwright test

# 运行登录测试
npx playwright test login.test.js

# 运行用户管理测试
npx playwright test user-management.test.js

# 显示浏览器界面运行
npx playwright test --headed
```

## 四、查看结果

```bash
# 查看 HTML 报告
npx playwright show-report ../playwright-report
```

## 五、测试截图

测试截图保存在 `screenshots/` 目录：
- `login-success.png` - 登录成功后的首页
- `user-management.png` - 用户管理页面
- `user-search-admin.png` - 搜索 admin 用户的结果
