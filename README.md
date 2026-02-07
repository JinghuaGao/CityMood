# CityMood 🌍💭

记录世界的心情 - 众包情绪地图与城市幸福感排名

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 💡 产品概念

**一句话**: 让每个人随手记录心情，看到整座城市/世界的情绪脉动

**核心机制**: 个人心情 → 聚合算法 → 城市心情指数

**愿景**: 发现世界上最幸福的城市，理解情绪的 collective consciousness

## ✨ 核心功能

### 个人端
- 😢😕😐🙂😄 **极简心情打卡** - 5级emoji + 可选标签
- 📅 **个人情绪日历** - 热力图展示情绪波动
- 🗺️ **同城情绪看板** - 实时城市心情 + 区域分布

### 聚合端
- 📊 **城市心情指数** - 实时指数 0-100
- 🏆 **全球城市排名** - 最快乐/压力最大城市榜
- 💬 **情绪故事** - 匿名分享与共鸣

## 🏗️ 技术架构

```
CityMood/
├── 📱 iOS App (SwiftUI)
│   ├── 心情打卡
│   ├── 情绪日历
│   ├── 热力地图
│   └── 城市排行
│
├── ⚙️ Backend API (Node.js/FastAPI)
│   ├── 用户服务
│   ├── 情绪记录服务
│   ├── 聚合算法服务
│   └── 排行榜服务
│
├── 🗄️ Database (PostgreSQL + PostGIS)
│   ├── 用户表
│   ├── 情绪记录表
│   └── 城市统计表
│
└── 🗺️ 地图服务 (高德/百度)
```

## 📅 开发路线图

### MVP v1.0 (4周)

| 周次 | 目标 | 关键交付 |
|------|------|----------|
| Week 1 | 基础架构 | 数据库设计 + API框架 + iOS项目搭建 |
| Week 2 | 核心功能 | 心情打卡 + 个人日历 + 基础地图 |
| Week 3 | 聚合算法 | 城市指数计算 + 热力图 + 排行榜 |
| Week 4 | 打磨上线 | UI优化 + 测试 + App Store准备 |

### 后续版本
- v1.1: 情绪故事社区 (UGC)
- v1.2: 情绪预测 (结合天气、日期)
- v1.3: AI情绪分析 (语音/文字)
- v2.0: 企业版 (员工情绪健康)

## 🚀 快速开始

### 环境要求
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Node.js 18+ (后端)
- PostgreSQL 14+ (数据库)

### iOS 端
```bash
cd ios
cd CityMood
xcodebuild -scheme CityMood -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 后端
```bash
cd backend
npm install
npm run dev
```

### 数据库
```bash
cd database
psql -f init.sql
```

## 📁 项目结构

```
CityMood/
├── 📁 ios/                    # iOS SwiftUI 应用
│   ├── CityMood/             # 主应用代码
│   ├── CityMoodTests/        # 单元测试
│   └── CityMoodUITests/      # UI测试
│
├── 📁 backend/               # 后端 API 服务
│   ├── src/                  # 源代码
│   ├── tests/                # 测试
│   └── package.json          # 依赖
│
├── 📁 database/              # 数据库脚本
│   ├── migrations/           # 迁移文件
│   └── seed/                 # 种子数据
│
├── 📁 design/                # 设计资源
│   ├── ui/                   # UI设计稿
│   └── assets/               # 图标、图片
│
├── 📁 docs/                  # 文档
│   ├── api.md               # API文档
│   ├── architecture.md      # 架构设计
│   └── privacy.md           # 隐私政策
│
└── 📄 README.md             # 本文件
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing'`)
4. 推送分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

## 📝 文档

- [API 文档](docs/api.md)
- [架构设计](docs/architecture.md)
- [开发流程](docs/development.md)
- [隐私政策](docs/privacy.md)

## ⚠️ 免责声明

CityMood 仅供娱乐和研究用途，不构成心理健康或医疗建议。

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

Made with ❤️ by 海森堡 & Feynman
