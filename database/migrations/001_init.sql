-- CityMood 数据库初始化脚本
-- PostgreSQL 14+ with PostGIS

-- 启用 PostGIS 扩展（地理空间数据支持）
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- 用户表
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(64) UNIQUE NOT NULL,
    device_fingerprint VARCHAR(128),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_users_device_id ON users(device_id);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================
-- 心情记录表
-- ============================================
CREATE TABLE mood_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- 心情数据
    mood_level INTEGER NOT NULL CHECK (mood_level BETWEEN 1 AND 5),
    tags TEXT[], -- 标签数组: ['work', 'weather', 'relationship']
    note TEXT, -- 可选日记内容，限制 500 字
    
    -- 地理位置（使用 PostGIS）
    location GEOGRAPHY(POINT, 4326), -- WGS84 坐标系
    city_code VARCHAR(20), -- 城市代码，如 "BJ", "SH"
    city_name VARCHAR(50), -- 城市名称，如 "北京"
    
    -- 数据质量标记
    is_valid BOOLEAN DEFAULT TRUE, -- 反作弊标记
    data_source VARCHAR(20) DEFAULT 'ios', -- ios, android, web
    
    -- 时间戳
    record_date DATE NOT NULL, -- 记录日期，用于分区
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_mood_records_user_id ON mood_records(user_id);
CREATE INDEX idx_mood_records_city_code ON mood_records(city_code);
CREATE INDEX idx_mood_records_record_date ON mood_records(record_date);
CREATE INDEX idx_mood_records_created_at ON mood_records(created_at);
CREATE INDEX idx_mood_records_location ON mood_records USING GIST(location);

-- 复合索引：城市 + 日期（聚合查询优化）
CREATE INDEX idx_mood_records_city_date ON mood_records(city_code, record_date);

-- ============================================
-- 城市统计表（每日聚合）
-- ============================================
CREATE TABLE city_daily_stats (
    city_code VARCHAR(20) NOT NULL,
    date DATE NOT NULL,
    
    -- 心情指数 0-100
    mood_index DECIMAL(5,2),
    mood_index_weighted DECIMAL(5,2), -- 加权指数（考虑用户活跃度）
    
    -- 统计数据
    total_records INTEGER DEFAULT 0,
    unique_users INTEGER DEFAULT 0,
    
    -- 心情分布（JSONB 存储灵活结构）
    mood_distribution JSONB DEFAULT '{}', -- {"1": 10, "2": 20, "3": 40, "4": 20, "5": 10}
    
    -- 标签词云数据
    top_tags JSONB DEFAULT '[]', -- [{"tag": "work", "count": 50}, ...]
    
    -- 时间衰减后的指数（更关注近期数据）
    recent_mood_index DECIMAL(5,2), -- 最近6小时数据
    
    -- 数据质量
    confidence_score DECIMAL(3,2), -- 置信度 0-1
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    PRIMARY KEY (city_code, date)
);

CREATE INDEX idx_city_daily_stats_date ON city_daily_stats(date);
CREATE INDEX idx_city_daily_stats_mood_index ON city_daily_stats(mood_index);

-- ============================================
-- 城市信息表（基础数据）
-- ============================================
CREATE TABLE cities (
    code VARCHAR(20) PRIMARY KEY, -- "BJ"
    name VARCHAR(50) NOT NULL, -- "北京"
    name_en VARCHAR(50), -- "Beijing"
    country VARCHAR(50) DEFAULT 'CN',
    country_code VARCHAR(2) DEFAULT 'CN',
    
    -- 地理边界（用于判断坐标所属城市）
    boundary GEOGRAPHY(MULTIPOLYGON, 4326),
    center_location GEOGRAPHY(POINT, 4326),
    
    -- 时区
    timezone VARCHAR(50) DEFAULT 'Asia/Shanghai',
    
    -- 人口（用于计算人均参与度）
    population INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_cities_boundary ON cities USING GIST(boundary);

-- ============================================
-- 初始化城市数据（中国主要城市）
-- ============================================
INSERT INTO cities (code, name, name_en, center_location, population) VALUES
('BJ', '北京', 'Beijing', 'POINT(116.4074 39.9042)', 21540000),
('SH', '上海', 'Shanghai', 'POINT(121.4737 31.2304)', 24280000),
('GZ', '广州', 'Guangzhou', 'POINT(113.2644 23.1291)', 14043500),
('SZ', '深圳', 'Shenzhen', 'POINT(114.0579 22.5431)', 12325900),
('CD', '成都', 'Chengdu', 'POINT(104.0668 30.5728)', 16000000),
('HZ', '杭州', 'Hangzhou', 'POINT(120.1551 30.2741)', 10360000),
('WH', '武汉', 'Wuhan', 'POINT(114.3054 30.5931)', 11212000),
('XA', '西安', 'Xi''an', 'POINT(108.9398 34.3416)', 10009700),
('CQ', '重庆', 'Chongqing', 'POINT(106.5516 29.5630)', 31243200),
('NJ', '南京', 'Nanjing', 'POINT(118.7969 32.0603)', 8500000),
('TJ', '天津', 'Tianjin', 'POINT(117.2009 39.0842)', 13866000),
('SU', '苏州', 'Suzhou', 'POINT(120.5853 31.2989)', 10725000);

-- ============================================
-- 连续打卡记录表
-- ============================================
CREATE TABLE user_streaks (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0, -- 当前连续天数
    longest_streak INTEGER DEFAULT 0, -- 历史最长
    last_checkin_date DATE, -- 上次打卡日期
    total_checkins INTEGER DEFAULT 0, -- 总打卡次数
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 反作弊日志表
-- ============================================
CREATE TABLE fraud_detection_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    detection_type VARCHAR(50), -- 'rapid_checkin', 'location_anomaly', 'device_farming'
    confidence_score DECIMAL(3,2), -- 作弊置信度
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fraud_logs_user_id ON fraud_detection_logs(user_id);
CREATE INDEX idx_fraud_logs_created_at ON fraud_detection_logs(created_at);

-- ============================================
-- 触发器：自动更新 updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_mood_records_updated_at 
    BEFORE UPDATE ON mood_records 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_city_daily_stats_updated_at 
    BEFORE UPDATE ON city_daily_stats 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 视图：方便查询
-- ============================================

-- 今日心情统计视图
CREATE VIEW today_mood_stats AS
SELECT 
    city_code,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(mood_level) as avg_mood,
    mood_level,
    COUNT(*) as count
FROM mood_records
WHERE record_date = CURRENT_DATE
GROUP BY city_code, mood_level;

-- 用户心情历史视图（带城市信息）
CREATE VIEW user_mood_history AS
SELECT 
    mr.id,
    mr.user_id,
    mr.mood_level,
    mr.tags,
    mr.note,
    mr.record_date,
    mr.created_at,
    c.name as city_name,
    c.country
FROM mood_records mr
LEFT JOIN cities c ON mr.city_code = c.code;

-- ============================================
-- 完成
-- ============================================
