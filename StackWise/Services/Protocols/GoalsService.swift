import Foundation

// MARK: - GoalsService Protocol
public protocol GoalsService {
    func fetchGoals() async throws -> [Goal]
    func fetchGoalsFromAPI() async throws -> [APIGoal]
}
