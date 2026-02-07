import Foundation
import CoreLocation

struct LocationData {
    let latitude: Double
    let longitude: Double
    let cityCode: String?
}

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<LocationData?, Never>?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func getCurrentLocation() async -> LocationData? {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return await waitForLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            return await waitForLocation()
        case .denied, .restricted:
            return nil
        @unknown default:
            return nil
        }
    }
    
    private func waitForLocation() async -> LocationData? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            
            // 超时处理
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if self?.continuation != nil {
                    self?.continuation?.resume(returning: nil)
                    self?.continuation = nil
                }
            }
        }
    }
    
    private func cityCodeFrom(location: CLLocation) -> String? {
        // 简化版：根据坐标粗略判断城市
        // 实际应该用地理编码服务
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        // 北京
        if lat >= 39.4 && lat <= 41.0 && lng >= 115.7 && lng <= 117.4 {
            return "BJ"
        }
        // 上海
        if lat >= 30.7 && lat <= 31.9 && lng >= 120.8 && lng <= 122.2 {
            return "SH"
        }
        // 广州
        if lat >= 22.8 && lat <= 24.0 && lng >= 112.9 && lng <= 114.5 {
            return "GZ"
        }
        // 深圳
        if lat >= 22.4 && lat <= 22.9 && lng >= 113.8 && lng <= 114.8 {
            return "SZ"
        }
        
        return nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            continuation?.resume(returning: nil)
            continuation = nil
            return
        }
        
        let data = LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            cityCode: cityCodeFrom(location: location)
        )
        
        continuation?.resume(returning: data)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 授权状态改变时重新请求位置
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
}
