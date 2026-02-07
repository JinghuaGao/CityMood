const express = require('express');
const db = require('../config/database');
const response = require('../utils/response');
const logger = require('../utils/logger');

const router = express.Router();

// GET /api/v1/stats/ranking - 城市排名
router.get('/ranking', async (req, res) => {
  try {
    const { date = new Date().toISOString().split('T')[0], limit = 10 } = req.query;

    // 最幸福城市
    const happiestResult = await db.query(
      `SELECT 
        c.code,
        c.name,
        c.name_en,
        cds.mood_index,
        cds.total_records,
        cds.unique_users
       FROM city_daily_stats cds
       JOIN cities c ON cds.city_code = c.code
       WHERE cds.date = $1
       AND cds.total_records >= 10
       ORDER BY cds.mood_index DESC
       LIMIT $2`,
      [date, parseInt(limit)]
    );

    // 压力最大城市
    const stressedResult = await db.query(
      `SELECT 
        c.code,
        c.name,
        c.name_en,
        cds.mood_index,
        cds.mood_distribution->>'1' as sad_count,
        cds.mood_distribution->>'2' as anxious_count
       FROM city_daily_stats cds
       JOIN cities c ON cds.city_code = c.code
       WHERE cds.date = $1
       AND cds.total_records >= 10
       ORDER BY (COALESCE((cds.mood_distribution->>'1')::int, 0) + 
                 COALESCE((cds.mood_distribution->>'2')::int, 0))::float / cds.total_records DESC
       LIMIT $2`,
      [date, parseInt(limit)]
    );

    return response.success(res, {
      date,
      happiest_cities: happiestResult.rows,
      most_stressed_cities: stressedResult.rows
    });

  } catch (err) {
    logger.error('Failed to fetch ranking:', err);
    return response.error(res, '获取排名失败', 500);
  }
});

// GET /api/v1/stats/global - 全球统计
router.get('/global', async (req, res) => {
  try {
    const { date = new Date().toISOString().split('T')[0] } = req.query;

    // 全球总览
    const globalResult = await db.query(
      `SELECT 
        SUM(total_records) as total_records,
        SUM(unique_users) as total_users,
        AVG(mood_index) as global_mood_index,
        COUNT(DISTINCT city_code) as active_cities
       FROM city_daily_stats
       WHERE date = $1`,
      [date]
    );

    // 总心情分布
    const distributionResult = await db.query(
      `SELECT 
        mood_level,
        SUM(count) as total_count
       FROM (
         SELECT 
           (key)::int as mood_level,
           (value)::int as count
         FROM city_daily_stats,
         jsonb_each(mood_distribution)
         WHERE date = $1
       ) t
       GROUP BY mood_level
       ORDER BY mood_level`,
      [date]
    );

    return response.success(res, {
      date,
      global: globalResult.rows[0],
      mood_distribution: distributionResult.rows
    });

  } catch (err) {
    logger.error('Failed to fetch global stats:', err);
    return response.error(res, '获取全球统计失败', 500);
  }
});

module.exports = router;
