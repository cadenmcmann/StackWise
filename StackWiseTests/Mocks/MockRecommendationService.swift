import Foundation
@testable import StackWise

// MARK: - MockRecommendationService
final class MockRecommendationService: RecommendationService {
    
    // MARK: - Call Tracking
    var startStackGenerationCallCount = 0
    var pollStackGenerationStatusCallCount = 0
    var retryStackGenerationCallCount = 0
    var fetchCurrentStackCallCount = 0
    var remixStackCallCount = 0
    
    // MARK: - Captured Parameters
    var lastIntake: Intake?
    var lastJobId: String?
    var lastStack: Stack?
    var lastRemixOptions: RemixOptions?
    
    // MARK: - Configured Responses
    var jobIdToReturn: String = "test-job-id"
    var stackJobStatusToReturn: StackJobStatus = .pending
    var stackToReturn: Stack?
    var errorToThrow: Error?
    
    // MARK: - RecommendationService Implementation
    
    func startStackGeneration(intake: Intake) async throws -> String {
        startStackGenerationCallCount += 1
        lastIntake = intake
        if let error = errorToThrow { throw error }
        return jobIdToReturn
    }
    
    func pollStackGenerationStatus(jobId: String) async throws -> StackJobStatus {
        pollStackGenerationStatusCallCount += 1
        lastJobId = jobId
        if let error = errorToThrow { throw error }
        return stackJobStatusToReturn
    }
    
    func retryStackGeneration(jobId: String) async throws {
        retryStackGenerationCallCount += 1
        lastJobId = jobId
        if let error = errorToThrow { throw error }
    }
    
    func fetchCurrentStack() async throws -> Stack? {
        fetchCurrentStackCallCount += 1
        if let error = errorToThrow { throw error }
        return stackToReturn
    }
    
    func remixStack(currentStack: Stack, options: RemixOptions) async throws -> Stack {
        remixStackCallCount += 1
        lastStack = currentStack
        lastRemixOptions = options
        if let error = errorToThrow { throw error }
        guard let stack = stackToReturn else {
            throw MockError.notConfigured
        }
        return stack
    }
    
    // MARK: - Helper
    func reset() {
        startStackGenerationCallCount = 0
        pollStackGenerationStatusCallCount = 0
        retryStackGenerationCallCount = 0
        fetchCurrentStackCallCount = 0
        remixStackCallCount = 0
        
        lastIntake = nil
        lastJobId = nil
        lastStack = nil
        lastRemixOptions = nil
        
        jobIdToReturn = "test-job-id"
        stackJobStatusToReturn = .pending
        stackToReturn = nil
        errorToThrow = nil
    }
}

