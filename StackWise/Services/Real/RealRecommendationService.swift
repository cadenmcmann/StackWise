import Foundation

// MARK: - RealRecommendationService
public class RealRecommendationService: RecommendationService {
    private let networkManager = NetworkManager.shared
    
    public init() {}
    
    public func startStackGeneration(intake: Intake) async throws -> String {
        // First, save the preferences
        let preferencesService = RealPreferencesService()
        try await preferencesService.savePreferences(intake)
        
        // Start async generation
        let response = try await networkManager.request(
            endpoint: "stack/generate",
            method: "POST",
            requiresAuth: true,
            responseType: GenerateStackJobResponse.self
        )
        
        return response.jobId
    }
    
    public func pollStackGenerationStatus(jobId: String) async throws -> StackJobStatus {
        let response = try await networkManager.request(
            endpoint: "stack/generate/status/\(jobId)",
            method: "GET",
            requiresAuth: true,
            responseType: StackJobStatusResponse.self
        )
        
        switch response.status {
        case "pending":
            return .pending
        case "processing":
            return .processing
        case "completed":
            guard let stackId = response.stackId else {
                struct MissingStackIdError: Error {}
                throw NetworkError.decodingError(MissingStackIdError())
            }
            return .completed(stackId: stackId)
        case "failed":
            return .failed(errorMessage: response.errorMessage ?? "Unknown error")
        default:
            struct InvalidStatusError: Error {}
            throw NetworkError.decodingError(InvalidStatusError())
        }
    }
    
    public func retryStackGeneration(jobId: String) async throws {
        _ = try await networkManager.request(
            endpoint: "stack/generate/retry/\(jobId)",
            method: "POST",
            requiresAuth: true,
            responseType: RetryJobResponse.self
        )
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
    
    public func toggleSupplementActive(stackId: String, supplementId: String, active: Bool) async throws {
        let request = ToggleSupplementsRequest(
            updates: [
                ToggleSupplementsRequest.SupplementUpdate(
                    supplementId: supplementId,
                    active: active
                )
            ]
        )
        
        _ = try await networkManager.request(
            endpoint: "stack/\(stackId)/supplements",
            method: "PATCH",
            body: request,
            requiresAuth: true,
            responseType: ToggleSupplementsResponse.self
        )
    }
}
