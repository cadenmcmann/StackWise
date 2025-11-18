import Foundation
import SwiftUI

// MARK: - StackViewModel
@MainActor
public class StackViewModel: ObservableObject {
    @Published var stack: Stack?
    @Published var isLoading = false
    @Published var showRemixConfirmation = false
    
    private let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
        self.stack = container.currentStack
        
        // Load current stack if not already loaded
        if stack == nil {
            Task {
                await loadStack()
            }
        }
    }
    
    // MARK: - Actions
    
    func startRemixFlow() async {
        // Fetch current user preferences to pre-fill the onboarding
        do {
            let preferences = try await container.preferencesService.fetchPreferences()
            
            // Set all flags together on main actor to avoid race conditions
            await MainActor.run {
                container.remixIntake = preferences
                container.isRemixFlow = true
                container.onboardingCompleted = false
            }
        } catch {
            print("Failed to fetch preferences for remix: \(error)")
            // If we can't fetch preferences, still allow remix with empty intake
            await MainActor.run {
                container.remixIntake = nil
                container.isRemixFlow = true
                container.onboardingCompleted = false
            }
        }
    }
    
    func exportStack() async -> URL? {
        guard let stack = stack,
              let user = container.currentUser else { return nil }
        
        do {
            return try await container.exportService.generateRegimenPDF(
                stack: stack,
                user: user
            )
        } catch {
            print("Failed to export stack: \(error)")
            return nil
        }
    }
    
    func loadStack() async {
        isLoading = true
        await container.loadCurrentStack()
        stack = container.currentStack
        isLoading = false
    }
    
    func toggleSupplementActive(supplementId: String, active: Bool) async {
        // Optimistically update local state
        stack?.toggleSupplementActive(supplementId: supplementId)
        
        // Update container's current stack
        container.currentStack = stack
        
        // Trigger a UI update
        objectWillChange.send()
        
        // Call API
        do {
            if let stackId = stack?.id,
               let service = container.recommendationService as? RealRecommendationService {
                try await service.toggleSupplementActive(
                    stackId: stackId,
                    supplementId: supplementId,
                    active: active
                )
            }
        } catch {
            // Revert on error
            stack?.toggleSupplementActive(supplementId: supplementId)
            container.currentStack = stack
            objectWillChange.send()
            print("Failed to toggle supplement: \(error)")
            // TODO: Show error toast
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredStack: Stack? {
        return stack
    }
}
