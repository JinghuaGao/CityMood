import SwiftUI

struct UserSettings {
    private static let nicknameKey = "user_nickname"
    
    static var nickname: String {
        get {
            UserDefaults.standard.string(forKey: nicknameKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nicknameKey)
        }
    }
}

struct MoodCalendarView: View {
    @EnvironmentObject var store: MoodStore
    @State private var nickname: String = UserSettings.nickname
    @State private var isEditingNickname = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    UserProfileCard(
                        nickname: $nickname,
                        isEditing: $isEditingNickname
                    )
                    
                    // 本月日历
                    CalendarGridView(records: store.recentMoods)
                    
                    // 最近记录
                    RecentRecordsList()
                }
                .padding()
            }
            .navigationTitle("我的")
            .onAppear {
                nickname = UserSettings.nickname
                Task {
                    await store.fetchRecentMoods()
                }
            }
        }
    }
}

// MARK: - UserProfileCard
struct UserProfileCard: View {
    @Binding var nickname: String
    @Binding var isEditing: Bool
    @State private var tempNickname = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // 头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6B6B7B"), Color(hex: "4B4B5B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(nickname.isEmpty ? "?" : String(nickname.prefix(1)))
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // 昵称
            if isEditing {
                HStack {
                    TextField("输入昵称", text: $tempNickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                    
                    Button("保存") {
                        nickname = tempNickname
                        UserSettings.nickname = tempNickname
                        isEditing = false
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("取消") {
                        isEditing = false
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Text(nickname.isEmpty ? "点击设置昵称" : nickname)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Button("编辑") {
                        tempNickname = nickname
                        isEditing = true
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            // 统计
            HStack(spacing: 40) {
                VStack {
                    Text("0")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("连续天数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("0")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("总记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - CalendarGridView
struct CalendarGridView: View {
    let records: [MoodRecord]
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: Date())
    }
    
    private var daysInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }
    
    private var firstWeekday: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard let firstDay = calendar.date(from: components) else { return 1 }
        return calendar.component(.weekday, from: firstDay)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentMonth)
                .font(.headline)
            
            // 星期标题
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日历格子
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 空白格子
                ForEach(1..<firstWeekday, id: \.self) { _ in
                    Text("")
                        .frame(width: 32, height: 32)
                }
                
                // 日期格子
                ForEach(1...daysInMonth, id: \.self) { day in
                    DayCell(day: day, record: recordForDay(day))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func recordForDay(_ day: Int) -> MoodRecord? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard let monthDate = calendar.date(from: components) else { return nil }
        
        let targetDate = calendar.date(byAdding: .day, value: day - 1, to: monthDate)!
        let dateString = formatter.string(from: targetDate)
        
        return records.first { $0.recordDate == dateString }
    }
}

// MARK: - DayCell
struct DayCell: View {
    let day: Int
    let record: MoodRecord?
    
    var body: some View {
        ZStack {
            if let record = record {
                Circle()
                    .fill(moodColor(for: record.moodLevel))
                    .frame(width: 32, height: 32)
                
                Text(moodEmoji(for: record.moodLevel))
                    .font(.system(size: 14))
            } else {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 1)
                    .frame(width: 32, height: 32)
            }
            
            Text("\(day)")
                .font(.caption2)
                .foregroundColor(record != nil ? .white : .secondary)
        }
    }
    
    private func moodColor(for level: Int) -> Color {
        switch level {
        case 1: return Color(hex: "8B0000")  // 仇恨
        case 2: return Color(hex: "FF4500")  // 愤怒
        case 3: return Color(hex: "FF8C00") // 焦虑
        case 4: return Color(hex: "6B7B8C")  // 平静
        case 5: return Color(hex: "5F9EA0")  // 满足
        case 6: return Color(hex: "FFD700")  // 喜悦
        case 7: return Color(hex: "98FB98")  // 平静超然
        default: return Color.gray
        }
    }
    
    private func moodEmoji(for level: Int) -> String {
        switch level {
        case 1: return "😠"
        case 2: return "😤"
        case 3: return "😰"
        case 4: return "😌"
        case 5: return "😊"
        case 6: return "😄"
        case 7: return "🕊️"
        default: return "😐"
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
            Text(moodEmoji(for: record.moodLevel))
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
    
    private func moodEmoji(for level: Int) -> String {
        switch level {
        case 1: return "😠"
        case 2: return "😤"
        case 3: return "😰"
        case 4: return "😌"
        case 5: return "😊"
        case 6: return "😄"
        case 7: return "🕊️"
        default: return "😐"
        }
    }
}

struct MoodCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MoodCalendarView()
            .environmentObject(MoodStore())
    }
}
