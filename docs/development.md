# CityMood 开发流程

本文档描述 CityMood 的开发规范、Git 工作流程和发布流程。

## 🔄 Git 工作流程

### 分支策略

```
main        生产环境分支，永远可部署
├── develop 开发分支，集成测试
│   ├── feature/mood-checkin    心情打卡功能
│   ├── feature/heatmap         热力地图
│   └── feature/ranking         排行榜
├── hotfix  紧急修复
└── release 发布准备
```

### 提交规范

使用 [Conventional Commits](https://conventionalcommits.org/)：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型 (type):**
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例:**
```bash
feat(ios): 添加心情打卡界面

- 5级emoji选择器
- 标签选择功能
- 本地存储

fix(backend): 修复情绪聚合算法权重计算错误
docs: 更新 API 文档
```

## 📱 iOS 开发规范

### 项目结构

```
CityMood/
├── App/
│   ├── CityMoodApp.swift      # App入口
│   └── AppDelegate.swift      # 生命周期
├── Core/
│   ├── Models/                # 数据模型
│   ├── Services/              # 网络/存储服务
│   └── Utils/                 # 工具类
├── Features/
│   ├── MoodCheckin/           # 心情打卡模块
│   ├── MoodCalendar/          # 情绪日历模块
│   ├── CityHeatmap/           # 城市热力图模块
│   └── CityRanking/           # 排行榜模块
├── UI/
│   ├── Components/            # 可复用组件
│   └── Styles/                # 主题/样式
└── Resources/
    ├── Assets.xcassets        # 图片资源
    └── Localizations/         # 本地化
```

### 编码规范

1. **SwiftUI 优先** - 尽可能使用 SwiftUI
2. **MVVM 架构** - 视图与逻辑分离
3. **Combine/AsyncAwait** - 异步编程
4. **CoreData/Keychain** - 本地存储

### UI 规范

- **颜色**: 使用系统自适应颜色
- **字体**: `.body`, `.headline` 等语义化字体
- **图标**: SF Symbols
- **间距**: 8pt 网格系统

## ⚙️ 后端开发规范

### API 设计

遵循 RESTful 原则：

```
POST   /api/v1/moods              创建心情记录
GET    /api/v1/moods              查询个人记录
GET    /api/v1/cities/{id}/mood   获取城市心情
GET    /api/v1/cities/ranking     城市排行榜
GET    /api/v1/stats/heatmap      热力图数据
```

### 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### 错误处理

```json
{
  "code": 400,
  "message": "Invalid parameters",
  "error": "mood_level must be between 1 and 5"
}
```

## 🗄️ 数据库规范

### 命名规则
- 表名: 小写 + 下划线 (`mood_records`)
- 字段: 小写 + 下划线 (`created_at`)
- 索引: `idx_表名_字段名`

### 核心表结构

```sql
-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(64) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_active_at TIMESTAMP
);

-- 心情记录表
CREATE TABLE mood_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    mood_level INT CHECK (mood_level BETWEEN 1 AND 5),
    tags TEXT[],
    note TEXT,
    location GEOGRAPHY(POINT, 4326),
    city_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 城市统计表
CREATE TABLE city_stats (
    city_code VARCHAR(20),
    date DATE,
    mood_index DECIMAL(5,2),
    total_records INT,
    mood_distribution JSONB,
    PRIMARY KEY (city_code, date)
);
```

## 🧪 测试规范

### iOS 测试

```swift
// 单元测试
func testMoodLevelValidation() {
    let mood = Mood(level: 3)
    XCTAssertTrue(mood.isValid)
}

// UI测试
func testMoodCheckinFlow() {
    app.buttons["打卡"].tap()
    app.buttons["😄"].tap()
    app.buttons["提交"].tap()
    XCTAssertTrue(app.staticTexts["打卡成功"].exists)
}
```

### 后端测试

```javascript
// API测试
describe('POST /api/v1/moods', () => {
  it('should create mood record', async () => {
    const res = await request(app)
      .post('/api/v1/moods')
      .send({ mood_level: 4, tags: ['work'] })
      .expect(201);
    expect(res.body.data.mood_level).toBe(4);
  });
});
```

## 📦 发布流程

### 版本号规范

使用 [语义化版本](https://semver.org/lang/zh-CN/)：

```
主版本.次版本.修订号
1.0.0
```

### iOS 发布流程

1. **开发完成** → 合并到 `develop`
2. **测试通过** → 创建 `release/1.0.0` 分支
3. **版本号更新** → 修改 `Version.xcconfig`
4. **归档打包** → Product → Archive
5. **上传 App Store** → Xcode Organizer
6. **等待审核** → 通常 1-2 天
7. **审核通过** → 合并到 `main`，打 tag

### 后端发布流程

1. **代码合并** → 合并到 `main`
2. **自动化测试** → CI/CD 运行测试
3. **构建镜像** → Docker build
4. **部署到 staging** → 预发布环境验证
5. **部署到生产** → 滚动更新
6. **监控观察** → 检查错误率和性能

## 🔒 安全规范

1. **敏感信息** - 使用环境变量，绝不提交到 Git
2. **API 密钥** - 使用密钥管理服务
3. **用户数据** - 加密存储，最小化收集
4. **HTTPS** - 所有 API 强制 HTTPS
5. **输入验证** - 服务端严格验证所有输入

## 📊 监控与日志

### 关键指标
- 日活跃用户 (DAU)
- 打卡转化率
- API 响应时间
- 崩溃率

### 日志规范
```swift
// iOS
Logger.mood.info("User checked in: level=\\(level), city=\\(city)")

// Backend
logger.info('Mood recorded', { userId, city, moodLevel });
```

## 🚀 快速命令

```bash
# 创建特性分支
git checkout -b feature/mood-checkin develop

# 提交代码
git add .
git commit -m "feat(ios): 添加心情打卡界面"
git push origin feature/mood-checkin

# 创建 PR
git checkout develop
git merge feature/mood-checkin

# 打标签
git tag -a v1.0.0 -m "CityMood 1.0.0 Release"
git push origin v1.0.0
```

## 📞 联系方式

- **项目负责人**: 海森堡
- **技术搭档**: Feynman
- **讨论**: GitHub Issues

---

Happy Coding! 🎉
