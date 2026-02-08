import SwiftUI

struct MoodCalendarView: View {
    @EnvironmentObject var store: MoodStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 本月日历
                    CalendarGridView()
                    
                    // 最近记录
                    RecentRecordsList()
                }
                .padding()
            }
            .navigationTitle("我的情绪")
            .onAppear {
                Task {
                    await store.fetchRecentMoods()
                }
            }
        }
    }
}

// MARK: - CalendarGridView
struct CalendarGridView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2024年2月")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(1..<32) { day in
                    DayCell(day: day, mood: nil)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - DayCell
struct DayCell: View {
    let day: Int
    let mood: MoodRecord?
    
    var body: some View {
        Text("\(day)")
            .font(.caption)
            .frame(width: 32, height: 32)
            .background(backgroundColor)
            .foregroundColor(.primary)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        guard let mood = mood else { return Color.clear }
        switch mood.moodLevel {
        case 1: return .red.opacity(0.3)
        case 2: return .orange.opacity(0.3)
        case 3: return .gray.opacity(0.3)
        case 4: return .green.opacity(0.3)
        case 5: return .blue.opacity(0.3)
        default: return Color.clear
        }
    }
}

// MARK: - RecentRecordsList
struct RecentRecordsList: View {
    @EnvironmentObject var store: MoodStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.headline)
            
            if store.recentMoods.isEmpty {
                Text("还没有记录，去打卡吧！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(store.recentMoods.prefix(10)) { record in
                    RecordRow(record: record)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - RecordRow
struct RecordRow: View {
    let record: MoodRecord
    
    var body: some View {
        HStack {
            Text(record.moodEmoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.recordDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let city = record.cityName {
                Text(city)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MoodCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MoodCalendarView()
            .environmentObject(MoodStore())
    }
}
