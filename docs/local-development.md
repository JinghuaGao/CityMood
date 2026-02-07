# CityMood 本地开发指南

## 🚀 快速开始（5分钟）

### 1. 启动数据库

```bash
# 安装 PostgreSQL（如未安装）
brew install postgresql@14

# 启动服务
brew services start postgresql@14

# 创建数据库
psql -U postgres -c "CREATE DATABASE citymood;"
psql -U postgres -d citymood -c "CREATE EXTENSION postgis;"

# 运行迁移
psql -U postgres -d citymood -f database/migrations/001_init.sql
```

### 2. 启动后端

```bash
cd backend

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env
# 编辑 .env，设置 DB_PASSWORD 为你本地的密码

# 启动开发服务器
npm run dev

# 看到以下输出表示成功
# CityMood API Server running on port 3000
```

### 3. 启动 iOS 模拟器

```bash
# 打开项目
cd ios
open CityMood/CityMood.xcodeproj

# 在 Xcode 中：
# 1. 选择 iPhone 15 模拟器
# 2. 按 Cmd+R 运行
```

## 📡 API 测试

后端启动后，可以测试 API：

```bash
# 健康检查
curl http://localhost:3000/health

# 注册设备
curl -X POST http://localhost:3000/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{"device_id": "test-device-001"}'

# 记录心情
curl -X POST http://localhost:3000/api/v1/moods \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test-device-001",
    "mood_level": 4,
    "tags": ["工作", "天气"],
    "note": "今天完成了CityMood的Week 1！",
    "city_code": "BJ"
  }'

# 查询城市心情
curl http://localhost:3000/api/v1/cities/BJ/mood
```

## 🔧 常见问题

### 问题1: PostgreSQL 连接失败
```bash
# 检查服务状态
brew services list | grep postgresql

# 重启服务
brew services restart postgresql@14

# 查看日志
tail -f /opt/homebrew/var/log/postgresql@14.log
```

### 问题2: 端口被占用
```bash
# 查看 3000 端口占用
lsof -i :3000

# 杀掉进程
kill -9 <PID>
```

### 问题3: iOS 无法连接后端
确保 iOS 和后端在同一网络：
1. 后端启动时不要绑定 localhost，改为 `0.0.0.0`
2. 修改 `APIService.swift` 中的 `baseURL` 为 Mac 的 IP 地址

```swift
// APIService.swift
#if DEBUG
private let baseURL = "http://192.168.1.xxx:3000/api/v1"  // 你的Mac IP
#else
```

查看 Mac IP：
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## 📝 测试场景

### 场景1: 单人测试
1. 启动后端
2. 打开 iOS 模拟器
3. 记录几条心情
4. 查看个人日历

### 场景2: 多人测试
1. 在模拟器记录心情（设备A）
2. 修改代码中的 device_id
3. 再次运行，记录不同心情（设备B）
4. 查看城市心情指数变化

### 场景3: 跨城市测试
```bash
# 模拟北京用户
curl -X POST http://localhost:3000/api/v1/moods \
  -d '{"device_id": "bj-user", "mood_level": 5, "city_code": "BJ"}'

# 模拟上海用户
curl -X POST http://localhost:3000/api/v1/moods \
  -d '{"device_id": "sh-user", "mood_level": 3, "city_code": "SH"}'

# 查看两个城市的心情指数
curl http://localhost:3000/api/v1/cities/BJ/mood
curl http://localhost:3000/api/v1/cities/SH/mood
```

## 🗄️ 数据库查看

```bash
# 进入数据库
psql -U postgres -d citymood

# 查看最近的心情记录
SELECT mood_level, city_code, created_at 
FROM mood_records 
ORDER BY created_at DESC 
LIMIT 10;

# 查看城市统计
SELECT * FROM city_daily_stats 
WHERE date = CURRENT_DATE;

# 退出
\q
```

## 🔄 开发流程

```bash
# 日常开发循环

# 1. 确保数据库运行
brew services list | grep postgresql

# 2. 启动后端（终端1）
cd backend && npm run dev

# 3. 修改代码，保存后自动重启

# 4. 测试API
curl http://localhost:3000/health

# 5. 在 Xcode 中运行 iOS

# 6. 提交代码
git add .
git commit -m "feat: xxx"
git push origin main
```

## 📦 后续部署

当你准备好服务器时：

1. 在服务器上安装 Node.js + PostgreSQL
2. 复制代码上去
3. 设置环境变量（生产环境配置）
4. 使用 PM2 启动后端：`pm2 start src/index.js`
5. 配置 Nginx 反向代理
6. 修改 iOS 的 baseURL 为服务器域名

需要部署文档时告诉我。

---

有问题随时喊我！
