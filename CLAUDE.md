# CLAUDE.md - ed-station 项目协作指南

## 项目概览

**ed-station** 是基于 BladeX 4.8.0 的企业级中后台系统，前后端分离架构。

- **前端**: `ed-station-web/` — Vue 3 + Vite + Element Plus + Avue
- **后端**: `ed-station-boot/` — Spring Boot 3.2.10 + BladeX
- **详细分析**: `docs/初始分析/` 目录

## 开发命令

### 前端 (ed-station-web/)
```bash
mkdir -p /home/workspace/com/ed-station/logs
pnpm dev > /home/workspace/com/ed-station/logs/frontend.log 2>&1 &  # 开发服务器 (端口 3888)
pnpm build        # 构建开发版
pnpm build:prod   # 构建生产版
```

### 后端 (ed-station-boot/)
```bash
mkdir -p /home/workspace/com/ed-station/logs
mvn spring-boot:run > /home/workspace/com/ed-station/logs/backend.log 2>&1 &  # 启动应用 (端口 18080)
mvn package            # 打包
```

### 查看日志
```bash
tail -f /home/workspace/com/ed-station/logs/frontend.log  # 前端日志
tail -f /home/workspace/com/ed-station/logs/backend.log   # 后端日志
```

## 技术栈

### 前端
- Vue 3.5.13, Vue Router 4.3.2, Vuex 4.1.0
- Element Plus 2.10.1, Avue 3.7.2
- Axios, Dayjs, 国密 SM2/SM3/SM4
- macOS 风格界面适配 (src/mac/)

### 后端
- Spring Boot 3.2.10, MyBatis-Plus
- BladeX OAuth2, JWT, 多租户
- Redis, PowerJob, OSS

## 目录速查

### 前端 (src/)
```
api/          # API 接口 (12 模块)
components/   # 通用组件
config/       # 应用配置
lang/         # 国际化
mac/          # macOS 适配界面
router/       # 路由
store/        # Vuex
utils/        # 工具
views/        # 视图页面 (12 模块)
axios.js      # HTTP 封装
permission.js # 权限控制
```

### 后端 (modules/)
```
auth/         # 认证授权
system/       # 系统管理
desk/         # 工作台
resource/     # 资源管理
```

## 配置要点

### 前端
- 开发端口：3888
- API 代理：`/api` → `http://localhost:18080`
- 路径别名：`@` → `src/`

### 后端
- 服务端口：18080
- 数据库：MySQL + Druid
- 多租户：tenant_id 字段隔离

## 接口文档

启动后端后访问：http://localhost:18080/doc.html

## 相关文档

### 初始分析文档

| 文档 | 描述 |
|------|------|
| [文档索引](docs/初始分析/文档索引.md) | 所有初始分析文档的索引 |
| [前端工程分析](docs/初始分析/前端工程分析.md) | 前端项目结构、技术栈分析 |
| [后端工程分析](docs/初始分析/后端工程分析.md) | 后端项目结构、模块分析 |
| [项目架构分析](docs/初始分析/项目架构分析.md) | 整体架构、目录结构分析 |
| [前端工程完整流程分析](docs/初始分析/前端工程完整流程分析.md) | 登录到首页的完整流程分析 |
| [端口管理与启动脚本](docs/初始分析/端口管理与启动脚本.md) | 端口管理、启动/停止脚本说明 |
| [cURL_接口测试示例](docs/初始分析/cURL_接口测试示例.md) | 后端接口 cURL 测试（含 SM2 加密） |
| [Playwright_自动化测试指南](docs/初始分析/Playwright_自动化测试指南.md) | Playwright 前端自动化测试 |

### 快速链接

- [📁 初始分析文档索引](docs/初始分析/文档索引.md) — 完整的文档导航
