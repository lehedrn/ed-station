/**
 * Playwright 配置文件
 * 用于 ed-station 前端自动化测试
 */

const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  // 测试超时时间
  timeout: 60 * 1000,

  // 测试文件位置
  testDir: './',

  // 测试文件匹配模式
  testMatch: '*.test.js',

  // 失败重试次数
  retries: 0,

  // 并行执行设置
  workers: 1,

  // 报告配置
  reporter: [
    ['html', { outputFolder: '../playwright-report' }],
    ['list']
  ],

  // 共享配置
  use: {
    // 基础 URL
    baseURL: 'http://localhost:3888',

    // 截图设置
    screenshot: 'only-on-failure',

    // 视频设置
    video: 'retain-on-failure',

    // 追踪设置
    trace: 'retain-on-failure',

    // 浏览器上下文
    viewport: { width: 1920, height: 1080 },

    // 语言设置
    locale: 'zh-CN',

    // 时区设置
    timezoneId: 'Asia/Shanghai',
  },

  // 浏览器配置
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
      },
    },
    // 可选：添加其他浏览器测试
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },
  ],

  // 输出目录
  outputDir: '../playwright-results',

  // 保存截图目录
  snapshotPathTemplate: '{testDir}/screenshots/{testFilePath}/{arg}{ext}',
});
