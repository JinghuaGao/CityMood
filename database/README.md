# CityMood Database

## 数据库
PostgreSQL 14+ with PostGIS extension

## 初始化

```bash
# 创建数据库
psql -U postgres -c "CREATE DATABASE citymood;"

# 启用 PostGIS
psql -U postgres -d citymood -c "CREATE EXTENSION postgis;"

# 运行迁移
psql -U postgres -d citymood -f migrations/001_init.sql
```

## 迁移

```bash
# 创建新迁移
npm run migration:create -- name

# 运行迁移
npm run migration:up

# 回滚
npm run migration:down
```

## 表结构
详见 [docs/architecture.md](../docs/architecture.md)
