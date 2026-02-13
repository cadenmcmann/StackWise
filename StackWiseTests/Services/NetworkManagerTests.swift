import Testing
import Foundation
@testable import StackWise

@Suite("NetworkManager Tests")
struct NetworkManagerTests {
    
    // MARK: - NetworkError Tests
    
    @Test("NetworkError.invalidURL has correct description")
    func invalidURLDescription() {
        let error = NetworkError.invalidURL
        #expect(error.errorDescription == "Invalid URL")
    }
    
    @Test("NetworkError.invalidResponse has correct description")
    func invalidResponseDescription() {
        let error = NetworkError.invalidResponse
        #expect(error.errorDescription == "Invalid server response")
    }
    
    @Test("NetworkError.apiError includes message")
    func apiErrorDescription() {
        let error = NetworkError.apiError(message: "User not found", statusCode: 404)
        #expect(error.errorDescription == "User not found")
    }
    
    @Test("NetworkError.httpError includes status code")
    func httpErrorDescription() {
        let error = NetworkError.httpError(statusCode: 500)
        #expect(error.errorDescription == "HTTP Error: 500")
    }
    
    @Test("NetworkError.decodingError includes error info")
    func decodingErrorDescription() {
        struct TestModel: Codable {
            let value: Int
        }
        
        let invalidJSON = "not json".data(using: .utf8)!
        do {
            _ = try JSONDecoder().decode(TestModel.self, from: invalidJSON)
        } catch let decodingErr {
            let error = NetworkError.decodingError(decodingErr)
            #expect(error.errorDescription?.contains("Data error") == true)
        }
    }
    
    @Test("NetworkError.noAuthToken has correct description")
    func noAuthTokenDescription() {
        let error = NetworkError.noAuthToken
        #expect(error.errorDescription == "Authentication required")
    }
    
    // MARK: - Token Management Tests
    // Note: These tests use the shared singleton and UserDefaults,
    // so they must clean up after themselves
    
    @Test("Token management lifecycle works correctly")
    func tokenManagementLifecycle() {
        let manager = NetworkManager.shared
        
        // Clean state
        manager.clearAuthToken()
        #expect(manager.hasValidToken() == false)
        
        // Set a token
        manager.setAuthToken("test-token-lifecycle")
        #expect(manager.hasValidToken() == true)
        
        // Clear the token
        manager.clearAuthToken()
        #expect(manager.hasValidToken() == false)
    }
    
    // MARK: - Error Conformance Tests
    
    @Test("NetworkError conforms to LocalizedError")
    func errorConformsToLocalizedError() {
        let error: LocalizedError = NetworkError.invalidURL
        #expect(error.errorDescription != nil)
    }
    
    @Test("All NetworkError cases have non-nil errorDescription")
    func allErrorsHaveDescriptions() {
        let errors: [NetworkError] = [
            .invalidURL,
            .invalidResponse,
            .apiError(message: "test", statusCode: 400),
            .httpError(statusCode: 500),
            .decodingError(NSError(domain: "test", code: 0)),
            .noAuthToken
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil, "Error \(error) should have description")
        }
    }
    
    // MARK: - HTTP Status Code Tests
    
    @Test("httpError preserves status code in description")
    func httpErrorStatusCodes() {
        let statusCodes = [400, 401, 403, 404, 500, 502, 503]
        
        for code in statusCodes {
            let error = NetworkError.httpError(statusCode: code)
            #expect(error.errorDescription?.contains("\(code)") == true)
        }
    }
    
    @Test("apiError preserves custom message")
    func apiErrorPreservesMessage() {
        let testMessages = [
            "Invalid credentials",
            "Session expired",
            "Resource not found",
            "Server error occurred"
        ]
        
        for message in testMessages {
            let error = NetworkError.apiError(message: message, statusCode: 400)
            #expect(error.errorDescription == message)
        }
    }
}

