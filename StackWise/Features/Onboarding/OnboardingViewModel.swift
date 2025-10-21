import Foundation
import SwiftUI

// MARK: - OnboardingViewModel
@MainActor
public class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var currentStep: OnboardingStep = .welcome
    @Published var intake = Intake()
    @Published var isLoading = false
    @Published var error: String?
    @Published var showHardStopAlert = false
    
    // Authentication
    @Published var isAuthenticated = false
    @Published var showLoginScreen = false
    @Published var showSignupScreen = false
    @Published var showAuthError = false
    @Published var authErrorMessage = ""
    
    // Splash & Consent
    @Published var isOver18 = false
    @Published var acceptsDisclaimer = false
    
    private let container: DIContainer
    
    // MARK: - OnboardingStep
    public enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case splash
        case goals
        case basics
        case risks
        case priority
        case review
        case generating
        
        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .splash: return "Important Information"
            case .goals: return "Your Goals"
            case .basics: return "Basic Information"
            case .risks: return "Health & Safety"
            case .priority: return "Top Priority"
            case .review: return "Review"
            case .generating: return "Creating Your Stack"
            }
        }
        
        var progress: Double {
            Double(self.rawValue) / Double(OnboardingStep.allCases.count - 1)
        }
    }
    
    // MARK: - Initialization
    public init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - Navigation
    
    public func canProceed() -> Bool {
        switch currentStep {
        case .welcome:
            return isAuthenticated
        case .splash:
            return isOver18 && acceptsDisclaimer
        case .goals:
            return !intake.goals.isEmpty
        case .basics:
            return intake.basics.age >= 18 && intake.basics.age <= 120
        case .risks:
            return !hasHardStopRisk()
        case .priority:
            return !intake.topPriorityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .review, .generating:
            return true
        }
    }
    
    public func nextStep() {
        guard canProceed() else { return }
        
        if currentStep == .risks && hasHardStopRisk() {
            showHardStopAlert = true
            return
        }
        
        if currentStep == .review {
            Task {
                await generateStack()
            }
        } else if let nextIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
                  nextIndex + 1 < OnboardingStep.allCases.count {
            withAnimation(Theme.Animation.standard) {
                currentStep = OnboardingStep.allCases[nextIndex + 1]
            }
        }
    }
    
    public func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        
        withAnimation(Theme.Animation.standard) {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }
    
    public func goToStep(_ step: OnboardingStep) {
        withAnimation(Theme.Animation.standard) {
            currentStep = step
        }
    }
    
    // MARK: - Business Logic
    
    private func hasHardStopRisk() -> Bool {
        return intake.risks.contains { $0.isHardStop }
    }
    
    private func generateStack() async {
        currentStep = .generating
        isLoading = true
        error = nil
        
        do {
            // Update the user's basic info from onboarding
            if var user = container.currentUser {
                user.age = intake.basics.age
                user.sex = intake.basics.sex
                user.height = intake.basics.height
                user.weight = intake.basics.weight
                user.bodyFat = intake.basics.bodyFat
                user.stimulantTolerance = intake.basics.stimulantTolerance
                user.budgetPerMonth = intake.basics.budgetPerMonth
                user.dietaryPreferences = intake.basics.dietaryPreferences
                
                container.currentUser = user
            }
            
            // Generate stack (this will also save preferences to the API)
            try await container.generateStack(from: intake)
            
            // Mark onboarding as complete
            container.onboardingCompleted = true
            
        } catch {
            if let networkError = error as? NetworkError {
                self.error = "Failed to generate your stack: \(networkError.localizedDescription)"
            } else {
                self.error = "Failed to generate your stack. Please try again."
            }
            currentStep = .review
        }
        
        isLoading = false
    }
    
    public func exportSummaryForClinician() async -> URL? {
        // TODO: Implement PDF export for hard-stop cases
        // For now, return nil
        return nil
    }
    
    // MARK: - Authentication Methods
    
    public func login(email: String, password: String) async {
        isLoading = true
        authErrorMessage = ""
        showAuthError = false
        
        do {
            let user = try await container.authService.signInEmail(email: email, password: password)
            container.currentUser = user
            isAuthenticated = true
            
            // Check if user has completed onboarding by trying to fetch their stack
            await container.loadCurrentStack()
            if container.currentStack != nil {
                // User has a stack, they've completed onboarding
                container.onboardingCompleted = true
            } else {
                // Move to next step in onboarding
                withAnimation(Theme.Animation.standard) {
                    currentStep = .splash
                }
            }
        } catch {
            if let networkError = error as? NetworkError {
                authErrorMessage = networkError.localizedDescription
            } else {
                authErrorMessage = "Failed to log in. Please check your credentials and try again."
            }
            showAuthError = true
        }
        
        isLoading = false
    }
    
    public func signup(name: String, email: String, password: String) async {
        isLoading = true
        authErrorMessage = ""
        showAuthError = false
        
        do {
            let user = try await container.authService.signUpEmail(name: name, email: email, password: password)
            container.currentUser = user
            isAuthenticated = true
            
            // New user, continue with onboarding
            withAnimation(Theme.Animation.standard) {
                currentStep = .splash
            }
        } catch {
            if let networkError = error as? NetworkError {
                authErrorMessage = networkError.localizedDescription
                // Check for specific errors
                if case .apiError(_, let statusCode) = networkError, statusCode == 409 {
                    authErrorMessage = "An account with this email already exists. Please log in instead."
                }
            } else {
                authErrorMessage = "Failed to create account. Please try again."
            }
            showAuthError = true
        }
        
        isLoading = false
    }
    
    public func signInWithApple() async {
        isLoading = true
        authErrorMessage = ""
        showAuthError = false
        
        do {
            // Mock Sign in with Apple
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay to simulate network
            
            let user = User(
                age: 25,
                sex: .other,
                height: 170,
                weight: 70,
                stimulantTolerance: .medium,
                budgetPerMonth: 100
            )
            
            container.currentUser = user
            isAuthenticated = true
            
            // Move to next step
            withAnimation(Theme.Animation.standard) {
                currentStep = .splash
            }
        } catch {
            authErrorMessage = "Failed to sign in with Apple. Please try again."
            showAuthError = true
        }
        
        isLoading = false
    }
}
