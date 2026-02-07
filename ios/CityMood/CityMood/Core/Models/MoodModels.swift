import Foundation

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
