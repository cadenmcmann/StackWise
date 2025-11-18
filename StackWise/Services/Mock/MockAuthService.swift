import Foundation

// MARK: - MockAuthService
public class MockAuthService: AuthService {
    private var _currentUser: User?
    private var verificationCodes: [String: String] = [:] // Store sent codes for verification
    
    public init(currentUser: User? = nil) {
        self._currentUser = currentUser
    }
    
    // MARK: - Apple Sign In
    
    public func signInApple() async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let user = User(
            id: UUID().uuidString,
            email: "apple.user@icloud.com",
            phoneNumber: nil,
            firstName: "Apple",
            lastName: "User",
            createdAt: Date(),
            age: 28,
            sex: .male,
            height: 175,
            weight: 75,
            bodyFat: 18,
            stimulantTolerance: .moderate,
            budgetPerMonth: 150,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    // MARK: - Email/Phone + Password Authentication
    
    public func signInEmail(email: String, password: String) async throws -> User {
        // Mock implementation - accept any email/password
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create a user with the provided email
        let user = User(
            id: UUID().uuidString,
            email: email,
            phoneNumber: nil,
            firstName: nil,
            lastName: nil,
            createdAt: Date(),
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            bodyFat: nil,
            stimulantTolerance: .moderate,
            budgetPerMonth: 100,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    public func signInPhone(phoneNumber: String, password: String) async throws -> User {
        // Mock implementation - accept any phone/password
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create a user with the provided phone
        let user = User(
            id: UUID().uuidString,
            email: nil,
            phoneNumber: phoneNumber,
            firstName: nil,
            lastName: nil,
            createdAt: Date(),
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            bodyFat: nil,
            stimulantTolerance: .moderate,
            budgetPerMonth: 100,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    public func signUpEmail(name: String, email: String, password: String, firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        // Mock implementation - accept any signup
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create a new user
        let user = User(
            id: UUID().uuidString,
            email: email,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            createdAt: Date(),
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            bodyFat: nil,
            stimulantTolerance: .moderate,
            budgetPerMonth: 100,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    // MARK: - Verification Code Methods
    
    public func sendVerificationCode(email: String?, phoneNumber: String?, purpose: String) async throws -> SendCodeResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate a mock verification code
        let code = String(format: "%06d", arc4random_uniform(1000000))
        
        // Store the code for later verification
        let key = (email ?? phoneNumber ?? "") + "_" + purpose
        verificationCodes[key] = code
        
        // In real app, this would be sent via SMS/email
        print("Mock verification code: \(code)")
        
        return SendCodeResponse(
            success: true,
            message: "Verification code sent",
            deliveryMethod: email != nil ? "email" : "sms"
        )
    }
    
    public func verifyCode(email: String?, phoneNumber: String?, code: String, purpose: String) async throws -> AuthResponse? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let key = (email ?? phoneNumber ?? "") + "_" + purpose
        
        // Check if code matches (in mock, also accept "123456" for easy testing)
        if code == verificationCodes[key] || code == "123456" {
            if purpose == "login" {
                // Create a logged in user
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    phoneNumber: phoneNumber,
                    firstName: nil,
                    lastName: nil,
                    createdAt: Date(),
                    age: 25,
                    sex: .other,
                    height: 170,
                    weight: 70,
                    bodyFat: nil,
                    stimulantTolerance: .moderate,
                    budgetPerMonth: 100,
                    dietaryPreferences: []
                )
                _currentUser = user
                
                return AuthResponse(
                    token: "mock_token_\(UUID().uuidString)",
                    user: APIUser(
                        id: user.id,
                        email: user.email,
                        phoneNumber: user.phoneNumber,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        createdAt: ISO8601DateFormatter().string(from: user.createdAt ?? Date())
                    ),
                    hasActiveStack: false,
                    needsOnboarding: true
                )
            } else {
                // For password reset, no auth response
                return nil
            }
        } else {
            throw NetworkError.apiError(message: "Invalid verification code", statusCode: 401)
        }
    }
    
    // MARK: - Password Reset
    
    public func resetPassword(email: String?, phoneNumber: String?, code: String, newPassword: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // In mock, just verify the code
        let key = (email ?? phoneNumber ?? "") + "_password_reset"
        
        if code == verificationCodes[key] || code == "123456" {
            // Password reset successful
            print("Mock: Password reset successful")
        } else {
            throw NetworkError.apiError(message: "Invalid verification code", statusCode: 401)
        }
    }
    
    // MARK: - Profile Management
    
    public func updateProfile(firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        guard var user = _currentUser else {
            throw NetworkError.apiError(message: "Not authenticated", statusCode: 401)
        }
        
        // Update user fields
        if let firstName = firstName {
            user.firstName = firstName
        }
        if let lastName = lastName {
            user.lastName = lastName
        }
        if let phoneNumber = phoneNumber {
            user.phoneNumber = phoneNumber
        }
        
        _currentUser = user
        return user
    }
    
    // MARK: - Session Management
    
    public func signOut() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        _currentUser = nil
        verificationCodes.removeAll()
    }
    
    public func currentUser() -> User? {
        return _currentUser
    }
}
