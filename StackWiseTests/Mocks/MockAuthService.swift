import Foundation
@testable import StackWise

// MARK: - MockAuthService
final class MockAuthService: AuthService {
    
    // MARK: - Call Tracking
    var signInAppleCallCount = 0
    var signInAppleWithTokenCallCount = 0
    var signInEmailCallCount = 0
    var signInPhoneCallCount = 0
    var signUpEmailCallCount = 0
    var sendVerificationCodeCallCount = 0
    var verifyCodeCallCount = 0
    var resetPasswordCallCount = 0
    var updateProfileCallCount = 0
    var deleteAccountCallCount = 0
    var signOutCallCount = 0
    
    // MARK: - Captured Parameters
    var lastEmail: String?
    var lastPassword: String?
    var lastPhoneNumber: String?
    var lastFirstName: String?
    var lastLastName: String?
    var lastPurpose: String?
    var lastCode: String?
    var lastNewPassword: String?
    
    // MARK: - Configured Responses
    var userToReturn: User?
    var sendCodeResponseToReturn: SendCodeResponse?
    var authResponseToReturn: AuthResponse?
    var errorToThrow: Error?
    var currentUserValue: User?
    
    // MARK: - AuthService Implementation
    
    func signInApple() async throws -> User {
        signInAppleCallCount += 1
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }

    func signInApple(identityToken: String, authorizationCode: String?, email: String?) async throws -> User {
        signInAppleWithTokenCallCount += 1
        lastEmail = email
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }
    
    func signInEmail(email: String, password: String) async throws -> User {
        signInEmailCallCount += 1
        lastEmail = email
        lastPassword = password
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }
    
    func signInPhone(phoneNumber: String, password: String) async throws -> User {
        signInPhoneCallCount += 1
        lastPhoneNumber = phoneNumber
        lastPassword = password
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }
    
    func signUpEmail(name: String, email: String, password: String, firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        signUpEmailCallCount += 1
        lastEmail = email
        lastPassword = password
        lastFirstName = firstName
        lastLastName = lastName
        lastPhoneNumber = phoneNumber
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }
    
    func sendVerificationCode(email: String?, phoneNumber: String?, purpose: String) async throws -> SendCodeResponse {
        sendVerificationCodeCallCount += 1
        lastEmail = email
        lastPhoneNumber = phoneNumber
        lastPurpose = purpose
        if let error = errorToThrow { throw error }
        guard let response = sendCodeResponseToReturn else {
            throw MockError.notConfigured
        }
        return response
    }
    
    func verifyCode(email: String?, phoneNumber: String?, code: String, purpose: String) async throws -> AuthResponse? {
        verifyCodeCallCount += 1
        lastEmail = email
        lastPhoneNumber = phoneNumber
        lastCode = code
        lastPurpose = purpose
        if let error = errorToThrow { throw error }
        return authResponseToReturn
    }
    
    func resetPassword(email: String?, phoneNumber: String?, code: String, newPassword: String) async throws {
        resetPasswordCallCount += 1
        lastEmail = email
        lastPhoneNumber = phoneNumber
        lastCode = code
        lastNewPassword = newPassword
        if let error = errorToThrow { throw error }
    }
    
    func updateProfile(firstName: String?, lastName: String?, phoneNumber: String?) async throws -> User {
        updateProfileCallCount += 1
        lastFirstName = firstName
        lastLastName = lastName
        lastPhoneNumber = phoneNumber
        if let error = errorToThrow { throw error }
        guard let user = userToReturn else {
            throw MockError.notConfigured
        }
        return user
    }

    func deleteAccount() async throws {
        deleteAccountCallCount += 1
        if let error = errorToThrow { throw error }
    }
    
    func signOut() async throws {
        signOutCallCount += 1
        if let error = errorToThrow { throw error }
        currentUserValue = nil
    }
    
    func currentUser() -> User? {
        return currentUserValue
    }
    
    // MARK: - Helper
    func reset() {
        signInAppleCallCount = 0
        signInAppleWithTokenCallCount = 0
        signInEmailCallCount = 0
        signInPhoneCallCount = 0
        signUpEmailCallCount = 0
        sendVerificationCodeCallCount = 0
        verifyCodeCallCount = 0
        resetPasswordCallCount = 0
        updateProfileCallCount = 0
        deleteAccountCallCount = 0
        signOutCallCount = 0
        
        lastEmail = nil
        lastPassword = nil
        lastPhoneNumber = nil
        lastFirstName = nil
        lastLastName = nil
        lastPurpose = nil
        lastCode = nil
        lastNewPassword = nil
        
        userToReturn = nil
        sendCodeResponseToReturn = nil
        authResponseToReturn = nil
        errorToThrow = nil
        currentUserValue = nil
    }
}

// MARK: - MockError
enum MockError: Error {
    case notConfigured
    case simulatedError
}

