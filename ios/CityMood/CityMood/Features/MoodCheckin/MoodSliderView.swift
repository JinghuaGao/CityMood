import SwiftUI

struct MoodSliderView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var moodValue: Double = 50
    @State private var isDragging = false
    
    // 未来复古配色
    private let colorStops: [(Double, Color)] = [
        (0, Color(hex: "0f0f23")),      // 0-10: 深夜深蓝
        (10, Color(hex: "1a1a3e")),     // 10-20: 深紫蓝
        (20, Color(hex: "2d1b4e")),     // 20-30: 暗紫
        (30, Color(hex: "4a1942")),     // 30-40: 暗红紫
        (40, Color(hex: "6b2d5c")),     // 40-50: 玫瑰灰
        (50, Color(hex: "8b6f47")),     // 50-60: 复古铜
        (60, Color(hex: "c4a35a")),     // 60-70: 金黄
        (70, Color(hex: "e8d5a3")),     // 70-80: 奶油黄
        (80, Color(hex: "fff8e7")),     // 80-90: 象牙白
        (90, Color(hex: "fffef0"))      // 90-100: 阳光明媚
    ]
    
    private var currentColor: Color {
        interpolateColor(value: moodValue)
    }
    
    private var moodText: String {
        switch moodValue {
        case 0..<10: return "绝望"
        case 10..<20: return "痛苦"
        case 20..<30: return "沮丧"
        case 30..<40: return "焦虑"
        case 40..<50: return "低落"
        case 50..<60: return "平静"
        case 60..<70: return "不错"
        case 70..<80: return "开心"
        case 80..<90: return "很棒"
        case 90...100: return "完美"
        default: return "平静"
        }
    }
    
    private var moodEmoji: String {
        switch moodValue {
        case 0..<20: return "🌑"
        case 20..<40: return "🌘"
        case 40..<50: return "🌗"
        case 50..<60: return "🌖"
        case 60..<80: return "🌕"
        case 80...100: return "☀️"
        default: return "🌕"
        }
    }
    
    var body: some View {
        ZStack {
            // 动态背景
            currentColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: moodValue)
            
            // 装饰性背景元素（未来复古风格）
            GeometryReader { geo in
                ZStack {
                    // 网格线
                    RetroGrid()
                        .opacity(0.1)
                    
                    // 光晕效果
                    RadialGradient(
                        gradient: Gradient(colors: [
                            currentColor.opacity(0.8),
                            currentColor.opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.8
                    )
                    .animation(.easeInOut(duration: 0.5), value: moodValue)
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // 日期和标题 + 城市名
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text(locationManager.currentCity)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        if locationManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Text("CITY MOOD")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(8)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(todayString)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // 心情显示区域
                VStack(spacing: 20) {
                    Text(moodEmoji)
                        .font(.system(size: 80))
                        .scaleEffect(isDragging ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: isDragging)
                    
                    Text(moodText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(Int(moodValue))")
                        .font(.system(size: 64, weight: .thin, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .kerning(4)
                }
                
                Spacer()
                
                // 滑动条区域
                VStack(spacing: 30) {
                    // 自定义滑动条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 背景轨道
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "0f0f23"),
                                            Color(hex: "2d1b4e"),
                                            Color(hex: "8b6f47"),
                                            Color(hex: "fffef0")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            // 进度条光效
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.cyan.opacity(0.6),
                                            Color.purple.opacity(0.4),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat(moodValue / 100.0) * geometry.size.width, height: 16)
                            
                            // 滑块
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [Color.white, Color.cyan.opacity(0.8)]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 20
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .position(
                                    x: CGFloat(moodValue / 100.0) * geometry.size.width,
                                    y: 8
                                )
                                .scaleEffect(isDragging ? 1.3 : 1.0)
                                .animation(.spring(response: 0.2), value: isDragging)
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let percentage = min(max(value.location.x / geometry.size.width, 0), 1)
                                    moodValue = Double(percentage * 100)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                    }
                    .frame(height: 32)
                    .padding(.horizontal, 20)
                    
                    // 标签
                    HStack {
                        Text("绝望")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("完美")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // 提交按钮
                Button(action: {
                    // 提交心情
                }) {
                    Text("记录心情")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(currentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.white.opacity(0.3), radius: 20, x: 0, y: 10)
                        )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: Date())
    }
    
    private func interpolateColor(value: Double) -> Color {
        let normalized = value / 100.0
        
        for i in 0..<(colorStops.count - 1) {
            let (pos1, color1) = colorStops[i]
            let (pos2, color2) = colorStops[i + 1]
            
            if normalized >= pos1 / 100.0 && normalized <= pos2 / 100.0 {
                let range = (pos2 - pos1) / 100.0
                let progress = (normalized - pos1 / 100.0) / range
                return color1.mix(with: color2, by: progress)
            }
        }
        return colorStops.last?.1 ?? Color.gray
    }
}

// MARK: - Retro Grid Background
struct RetroGrid: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let gridSize: CGFloat = 40
                
                // 竖线
                for x in stride(from: 0, to: size.width, by: gridSize) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 0.5)
                }
                
                // 横线（透视效果）
                for y in stride(from: 0, to: size.height, by: gridSize) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func mix(with target: Color, by amount: Double) -> Color {
        // 简化混合，实际应该解包 Color 组件
        return self.opacity(1 - amount).opacity(amount)
    }
}

struct MoodSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MoodSliderView(locationManager: LocationManager())
    }
}
