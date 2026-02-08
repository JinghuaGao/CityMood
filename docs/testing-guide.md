# CityMood 零基础测试指南

> 专为天体物理博士打造，无需编程基础也能上手 🎓

## 🎯 测试目标

验证 App 三大核心功能：
1. ✅ 能记录心情
2. ✅ 能看到城市心情指数
3. ✅ 能看到排行榜

---

## 📱 第一步：打开项目

### 1.1 打开 Xcode

```bash
# 在终端输入
open ~/workspace/CityMood/ios/CityMood/CityMood.xcodeproj
```

或者直接去 Finder → 打开 `CityMood.xcodeproj`

### 1.2 选择模拟器

在 Xcode 顶部工具栏：
```
[CityMood ▶]  [iPhone 15]  [运行按钮 ▶]
```

点击 `[iPhone 15]` 可以换其他机型

### 1.3 运行 App

点击左上角的 **▶ 运行按钮**（或按 `Cmd+R`）

等待 10-30 秒，模拟器会弹出 iPhone 界面，显示 CityMood。

---

## 🧪 第二步：功能测试

### 测试 1：心情打卡

**操作步骤：**
1. 打开 App，默认在「打卡」标签
2. 点击一个 emoji（比如 😄）
3. 选择几个标签（比如「工作」「天气」）
4. 写一句日记（可选）："今天天气不错"
5. 点击「记录心情」按钮

**预期结果：**
- 按钮变灰/显示加载
- 弹出「打卡成功」提示
- 数据已发送到后端

**验证方法：**
```bash
# 在终端查看数据库
cd ~/workspace/CityMood
psql -U postgres -d citymood -c "SELECT * FROM mood_records ORDER BY created_at DESC LIMIT 1;"
```

能看到刚才的记录 = ✅ 通过

---

### 测试 2：城市心情

**操作步骤：**
1. 点击底部「地图」标签
2. 选择城市：北京、上海、成都等
3. 查看卡片显示的心情指数

**预期结果：**
- 显示城市名称
- 显示心情指数（0-100）
- 显示今日记录数

**如果没有数据：**
显示「今日暂无数据」是正常的，因为你还没给那个城市打记录。

**手动添加测试数据：**
```bash
# 给上海打几条记录
curl -X POST http://localhost:3000/api/v1/moods \
  -H "Content-Type: application/json" \
  -d '{"device_id": "test1", "mood_level": 5, "city_code": "SH"}'

curl -X POST http://localhost:3000/api/v1/moods \
  -d '{"device_id": "test2", "mood_level": 4, "city_code": "SH"}'

curl -X POST http://localhost:3000/api/v1/moods \
  -d '{"device_id": "test3", "mood_level": 3, "city_code": "SH"}'
```

然后再看上海的心情指数 = ✅ 通过

---

### 测试 3：排行榜

**操作步骤：**
1. 点击底部「排行」标签
2. 切换三个选项：最幸福 / 压力最大 / 全球

**预期结果：**
- 显示城市列表
- 有排名、城市名、分数
- 全球页显示统计数据

---

### 测试 4：个人日历

**操作步骤：**
1. 多打几条心情记录（换不同心情）
2. 点击底部「我的」标签
3. 查看日历视图

**预期结果：**
- 日历上有颜色标记
- 点击日期能看到记录

---

## 🔧 常见问题

### 问题 1：App 无法启动（Build Failed）

**现象：** Xcode 显示红色错误 ❌

**解决方法：**
```bash
# 1. 清理缓存
rm -rf ~/workspace/CityMood/ios/CityMood/CityMood.xcodeproj/project.xcworkspace/xcuserdata

# 2. 在 Xcode 中
# Product → Clean Build Folder (Cmd+Shift+K)
# 然后重新运行 (Cmd+R)
```

---

### 问题 2：无法连接后端

**现象：** 点击「记录心情」后一直转圈

**检查清单：**
1. 后端是否启动？
   ```bash
   curl http://localhost:3000/health
   # 应该返回 {"code":200}
   ```

2. 数据库是否运行？
   ```bash
   brew services list | grep postgresql
   # 应该显示 started
   ```

3. 修改 iOS 代码使用正确 IP：
   ```swift
   // ios/CityMood/CityMood/Core/Services/APIService.swift
   // 改成你的 Mac IP
   private let baseURL = "http://192.168.1.xxx:3000/api/v1"
   ```

---

### 问题 3：模拟器定位失败

**现象：** 城市心情显示「北京」，但你在上海

**原因：** 模拟器默认定位是苹果总部（美国加州）

**解决方法：**
1. 在模拟器中打开「设置」→「隐私」→「定位服务」
2. 允许 CityMood 使用定位
3. 或者在 Xcode 中：
   - Debug → Simulate Location → 选择 Beijing

---

## 📝 测试记录表

建议用备忘录记录测试结果：

| 测试项 | 日期 | 结果 | 问题 |
|--------|------|------|------|
| 心情打卡 | 2/8 | ✅ | 无 |
| 城市心情 | 2/8 | ⚠️ | 数据不足 |
| 排行榜 | 2/8 | ✅ | 无 |
| 个人日历 | 2/8 | ❌ | 界面未显示 |

发现问题截图给我，我改代码。

---

## 🎓 给博士的特别提示

**思考方式对比：**

| 天体物理 | iOS 开发 |
|---------|---------|
| 观测数据 → 分析 → 论文 | 写代码 → 编译 → 看效果 |
| 望远镜是工具 | Xcode 是工具 |
| 数据质量很重要 | 日志输出很重要 |
| 需要长时间曝光 | 需要多次调试迭代 |

**关键心态：**
- 报错是正常的，就像观测有噪声
- 看不懂的错误先 Google，就像查文献
- 从简单功能开始测，就像先观测亮星

---

## 🚀 进阶测试（可选）

### 压力测试
连续打 100 条记录，看后端是否稳定：
```bash
for i in {1..100}; do
  curl -X POST http://localhost:3000/api/v1/moods \
    -d "{\"device_id\": \"stress_test_$i\", \"mood_level\": $((RANDOM % 5 + 1)), \"city_code\": \"BJ\"}"
done
```

### 多城市测试
同时给北京、上海、成都打记录，看排名是否正确。

---

## 📞 求助方式

遇到问题时：
1. **截图** Xcode 的错误提示
2. **复制** 完整的错误日志
3. **描述** 你做了什么操作
4. 发给我

就像写论文时找导师讨论一样，信息越完整，解决越快。

---

**祝测试顺利！** 🧪

— Feynman
