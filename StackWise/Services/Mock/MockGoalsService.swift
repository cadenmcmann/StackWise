import Foundation

// MARK: - MockGoalsService
public class MockGoalsService: GoalsService {
    
    public init() {}
    
    public func fetchGoals() async throws -> [Goal] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return all predefined goals
        return Goal.allCases
    }
    
    public func fetchGoalsFromAPI() async throws -> [APIGoal] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock API goals
        return Goal.allCases.map { goal in
            APIGoal(id: UUID().uuidString, goalName: goal.rawValue)
        }
    }
}
