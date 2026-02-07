import Foundation

class APIService {
    static let shared = APIService()
    
    // MARK: - Configuration
    #if DEBUG
    private let baseURL = "http://localhost:3000/api/v1"
    #else
    private let baseURL = "https://api.citymood.app/api/v1"
    #endif
    
    private init() {}
    
    // MARK: - Generic Request
    func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> APIResponse<T> {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        return decoded
    }
    
    // MARK: - Convenience Methods
    func get<T: Codable>(endpoint: String) async throws -> APIResponse<T> {
        try await request(endpoint: endpoint, method: "GET")
    }
    
    func post<T: Codable>(endpoint: String, body: Encodable) async throws -> APIResponse<T> {
        try await request(endpoint: endpoint, method: "POST", body: body)
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        }
    }
}
