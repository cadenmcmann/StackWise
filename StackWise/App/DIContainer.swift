import Foundation
import SwiftUI

// MARK: - DIContainer
/// Simple dependency injection container for managing app services
@MainActor
public class DIContainer: ObservableObject {
    
    // MARK: - Services
    private(set) var authService: AuthService
    private(set) var recommendationService: RecommendationService
    private(set) var trackingService: TrackingService
    private(set) var chatService: ChatService
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
    private var authExpiryTask: Task<Void, Never>?
    
    // MARK: - Services Access
    public var services: Services {
        Services(
            authService: authService,
            recommendationService: recommendationService,
            trackingService: trackingService,
            chatService: chatService,
            goalsService: goalsService,
            preferencesService: preferencesService
        )
    }
    
    // MARK: - Initialization
    public init() {
        // Initialize intake log manager
        self.intakeLogManager = IntakeLogManager()
        
        // Initialize services
        self.authService = AuthServiceImpl()
        self.recommendationService = RecommendationServiceImpl()
        self.trackingService = TrackingServiceImpl()
        self.chatService = ChatServiceImpl()
        self.goalsService = GoalsServiceImpl()
        self.preferencesService = PreferencesServiceImpl()

        startTokenExpiryListener()
        
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
    
    /// Testing initializer - allows injecting mock services
    public init(
        authService: AuthService? = nil,
        recommendationService: RecommendationService? = nil,
        trackingService: TrackingService? = nil,
        chatService: ChatService? = nil,
        goalsService: GoalsService? = nil,
        preferencesService: PreferencesService? = nil,
        intakeLogManager: IntakeLogManager? = nil,
        skipInitialLoad: Bool = false
    ) {
        self.authService = authService ?? AuthServiceImpl()
        self.recommendationService = recommendationService ?? RecommendationServiceImpl()
        self.trackingService = trackingService ?? TrackingServiceImpl()
        self.chatService = chatService ?? ChatServiceImpl()
        self.goalsService = goalsService ?? GoalsServiceImpl()
        self.preferencesService = preferencesService ?? PreferencesServiceImpl()
        self.intakeLogManager = intakeLogManager ?? IntakeLogManager()
        startTokenExpiryListener()
        
        // Skip loading persisted state and network checks during tests
        if !skipInitialLoad {
            if NetworkManager.shared.hasValidToken() {
                currentUser = self.authService.currentUser()
                if currentUser != nil {
                    Task {
                        await loadCurrentStack()
                    }
                }
            }
            loadPersistedState()
        }
    }

    deinit {
        authExpiryTask?.cancel()
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
                #if DEBUG
                print("✅ Stack generation completed: \(stackId)")
                #endif
                // Fetch the completed stack
                currentStack = try await service.fetchCurrentStack()
                currentJobId = nil
                savePersistedState()
                return
                
            case .failed(let errorMessage):
                if jobRetryCount < 1 {
                    // Auto-retry once
                    #if DEBUG
                    print("⚠️ Stack generation failed, retrying... Error: \(errorMessage)")
                    #endif
                    jobRetryCount += 1
                    savePersistedState()
                    try await service.retryStackGeneration(jobId: jobId)
                    // Wait and continue polling
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                } else {
                    // Give up after one retry
                    #if DEBUG
                    print("❌ Stack generation failed after retry: \(errorMessage)")
                    #endif
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
        
        #if DEBUG
        print("🔄 Resuming job polling for: \(jobId)")
        #endif
        
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
            if let service = recommendationService as? RecommendationServiceImpl {
                currentStack = try await service.fetchCurrentStack()
                savePersistedState()
            }
        } catch {
            #if DEBUG
            print("Failed to load current stack: \(error)")
            #endif
        }
    }
    
    public func fetchGoals() async throws -> [Goal] {
        return try await goalsService.fetchGoals()
    }
    
    // MARK: - Persistence
    
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        
        // Load onboarding status
        onboardingCompleted = defaults.bool(forKey: "onboardingCompleted")
        
        // Load job state
        currentJobId = defaults.string(forKey: "currentJobId")
        jobRetryCount = defaults.integer(forKey: "jobRetryCount")
        
        // Load user and stack from secure storage
        if let user = SecureStorage.shared.getCodable(User.self, for: SecureStorageKeys.currentUser) {
            currentUser = user
        }
        
        if let stack = SecureStorage.shared.getCodable(Stack.self, for: SecureStorageKeys.currentStack) {
            currentStack = stack
        }
    }
    
    private func savePersistedState() {
        let defaults = UserDefaults.standard
        
        defaults.set(onboardingCompleted, forKey: "onboardingCompleted")
        defaults.set(currentJobId, forKey: "currentJobId")
        defaults.set(jobRetryCount, forKey: "jobRetryCount")
        
        if let user = currentUser {
            SecureStorage.shared.setCodable(user, for: SecureStorageKeys.currentUser)
        } else {
            SecureStorage.shared.deleteValue(for: SecureStorageKeys.currentUser)
        }
        
        if let stack = currentStack {
            SecureStorage.shared.setCodable(stack, for: SecureStorageKeys.currentStack)
        } else {
            SecureStorage.shared.deleteValue(for: SecureStorageKeys.currentStack)
        }
    }
    
    private func clearPersistedState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingCompleted")
        defaults.removeObject(forKey: "currentJobId")
        defaults.removeObject(forKey: "jobRetryCount")
        SecureStorage.shared.deleteValue(for: SecureStorageKeys.currentUser)
        SecureStorage.shared.deleteValue(for: SecureStorageKeys.currentStack)
    }

    private func startTokenExpiryListener() {
        authExpiryTask?.cancel()
        authExpiryTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .authTokenExpired) {
                await self?.handleAuthTokenExpired()
            }
        }
    }

    private func handleAuthTokenExpired() async {
        try? await authService.signOut()
        currentUser = nil
        currentStack = nil
        onboardingCompleted = false
        clearPersistedState()
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
    public let trackingService: TrackingService
    public let chatService: ChatService
    public let goalsService: GoalsService
    public let preferencesService: PreferencesService
}
