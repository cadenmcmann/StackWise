import Foundation

// MARK: - NetworkManager
public class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = AppConfig.apiBaseURL
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Token Management
    
    private var authToken: String? {
        get {
            SecureStorage.shared.getString(for: SecureStorageKeys.authToken)
        }
        set {
            if let token = newValue {
                SecureStorage.shared.setString(token, for: SecureStorageKeys.authToken)
            } else {
                SecureStorage.shared.deleteValue(for: SecureStorageKeys.authToken)
            }
        }
    }
    
    public func setAuthToken(_ token: String?) {
        authToken = token
    }
    
    public func clearAuthToken() {
        authToken = nil
    }
    
    public func hasValidToken() -> Bool {
        return authToken != nil
    }
    
    // MARK: - Request Building
    
    private func buildRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        
        return request
    }
    
    // MARK: - Generic Request Method
    
    public func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        rawBodyData: Data? = nil,
        requiresAuth: Bool = true,
        responseType: T.Type
    ) async throws -> T {
        var bodyData: Data? = nil
        
        // Use rawBodyData if provided (bypasses snake_case encoding)
        // Otherwise encode the body with snake_case strategy
        if let rawData = rawBodyData {
            bodyData = rawData
            
            // Debug logging
            #if DEBUG
            if let jsonString = String(data: rawData, encoding: .utf8) {
                print("📤 \(method) \(endpoint)")
                print("📦 Request body (raw): \(jsonString)")
            }
            #endif
        } else if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            bodyData = try encoder.encode(body)
            
            // Debug logging
            #if DEBUG
            if let jsonString = String(data: bodyData!, encoding: .utf8) {
                print("📤 \(method) \(endpoint)")
                print("📦 Request body: \(jsonString)")
            }
            #endif
        }
        
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: bodyData,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Debug logging for responses
        #if DEBUG
        print("📥 Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Response body: \(responseString)")
        }
        #endif
        
        // Check for errors
        if httpResponse.statusCode >= 400 {
            if requiresAuth && httpResponse.statusCode == 401 {
                clearAuthToken()
                NotificationCenter.default.post(name: .authTokenExpired, object: nil)
            }

            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.apiError(message: errorResponse.error, statusCode: httpResponse.statusCode)
            } else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        // Decode successful response
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            #endif
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Network Error

public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(message: String, statusCode: Int)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noAuthToken
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .apiError(let message, _):
            return message
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .noAuthToken:
            return "Authentication required"
        }
    }
}

// MARK: - Response Models

struct ErrorResponse: Codable {
    let error: String
}

extension Notification.Name {
    static let authTokenExpired = Notification.Name("NetworkManagerAuthTokenExpired")
}
