import SwiftUI

struct MoodCheckinView: View {
    @EnvironmentObject var store: MoodStore
    @State private var selectedMood = 3
    @State private var selectedTags: Set<String> = []
    @State private var note = ""
    @State private var showSuccess = false
    
    let moodOptions = [
        (1, "😢", "难过", Color.red),
        (2, "😕", "焦虑", Color.orange),
        (3, "😐", "平静", Color.gray),
        (4, "🙂", "开心", Color.green),
        (5, "😄", "很棒", Color.blue)
    ]
    
    let tagOptions = ["工作", "学习", "家庭", "健康", "天气", "社交", "休闲", "其他"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 日期显示
                    Text(todayString)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // 心情选择器
                    VStack(spacing: 16) {
                        Text("今天心情怎么样？")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            ForEach(moodOptions, id: \.0) { mood in
                                MoodButton(
                                    emoji: mood.1,
                                    label: mood.2,
                                    isSelected: selectedMood == mood.0,
                                    color: mood.3
                                ) {
                                    withAnimation(.spring()) {
                                        selectedMood = mood.0
                                    }
                                }
                            }
                        }
                    }
                    
                    // 标签选择
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
                    
                    // 日记输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日记（可选）")
                            .font(.headline)
                        
                        TextEditor(text: $note)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // 提交按钮
                    Button(action: submit) {
                        HStack {
                            if store.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("记录心情")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(store.isLoading)
                    
                    if let error = store.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("心情打卡")
            .alert("打卡成功！", isPresented: $showSuccess) {
                Button("确定", role: .cancel) { }
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
        Task {
            await store.checkin(
                moodLevel: selectedMood,
                tags: Array(selectedTags),
                note: note.isEmpty ? nil : note
            )
            
            if store.errorMessage == nil {
                await MainActor.run {
                    showSuccess = true
                    note = ""
                    selectedTags.removeAll()
                }
            }
        }
    }
}

// MARK: - MoodButton
struct MoodButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 40))
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? color.opacity(0.15) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
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
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
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
