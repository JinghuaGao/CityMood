import SwiftUI
import MapKit

struct CityHeatmapView: View {
    @EnvironmentObject var store: MoodStore
    @State private var selectedCity: String = "BJ"
    @State private var showHeatmapDetail = false
    @State private var selectedMoodZone: MoodZone?
    
    let cities = [
        ("BJ", "北京", 39.9042, 116.4074),
        ("SH", "上海", 31.2304, 121.4737),
        ("GZ", "广州", 23.1291, 113.2644),
        ("SZ", "深圳", 22.5431, 114.0579),
        ("CD", "成都", 30.5728, 104.0668),
        ("HZ", "杭州", 30.2741, 120.1551)
    ]
    
    // 模拟心情热度区域数据
    private var mockMoodZones: [MoodZone] {
        let baseCoordinates = cities.first(where: { $0.0 == selectedCity }) ?? cities[0]
        
        // 生成不同心情热度的区域
        return [
            MoodZone(
                name: "大学城区",
                moodIndex: 85,
                emoji: "🌕",
                description: "学术氛围浓厚",
                coordinate: CLLocationCoordinate2D(latitude: baseCoordinates.2 + 0.01, longitude: baseCoordinates.3 + 0.01),
                color: .blue.opacity(0.6),
                records: 156
            ),
            MoodZone(
                name: "商业中心区",
                moodIndex: 72,
                emoji: "🌖",
                description: "工作压力大",
                coordinate: CLLocationCoordinate2D(latitude: baseCoordinates.2 - 0.008, longitude: baseCoordinates.3 + 0.012),
                color: .green.opacity(0.5),
                records: 234
            ),
            MoodZone(
                name: "居住社区区",
                moodIndex: 65,
                emoji: "🌕",
                description: "生活平衡",
                coordinate: CLLocationCoordinate2D(latitude: baseCoordinates.2 - 0.015, longitude: baseCoordinates.3 - 0.01),
                color: .yellow.opacity(0.4),
                records: 189
            ),
            MoodZone(
                name: "科技园区",
                moodIndex: 58,
                emoji: "🌗",
                description: "竞争激烈",
                coordinate: CLLocationCoordinate2D(latitude: baseCoordinates.2 + 0.005, longitude: baseCoordinates.3 - 0.008),
                color: .orange.opacity(0.5),
                records: 312
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部心情概览卡片
                CityMoodOverviewCard(selectedCity: selectedCity)
                    .padding()
                
                // 城市选择器 - 紧凑版
                HStack(spacing: 8) {
                    ForEach(cities, id: \.0) { city in
                        CompactCityChip(
                            code: city.0,
                            name: city.1,
                            isSelected: selectedCity == city.0
                        ) {
                            selectedCity = city.0
                            loadCityMood()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 地图区域 - 心情热度展示
                ZStack {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: mockBaseCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )))
                    .mapStyle(.hybrid)
                    
                    // 心情热度覆盖层
                    ForEach(mockMoodZones) { zone in
                        MoodZoneMarker(zone: zone)
                            .onTapGesture {
                                selectedMoodZone = zone
                                showHeatmapDetail = true
                            }
                    }
                }
                .frame(height: 400)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                
                // 底部统计信息
                MoodStatisticsView(zones: mockMoodZones)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("心情热度")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showHeatmapDetail) {
                if let zone = selectedMoodZone {
                    MoodZoneDetailView(zone: zone)
                }
            }
            .onAppear {
                loadCityMood()
            }
        }
    }
    
    private var mockBaseCoordinate: CLLocationCoordinate2D {
        let base = cities.first(where: { $0.0 == selectedCity }) ?? cities[0]
        return CLLocationCoordinate2D(latitude: base.2, longitude: base.3)
    }
    
    private func loadCityMood() {
        Task {
            await store.fetchCityMood(cityCode: selectedCity)
        }
    }
}

// MARK: - City Mood Overview Card
struct CityMoodOverviewCard: View {
    @EnvironmentObject var store: MoodStore
    let selectedCity: String
    
    private var cityName: String {
        switch selectedCity {
        case "BJ": return "北京"
        case "SH": return "上海"
        case "GZ": return "广州"
        case "SZ": return "深圳"
        case "CD": return "成都"
        case "HZ": return "杭州"
        default: return "北京"
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // 左侧：城市名和心情指数
            VStack(alignment: .leading, spacing: 8) {
                Text(cityName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text("今日心情指数")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let mood = store.cityMoods.first(where: { $0.cityCode == selectedCity }),
                       let index = mood.moodIndex {
                        Text("\(Int(index))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(moodColor(for: index))
                    }
                }
            }
            
            Spacer()
            
            // 右侧：心情趋势图
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("记录数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let mood = store.cityMoods.first(where: { $0.cityCode == selectedCity }) {
                            Text("\(mood.totalRecords)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("参与人数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let mood = store.cityMoods.first(where: { $0.cityCode == selectedCity }) {
                            Text("\(mood.uniqueUsers)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func moodColor(for index: Double) -> Color {
        if index >= 80 { return .blue }
        if index >= 60 { return .green }
        if index >= 40 { return .yellow }
        if index >= 20 { return .orange }
        return .red
    }
}

// MARK: - Compact City Chip
struct CompactCityChip: View {
    let code: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mood Zone Marker
struct MoodZoneMarker: View {
    let zone: MoodZone
    
    var body: some View {
        ZStack {
            // 热度光晕
            Circle()
                .fill(zone.color)
                .frame(width: 100, height: 100)
                .blur(radius: 20)
                .opacity(0.3)
            
            // 中心图标
            Circle()
                .fill(zone.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(zone.emoji)
                        .font(.system(size: 24))
                )
                .shadow(color: zone.color.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // 区域名称
            Text(zone.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .offset(y: 35)
        }
    }
}

// MARK: - Mood Statistics View
struct MoodStatisticsView: View {
    let zones: [MoodZone]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("区域心情分布")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("查看全部") {
                    // 导航到详细统计
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // 心情分布条
            HStack(alignment: .top, spacing: 4) {
                ForEach(zones) { zone in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(zone.color)
                            .frame(width: 40, height: CGFloat(zone.moodIndex) * 2)
                            .cornerRadius(4)
                        
                        Text("\(Int(zone.moodIndex))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Mood Zone Detail View
struct MoodZoneDetailView: View {
    let zone: MoodZone
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 心情指示器
                ZStack {
                    Circle()
                        .fill(zone.color)
                        .frame(width: 120, height: 120)
                    
                    Text(zone.emoji)
                        .font(.system(size: 48))
                }
                .shadow(color: zone.color.opacity(0.5), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 16) {
                    Text(zone.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("心情指数: \(Int(zone.moodIndex))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(zone.color)
                    
                    Text(zone.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 24) {
                        StatisticItem(label: "记录数", value: "\(zone.records)")
                        StatisticItem(label: "更新", value: "刚刚")
                    }
                }
                
                Spacer()
                
                // 行动按钮
                VStack(spacing: 12) {
                    Button("我也来打卡") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("查看历史趋势") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("区域详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Statistic Item
struct StatisticItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Models
struct MoodZone: Identifiable {
    let id = UUID()
    let name: String
    let moodIndex: Double
    let emoji: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let records: Int
}

// MARK: - Rounded Corner Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct CityHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        CityHeatmapView()
            .environmentObject(MoodStore())
    }
}