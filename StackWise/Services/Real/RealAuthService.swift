import Foundation

// MARK: - RealAuthService
public class RealAuthService: AuthService {
    private let networkManager = NetworkManager.shared
    private var _currentUser: User?
    
    public init() {
        // Check if we have a stored user
        loadStoredUser()
    }
    
    public func signInApple() async throws -> User {
        // TODO: Implement real Apple Sign In
        throw NetworkError.apiError(message: "Apple Sign In not yet implemented", statusCode: 501)
    }
    
    public func signInEmail(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        
        do {
            let response = try await networkManager.request(
                endpoint: "auth/login",
                method: "POST",
                body: request,
                requiresAuth: false,
                responseType: AuthResponse.self
            )
            
            // Store the token
            networkManager.setAuthToken(response.token)
            
            // Create and store user
            let user = User(
                id: response.user.id,
                age: 25, // Will be updated from preferences
                sex: .other,
                height: 170,
                weight: 70,
                stimulantTolerance: .medium,
                budgetPerMonth: 100,
                dietaryPreferences: []
            )
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            print("Login error: \(error)")
            throw error
        }
    }
    
    public func signUpEmail(name: String, email: String, password: String) async throws -> User {
        let request = SignupRequest(email: email, password: password)
        
        do {
            let response = try await networkManager.request(
                endpoint: "auth/signup",
                method: "POST",
                body: request,
                requiresAuth: false,
                responseType: AuthResponse.self
            )
            
            // Store the token
            networkManager.setAuthToken(response.token)
            
            // Create and store user
            let user = User(
                id: response.user.id,
                age: 25, // Will be updated in onboarding
                sex: .other,
                height: 170,
                weight: 70,
                stimulantTolerance: .medium,
                budgetPerMonth: 100,
                dietaryPreferences: []
            )
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            print("Signup error: \(error)")
            throw error
        }
    }
    
    public func signOut() async throws {
        networkManager.clearAuthToken()
        _currentUser = nil
        clearStoredUser()
    }
    
    public func currentUser() -> User? {
        return _currentUser
    }
    
    // MARK: - Persistence Helpers
    
    private func storeUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "current_user")
        }
    }
    
    private func loadStoredUser() {
        if let data = UserDefaults.standard.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            _currentUser = user
        }
    }
    
    private func clearStoredUser() {
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}
