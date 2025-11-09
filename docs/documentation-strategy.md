# 文档展示方案

## 当前情况

平台使用 `content/` 目录存放markdown文档，通过文档查看器在线渲染。

## 可选方案

### 方案1：继续使用当前文档查看器（推荐）
**优点：**
- 已实现，无需额外配置
- 统一的UI体验
- 支持代码高亮
- 响应式设计

**缺点：**
- 需要将所有文档上传到服务器
- 大文件加载可能较慢
- 不支持文档间的复杂导航

**实施：**
- 已部署文档到 `/var/www/superbrain/content/`
- 路径已更新为 `content/` 前缀
- 使用marked.js渲染markdown

### 方案2：使用MkDocs
**优点：**
- 专业文档站点生成器
- 支持文档导航和搜索
- 自动生成目录
- 可导出静态站点

**缺点：**
- 需要额外配置和构建
- 样式与主平台不一致
- 需要维护两套系统

**实施步骤：**
```bash
# 安装mkdocs
pip install mkdocs mkdocs-material

# 初始化配置
cd platform
mkdocs new docs-site

# 配置mkdocs.yml
# 将content/目录链接到docs-site/docs/

# 构建
mkdocs build

# 部署到子路径
# 或使用nginx代理到mkdocs服务
```

### 方案3：转换为静态HTML页面
**优点：**
- 完全控制样式
- 与平台UI完美一致
- 可离线访问
- 加载速度快

**缺点：**
- 需要手动或脚本转换
- 维护成本高
- 文档更新需要重新转换

**实施：**
- 编写转换脚本（使用marked.js + 自定义模板）
- 批量转换所有markdown
- 部署到服务器

### 方案4：GitHub Pages集成
**优点：**
- 文档版本控制
- 自动更新
- 无需服务器存储
- 支持PR协作

**缺点：**
- 依赖外部服务
- 样式可能不一致
- 加载速度受GitHub影响

## 推荐方案

**当前阶段：** 继续使用方案1（文档查看器）
- 简单直接，已实现
- 满足当前需求
- 易于维护

**未来优化：**
1. 如果文档量增长，考虑方案2（MkDocs）
2. 如果需要更好的导航，可以增强文档查看器，添加：
   - 侧边栏目录
   - 文档间链接
   - 搜索功能

## 当前文档路径映射

| 资源中心显示 | 实际文件路径 | 说明 |
|------------|------------|------|
| 领航员SOP工作流 | `content/guidelines/领航员SOP工作流（v1）.md` | ✅ 可用 |
| AI提示词库 | `content/guidelines/AI提示词库-领航员专用.md` | ✅ 可用 |
| 黑客松总手册 | `content/guidelines/超脑线上黑客松手册V1.0.md` | ✅ 可用 |
| 操作指南 | `content/workflow/操作指南.md` | ✅ 可用 |
| 快速参考 | `content/workflow/快速参考.md` | ✅ 可用 |
| 会议记录导航 | `content/meetings/README.md` | ✅ 可用 |
| 复盘文档导航 | `content/meetings/复盘文档导航.md` | ✅ 可用 |

## 部署检查清单

- [x] 文档已上传到服务器 `/var/www/superbrain/content/`
- [x] Nginx配置支持 `.md` 文件MIME类型
- [x] 文档查看器路径已更新为 `content/` 前缀
- [x] marked.js和highlight.js已加载
- [ ] 测试所有文档链接是否可访问

