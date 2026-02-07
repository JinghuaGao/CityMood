# CityMood iOS App

## 项目设置

### 开发环境
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### 依赖管理
使用 Swift Package Manager

### 主要依赖
- [Alamofire](https://github.com/Alamofire/Alamofire) - 网络请求
- [MapKit](https://developer.apple.com/documentation/mapkit) - 地图
- [Swift Charts](https://developer.apple.com/documentation/charts) - 图表

### 项目结构
```
CityMood/
├── App/
├── Core/
├── Features/
├── UI/
└── Resources/
```

### 构建运行
```bash
# 打开项目
open CityMood.xcodeproj

# 或使用命令行
xcodebuild -scheme CityMood -destination 'platform=iOS Simulator,name=iPhone 15'
```
