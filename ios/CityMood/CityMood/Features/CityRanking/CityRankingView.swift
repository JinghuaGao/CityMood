import SwiftUI

struct CityRankingView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分段控制器
                Picker("榜单类型", selection: $selectedTab) {
                    Text("最幸福").tag(0)
                    Text("压力最大").tag(1)
                    Text("全球").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 榜单内容
                TabView(selection: $selectedTab) {
                    HappiestCitiesView()
                        .tag(0)
                    
                    StressedCitiesView()
                        .tag(1)
                    
                    GlobalStatsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("城市排行")
        }
    }
}

// MARK: - HappiestCitiesView
struct HappiestCitiesView: View {
    let mockData = [
        (1, "成都", "CD", 87.5, 1250),
        (2, "杭州", "HZ", 82.3, 980),
        (3, "深圳", "SZ", 79.8, 2100),
        (4, "广州", "GZ", 76.5, 1850),
        (5, "上海", "SH", 73.2, 3200),
        (6, "北京", "BJ", 68.9, 2800)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(mockData, id: \.1) { city in
                    RankingRow(
                        rank: city.0,
                        cityName: city.1,
                        cityCode: city.2,
                        score: city.3,
                        count: city.4,
                        emoji: "😄",
                        color: .green
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - StressedCitiesView
struct StressedCitiesView: View {
    let mockData = [
        (1, "北京", "BJ", 32.5, 2800),
        (2, "上海", "SH", 35.8, 3200),
        (3, "深圳", "SZ", 41.2, 2100),
        (4, "广州", "GZ", 45.6, 1850),
        (5, "杭州", "HZ", 52.3, 980)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(mockData, id: \.1) { city in
                    RankingRow(
                        rank: city.0,
                        cityName: city.1,
                        cityCode: city.2,
                        score: city.3,
                        count: city.4,
                        emoji: "😰",
                        color: .orange
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - GlobalStatsView
struct GlobalStatsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 全球总览
                VStack(spacing: 16) {
                    Text("今日全球")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 40) {
                        StatItem(value: "12,580", label: "记录数", icon: "doc.text")
                        StatItem(value: "8,420", label: "参与人数", icon: "person.2")
                    }
                    
                    HStack(spacing: 40) {
                        StatItem(value: "42", label: "城市数", icon: "building.2")
                        StatItem(value: "72.5", label: "全球指数", icon: "globe")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // 心情分布
                VStack(alignment: .leading, spacing: 12) {
                    Text("心情分布")
                        .font(.headline)
                    
                    MoodDistributionBar()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

// MARK: - RankingRow
struct RankingRow: View {
    let rank: Int
    let cityName: String
    let cityCode: String
    let score: Double
    let count: Int
    let emoji: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // 排名
            Text("\(rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(rank <= 3 ? color : .secondary)
                .frame(width: 40)
            
            // 城市信息
            VStack(alignment: .leading, spacing: 4) {
                Text(cityName)
                    .font(.headline)
                Text("\(count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 分数
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.title3)
                Text(String(format: "%.1f", score))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - StatItem
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - MoodDistributionBar
struct MoodDistributionBar: View {
    let data = [
        ("😄", 0.25, Color.blue),
        ("🙂", 0.30, Color.green),
        ("😐", 0.20, Color.yellow),
        ("😕", 0.15, Color.orange),
        ("😢", 0.10, Color.red)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(data, id: \.0) { item in
                        Rectangle()
                            .fill(item.2)
                            .frame(width: geometry.size.width * item.1)
                    }
                }
                .cornerRadius(4)
            }
            .frame(height: 24)
            
            HStack {
                ForEach(data, id: \.0) { item in
                    HStack(spacing: 2) {
                        Text(item.0)
                        Text("\(Int(item.1 * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CityRankingView_Previews: PreviewProvider {
    static var previews: some View {
        CityRankingView()
    }
}
