import Foundation
import SwiftUI

// MARK: - StackViewModel
@MainActor
public class StackViewModel: ObservableObject {
    @Published var stack: Stack?
    @Published var isLoading = false
    @Published var showRemixSheet = false
    @Published var remixOptions = RemixOptions()
    
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
    
    func startSchedule() {
        // TODO: Navigate to Schedule tab and pre-fill reminders
        // For now, just set a flag or notification
    }
    
    func remixStack() async {
        isLoading = true
        
        do {
            try await container.remixStack(with: remixOptions)
            stack = container.currentStack
            showRemixSheet = false
            remixOptions = RemixOptions() // Reset options
        } catch {
            // Handle error
            print("Failed to remix stack: \(error)")
        }
        
        isLoading = false
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
    
    func bindingForSupplement(_ supplement: Supplement) -> Binding<Bool>? {
        guard let stack = stack else { return nil }
        
        // Find the supplement in either minimal or addons
        if let index = stack.minimal.firstIndex(where: { $0.id == supplement.id }) {
            return Binding(
                get: { self.stack?.minimal[index].active ?? false },
                set: { _ in } // We'll handle the actual update in toggleSupplementActive
            )
        } else if let index = stack.addons.firstIndex(where: { $0.id == supplement.id }) {
            return Binding(
                get: { self.stack?.addons[index].active ?? false },
                set: { _ in } // We'll handle the actual update in toggleSupplementActive
            )
        }
        
        return nil
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
