const { Pool } = require('pg');
const config = require('./index');
const logger = require('../utils/logger');

const pool = new Pool({
  host: config.database.host,
  port: config.database.port,
  database: config.database.name,
  user: config.database.user,
  password: config.database.password,
  max: config.database.poolSize,
  ssl: config.database.ssl ? { rejectUnauthorized: false } : false,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// 连接事件
pool.on('connect', () => {
  logger.debug('New database connection established');
});

pool.on('error', (err) => {
  logger.error('Unexpected database error:', err);
});

// 查询辅助函数
const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    logger.debug('Query executed', { 
      text: text.substring(0, 100), 
      duration: `${duration}ms`,
      rows: result.rowCount 
    });
    return result;
  } catch (err) {
    logger.error('Query error:', err);
    throw err;
  }
};

// 测试连接
const testConnection = async () => {
  try {
    await pool.query('SELECT NOW()');
    return true;
  } catch (err) {
    throw err;
  }
};

// 关闭连接
const close = async () => {
  await pool.end();
  logger.info('Database pool closed');
};

// 事务辅助
const transaction = async (callback) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

module.exports = {
  query,
  testConnection,
  close,
  transaction,
  pool
};
