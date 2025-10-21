import Foundation

// MARK: - NetworkManager
public class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://xuy07kjq0b.execute-api.us-east-1.amazonaws.com/"
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
            UserDefaults.standard.string(forKey: "auth_token")
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: "auth_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "auth_token")
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
        requiresAuth: Bool = true,
        responseType: T.Type
    ) async throws -> T {
        var bodyData: Data? = nil
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            bodyData = try encoder.encode(body)
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
        
        // Check for errors
        if httpResponse.statusCode >= 400 {
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
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
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
