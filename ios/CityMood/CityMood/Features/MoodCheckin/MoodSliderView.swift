import SwiftUI

struct MoodSliderView: View {
    @ObservedObject var locationManager: LocationManager
    @EnvironmentObject var store: MoodStore
    @State private var moodValue: Double = 50
    @State private var isDragging = false
    @State private var selectedTags: Set<String> = []
    @State private var showSuccess = false
    @State private var note = ""
    @FocusState private var isNoteFocused: Bool
    
    let influenceFactors = [
        ("工作", "💼"),
        ("学业", "📚"),
        ("健康", "🏥"),
        ("金钱", "💰"),
        ("人际关系", "👥"),
        ("恋爱", "💕"),
        ("婚姻", "💑"),
        ("家庭", "🏠"),
        ("友情", "🤝"),
        ("天气", "🌤️"),
        ("睡眠", "😴"),
        ("饮食", "🍽️"),
        ("运动", "🏃"),
        ("娱乐", "🎮"),
        ("社交媒体", "📱"),
        ("政治", "🗳️")
    ]
    
    private var currentColor: Color {
        let normalized = moodValue / 100.0
        if normalized < 0.15 { return Color(hex: "8B4513") }
        if normalized < 0.30 { return Color(hex: "CD5C5C") }
        if normalized < 0.45 { return Color(hex: "FF8C00") }
        if normalized < 0.55 { return Color(hex: "A5A5B0") }
        if normalized < 0.70 { return Color(hex: "5F9EA0") }
        if normalized < 0.85 { return Color(hex: "66CDAA") }
        return Color(hex: "98FB98")
    }
    
    private var moodText: String {
        switch moodValue {
        case 0..<15: return "仇恨"
        case 15..<30: return "愤怒"
        case 30..<45: return "焦虑"
        case 45..<55: return "平静"
        case 55..<70: return "满足"
        case 70..<85: return "喜悦"
        case 85...100: return "平静超然"
        default: return "平静"
        }
    }
    
    private var moodEmoji: String {
        switch moodValue {
        case 0..<15: return "😠"
        case 15..<30: return "😤"
        case 30..<45: return "😰"
        case 45..<55: return "😌"
        case 55..<70: return "😊"
        case 70..<85: return "😄"
        case 85...100: return "🕊️"
        default: return "😌"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F5F5F7"),
                    Color(hex: "E8E8ED"),
                    Color(hex: "DCDCE2")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    moodDisplaySection
                    
                    sliderSection
                    
                    influenceFactorsSection
                    
                    noteSection
                    
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .alert("记录成功", isPresented: $showSuccess) {
            Button("确定", role: .cancel) {
                selectedTags.removeAll()
                note = ""
                moodValue = 50
            }
        } message: {
            Text("今日心情已记录")
        }
    }
    
    private func hideKeyboard() {
        isNoteFocused = false
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                Text(locationManager.currentCity.isEmpty ? "定位中..." : locationManager.currentCity)
                    .font(.system(size: 14, weight: .medium))
                if locationManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .foregroundColor(Color(hex: "6B6B80"))
            
            Text(todayString)
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(Color(hex: "3A3A3A"))
        }
        .padding(.top, 20)
    }
    
    private var moodDisplaySection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentColor.opacity(0.2),
                                currentColor.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 150
                        )
                    )
                    .frame(width: 180, height: 180)
                
                Text(moodEmoji)
                    .font(.system(size: 64))
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDragging)
            }
            
            Text(moodText)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "3A3A3A"))
            
            Text("\(Int(moodValue))")
                .font(.system(size: 36, weight: .thin, design: .rounded))
                .foregroundColor(Color(hex: "6B6B80"))
        }
    }
    
    private var sliderSection: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "E0E0E5"))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(currentColor.opacity(0.4))
                        .frame(width: CGFloat(moodValue / 100.0) * geometry.size.width, height: 20)
                    
                    Circle()
                        .fill(currentColor)
                        .frame(width: 28, height: 28)
                        .shadow(color: currentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                        .position(
                            x: CGFloat(moodValue / 100.0) * geometry.size.width,
                            y: 10
                        )
                        .scaleEffect(isDragging ? 1.15 : 1.0)
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
            .frame(height: 28)
            
            HStack {
                Text("仇恨")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8B8B9A"))
                Spacer()
                Text("平静超然")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8B8B9A"))
            }
        }
    }
    
    private var influenceFactorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日影响心情的因素")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "3A3A3A"))
            
            MoodSliderFlowLayout(spacing: 8) {
                ForEach(influenceFactors, id: \.0) { factor in
                    InfluenceTag(
                        text: factor.0,
                        emoji: factor.1,
                        isSelected: selectedTags.contains(factor.0)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedTags.contains(factor.0) {
                                selectedTags.remove(factor.0)
                            } else {
                                selectedTags.insert(factor.0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("记录一下今天")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "3A3A3A"))
            
            TextField("写下你的感受...", text: $note, axis: .vertical)
                .focused($isNoteFocused)
                .lineLimit(3...5)
                .padding(12)
                .background(Color(hex: "F0F0F2"))
                .cornerRadius(12)
        }
    }
    
    private var submitButton: some View {
        Button(action: submitMood) {
            HStack {
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("记录今日心情")
                        .font(.system(size: 17, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "6B6B7B"),
                                Color(hex: "4B4B5B")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color(hex: "4B4B5B").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(store.isLoading)
    }
    
    private func submitMood() {
        Task {
            await store.checkin(
                moodLevel: Int(moodValue),
                tags: Array(selectedTags),
                note: note.isEmpty ? nil : note
            )
            
            if store.errorMessage == nil {
                await MainActor.run {
                    showSuccess = true
                }
            }
        }
    }
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: Date())
    }
}

// MARK: - Influence Tag
struct InfluenceTag: View {
    let text: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 12))
                Text(text)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(hex: "5B5B6B") : Color(hex: "F0F0F2"))
            )
            .foregroundColor(isSelected ? .white : Color(hex: "4A4A5A"))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout
fileprivate struct MoodSliderFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

struct MoodSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MoodSliderView(locationManager: LocationManager())
            .environmentObject(MoodStore())
    }
}
