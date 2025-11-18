import Foundation
import SwiftUI

// MARK: - ProfileEditViewModel
@MainActor
public class ProfileEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var email = ""
    @Published public var phoneNumber = ""
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var showError = false
    @Published public var errorMessage = ""
    @Published public var showSuccessMessage = false
    @Published public var successMessage = ""
    
    private let container: DIContainer
    private var originalUser: User?
    
    // MARK: - Initialization
    public init(container: DIContainer, user: User) {
        self.container = container
        self.originalUser = user
        
        // Populate fields from current user
        self.firstName = user.firstName ?? ""
        self.lastName = user.lastName ?? ""
        self.email = user.email ?? ""
        self.phoneNumber = formatPhoneForDisplay(user.phoneNumber ?? "")
    }
    
    // MARK: - Computed Properties
    public var hasChanges: Bool {
        guard let originalUser = originalUser else { return false }
        
        let currentPhoneFormatted = "+1" + phoneNumber.filter { $0.isNumber }
        
        return firstName != (originalUser.firstName ?? "") ||
               lastName != (originalUser.lastName ?? "") ||
               (phoneNumber.filter { $0.isNumber }.count >= 10 && currentPhoneFormatted != originalUser.phoneNumber)
    }
    
    public var isValid: Bool {
        // At least one contact method must be present
        let hasEmail = !email.isEmpty
        let hasPhone = phoneNumber.filter { $0.isNumber }.count >= 10
        
        return hasEmail || hasPhone
    }
    
    public var validationMessage: String? {
        if email.isEmpty && phoneNumber.filter { $0.isNumber }.count < 10 {
            return "At least one contact method (email or phone) is required"
        }
        return nil
    }
    
    // MARK: - Actions
    public func saveChanges() async {
        guard hasChanges else { return }
        
        isLoading = true
        error = nil
        showError = false
        showSuccessMessage = false
        
        do {
            // Prepare phone number for API (E.164 format)
            let phoneToSend: String?
            if phoneNumber.filter { $0.isNumber }.count >= 10 {
                phoneToSend = "+1" + phoneNumber.filter { $0.isNumber }
            } else {
                phoneToSend = nil
            }
            
            // Call update profile API
            let updatedUser = try await container.services.authService.updateProfile(
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                phoneNumber: phoneToSend
            )
            
            // Update container with new user data
            container.currentUser = updatedUser
            originalUser = updatedUser
            
            // Update local fields with response
            self.firstName = updatedUser.firstName ?? ""
            self.lastName = updatedUser.lastName ?? ""
            self.email = updatedUser.email ?? ""
            self.phoneNumber = formatPhoneForDisplay(updatedUser.phoneNumber ?? "")
            
            successMessage = "Profile updated successfully"
            showSuccessMessage = true
            
            // Hide success message after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            showSuccessMessage = false
            
        } catch {
            self.error = error
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Failed to update profile. Please try again."
            }
            showError = true
        }
        
        isLoading = false
    }
    
    public func formatPhoneNumber(_ value: String) -> String {
        // Remove all non-digit characters
        let digits = value.filter { $0.isNumber }
        
        // Limit to 10 digits
        let limited = String(digits.prefix(10))
        
        // Format as (XXX) XXX-XXXX
        var formatted = ""
        for (index, character) in limited.enumerated() {
            if index == 0 {
                formatted += "("
            } else if index == 3 {
                formatted += ") "
            } else if index == 6 {
                formatted += "-"
            }
            formatted.append(character)
        }
        
        return formatted
    }
    
    // MARK: - Private Helpers
    private func formatPhoneForDisplay(_ phone: String) -> String {
        // Remove country code if present
        let digits = phone.replacingOccurrences(of: "+1", with: "").filter { $0.isNumber }
        
        // Format for display
        return formatPhoneNumber(digits)
    }
}
