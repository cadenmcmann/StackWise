import Testing
import Foundation
@testable import StackWise

@Suite("OnboardingViewModel Tests")
@MainActor
struct OnboardingViewModelTests {
    
    // MARK: - Helper Methods
    
    private func makeContainer(
        authService: MockAuthService = MockAuthService(),
        recommendationService: MockRecommendationService = MockRecommendationService()
    ) -> DIContainer {
        return DIContainer(
            authService: authService,
            recommendationService: recommendationService,
            skipInitialLoad: true
        )
    }
    
    // MARK: - canProceed Tests
    
    @Test("canProceed returns false at welcome when not authenticated")
    func canProceedWelcomeNotAuthenticated() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .welcome
        viewModel.isAuthenticated = false
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at welcome when authenticated")
    func canProceedWelcomeAuthenticated() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .welcome
        viewModel.isAuthenticated = true
        
        #expect(viewModel.canProceed() == true)
    }
    
    @Test("canProceed returns false at splash when not consented")
    func canProceedSplashNotConsented() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .splash
        viewModel.isOver18 = false
        viewModel.acceptsDisclaimer = true
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at splash when fully consented")
    func canProceedSplashConsented() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .splash
        viewModel.isOver18 = true
        viewModel.acceptsDisclaimer = true
        
        #expect(viewModel.canProceed() == true)
    }
    
    @Test("canProceed returns false at goals when no goals selected")
    func canProceedGoalsEmpty() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .goals
        viewModel.intake.goals = []
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at goals when goals selected")
    func canProceedGoalsSelected() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .goals
        viewModel.intake.goals = [.buildMuscle]
        
        #expect(viewModel.canProceed() == true)
    }
    
    @Test("canProceed returns false at basics when age invalid")
    func canProceedBasicsInvalidAge() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .basics
        viewModel.intake.basics.age = 15 // Under 18
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at basics when age valid")
    func canProceedBasicsValidAge() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .basics
        viewModel.intake.basics.age = 30
        
        #expect(viewModel.canProceed() == true)
    }
    
    @Test("canProceed returns false at priority when text empty")
    func canProceedPriorityEmpty() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .priority
        viewModel.intake.topPriorityText = "   " // Whitespace only
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at priority when text provided")
    func canProceedPriorityProvided() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .priority
        viewModel.intake.topPriorityText = "Build muscle"
        
        #expect(viewModel.canProceed() == true)
    }
    
    // MARK: - nextStep Tests
    
    @Test("nextStep advances when canProceed is true")
    func nextStepAdvances() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .splash
        viewModel.isOver18 = true
        viewModel.acceptsDisclaimer = true
        
        viewModel.nextStep()
        
        #expect(viewModel.currentStep == .goals)
    }
    
    @Test("nextStep blocks when canProceed is false")
    func nextStepBlocks() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .goals
        viewModel.intake.goals = [] // Empty goals
        
        viewModel.nextStep()
        
        #expect(viewModel.currentStep == .goals) // Should not advance
    }
    
    // MARK: - previousStep Tests
    
    @Test("previousStep goes back correctly")
    func previousStepGoesBack() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .goals
        
        viewModel.previousStep()
        
        #expect(viewModel.currentStep == .splash)
    }
    
    @Test("previousStep does nothing at first step")
    func previousStepAtFirstStep() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .welcome
        
        viewModel.previousStep()
        
        #expect(viewModel.currentStep == .welcome)
    }
    
    // MARK: - hasHardStopRisk Tests
    
    @Test("canProceed returns false at risks with hard stop risk")
    func hasHardStopRiskDetected() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .risks
        viewModel.intake.risks = [.pregnancy] // Hard stop risk
        
        #expect(viewModel.canProceed() == false)
    }
    
    @Test("canProceed returns true at risks without hard stop")
    func noHardStopRisk() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .risks
        viewModel.intake.risks = [.bloodPressureMeds] // Not a hard stop
        
        #expect(viewModel.canProceed() == true)
    }
    
    // MARK: - login Tests
    
    @Test("login success sets authenticated state")
    func loginSuccessSetsAuthenticated() async {
        let mockAuth = MockAuthService()
        mockAuth.userToReturn = TestHelpers.makeUser()
        let container = makeContainer(authService: mockAuth)
        
        let viewModel = OnboardingViewModel(container: container)
        
        await viewModel.login(email: "test@example.com", password: "password123")
        
        #expect(viewModel.isAuthenticated == true)
        #expect(container.currentUser != nil)
        #expect(mockAuth.signInEmailCallCount == 1)
        #expect(mockAuth.lastEmail == "test@example.com")
    }
    
    @Test("login failure shows error message")
    func loginFailureShowsError() async {
        let mockAuth = MockAuthService()
        mockAuth.errorToThrow = NetworkError.apiError(message: "Invalid credentials", statusCode: 401)
        let container = makeContainer(authService: mockAuth)
        
        let viewModel = OnboardingViewModel(container: container)
        
        await viewModel.login(email: "test@example.com", password: "wrong")
        
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.showAuthError == true)
        #expect(!viewModel.authErrorMessage.isEmpty)
    }
    
    // MARK: - signup Tests
    
    @Test("signup handles 409 conflict correctly")
    func signupHandles409Conflict() async {
        let mockAuth = MockAuthService()
        mockAuth.errorToThrow = NetworkError.apiError(message: "Email exists", statusCode: 409)
        let container = makeContainer(authService: mockAuth)
        
        let viewModel = OnboardingViewModel(container: container)
        
        await viewModel.signup(name: "Test", email: "existing@example.com", password: "password")
        
        #expect(viewModel.showAuthError == true)
        #expect(viewModel.authErrorMessage.contains("already exists"))
    }
    
    // MARK: - Remix Flow Tests
    
    @Test("remix flow pre-fills intake correctly")
    func remixFlowPreFillsIntake() {
        let container = makeContainer()
        container.isRemixFlow = true
        container.remixIntake = TestHelpers.makeIntake(
            goals: [.buildMuscle, .improveFocus],
            topPriorityText: "Test priority"
        )
        
        let viewModel = OnboardingViewModel(container: container)
        
        #expect(viewModel.intake.goals.contains(.buildMuscle))
        #expect(viewModel.intake.goals.contains(.improveFocus))
        #expect(viewModel.intake.topPriorityText == "Test priority")
        #expect(viewModel.currentStep == .splash) // Skips welcome
        #expect(viewModel.isAuthenticated == true)
        #expect(viewModel.isOver18 == true)
        #expect(viewModel.acceptsDisclaimer == true)
    }
    
    @Test("remix flow without intake starts at splash")
    func remixFlowWithoutIntake() {
        let container = makeContainer()
        container.isRemixFlow = true
        container.remixIntake = nil
        
        let viewModel = OnboardingViewModel(container: container)
        
        #expect(viewModel.currentStep == .splash)
        #expect(viewModel.isAuthenticated == true)
        #expect(viewModel.intake.goals.isEmpty)
    }
    
    // MARK: - OnboardingStep Tests
    
    @Test("OnboardingStep has correct titles")
    func stepTitles() {
        #expect(OnboardingViewModel.OnboardingStep.welcome.title == "Welcome")
        #expect(OnboardingViewModel.OnboardingStep.goals.title == "Your Goals")
        #expect(OnboardingViewModel.OnboardingStep.generating.title == "Creating Your Stack")
    }
    
    @Test("OnboardingStep progress calculation is correct")
    func stepProgress() {
        let steps = OnboardingViewModel.OnboardingStep.allCases
        
        #expect(steps[0].progress == 0.0) // welcome
        #expect(steps[steps.count - 1].progress == 1.0) // generating (last step)
    }
    
    // MARK: - skipGoals Tests
    
    @Test("skipGoals clears goals and moves to basics")
    func skipGoalsClearsAndMoves() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.intake.goals = [.buildMuscle]
        viewModel.currentStep = .goals
        
        viewModel.skipGoals()
        
        #expect(viewModel.intake.goals.isEmpty)
        #expect(viewModel.currentStep == .basics)
    }
    
    // MARK: - goToStep Tests
    
    @Test("goToStep navigates to specified step")
    func goToStepNavigates() {
        let container = makeContainer()
        let viewModel = OnboardingViewModel(container: container)
        
        viewModel.currentStep = .welcome
        
        viewModel.goToStep(.review)
        
        #expect(viewModel.currentStep == .review)
    }
}

