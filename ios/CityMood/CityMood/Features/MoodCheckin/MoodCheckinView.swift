import SwiftUI

struct MoodCheckinView: View {
    @EnvironmentObject var store: MoodStore
    @State private var selectedMood: MoodLevel?
    @State private var selectedTags: Set<String> = []
    @State private var note = ""
    @State private var showSuccess = false
    
    let moodLevels = MoodLevel.allCases
    
    let tagOptions = ["工作", "学习", "家庭", "健康", "天气", "社交", "休闲", "其他"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    Text(todayString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("此刻，你感觉如何？")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    MoodCardGrid(
                        moods: moodLevels,
                        selectedMood: $selectedMood
                    )
                    
                    if let mood = selectedMood {
                        VStack(spacing: 8) {
                            Text(mood.description)
                                .font(.subheadline)
                                .foregroundColor(mood.color)
                                .transition(.scale.combined(with: .opacity))
                        }
                        .animation(.spring(response: 0.3), value: selectedMood?.rawValue)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("影响因素")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(tagOptions, id: \.self) { tag in
                                TagButton(
                                    text: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    toggleTag(tag)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("记录此刻（可选）")
                            .font(.headline)
                        
                        TextEditor(text: $note)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Button(action: submit) {
                        HStack {
                            if store.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(selectedMood == nil ? "先选择一个心情" : "记录心情")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMood != nil ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedMood == nil || store.isLoading)
                    
                    if let error = store.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("心情打卡")
            .alert("记录成功", isPresented: $showSuccess) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("你的心情已被记录")
            }
        }
    }
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    private func submit() {
        guard let mood = selectedMood else { return }
        Task {
            await store.checkin(
                moodLevel: mood.rawValue,
                tags: Array(selectedTags),
                note: note.isEmpty ? nil : note
            )
            
            if store.errorMessage == nil {
                await MainActor.run {
                    showSuccess = true
                    note = ""
                    selectedTags.removeAll()
                    selectedMood = nil
                }
            }
        }
    }
}

// MARK: - MoodCardGrid
struct MoodCardGrid: View {
    let moods: [MoodLevel]
    @Binding var selectedMood: MoodLevel?
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(moods, id: \.rawValue) { mood in
                MoodCard(
                    mood: mood,
                    isSelected: selectedMood == mood
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedMood = mood
                    }
                }
            }
        }
    }
}

// MARK: - MoodCard
struct MoodCard: View {
    let mood: MoodLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: mood.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: mood.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    }
                    
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 32))
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                        
                        Text(mood.label)
                            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                    .padding(.vertical, 16)
                }
            }
            .frame(height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - TagButton
struct TagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
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

struct MoodCheckinView_Previews: PreviewProvider {
    static var previews: some View {
        MoodCheckinView()
            .environmentObject(MoodStore())
    }
}
