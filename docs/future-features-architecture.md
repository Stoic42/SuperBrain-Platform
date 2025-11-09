# 超脑平台未来功能架构设计

## 📋 文档信息
- **版本**: v1.0
- **创建日期**: 2024年11月2日
- **状态**: 规划中
- **维护者**: 平台开发团队

---

## 🎯 功能概述

本文档描述超脑平台未来计划开发的三大核心功能模块：

1. **用户权限管理系统** - 多用户角色与文件权限控制
2. **数据库与看板系统** - 数据持久化与可拖拽任务看板
3. **AI智能评估系统** - 基于文件上传与改动的个性化AI反馈

---

## 1. 用户权限管理系统

### 1.1 功能需求

#### 核心功能
- **多用户登录系统**
  - 用户注册/登录（支持多种认证方式）
  - 用户角色管理（学员、领航员、导师、管理员等）
  - Session管理和安全控制

- **文件权限控制**
  - 基于角色的文件访问权限（读/写/删除）
  - 文件共享机制（@提及用户，分配特定权限）
  - 权限继承和覆盖机制

- **用户提及与通知**
  - @提及用户功能
  - 权限分配通知
  - 文件变更通知

#### 用户角色定义

| 角色 | 权限范围 | 特殊权限 |
|------|---------|---------|
| **学员** | 查看自己的项目、上传自己的文件 | 可查看共享给自己的文件 |
| **领航员** | 管理所负责团队的项目和文件 | 可@学员分配文件权限 |
| **导师** | 查看所有项目，提供指导 | 可@任何用户，分配全局权限 |
| **管理员** | 完全系统访问权限 | 用户管理、系统配置 |

### 1.2 技术架构

#### 后端架构
```
推荐方案：
- 认证：NextAuth.js / Passport.js
- 数据库：PostgreSQL (用户、角色、权限表)
- API：RESTful API + GraphQL (可选)

数据结构：
- users 表：用户基本信息
- roles 表：角色定义
- permissions 表：权限定义
- file_permissions 表：文件权限关联
- user_notifications 表：用户通知
```

#### 前端架构
```
- 登录/注册界面
- 用户权限管理界面
- 文件权限设置弹窗
- @提及用户自动完成组件
- 权限提示和错误处理
```

#### 文件权限模型
```javascript
{
  fileId: "file-123",
  owner: "user-456",
  permissions: [
    {
      userId: "user-789",
      permissions: ["read", "write"],
      grantedBy: "user-456",
      grantedAt: "2024-11-02T10:00:00Z"
    }
  ],
  sharedWithRoles: [
    {
      roleId: "role-navigator",
      permissions: ["read"]
    }
  ]
}
```

### 1.3 实施步骤

**Phase 1: 基础认证系统** (2周)
- [ ] 用户注册/登录界面
- [ ] Session管理
- [ ] 基础角色系统

**Phase 2: 文件权限系统** (2周)
- [ ] 文件权限数据模型
- [ ] 权限检查中间件
- [ ] 文件上传权限控制

**Phase 3: @提及与通知** (1周)
- [ ] @提及解析和用户选择
- [ ] 权限分配通知
- [ ] 通知中心

---

## 2. 数据库与看板系统

### 2.1 功能需求

#### 核心功能
- **数据持久化**
  - 任务数据存储（看板卡片、任务详情）
  - 项目进度数据存储
  - 用户操作历史记录

- **可拖拽看板**
  - 拖拽任务卡片在不同列之间移动
  - 实时保存拖拽状态
  - 多用户协同拖拽（冲突解决）

- **进度自动计算**
  - 基于看板状态自动计算项目进度
  - 进度变化通知相关用户
  - 进度历史记录

- **数据同步**
  - 前端看板操作同步到数据库
  - 数据库变更实时推送到前端（WebSocket）
  - 离线操作队列和同步

### 2.2 技术架构

#### 数据库设计

**任务表 (tasks)**
```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY,
  project_id VARCHAR(100) NOT NULL,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL, -- 'todo', 'in_progress', 'done'
  assignee_id VARCHAR(100),
  priority VARCHAR(20), -- 'low', 'medium', 'high', 'urgent'
  due_date DATE,
  position INTEGER, -- 在同一列中的位置
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(100) NOT NULL
);

CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id);
```

**项目进度表 (project_progress)**
```sql
CREATE TABLE project_progress (
  id UUID PRIMARY KEY,
  project_id VARCHAR(100) NOT NULL UNIQUE,
  overall_progress INTEGER DEFAULT 0, -- 0-100
  total_tasks INTEGER DEFAULT 0,
  completed_tasks INTEGER DEFAULT 0,
  in_progress_tasks INTEGER DEFAULT 0,
  todo_tasks INTEGER DEFAULT 0,
  last_calculated_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**操作历史表 (operation_history)**
```sql
CREATE TABLE operation_history (
  id UUID PRIMARY KEY,
  user_id VARCHAR(100) NOT NULL,
  project_id VARCHAR(100) NOT NULL,
  operation_type VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'move'
  entity_type VARCHAR(50) NOT NULL, -- 'task', 'milestone', etc.
  entity_id VARCHAR(100) NOT NULL,
  old_value JSONB,
  new_value JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_operation_history_project ON operation_history(project_id, created_at DESC);
```

#### 后端API设计

```typescript
// 任务管理 API
POST   /api/tasks                    // 创建任务
GET    /api/tasks/:id                // 获取任务详情
PUT    /api/tasks/:id                // 更新任务
DELETE /api/tasks/:id                // 删除任务
PATCH  /api/tasks/:id/move           // 移动任务（拖拽）
GET    /api/projects/:id/tasks       // 获取项目所有任务

// 项目进度 API
GET    /api/projects/:id/progress    // 获取项目进度
POST   /api/projects/:id/progress/recalculate // 手动重新计算进度

// WebSocket 事件
websocket.on('task:moved', (data) => {
  // 广播任务移动事件给所有在线用户
});
```

#### 前端实现

**看板拖拽功能**
```javascript
// 使用 Sortable.js 或 dnd-kit
import { DndContext, DragOverlay } from '@dnd-kit/core';
import { useSortable } from '@dnd-kit/sortable';

// 拖拽处理
const handleDragEnd = async (event) => {
  const { active, over } = event;
  if (!over) return;
  
  const taskId = active.id;
  const newStatus = over.data.current.status;
  
  // 调用API更新任务状态
  await fetch(`/api/tasks/${taskId}/move`, {
    method: 'PATCH',
    body: JSON.stringify({ status: newStatus })
  });
  
  // 触发进度重新计算
  await recalculateProgress();
};
```

**实时同步**
```javascript
// WebSocket连接
const ws = new WebSocket('ws://api.superbrain.ton-ton.fun');

ws.onmessage = (event) => {
  const { type, data } = JSON.parse(event.data);
  
  switch(type) {
    case 'task:moved':
      updateTaskInState(data);
      break;
    case 'task:created':
      addTaskToState(data);
      break;
    case 'progress:updated':
      updateProjectProgress(data);
      break;
  }
};
```

### 2.3 进度评估集成

#### 评估维度
1. **任务完成率** = 已完成任务 / 总任务
2. **进度趋势** = 最近7天的完成速度
3. **里程碑达成率** = 已达成里程碑 / 总里程碑
4. **团队活跃度** = 团队成员任务分配和执行情况

#### 自动评估触发
- 任务状态变更时
- 每天定时评估（00:00）
- 里程碑日期临近时
- 手动触发评估

---

## 3. AI智能评估系统

### 3.1 功能需求

#### 核心功能
- **文件上传分析**
  - 自动识别上传文件类型（代码、文档、图片等）
  - 文件内容提取和分析
  - 与项目进度关联分析

- **改动追踪与分析**
  - Git提交记录分析
  - 代码变更diff分析
  - 文档修改内容分析

- **个性化AI反馈**
  - 基于用户历史表现的个性化建议
  - 针对性的学习资源推荐
  - 风险评估和预警

- **多维度评估**
  - 技术能力评估
  - 团队协作评估
  - 项目管理能力评估
  - 创新思维评估

### 3.2 技术架构

#### AI服务架构

```
前端上传/改动 → API Gateway → AI分析服务 → 反馈生成 → 数据库存储 → 前端展示
                                    ↓
                               OpenAI API / Claude API
                                    ↓
                              自定义Prompt工程
```

#### 数据流设计

**文件上传流程**
```
1. 用户上传文件
   ↓
2. 文件存储（S3/OSS）
   ↓
3. 触发AI分析任务（异步）
   ↓
4. AI提取文件内容、类型、关键信息
   ↓
5. 与项目进度、用户历史关联分析
   ↓
6. 生成个性化反馈
   ↓
7. 保存反馈到数据库
   ↓
8. 通知用户查看反馈
```

**改动分析流程**
```
1. 检测到Git提交/文件修改
   ↓
2. 提取变更内容（diff）
   ↓
3. AI分析变更：
   - 代码质量变化
   - 技术实现改进
   - 潜在问题识别
   - 最佳实践建议
   ↓
4. 结合用户当前任务和目标
   ↓
5. 生成针对性反馈
```

#### API设计

```typescript
// 文件上传与AI分析
POST   /api/files/upload              // 上传文件，触发AI分析
GET    /api/files/:id/analysis        // 获取文件AI分析结果
POST   /api/files/:id/reanalyze       // 重新分析文件

// 改动分析与反馈
POST   /api/changes/analyze           // 分析代码/文档改动
GET    /api/users/:id/feedback        // 获取用户的所有AI反馈
GET    /api/users/:id/feedback/latest // 获取最新反馈

// AI评估报告
GET    /api/users/:id/assessment      // 获取用户综合评估报告
POST   /api/users/:id/assessment/refresh // 刷新评估报告
```

#### AI Prompt设计

**文件分析Prompt模板**
```
你是一位经验丰富的项目导师，正在评估学员提交的项目文件。

文件信息：
- 文件名：{filename}
- 文件类型：{fileType}
- 所属项目：{projectName}
- 提交者：{userName}
- 提交时间：{uploadTime}

文件内容：
{fileContent}

用户背景：
- 当前项目阶段：{projectPhase}
- 已完成任务：{completedTasks}
- 遇到的技术难点：{technicalChallenges}
- 历史表现：{historicalPerformance}

请从以下维度提供个性化反馈：
1. 技术实现评估：代码/设计质量、最佳实践应用
2. 项目进度关联：这份文件如何推进项目目标
3. 学习建议：针对性的改进建议和学习资源
4. 风险评估：识别潜在问题和技术风险
5. 鼓励与激励：指出亮点，给予建设性鼓励

请使用友好的、支持性的语调，适合青少年学习者。
```

**改动分析Prompt模板**
```
分析以下代码/文档改动，提供针对性反馈：

变更摘要：
- 变更类型：{changeType}
- 变更文件：{changedFiles}
- 变更行数：+{additions} -{deletions}

变更内容：
{changeDiff}

项目上下文：
- 当前任务：{currentTask}
- 项目目标：{projectGoal}
- 技术栈：{techStack}

请评估：
1. 改动质量：是否符合最佳实践
2. 问题识别：是否有潜在的bug或问题
3. 改进建议：具体的优化建议
4. 学习价值：这次改动体现了哪些技能提升
```

#### 环境变量配置

创建 `.env.example` 文件：
```bash
# OpenAI API (推荐用于代码分析)
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
OPENAI_MODEL=gpt-4-turbo-preview

# Anthropic Claude API (推荐用于文档分析)
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
ANTHROPIC_MODEL=claude-3-opus-20240229

# AI服务配置
AI_SERVICE_ENABLED=true
AI_ANALYSIS_ASYNC=true
AI_FEEDBACK_LANGUAGE=zh-CN

# 文件存储配置
FILE_STORAGE_TYPE=s3  # s3, oss, local
AWS_S3_BUCKET=superbrain-files
AWS_ACCESS_KEY_ID=xxxxx
AWS_SECRET_ACCESS_KEY=xxxxx

# 数据库配置
DATABASE_URL=postgresql://user:password@localhost:5432/superbrain
```

### 3.3 评估维度设计

#### 技术能力评估
- **代码质量**：规范性、可读性、可维护性
- **技术选型**：是否合适、是否有更好的方案
- **问题解决**：调试能力、错误处理
- **学习能力**：新技术掌握速度、文档阅读能力

#### 团队协作评估
- **沟通频率**：在团队中的参与度
- **任务完成**：按时完成率、质量
- **互助行为**：帮助其他成员的频率
- **冲突处理**：解决团队分歧的能力

#### 项目管理能力评估
- **计划执行**：是否按计划推进
- **时间管理**：任务优先级判断
- **风险管理**：识别和应对风险
- **进度跟踪**：对自己的进度有清晰认知

#### 创新思维评估
- **创意提出**：是否有创新的想法
- **问题发现**：主动发现和解决问题
- **优化改进**：持续改进的思维
- **AI协作**：有效使用AI工具的能力

### 3.4 反馈展示设计

**反馈卡片结构**
```html
<div class="ai-feedback-card">
  <header>
    <span class="feedback-type">技术能力</span>
    <span class="feedback-time">2小时前</span>
  </header>
  
  <div class="feedback-content">
    <div class="feedback-highlights">
      <h3>✨ 亮点</h3>
      <ul>
        <li>代码结构清晰，模块化做得很好</li>
        <li>使用了合适的设计模式</li>
      </ul>
    </div>
    
    <div class="feedback-suggestions">
      <h3>💡 建议</h3>
      <ul>
        <li>可以添加更多错误处理</li>
        <li>建议学习一下单元测试</li>
      </ul>
    </div>
    
    <div class="feedback-resources">
      <h3>📚 推荐资源</h3>
      <ul>
        <li><a href="#">JavaScript最佳实践</a></li>
      </ul>
    </div>
  </div>
  
  <div class="feedback-actions">
    <button>👍 有帮助</button>
    <button>💬 查看详情</button>
  </div>
</div>
```

---

## 4. 系统集成方案

### 4.1 整体架构图

```
┌─────────────────────────────────────────────────┐
│              前端层 (React/Next.js)              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ 看板系统 │  │ 文件管理 │  │ AI反馈  │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
                      ↕ HTTP/WebSocket
┌─────────────────────────────────────────────────┐
│            API Gateway / 中间件层                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ 认证授权 │  │ 权限检查 │  │ 限流控制 │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│              业务逻辑层 (Node.js)                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ 任务服务 │  │ 文件服务 │  │ AI服务   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│              数据层                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │PostgreSQL│  │ 文件存储 │  │ AI API   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
```

### 4.2 数据同步流程

```
用户操作看板
    ↓
前端状态更新（乐观更新）
    ↓
API调用 → 数据库更新
    ↓
WebSocket广播 → 其他用户收到更新
    ↓
AI分析服务（异步）→ 生成反馈
    ↓
反馈保存到数据库
    ↓
通知用户查看反馈
```

### 4.3 安全考虑

1. **认证安全**
   - JWT Token过期机制
   - Refresh Token轮换
   - 防止CSRF攻击

2. **权限安全**
   - 服务器端权限验证（不要只依赖前端）
   - 文件访问权限检查
   - 敏感操作审计日志

3. **数据安全**
   - 文件上传大小限制
   - 文件类型白名单
   - 恶意文件扫描

4. **AI API安全**
   - API密钥存储在环境变量
   - 请求限流
   - 敏感信息过滤（不要发送API密钥等）

---

## 5. 实施路线图

### Phase 1: 基础数据库与看板 (4周)
- Week 1-2: 数据库设计与API开发
- Week 3: 前端看板拖拽功能
- Week 4: 实时同步与测试

### Phase 2: 用户权限系统 (3周)
- Week 1: 用户认证系统
- Week 2: 文件权限系统
- Week 3: @提及与通知功能

### Phase 3: AI评估系统 (4周)
- Week 1: 文件上传与存储
- Week 2: AI分析服务开发
- Week 3: 反馈生成与展示
- Week 4: 改动追踪与分析

### Phase 4: 集成与优化 (2周)
- Week 1: 系统集成测试
- Week 2: 性能优化与用户体验改进

---

## 6. 技术选型建议

### 后端框架
- **推荐**: Next.js 14 (App Router) + TypeScript
  - 原因：全栈框架，API Routes内置，部署简单
- **备选**: Express.js + TypeScript
  - 原因：更灵活，适合复杂业务逻辑

### 数据库
- **推荐**: PostgreSQL
  - 原因：关系型数据库，支持JSONB，适合复杂查询
- **备选**: MySQL 8.0
  - 原因：更成熟，社区支持好

### 文件存储
- **推荐**: AWS S3 / 阿里云OSS
  - 原因：可扩展，CDN支持，成本低
- **备选**: MinIO (自建)
  - 原因：S3兼容，成本可控

### AI服务
- **推荐**: OpenAI GPT-4 / Claude Opus
  - 原因：性能好，中文支持好
- **备选**: 国产大模型（文心一言、通义千问）
  - 原因：成本更低，数据不出境

### 实时通信
- **推荐**: Socket.io
  - 原因：跨平台支持好，自动降级
- **备选**: WebSocket (原生)
  - 原因：性能更好，但需要手动处理重连

---

## 7. 后续优化方向

1. **移动端支持**
   - 响应式设计优化
   - 移动端App（React Native）

2. **数据分析增强**
   - 更多可视化图表
   - 团队对比分析
   - 个人成长轨迹

3. **AI能力扩展**
   - 代码自动审查
   - 自动生成测试
   - 智能任务分配

4. **协作功能**
   - 实时文档协作
   - 视频会议集成
   - 评论和讨论系统

---

## 8. 参考资源

- [Next.js 官方文档](https://nextjs.org/docs)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)
- [OpenAI API 文档](https://platform.openai.com/docs)
- [Socket.io 文档](https://socket.io/docs/v4/)
- [React DnD Kit](https://docs.dndkit.com/)

---

**最后更新**: 2024年11月2日  
**版本**: v1.0  
**维护者**: 平台开发团队











