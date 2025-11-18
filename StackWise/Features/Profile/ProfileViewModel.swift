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
    @Published var showExportSuccess = false
    @Published var showEditProfile = false
    @Published var showPasswordReset = false
    @Published var isLoading = false
    
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
    
    func updateBudget(_ newBudget: Double) {
        user?.budgetPerMonth = newBudget
        container.currentUser = user
        // TODO: Trigger stack regeneration with new budget
    }
    
    func toggleDietaryPreference(_ preference: DietaryPreference) {
        guard var user = user else { return }
        
        if user.dietaryPreferences.contains(preference) {
            user.dietaryPreferences.remove(preference)
        } else {
            user.dietaryPreferences.insert(preference)
        }
        
        self.user = user
        container.currentUser = user
    }
    
    func exportPDF() async {
        guard let stack = stack, let user = user else { return }
        
        isLoading = true
        
        do {
            let url = try await container.exportService.generateRegimenPDF(
                stack: stack,
                user: user
            )
            // In a real app, you'd present a share sheet here
            showExportSuccess = true
            print("PDF exported to: \(url)")
        } catch {
            print("Failed to export PDF: \(error)")
        }
        
        isLoading = false
    }
    
    func exportCalendar() async {
        isLoading = true
        
        do {
            let reminders = try await container.scheduleService.getReminders()
            let url = try await container.exportService.generateCalendarICS(
                reminders: reminders
            )
            // In a real app, you'd present a share sheet here
            showExportSuccess = true
            print("Calendar exported to: \(url)")
        } catch {
            print("Failed to export calendar: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        // Clear all data
        do {
            try await container.signOut()
        } catch {
            print("Failed to delete account: \(error)")
        }
    }
    
    func signOut() async {
        do {
            try await container.signOut()
        } catch {
            print("Failed to sign out: \(error)")
        }
    }
}
