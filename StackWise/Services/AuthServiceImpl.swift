import Foundation
import AuthenticationServices

// MARK: - AuthServiceImpl
public class AuthServiceImpl: AuthService {
    private let networkManager = NetworkManager.shared
    private var _currentUser: User?
    private let appleSignInManager = AppleSignInManager()
    
    public init() {
        // Check if we have a stored user
        loadStoredUser()
    }
    
    // MARK: - Apple Sign In
    
    public func signInApple() async throws -> User {
        // Get Apple credentials using AppleSignInManager
        let credentials = try await appleSignInManager.startSignIn()
        return try await signInApple(
            identityToken: credentials.identityToken,
            authorizationCode: credentials.authorizationCode,
            email: credentials.email
        )
    }

    public func signInApple(identityToken: String, authorizationCode: String?, email: String?) async throws -> User {
        let request = AppleSignInRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            email: email
        )

        let encoder = JSONEncoder()
        let rawBodyData = try encoder.encode(request)

        do {
            let response = try await networkManager.request(
                endpoint: "auth/apple",
                method: "POST",
                rawBodyData: rawBodyData,
                requiresAuth: false,
                responseType: AuthResponse.self
            )
            
            // Store the token
            networkManager.setAuthToken(response.token)
            
            // Create user from API response and load preferences with retry
            let user = try await hydrateUserWithPreferences(from: response.user)
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            #if DEBUG
            print("Apple Sign In error: \(error)")
            #endif
            throw error
        }
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
            
            // Create user from API response and load preferences with retry
            let user = try await hydrateUserWithPreferences(from: response.user)
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            #if DEBUG
            print("Login error: \(error)")
            #endif
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
            
            // Create user from API response and load preferences with retry
            let user = try await hydrateUserWithPreferences(from: response.user)
            
            _currentUser = user
            storeUser(user)
            
            return user
        } catch {
            #if DEBUG
            print("Phone login error: \(error)")
            #endif
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
            #if DEBUG
            print("Signup error: \(error)")
            #endif
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
            #if DEBUG
            print("Send verification code error: \(error)")
            #endif
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
                
                // Create user from API response and load preferences with retry
                let user = try await hydrateUserWithPreferences(from: response.user)
                
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
            #if DEBUG
            print("Verify code error: \(error)")
            #endif
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
            #if DEBUG
            print("Reset password error: \(error)")
            #endif
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
            #if DEBUG
            print("Update profile error: \(error)")
            #endif
            throw error
        }
    }

    public func deleteAccount() async throws {
        _ = try await networkManager.request(
            endpoint: "users/deactivate",
            method: "POST",
            requiresAuth: true,
            responseType: DeactivateAccountResponse.self
        )
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
        SecureStorage.shared.setCodable(user, for: SecureStorageKeys.currentUser)
    }
    
    private func loadStoredUser() {
        if let user = SecureStorage.shared.getCodable(User.self, for: SecureStorageKeys.currentUser) {
            _currentUser = user
        }
    }
    
    private func clearStoredUser() {
        SecureStorage.shared.deleteValue(for: SecureStorageKeys.currentUser)
    }

    private func hydrateUserWithPreferences(from apiUser: APIUser) async throws -> User {
        var user = apiUser.toUser()
        var lastError: Error?

        for attempt in 1...2 {
            do {
                let preferencesResponse = try await networkManager.request(
                    endpoint: "preferences",
                    method: "GET",
                    requiresAuth: true,
                    responseType: PreferencesResponse.self
                )
                user = apiUser.toUser(withPreferences: preferencesResponse.preferences)
                return user
            } catch {
                if case NetworkError.apiError(_, let statusCode) = error, statusCode == 404 {
                    return user
                }
                if case NetworkError.httpError(let statusCode) = error, statusCode == 404 {
                    return user
                }

                lastError = error
                if attempt == 1 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }

        if let lastError {
            throw lastError
        }
        return user
    }
}

