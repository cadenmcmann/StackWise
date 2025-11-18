import Foundation
import SwiftUI

// MARK: - DIContainer
/// Simple dependency injection container for managing app services
@MainActor
public class DIContainer: ObservableObject {
    
    // MARK: - Services
    private(set) var authService: AuthService
    private(set) var recommendationService: RecommendationService
    private(set) var scheduleService: ScheduleService
    private(set) var trackingService: TrackingService
    private(set) var chatService: ChatService
    private(set) var exportService: ExportService
    private(set) var goalsService: GoalsService
    private(set) var preferencesService: PreferencesService
    
    // MARK: - Shared State
    @Published public var currentUser: User?
    @Published public var currentStack: Stack?
    @Published public var onboardingCompleted: Bool = false
    @Published public var isRemixFlow: Bool = false
    @Published public var remixIntake: Intake? = nil
    @Published public var currentJobId: String? = nil
    @Published public var jobRetryCount: Int = 0
    
    // Shared intake log manager for both Today and Track screens
    public let intakeLogManager: IntakeLogManager
    
    // MARK: - Services Access
    public var services: Services {
        Services(
            authService: authService,
            recommendationService: recommendationService,
            scheduleService: scheduleService,
            trackingService: trackingService,
            chatService: chatService,
            exportService: exportService,
            goalsService: goalsService,
            preferencesService: preferencesService
        )
    }
    
    // MARK: - Initialization
    public init(useMocks: Bool = false) {
        // Initialize intake log manager
        self.intakeLogManager = IntakeLogManager()
        
        if useMocks {
            // Initialize with mock services
            self.authService = MockAuthService()
            self.recommendationService = MockRecommendationService()
            self.scheduleService = MockScheduleService()
            self.trackingService = MockTrackingService()
            self.chatService = MockChatService()
            self.exportService = MockExportService()
            self.goalsService = MockGoalsService()
            self.preferencesService = MockPreferencesService()
        } else {
            // Initialize with real services
            self.authService = RealAuthService()
            self.recommendationService = RealRecommendationService()
            self.scheduleService = MockScheduleService() // Still mocked - not in API yet
            self.trackingService = RealTrackingService() // Now using real API!
            self.chatService = RealChatService() // Now using real API!
            self.exportService = MockExportService() // Still mocked - not in API yet
            self.goalsService = RealGoalsService()
            self.preferencesService = RealPreferencesService()
        }
        
        // Check if user has a valid token
        if NetworkManager.shared.hasValidToken() {
            // Try to load current user from stored data
            currentUser = authService.currentUser()
            
            // If we have a user, fetch their current stack
            if currentUser != nil {
                Task {
                    await loadCurrentStack()
                }
            }
        }
        
        // Load any persisted state
        loadPersistedState()
    }
    
    // MARK: - Public Methods
    
    public func signIn() async throws {
        currentUser = try await authService.signInApple()
        onboardingCompleted = true
        savePersistedState()
    }
    
    public func signOut() async throws {
        try await authService.signOut()
        currentUser = nil
        currentStack = nil
        onboardingCompleted = false
        clearPersistedState()
    }
    
    public func generateStack(from intake: Intake) async throws {
        let service = recommendationService
        
        // Start generation and get job_id
        let jobId = try await service.startStackGeneration(intake: intake)
        
        // Persist job_id for app backgrounding
        currentJobId = jobId
        jobRetryCount = 0
        savePersistedState()
        
        // Wait 20 seconds before first poll
        try await Task.sleep(nanoseconds: 20_000_000_000)
        
        // Poll until completed or failed
        try await pollJobUntilComplete(jobId: jobId)
    }
    
    private func pollJobUntilComplete(jobId: String) async throws {
        let service = recommendationService
        
        while true {
            let status = try await service.pollStackGenerationStatus(jobId: jobId)
            
            switch status {
            case .completed(let stackId):
                print("✅ Stack generation completed: \(stackId)")
                // Fetch the completed stack
                currentStack = try await service.fetchCurrentStack()
                currentJobId = nil
                savePersistedState()
                return
                
            case .failed(let errorMessage):
                if jobRetryCount < 1 {
                    // Auto-retry once
                    print("⚠️ Stack generation failed, retrying... Error: \(errorMessage)")
                    jobRetryCount += 1
                    savePersistedState()
                    try await service.retryStackGeneration(jobId: jobId)
                    // Wait and continue polling
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                } else {
                    // Give up after one retry
                    print("❌ Stack generation failed after retry: \(errorMessage)")
                    currentJobId = nil
                    savePersistedState()
                    throw NetworkError.apiError(message: "Stack generation failed: \(errorMessage)", statusCode: 500)
                }
                
            case .pending, .processing:
                // Wait 3 seconds before next poll
                try await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
    
    public func resumeJobPolling() async throws {
        guard let jobId = currentJobId else { return }
        
        print("🔄 Resuming job polling for: \(jobId)")
        
        // Continue polling the existing job
        try await pollJobUntilComplete(jobId: jobId)
    }
    
    public func remixStack(with options: RemixOptions) async throws {
        guard let stack = currentStack else { return }
        currentStack = try await recommendationService.remixStack(currentStack: stack, options: options)
        savePersistedState()
    }
    
    public func loadCurrentStack() async {
        do {
            if let service = recommendationService as? RealRecommendationService {
                currentStack = try await service.fetchCurrentStack()
                savePersistedState()
            }
        } catch {
            print("Failed to load current stack: \(error)")
        }
    }
    
    public func fetchGoals() async throws -> [Goal] {
        return try await goalsService.fetchGoals()
    }
    
    // MARK: - Persistence (Simple UserDefaults for scaffold)
    
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        
        // Load onboarding status
        onboardingCompleted = defaults.bool(forKey: "onboardingCompleted")
        
        // Load job state
        currentJobId = defaults.string(forKey: "currentJobId")
        jobRetryCount = defaults.integer(forKey: "jobRetryCount")
        
        // Load user if exists
        if let userData = defaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        // Load stack if exists
        if let stackData = defaults.data(forKey: "currentStack"),
           let stack = try? JSONDecoder().decode(Stack.self, from: stackData) {
            currentStack = stack
        }
    }
    
    private func savePersistedState() {
        let defaults = UserDefaults.standard
        
        defaults.set(onboardingCompleted, forKey: "onboardingCompleted")
        defaults.set(currentJobId, forKey: "currentJobId")
        defaults.set(jobRetryCount, forKey: "jobRetryCount")
        
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            defaults.set(userData, forKey: "currentUser")
        }
        
        if let stack = currentStack,
           let stackData = try? JSONEncoder().encode(stack) {
            defaults.set(stackData, forKey: "currentStack")
        }
    }
    
    private func clearPersistedState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingCompleted")
        defaults.removeObject(forKey: "currentUser")
        defaults.removeObject(forKey: "currentStack")
        defaults.removeObject(forKey: "currentJobId")
        defaults.removeObject(forKey: "jobRetryCount")
    }
}

// MARK: - Environment Key
private struct DIContainerKey: EnvironmentKey {
    @MainActor
    static let defaultValue = DIContainer()
}

public extension EnvironmentValues {
    var container: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - Services
public struct Services {
    public let authService: AuthService
    public let recommendationService: RecommendationService
    public let scheduleService: ScheduleService
    public let trackingService: TrackingService
    public let chatService: ChatService
    public let exportService: ExportService
    public let goalsService: GoalsService
    public let preferencesService: PreferencesService
}
