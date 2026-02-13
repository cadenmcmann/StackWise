import Foundation
import SwiftUI

// MARK: - ProfileEditViewModel
@MainActor
public class ProfileEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var email = ""
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
    }
    
    // MARK: - Computed Properties
    public var hasChanges: Bool {
        guard let originalUser = originalUser else { return false }
        
        return firstName != (originalUser.firstName ?? "") ||
               lastName != (originalUser.lastName ?? "")
    }
    
    public var isValid: Bool {
        // At least email must be present (which we keep read-only)
        return !email.isEmpty
    }
    
    public var validationMessage: String? {
        if email.isEmpty {
            return "An email address is required"
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
            // Call update profile API
            let updatedUser = try await container.services.authService.updateProfile(
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                phoneNumber: nil
            )
            
            // Update container with new user data
            container.currentUser = updatedUser
            originalUser = updatedUser
            
            // Update local fields with response
            self.firstName = updatedUser.firstName ?? ""
            self.lastName = updatedUser.lastName ?? ""
            self.email = updatedUser.email ?? ""
            
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
}
