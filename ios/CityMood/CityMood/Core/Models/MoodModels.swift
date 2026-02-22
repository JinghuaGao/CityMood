import Foundation
import SwiftUI

enum MoodLevel: Int, CaseIterable, Codable {
    case hatred = 1      // 仇恨
    case anger = 2        // 愤怒
    case anxiety = 3      // 焦虑
    case calm = 4         // 平静
    case content = 5     // 满足
    case joy = 6         // 喜悦
    case serenity = 7    // 平静超然
    
    var label: String {
        switch self {
        case .hatred: return "仇恨"
        case .anger: return "愤怒"
        case .anxiety: return "焦虑"
        case .calm: return "平静"
        case .content: return "满足"
        case .joy: return "喜悦"
        case .serenity: return "平静超然"
        }
    }
    
    var emoji: String {
        switch self {
        case .hatred: return "😠"
        case .anger: return "😤"
        case .anxiety: return "😰"
        case .calm: return "😌"
        case .content: return "😊"
        case .joy: return "😄"
        case .serenity: return "🕊️"
        }
    }
    
    var color: Color {
        switch self {
        case .hatred: return Color(hex: "8B0000")
        case .anger: return Color(hex: "FF4500")
        case .anxiety: return Color(hex: "FF8C00")
        case .calm: return Color(hex: "6B7B8C")
        case .content: return Color(hex: "5F9EA0")
        case .joy: return Color(hex: "FFD700")
        case .serenity: return Color(hex: "E8DFD0")
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .hatred: return [Color(hex: "8B0000"), Color(hex: "4A0000")]
        case .anger: return [Color(hex: "FF4500"), Color(hex: "CC3700")]
        case .anxiety: return [Color(hex: "FF8C00"), Color(hex: "CC7000")]
        case .calm: return [Color(hex: "6B7B8C"), Color(hex: "4A5A6A")]
        case .content: return [Color(hex: "5F9EA0"), Color(hex: "4A7A7C")]
        case .joy: return [Color(hex: "FFD700"), Color(hex: "FFA500")]
        case .serenity: return [Color(hex: "E8DFD0"), Color(hex: "F5F5F0")]
        }
    }
    
    var description: String {
        switch self {
        case .hatred: return "强烈的厌恶与敌意"
        case .anger: return "愤怒、烦躁、想发泄"
        case .anxiety: return "不安、紧张、担忧"
        case .calm: return "内心平静、无波无澜"
        case .content: return "满足、舒适、轻松"
        case .joy: return "开心、愉悦、充满能量"
        case .serenity: return "超越喜悲的内心安宁"
        }
    }
    
    var value: Int {
        return rawValue
    }
}

// MARK: - MoodRecord
struct MoodRecord: Identifiable, Codable {
    let id: String
    let userId: String
    let moodLevel: Int
    let tags: [String]
    let note: String?
    let cityCode: String?
    let cityName: String?
    let recordDate: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case moodLevel = "mood_level"
        case tags
        case note
        case cityCode = "city_code"
        case cityName = "city_name"
        case recordDate = "record_date"
        case createdAt = "created_at"
    }
    
    var moodEmoji: String {
        switch moodLevel {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    var moodColor: String {
        switch moodLevel {
        case 1: return "sad"
        case 2: return "anxious"
        case 3: return "neutral"
        case 4: return "happy"
        case 5: return "excited"
        default: return "neutral"
        }
    }
}

// MARK: - CityMood
struct CityMood: Codable {
    let cityCode: String
    let cityName: String
    let date: String
    let moodIndex: Double?
    let totalRecords: Int
    let uniqueUsers: Int
    let avgMood: Double?
    let distribution: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case cityCode = "city_code"
        case cityName = "city_name"
        case date
        case moodIndex = "mood_index"
        case totalRecords = "total_records"
        case uniqueUsers = "unique_users"
        case avgMood = "avg_mood"
        case distribution
    }
    
    var moodEmoji: String {
        guard let index = moodIndex else { return "😐" }
        if index >= 80 { return "😄" }
        if index >= 60 { return "🙂" }
        if index >= 40 { return "😐" }
        if index >= 20 { return "😕" }
        return "😢"
    }
}

// MARK: - City
struct City: Identifiable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let nameEn: String
    let longitude: Double
    let latitude: Double
    let population: Int?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case nameEn = "name_en"
        case longitude
        case latitude
        case population
    }
}

// MARK: - MoodCheckinRequest
struct MoodCheckinRequest: Codable {
    let deviceId: String
    let moodLevel: Int
    let tags: [String]?
    let note: String?
    let latitude: Double?
    let longitude: Double?
    let cityCode: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case moodLevel = "mood_level"
        case tags
        case note
        case latitude
        case longitude
        case cityCode = "city_code"
    }
}

// MARK: - APIResponse
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let timestamp: String
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
