import Foundation

// MARK: - AuthService Protocol
public protocol AuthService {
    // Apple Sign In
    func signInApple() async throws -> User
    
    // Email/Phone + Password Authentication
    func signInEmail(email: String, password: String) async throws -> User
    func signInPhone(phoneNumber: String, password: String) async throws -> User
    func signUpEmail(name: String, email: String, password: String, firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User
    
    // Verification Code Methods
    func sendVerificationCode(email: String?, phoneNumber: String?, purpose: String) async throws -> SendCodeResponse
    func verifyCode(email: String?, phoneNumber: String?, code: String, purpose: String) async throws -> AuthResponse?
    
    // Password Reset
    func resetPassword(email: String?, phoneNumber: String?, code: String, newPassword: String) async throws
    
    // Profile Management
    func updateProfile(firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User
    
    // Session Management
    func signOut() async throws
    func currentUser() -> User?
}
