import Foundation

// MARK: - RecommendationService Protocol
public protocol RecommendationService {
    func startStackGeneration(intake: Intake) async throws -> String
    func pollStackGenerationStatus(jobId: String) async throws -> StackJobStatus
    func retryStackGeneration(jobId: String) async throws
    func fetchCurrentStack() async throws -> Stack?
    func remixStack(currentStack: Stack, options: RemixOptions) async throws -> Stack
}
