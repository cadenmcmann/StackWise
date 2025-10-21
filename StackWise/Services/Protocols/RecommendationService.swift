import Foundation

// MARK: - RecommendationService Protocol
public protocol RecommendationService {
    func generateStack(intake: Intake) async throws -> Stack
    func remixStack(currentStack: Stack, options: RemixOptions) async throws -> Stack
}
