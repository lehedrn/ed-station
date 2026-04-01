# 前后端开发示例文档索引

> 本文档汇总了 ed-station 项目的所有前后端开发示例和指南。

---

## 📚 文档清单

| 文档名称 | 描述 | 创建时间 |
|---------|------|---------|
| [模块开发指南.md](./模块开发指南.md) | 基于内部消息模块反向推导的完整开发流程 | 2026-04-02 |

---

## 📖 模块开发指南内容概览

### 开发流程

1. **数据库设计** - 表结构设计、字段规范、SQL 脚本
2. **后端开发** - Entity、VO、Mapper、Service、Controller、Wrapper
3. **前端开发** - API 封装、Vue 页面组件、Avue 配置
4. **字典配置** - 下拉选择框字典数据配置
5. **权限配置** - 菜单管理、权限码配置
6. **测试验证** - 前后端功能测试清单

### 涉及文件

**后端** (ed-station-boot/):
- `pojo/entity/InnerMessage.java` - 实体类
- `pojo/vo/InnerMessageVO.java` - 视图对象
- `mapper/InnerMessageMapper.java` - Mapper 接口
- `mapper/InnerMessageMapper.xml` - MyBatis XML
- `service/IInnerMessageService.java` - 服务接口
- `service/impl/InnerMessageServiceImpl.java` - 服务实现
- `wrapper/InnerMessageWrapper.java` - 数据包装类
- `controller/InnerMessageController.java` - 控制器

**前端** (ed-station-web/):
- `api/desk/innermessage.js` - API 接口封装
- `views/desk/innermessage.vue` - 页面组件

---

## 🔗 相关资源

- 初始分析文档：[../初始分析/README.md](../初始分析/README.md)
- 项目根目录：[../../CLAUDE.md](../../CLAUDE.md)
- 远程仓库：https://github.com/lehedrn/ed-station
