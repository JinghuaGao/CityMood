import Foundation
import Combine

class MoodStore: ObservableObject {
    // MARK: - Published Properties
    @Published var todayMood: MoodRecord?
    @Published var recentMoods: [MoodRecord] = []
    @Published var cityMoods: [CityMood] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let apiService = APIService.shared
    private let locationService = LocationService.shared
    
    // MARK: - Device ID
    private let deviceId: String = {
        if let saved = UserDefaults.standard.string(forKey: "device_id") {
            return saved
        }
        let newId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        UserDefaults.standard.set(newId, forKey: "device_id")
        return newId
    }()
    
    // MARK: - Methods
    func checkin(moodLevel: Int, tags: [String] = [], note: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let location = await locationService.getCurrentLocation()
        
        let request = MoodCheckinRequest(
            deviceId: deviceId,
            moodLevel: moodLevel,
            tags: tags.isEmpty ? nil : tags,
            note: note,
            latitude: location?.latitude,
            longitude: location?.longitude,
            cityCode: location?.cityCode
        )
        
        do {
            let response: APIResponse<[String: String]> = try await apiService.post(
                endpoint: "/moods",
                body: request
            )
            
            if response.code == 201 {
                await fetchRecentMoods()
            } else {
                await MainActor.run {
                    errorMessage = response.message
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func fetchRecentMoods() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response: APIResponse<[MoodRecord]> = try await apiService.get(
                endpoint: "/moods?device_id=\(deviceId)&limit=30"
            )
            
            if let data = response.data {
                await MainActor.run {
                    self.recentMoods = data
                    self.todayMood = data.first { record in
                        Calendar.current.isDateInToday(
                            ISO8601DateFormatter().date(from: record.createdAt) ?? Date()
                        )
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func fetchCityMood(cityCode: String) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response: APIResponse<CityMood> = try await apiService.get(
                endpoint: "/cities/\(cityCode)/mood"
            )
            
            if let data = response.data {
                await MainActor.run {
                    if let index = self.cityMoods.firstIndex(where: { $0.cityCode == cityCode }) {
                        self.cityMoods[index] = data
                    } else {
                        self.cityMoods.append(data)
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}
