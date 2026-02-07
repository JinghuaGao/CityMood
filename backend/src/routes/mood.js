const express = require('express');
const Joi = require('joi');
const db = require('../config/database');
const response = require('../utils/response');
const logger = require('../utils/logger');

const router = express.Router();

// 验证规则
const checkinSchema = Joi.object({
  device_id: Joi.string().required(),
  mood_level: Joi.number().integer().min(1).max(5).required(),
  tags: Joi.array().items(Joi.string().max(20)).max(5),
  note: Joi.string().max(500).allow(''),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  city_code: Joi.string().length(2).uppercase()
});

// POST /api/v1/moods - 创建心情记录
router.post('/', async (req, res) => {
  try {
    // 验证输入
    const { error: validationError, value } = checkinSchema.validate(req.body);
    if (validationError) {
      return response.error(res, '参数验证失败', 400, validationError.details);
    }

    const { device_id, mood_level, tags, note, latitude, longitude, city_code } = value;

    // 查找或创建用户
    let userResult = await db.query(
      'SELECT id FROM users WHERE device_id = $1',
      [device_id]
    );

    let userId;
    if (userResult.rows.length === 0) {
      // 创建新用户
      const newUser = await db.query(
        'INSERT INTO users (device_id) VALUES ($1) RETURNING id',
        [device_id]
      );
      userId = newUser.rows[0].id;
      logger.info('New user created', { userId, device_id });
    } else {
      userId = userResult.rows[0].id;
    }

    // 插入心情记录
    const location = latitude && longitude 
      ? `POINT(${longitude} ${latitude})` 
      : null;

    const moodResult = await db.query(
      `INSERT INTO mood_records 
       (user_id, mood_level, tags, note, location, city_code, record_date) 
       VALUES ($1, $2, $3, $4, ${location ? 'ST_GeogFromText($5)' : 'NULL'}, $6, CURRENT_DATE) 
       RETURNING *`,
      location 
        ? [userId, mood_level, tags || [], note || '', location, city_code]
        : [userId, mood_level, tags || [], note || '', city_code]
    );

    // 更新用户活跃时间
    await db.query(
      'UPDATE users SET last_active_at = NOW() WHERE id = $1',
      [userId]
    );

    logger.info('Mood recorded', { 
      userId, 
      moodLevel: mood_level, 
      cityCode: city_code 
    });

    return response.success(res, {
      record: moodResult.rows[0],
      user_id: userId
    }, '心情记录成功', 201);

  } catch (err) {
    logger.error('Failed to record mood:', err);
    return response.error(res, '记录心情失败', 500);
  }
});

// GET /api/v1/moods - 查询个人记录
router.get('/', async (req, res) => {
  try {
    const { device_id, limit = 30, offset = 0 } = req.query;

    if (!device_id) {
      return response.error(res, 'device_id 不能为空', 400);
    }

    // 获取用户记录
    const result = await db.query(
      `SELECT 
        mr.id, mr.mood_level, mr.tags, mr.note, mr.record_date, mr.created_at,
        c.name as city_name
       FROM mood_records mr
       LEFT JOIN users u ON mr.user_id = u.id
       LEFT JOIN cities c ON mr.city_code = c.code
       WHERE u.device_id = $1
       ORDER BY mr.created_at DESC
       LIMIT $2 OFFSET $3`,
      [device_id, parseInt(limit), parseInt(offset)]
    );

    // 获取总数
    const countResult = await db.query(
      `SELECT COUNT(*) 
       FROM mood_records mr
       JOIN users u ON mr.user_id = u.id
       WHERE u.device_id = $1`,
      [device_id]
    );

    return response.paginated(res, result.rows, {
      page: Math.floor(offset / limit) + 1,
      pageSize: parseInt(limit),
      total: parseInt(countResult.rows[0].count)
    });

  } catch (err) {
    logger.error('Failed to fetch mood records:', err);
    return response.error(res, '获取记录失败', 500);
  }
});

// GET /api/v1/moods/stats - 个人统计
router.get('/stats', async (req, res) => {
  try {
    const { device_id, days = 30 } = req.query;

    if (!device_id) {
      return response.error(res, 'device_id 不能为空', 400);
    }

    // 统计数据
    const statsResult = await db.query(
      `SELECT 
        AVG(mood_level) as avg_mood,
        COUNT(*) as total_records,
        COUNT(DISTINCT record_date) as active_days,
        MIN(mood_level) as min_mood,
        MAX(mood_level) as max_mood
       FROM mood_records mr
       JOIN users u ON mr.user_id = u.id
       WHERE u.device_id = $1
       AND mr.record_date >= CURRENT_DATE - INTERVAL '${days} days'`,
      [device_id]
    );

    // 心情分布
    const distributionResult = await db.query(
      `SELECT 
        mood_level,
        COUNT(*) as count
       FROM mood_records mr
       JOIN users u ON mr.user_id = u.id
       WHERE u.device_id = $1
       AND mr.record_date >= CURRENT_DATE - INTERVAL '${days} days'
       GROUP BY mood_level
       ORDER BY mood_level`,
      [device_id]
    );

    return response.success(res, {
      period_days: parseInt(days),
      summary: statsResult.rows[0],
      distribution: distributionResult.rows
    });

  } catch (err) {
    logger.error('Failed to fetch mood stats:', err);
    return response.error(res, '获取统计失败', 500);
  }
});

module.exports = router;
