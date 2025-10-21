import Foundation

// MARK: - AuthService Protocol
public protocol AuthService {
    func signInApple() async throws -> User
    func signInEmail(email: String, password: String) async throws -> User
    func signUpEmail(name: String, email: String, password: String) async throws -> User
    func signOut() async throws
    func currentUser() -> User?
}
