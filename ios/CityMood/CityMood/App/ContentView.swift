import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MoodCheckinView()
                .tabItem {
                    Label("打卡", systemImage: "plus.circle.fill")
                }
                .tag(0)
            
            CityHeatmapView()
                .tabItem {
                    Label("地图", systemImage: "map.fill")
                }
                .tag(1)
            
            CityRankingView()
                .tabItem {
                    Label("排行", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            MoodCalendarView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MoodStore())
    }
}
