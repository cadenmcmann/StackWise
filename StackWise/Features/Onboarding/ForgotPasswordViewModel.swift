import Foundation
import SwiftUI

// MARK: - ForgotPasswordStep
public enum ForgotPasswordStep {
    case contactInput
    case verifyCode
    case newPassword
    case success
}

// MARK: - ForgotPasswordViewModel
@MainActor
public class ForgotPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var currentStep = ForgotPasswordStep.contactInput
    @Published public var email = ""
    @Published public var verificationCode = ""
    @Published public var newPassword = ""
    @Published public var confirmPassword = ""
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var showError = false
    @Published public var errorMessage = ""
    
    // Skip password flow
    @Published public var shouldSkipPasswordReset = false
    
    private let container: DIContainer
    
    // MARK: - Initialization
    public init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - Computed Properties
    public var isContactValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    public var isPasswordValid: Bool {
        newPassword.count >= 8 && passwordsMatch
    }
    
    // MARK: - Actions
    public func sendVerificationCode() async {
        isLoading = true
        error = nil
        showError = false
        
        do {
            let response = try await container.services.authService.sendVerificationCode(
                email: email,
                phoneNumber: nil,
                purpose: "password_reset"
            )
            
            if response.success {
                withAnimation(Theme.Animation.standard) {
                    currentStep = .verifyCode
                }
            } else {
                errorMessage = response.message
                showError = true
            }
        } catch {
            self.error = error
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Failed to send verification code. Please try again."
            }
            showError = true
        }
        
        isLoading = false
    }
    
    public func resendCode() async {
        // Don't reset step, just resend
        isLoading = true
        
        do {
            let response = try await container.services.authService.sendVerificationCode(
                email: email,
                phoneNumber: nil,
                purpose: "password_reset"
            )
            
            if response.success {
                // CountdownTimer component handles its own state reset
            }
        } catch {
            // Silently fail for resend
            #if DEBUG
            print("Resend failed: \(error)")
            #endif
        }
        
        isLoading = false
    }
    
    public func verifyCode() async {
        isLoading = true
        error = nil
        showError = false
        
        do {
            _ = try await container.services.authService.verifyCode(
                email: email,
                phoneNumber: nil,
                code: verificationCode,
                purpose: "password_reset"
            )
            
            // Code verified successfully
            withAnimation(Theme.Animation.standard) {
                currentStep = .newPassword
            }
        } catch {
            self.error = error
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Invalid verification code. Please try again."
            }
            showError = true
        }
        
        isLoading = false
    }
    
    public func skipAndLogin() async {
        // Use the verified code to login
        isLoading = true
        error = nil
        showError = false
        
        do {
            let authResponse = try await container.services.authService.verifyCode(
                email: email,
                phoneNumber: nil,
                code: verificationCode,
                purpose: "login"
            )
            
            if authResponse != nil {
                // Successfully logged in
                shouldSkipPasswordReset = true
                withAnimation(Theme.Animation.standard) {
                    currentStep = .success
                }
            }
        } catch {
            self.error = error
            errorMessage = "Failed to log in with verification code."
            showError = true
        }
        
        isLoading = false
    }
    
    public func resetPassword() async {
        isLoading = true
        error = nil
        showError = false
        
        do {
            try await container.services.authService.resetPassword(
                email: email,
                phoneNumber: nil,
                code: verificationCode,
                newPassword: newPassword
            )
            
            // Password reset successful
            withAnimation(Theme.Animation.standard) {
                currentStep = .success
            }
        } catch {
            self.error = error
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Failed to reset password. Please try again."
            }
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation
    public func goBack() {
        withAnimation(Theme.Animation.standard) {
            switch currentStep {
            case .contactInput:
                break // Can't go back from first step
            case .verifyCode:
                currentStep = .contactInput
                verificationCode = ""
            case .newPassword:
                currentStep = .verifyCode
                newPassword = ""
                confirmPassword = ""
            case .success:
                break // Can't go back from success
            }
        }
    }
    
    public func reset() {
        currentStep = .contactInput
        email = ""
        verificationCode = ""
        newPassword = ""
        confirmPassword = ""
        isLoading = false
        error = nil
        showError = false
        errorMessage = ""
        shouldSkipPasswordReset = false
    }
}
