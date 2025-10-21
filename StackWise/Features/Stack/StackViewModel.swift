import Foundation
import SwiftUI

// MARK: - StackViewModel
@MainActor
public class StackViewModel: ObservableObject {
    @Published var stack: Stack?
    @Published var isLoading = false
    @Published var showRemixSheet = false
    @Published var remixOptions = RemixOptions()
    @Published var expandedSupplementIds: Set<String> = []
    
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
    
    func toggleSupplementExpanded(_ supplementId: String) {
        if expandedSupplementIds.contains(supplementId) {
            expandedSupplementIds.remove(supplementId)
        } else {
            expandedSupplementIds.insert(supplementId)
        }
    }
    
    func loadStack() async {
        isLoading = true
        await container.loadCurrentStack()
        stack = container.currentStack
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    var filteredStack: Stack? {
        return stack
    }
}
