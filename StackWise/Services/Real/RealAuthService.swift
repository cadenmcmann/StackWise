import Foundation

// MARK: - RealAuthService
public class RealAuthService: AuthService {
    private let networkManager = NetworkManager.shared
    private var _currentUser: User?
    
    public init() {
        // Check if we have a stored user
        loadStoredUser()
    }
    
    // MARK: - Apple Sign In
    
    public func signInApple() async throws -> User {
        // TODO: Implement real Apple Sign In
        throw NetworkError.apiError(message: "Apple Sign In not yet implemented", statusCode: 501)
    }
    
    // MARK: - Email/Phone + Password Authentication
    
    public func signInEmail(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, phoneNumber: nil, password: password)
        
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
            
            // Create user from API response and fetch preferences if available
            var user = response.user.toUser()
            
            // Try to fetch preferences
            if let preferencesResponse = try? await networkManager.request(
                endpoint: "preferences",
                method: "GET",
                requiresAuth: true,
                responseType: PreferencesResponse.self
            ) {
                user = response.user.toUser(withPreferences: preferencesResponse.preferences)
            }
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            print("Login error: \(error)")
            throw error
        }
    }
    
    public func signInPhone(phoneNumber: String, password: String) async throws -> User {
        let request = LoginRequest(email: nil, phoneNumber: phoneNumber, password: password)
        
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
            
            // Create user from API response and fetch preferences if available
            var user = response.user.toUser()
            
            // Try to fetch preferences
            if let preferencesResponse = try? await networkManager.request(
                endpoint: "preferences",
                method: "GET",
                requiresAuth: true,
                responseType: PreferencesResponse.self
            ) {
                user = response.user.toUser(withPreferences: preferencesResponse.preferences)
            }
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            print("Phone login error: \(error)")
            throw error
        }
    }
    
    public func signUpEmail(name: String, email: String, password: String, firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        let request = SignupRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        
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
            
            // Create user from API response
            let user = response.user.toUser()
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            print("Signup error: \(error)")
            throw error
        }
    }
    
    // MARK: - Verification Code Methods
    
    public func sendVerificationCode(email: String?, phoneNumber: String?, purpose: String) async throws -> SendCodeResponse {
        let request = SendCodeRequest(email: email, phoneNumber: phoneNumber, purpose: purpose)
        
        do {
            let response = try await networkManager.request(
                endpoint: "auth/send-code",
                method: "POST",
                body: request,
                requiresAuth: false,
                responseType: SendCodeResponse.self
            )
            
            return response
        } catch {
            print("Send verification code error: \(error)")
            throw error
        }
    }
    
    public func verifyCode(email: String?, phoneNumber: String?, code: String, purpose: String) async throws -> AuthResponse? {
        let request = VerifyCodeRequest(email: email, phoneNumber: phoneNumber, code: code, purpose: purpose)
        
        do {
            if purpose == "login" {
                // For login, we get full auth response
                let response = try await networkManager.request(
                    endpoint: "auth/verify-code",
                    method: "POST",
                    body: request,
                    requiresAuth: false,
                    responseType: AuthResponse.self
                )
                
                // Store the token
                networkManager.setAuthToken(response.token)
                
                // Create user from API response and fetch preferences if available
                var user = response.user.toUser()
                
                // Try to fetch preferences
                if let preferencesResponse = try? await networkManager.request(
                    endpoint: "preferences",
                    method: "GET",
                    requiresAuth: true,
                    responseType: PreferencesResponse.self
                ) {
                    user = response.user.toUser(withPreferences: preferencesResponse.preferences)
                }
                
                _currentUser = user
                storeUser(user)
                
                return response
            } else {
                // For password reset, we get a different response
                _ = try await networkManager.request(
                    endpoint: "auth/verify-code",
                    method: "POST",
                    body: request,
                    requiresAuth: false,
                    responseType: VerifyCodeResetResponse.self
                )
                
                // For password reset, we don't get an auth response
                return nil
            }
        } catch {
            print("Verify code error: \(error)")
            throw error
        }
    }
    
    // MARK: - Password Reset
    
    public func resetPassword(email: String?, phoneNumber: String?, code: String, newPassword: String) async throws {
        let request = ResetPasswordRequest(
            email: email,
            phoneNumber: phoneNumber,
            code: code,
            newPassword: newPassword
        )
        
        do {
            _ = try await networkManager.request(
                endpoint: "auth/reset-password",
                method: "POST",
                body: request,
                requiresAuth: false,
                responseType: ResetPasswordResponse.self
            )
        } catch {
            print("Reset password error: \(error)")
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    public func updateProfile(firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        let request = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        
        do {
            let response = try await networkManager.request(
                endpoint: "users/profile",
                method: "PATCH",
                body: request,
                requiresAuth: true,
                responseType: UpdateProfileResponse.self
            )
            
            // Update current user with new profile info
            if var user = _currentUser {
                user.firstName = response.user.firstName
                user.lastName = response.user.lastName
                user.phoneNumber = response.user.phoneNumber
                user.email = response.user.email
                
                _currentUser = user
                storeUser(user)
                
                return user
            } else {
                // If no current user, create from response
                let user = response.user.toUser()
                _currentUser = user
                storeUser(user)
                return user
            }
        } catch {
            print("Update profile error: \(error)")
            throw error
        }
    }
    
    // MARK: - Session Management
    
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
