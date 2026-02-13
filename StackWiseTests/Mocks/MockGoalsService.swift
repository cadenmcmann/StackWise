import Foundation
@testable import StackWise

// MARK: - MockGoalsService
final class MockGoalsService: GoalsService {
    
    // MARK: - Call Tracking
    var fetchGoalsCallCount = 0
    var fetchGoalsFromAPICallCount = 0
    
    // MARK: - Configured Responses
    var goalsToReturn: [Goal] = []
    var apiGoalsToReturn: [APIGoal] = []
    var errorToThrow: Error?
    
    // MARK: - GoalsService Implementation
    
    func fetchGoals() async throws -> [Goal] {
        fetchGoalsCallCount += 1
        if let error = errorToThrow { throw error }
        return goalsToReturn
    }
    
    func fetchGoalsFromAPI() async throws -> [APIGoal] {
        fetchGoalsFromAPICallCount += 1
        if let error = errorToThrow { throw error }
        return apiGoalsToReturn
    }
    
    // MARK: - Helper
    func reset() {
        fetchGoalsCallCount = 0
        fetchGoalsFromAPICallCount = 0
        goalsToReturn = []
        apiGoalsToReturn = []
        errorToThrow = nil
    }
}

