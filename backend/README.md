# CityMood Backend

## 技术栈
- Node.js 18+
- Express.js
- PostgreSQL + PostGIS
- Redis (缓存)

## 项目结构
```
backend/
├── src/
│   ├── config/         # 配置
│   ├── controllers/    # 控制器
│   ├── models/         # 数据模型
│   ├── routes/         # 路由
│   ├── services/       # 业务逻辑
│   ├── middleware/     # 中间件
│   └── utils/          # 工具函数
├── tests/              # 测试
└── package.json        # 依赖
```

## 快速开始

```bash
# 安装依赖
npm install

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件

# 运行开发服务器
npm run dev

# 运行测试
npm test
```

## API 文档
详见 [docs/api.md](../docs/api.md)
