import Foundation

// MARK: - RealRecommendationService
public class RealRecommendationService: RecommendationService {
    private let networkManager = NetworkManager.shared
    
    public init() {}
    
    public func generateStack(intake: Intake) async throws -> Stack {
        // First, save the preferences
        let preferencesService = RealPreferencesService()
        try await preferencesService.savePreferences(intake)
        
        // Then generate the stack
        let response = try await networkManager.request(
            endpoint: "stack/generate",
            method: "POST",
            requiresAuth: true,
            responseType: StackResponse.self
        )
        
        return response.stack.toStack()
    }
    
    public func remixStack(currentStack: Stack, options: RemixOptions) async throws -> Stack {
        // For now, remix just regenerates the stack
        // TODO: Implement actual remix logic when API supports it
        let response = try await networkManager.request(
            endpoint: "stack/generate",
            method: "POST",
            requiresAuth: true,
            responseType: StackResponse.self
        )
        
        var newStack = response.stack.toStack()
        
        // Apply client-side filtering based on options
        if options.stimulantFree {
            newStack = Stack(
                minimal: newStack.minimal.filter { $0.flags.contains(.stimulantFree) || !$0.name.lowercased().contains("caffeine") },
                addons: newStack.addons.filter { $0.flags.contains(.stimulantFree) || !$0.name.lowercased().contains("caffeine") }
            )
        }
        
        if options.fewerPills {
            newStack = Stack(
                minimal: Array(newStack.minimal.prefix(2)),
                addons: []
            )
        }
        
        return newStack
    }
    
    public func fetchCurrentStack() async throws -> Stack? {
        do {
            let response = try await networkManager.request(
                endpoint: "stack/current",
                method: "GET",
                requiresAuth: true,
                responseType: StackResponse.self
            )
            
            return response.stack.toStack()
        } catch {
            // If 404 (no stack), return nil
            if case NetworkError.httpError(let statusCode) = error, statusCode == 404 {
                return nil
            }
            throw error
        }
    }
}
