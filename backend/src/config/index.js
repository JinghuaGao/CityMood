// 配置文件

const config = {
  // 环境
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  
  // CORS
  corsOrigin: process.env.CORS_ORIGIN || '*',
  
  // 数据库
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    name: process.env.DB_NAME || 'citymood',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    poolSize: parseInt(process.env.DB_POOL_SIZE, 10) || 10,
    ssl: process.env.DB_SSL === 'true'
  },
  
  // 日志
  logLevel: process.env.LOG_LEVEL || 'info',
  
  // 心情聚合配置
  moodAggregation: {
    // 时间衰减系数（越新的记录权重越高）
    timeDecayFactor: 0.95,
    // 近期数据时间窗口（小时）
    recentWindowHours: 6,
    // 最小有效记录数
    minRecordsForStats: 10,
    // 置信度阈值
    minConfidenceScore: 0.6
  },
  
  // 反作弊配置
  fraudDetection: {
    // 最小打卡间隔（秒）
    minCheckinInterval: 300, // 5分钟
    // 单日最大打卡数
    maxDailyCheckins: 10,
    // 位置异常阈值（米）
    locationAnomalyThreshold: 100000 // 100公里
  }
};

module.exports = config;
