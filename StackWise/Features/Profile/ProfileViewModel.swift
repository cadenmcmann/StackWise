import Foundation
import SwiftUI

// MARK: - ProfileViewModel
@MainActor
public class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var stack: Stack?
    @Published var athleteMode = false
    @Published var visibleSupplementIds: Set<String> = []
    @Published var showDeleteAccountAlert = false
    @Published var showDeleteAccountSuccessAlert = false
    @Published var showDeleteAccountErrorAlert = false
    @Published var showSignOutAlert = false
    @Published var showEditProfile = false
    @Published var showPasswordReset = false
    @Published var isLoading = false
    @Published var deleteAccountSuccessMessage = ""
    @Published var deleteAccountErrorMessage = ""
    
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
        self.user = container.currentUser
        self.stack = container.currentStack
        
        // Initialize all supplements as visible
        if let stack = stack {
            visibleSupplementIds = Set(stack.allSupplements.map { $0.id })
        }
    }
    
    // MARK: - Actions
    
    func loadUserData() {
        self.user = container.currentUser
        self.stack = container.currentStack
        
        // Initialize all supplements as visible
        if let stack = stack {
            visibleSupplementIds = Set(stack.allSupplements.map { $0.id })
        }
    }
    
    func toggleSupplementVisibility(_ supplementId: String) {
        if visibleSupplementIds.contains(supplementId) {
            visibleSupplementIds.remove(supplementId)
        } else {
            visibleSupplementIds.insert(supplementId)
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        do {
            try await container.authService.deleteAccount()
            deleteAccountSuccessMessage = "Your account has been deactivated. It will be permanently deleted after 7 days. This action cannot be undone."
            showDeleteAccountSuccessAlert = true
        } catch {
            if let networkError = error as? NetworkError {
                deleteAccountErrorMessage = networkError.localizedDescription
            } else {
                deleteAccountErrorMessage = "Failed to deactivate your account. Please try again."
            }
            showDeleteAccountErrorAlert = true
            #if DEBUG
            print("Failed to delete account: \(error)")
            #endif
        }
        isLoading = false
    }

    func completeAccountDeletionSignOut() async {
        isLoading = true
        do {
            try await container.signOut()
        } catch {
            #if DEBUG
            print("Failed to complete account deletion sign out: \(error)")
            #endif
        }
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        do {
            try await container.signOut()
        } catch {
            #if DEBUG
            print("Failed to sign out: \(error)")
            #endif
        }
        isLoading = false
    }
}
