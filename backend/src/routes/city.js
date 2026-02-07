const express = require('express');
const db = require('../config/database');
const response = require('../utils/response');
const logger = require('../utils/logger');

const router = express.Router();

// GET /api/v1/cities - 城市列表
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        code, name, name_en, country,
        ST_X(center_location::geometry) as longitude,
        ST_Y(center_location::geometry) as latitude,
        population
       FROM cities
       ORDER BY population DESC`
    );

    return response.success(res, result.rows);
  } catch (err) {
    logger.error('Failed to fetch cities:', err);
    return response.error(res, '获取城市列表失败', 500);
  }
});

// GET /api/v1/cities/:code/mood - 城市心情指数
router.get('/:code/mood', async (req, res) => {
  try {
    const { code } = req.params;
    const { date = new Date().toISOString().split('T')[0] } = req.query;

    // 验证城市存在
    const cityResult = await db.query(
      'SELECT name FROM cities WHERE code = $1',
      [code.toUpperCase()]
    );

    if (cityResult.rows.length === 0) {
      return response.error(res, '城市不存在', 404);
    }

    // 获取统计记录
    const statsResult = await db.query(
      `SELECT * FROM city_daily_stats 
       WHERE city_code = $1 AND date = $2`,
      [code.toUpperCase(), date]
    );

    // 如果没有统计记录，实时计算
    if (statsResult.rows.length === 0) {
      // 实时聚合
      const realtimeResult = await db.query(
        `SELECT 
          COUNT(*) as total_records,
          COUNT(DISTINCT user_id) as unique_users,
          AVG(mood_level) as avg_mood,
          jsonb_object_agg(mood_level, cnt) as distribution
         FROM (
           SELECT mood_level, COUNT(*) as cnt
           FROM mood_records
           WHERE city_code = $1 AND record_date = $2
           GROUP BY mood_level
         ) t
         JOIN mood_records mr ON mr.city_code = $1 AND mr.record_date = $2`,
        [code.toUpperCase(), date]
      );

      const data = realtimeResult.rows[0];
      
      if (data.total_records === '0') {
        return response.success(res, {
          city_code: code.toUpperCase(),
          city_name: cityResult.rows[0].name,
          date,
          mood_index: null,
          total_records: 0,
          message: '今日暂无数据'
        });
      }

      // 计算心情指数 (0-100)
      const moodIndex = ((parseFloat(data.avg_mood) - 1) / 4) * 100;

      return response.success(res, {
        city_code: code.toUpperCase(),
        city_name: cityResult.rows[0].name,
        date,
        mood_index: Math.round(moodIndex),
        total_records: parseInt(data.total_records),
        unique_users: parseInt(data.unique_users),
        avg_mood: parseFloat(data.avg_mood),
        distribution: data.distribution || {},
        is_realtime: true
      });
    }

    const stats = statsResult.rows[0];
    
    return response.success(res, {
      city_code: stats.city_code,
      city_name: cityResult.rows[0].name,
      date: stats.date,
      mood_index: parseFloat(stats.mood_index),
      mood_index_weighted: parseFloat(stats.mood_index_weighted),
      total_records: stats.total_records,
      unique_users: stats.unique_users,
      mood_distribution: stats.mood_distribution,
      top_tags: stats.top_tags,
      confidence_score: parseFloat(stats.confidence_score),
      updated_at: stats.updated_at
    });

  } catch (err) {
    logger.error('Failed to fetch city mood:', err);
    return response.error(res, '获取城市心情失败', 500);
  }
});

// GET /api/v1/cities/:code/heatmap - 城市热力图数据
router.get('/:code/heatmap', async (req, res) => {
  try {
    const { code } = req.params;
    const { hours = 24 } = req.query;

    // 网格化聚合（保护隐私）
    const result = await db.query(
      `SELECT 
        ROUND(ST_X(location::geometry)::numeric, 2) as grid_lng,
        ROUND(ST_Y(location::geometry)::numeric, 2) as grid_lat,
        AVG(mood_level) as avg_mood,
        COUNT(*) as count
       FROM mood_records
       WHERE city_code = $1
       AND created_at >= NOW() - INTERVAL '${hours} hours'
       AND location IS NOT NULL
       GROUP BY 
         ROUND(ST_X(location::geometry)::numeric, 2),
         ROUND(ST_Y(location::geometry)::numeric, 2)
       HAVING COUNT(*) >= 3`,
      [code.toUpperCase()]
    );

    return response.success(res, {
      city_code: code.toUpperCase(),
      time_window_hours: parseInt(hours),
      grid_size: '0.01 degree (~1km)',
      points: result.rows.map(row => ({
        longitude: parseFloat(row.grid_lng),
        latitude: parseFloat(row.grid_lat),
        mood_level: parseFloat(row.avg_mood),
        count: parseInt(row.count)
      }))
    });

  } catch (err) {
    logger.error('Failed to fetch heatmap:', err);
    return response.error(res, '获取热力图失败', 500);
  }
});

module.exports = router;
