import Foundation

// MARK: - RealGoalsService
public class RealGoalsService: GoalsService {
    private let networkManager = NetworkManager.shared
    private var cachedGoals: [Goal] = []
    
    public init() {}
    
    public func fetchGoals() async throws -> [Goal] {
        // Since our Goal enum now matches the API exactly, we can just return all cases
        // The API would be used to filter which goals to show if needed in the future
        return Goal.allCases
    }
    
    public func fetchGoalsFromAPI() async throws -> [APIGoal] {
        let response = try await networkManager.request(
            endpoint: "goals",
            method: "GET",
            requiresAuth: true,
            responseType: GoalsResponse.self
        )
        
        return response.goals
    }
}
