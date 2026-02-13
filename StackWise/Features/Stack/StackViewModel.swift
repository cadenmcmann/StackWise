import Foundation
import SwiftUI

// MARK: - StackViewModel
@MainActor
public class StackViewModel: ObservableObject {
    @Published var stack: Stack?
    @Published var isLoading = false
    @Published var showRemixConfirmation = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showErrorToast = false
    @Published var toastMessage = ""
    
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
        #if DEBUG
        print("🔄 Starting remix flow...")
        #endif
        // Fetch current user preferences to pre-fill the onboarding
        do {
            let preferences = try await container.preferencesService.fetchPreferences()
            
            #if DEBUG
            if let prefs = preferences {
                print("✅ Got preferences for remix - goals: \(prefs.goals.count), age: \(prefs.basics.age)")
            } else {
                print("⚠️ fetchPreferences returned nil")
            }
            #endif
            
            // Set all flags together on main actor to avoid race conditions
            await MainActor.run {
                container.remixIntake = preferences
                container.isRemixFlow = true
                container.onboardingCompleted = false
                #if DEBUG
                print("✅ Set remix flags - remixIntake: \(container.remixIntake != nil ? "set" : "nil")")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Failed to fetch preferences for remix: \(error)")
            #endif
            // If we can't fetch preferences, still allow remix with empty intake
            await MainActor.run {
                container.remixIntake = nil
                container.isRemixFlow = true
                container.onboardingCompleted = false
            }
        }
    }
    
    func loadStack() async {
        isLoading = true
        showError = false
        
        do {
            let loadedStack = try await container.recommendationService.fetchCurrentStack()
            stack = loadedStack
            container.currentStack = loadedStack
        } catch {
            #if DEBUG
            print("Failed to load stack: \(error)")
            #endif
            errorMessage = "Failed to load your stack. Please check your connection and try again."
            showError = true
        }
        
        isLoading = false
    }
    
    func retry() async {
        await loadStack()
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
               let service = container.recommendationService as? RecommendationServiceImpl {
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
            #if DEBUG
            print("Failed to toggle supplement: \(error)")
            #endif
            toastMessage = "Failed to update supplement. Please try again."
            showErrorToast = true
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredStack: Stack? {
        return stack
    }
}
