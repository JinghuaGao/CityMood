const winston = require('winston');
const config = require('../config');

// 日志格式
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// 控制台格式（开发环境更易读）
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(({ level, message, timestamp, ...metadata }) => {
    let msg = `${timestamp} [${level}]: ${message}`;
    if (Object.keys(metadata).length > 0) {
      msg += ` ${JSON.stringify(metadata)}`;
    }
    return msg;
  })
);

// 创建 logger
const logger = winston.createLogger({
  level: config.logLevel,
  defaultMeta: { service: 'citymood-api' },
  transports: [
    // 文件日志
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error',
      format: logFormat 
    }),
    new winston.transports.File({ 
      filename: 'logs/combined.log',
      format: logFormat 
    })
  ]
});

// 开发环境添加控制台输出
if (config.env === 'development') {
  logger.add(new winston.transports.Console({
    format: consoleFormat
  }));
}

module.exports = logger;
