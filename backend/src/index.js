const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const config = require('./config');
const logger = require('./utils/logger');
const db = require('./config/database');

// 路由
const moodRoutes = require('./routes/mood');
const cityRoutes = require('./routes/city');
const userRoutes = require('./routes/user');
const statsRoutes = require('./routes/stats');

const app = express();

// 安全中间件
app.use(helmet());
app.use(cors({
  origin: config.corsOrigin,
  credentials: true
}));

// 压缩响应
app.use(compression());

// 限流
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 每IP 100请求
  message: {
    code: 429,
    message: '请求过于频繁，请稍后再试'
  }
});
app.use(limiter);

// 解析JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 请求日志
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path} - ${req.ip}`);
  next();
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    code: 200,
    message: 'OK',
    data: {
      timestamp: new Date().toISOString(),
      version: '0.1.0',
      env: config.env
    }
  });
});

// API 路由
app.use('/api/v1/moods', moodRoutes);
app.use('/api/v1/cities', cityRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/stats', statsRoutes);

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    code: 404,
    message: '接口不存在',
    path: req.path
  });
});

// 错误处理
app.use((err, req, res, next) => {
  logger.error('Unhandled error:', err);
  res.status(500).json({
    code: 500,
    message: '服务器内部错误',
    error: config.env === 'development' ? err.message : undefined
  });
});

// 启动服务器
const PORT = config.port || 3000;

// 数据库连接检查
db.testConnection()
  .then(() => {
    logger.info('Database connected successfully');
    app.listen(PORT, () => {
      logger.info(`CityMood API Server running on port ${PORT}`);
      logger.info(`Environment: ${config.env}`);
    });
  })
  .catch(err => {
    logger.error('Database connection failed:', err);
    process.exit(1);
  });

// 优雅关闭
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, closing server...');
  db.close();
  process.exit(0);
});

module.exports = app;
