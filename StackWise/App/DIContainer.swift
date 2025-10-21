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
    
    // Shared intake log manager for both Today and Track screens
    public let intakeLogManager: IntakeLogManager
    
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
            self.chatService = MockChatService() // Still mocked - not in API yet
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
        currentStack = try await recommendationService.generateStack(intake: intake)
        savePersistedState()
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
