import SwiftUI
import MapKit

struct CityHeatmapView: View {
    @EnvironmentObject var store: MoodStore
    @State private var selectedCity: String = "BJ"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    let cities = [
        ("BJ", "北京", 39.9042, 116.4074),
        ("SH", "上海", 31.2304, 121.4737),
        ("GZ", "广州", 23.1291, 113.2644),
        ("SZ", "深圳", 22.5431, 114.0579),
        ("CD", "成都", 30.5728, 104.0668),
        ("HZ", "杭州", 30.2741, 120.1551)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 城市选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(cities, id: \.0) { city in
                            CityChip(
                                code: city.0,
                                name: city.1,
                                isSelected: selectedCity == city.0
                            ) {
                                selectedCity = city.0
                                updateRegion(city: city)
                                loadCityMood()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // 地图
                Map(coordinateRegion: $region)
                    .overlay(
                        HeatmapOverlay()
                    )
                
                // 城市心情卡片
                if let mood = store.cityMoods.first(where: { $0.cityCode == selectedCity }) {
                    CityMoodCard(mood: mood)
                        .padding()
                } else {
                    CityMoodPlaceholder(cityCode: selectedCity)
                        .padding()
                }
            }
            .navigationTitle("城市心情")
            .onAppear {
                loadCityMood()
            }
        }
    }
    
    private func updateRegion(city: (String, String, Double, Double)) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: city.2, longitude: city.3),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    
    private func loadCityMood() {
        Task {
            await store.fetchCityMood(cityCode: selectedCity)
        }
    }
}

// MARK: - CityChip
struct CityChip: View {
    let code: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - CityMoodCard
struct CityMoodCard: View {
    let mood: CityMood
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mood.cityName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(mood.moodEmoji)
                    .font(.system(size: 40))
            }
            
            if let index = mood.moodIndex {
                HStack {
                    Text("心情指数")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(index))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(moodColor(for: index))
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(moodColor(for: index))
                            .frame(width: geometry.size.width * CGFloat(index / 100), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Label("\(mood.totalRecords) 条记录", systemImage: "doc.text")
                    Spacer()
                    Label("\(mood.uniqueUsers) 人参与", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
                Text("今日暂无数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func moodColor(for index: Double) -> Color {
        if index >= 80 { return .blue }
        if index >= 60 { return .green }
        if index >= 40 { return .yellow }
        if index >= 20 { return .orange }
        return .red
    }
}

// MARK: - CityMoodPlaceholder
struct CityMoodPlaceholder: View {
    let cityCode: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - HeatmapOverlay
struct HeatmapOverlay: View {
    var body: some View {
        // 简化版热力图覆盖层
        // 实际应该用 MapKit 的 overlay
        EmptyView()
    }
}

struct CityHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        CityHeatmapView()
            .environmentObject(MoodStore())
    }
}
