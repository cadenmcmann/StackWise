import Foundation

// MARK: - MockAuthService
public class MockAuthService: AuthService {
    private var _currentUser: User?
    
    public init(currentUser: User? = nil) {
        self._currentUser = currentUser
    }
    
    public func signInApple() async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let user = User(
            age: 28,
            sex: .male,
            height: 175,
            weight: 75,
            bodyFat: 18,
            stimulantTolerance: .medium,
            budgetPerMonth: 150,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    public func signInEmail(email: String, password: String) async throws -> User {
        // Mock implementation - accept any email/password
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create a user with the provided email
        let user = User(
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            bodyFat: nil,
            stimulantTolerance: .medium,
            budgetPerMonth: 100,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    public func signUpEmail(name: String, email: String, password: String) async throws -> User {
        // Mock implementation - accept any signup
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create a new user
        let user = User(
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            bodyFat: nil,
            stimulantTolerance: .medium,
            budgetPerMonth: 100,
            dietaryPreferences: []
        )
        _currentUser = user
        return user
    }
    
    public func signOut() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        _currentUser = nil
    }
    
    public func currentUser() -> User? {
        return _currentUser
    }
}
