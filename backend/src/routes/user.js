const express = require('express');
const db = require('../config/database');
const response = require('../utils/response');
const logger = require('../utils/logger');

const router = express.Router();

// POST /api/v1/users/register - 用户注册（设备注册）
router.post('/register', async (req, res) => {
  try {
    const { device_id, device_fingerprint } = req.body;

    if (!device_id) {
      return response.error(res, 'device_id 不能为空', 400);
    }

    // 检查是否已存在
    const existing = await db.query(
      'SELECT id FROM users WHERE device_id = $1',
      [device_id]
    );

    if (existing.rows.length > 0) {
      // 更新活跃时间
      await db.query(
        'UPDATE users SET last_active_at = NOW() WHERE id = $1',
        [existing.rows[0].id]
      );

      return response.success(res, {
        user_id: existing.rows[0].id,
        is_new: false
      }, '用户已存在');
    }

    // 创建新用户
    const result = await db.query(
      'INSERT INTO users (device_id, device_fingerprint) VALUES ($1, $2) RETURNING id',
      [device_id, device_fingerprint || null]
    );

    logger.info('New user registered', { userId: result.rows[0].id, device_id });

    return response.success(res, {
      user_id: result.rows[0].id,
      is_new: true
    }, '注册成功', 201);

  } catch (err) {
    logger.error('Failed to register user:', err);
    return response.error(res, '注册失败', 500);
  }
});

// GET /api/v1/users/:id/streak - 连续打卡统计
router.get('/:id/streak', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        current_streak,
        longest_streak,
        last_checkin_date,
        total_checkins
       FROM user_streaks
       WHERE user_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return response.success(res, {
        current_streak: 0,
        longest_streak: 0,
        last_checkin_date: null,
        total_checkins: 0
      });
    }

    return response.success(res, result.rows[0]);

  } catch (err) {
    logger.error('Failed to fetch streak:', err);
    return response.error(res, '获取打卡统计失败', 500);
  }
});

module.exports = router;
