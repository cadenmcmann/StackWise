import Foundation
import SwiftUI
import AuthenticationServices

// MARK: - OnboardingViewModel
@MainActor
public class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var currentStep: OnboardingStep = .welcome
    @Published var intake = Intake()
    @Published var isLoading = false
    @Published var error: String?
    
    // Authentication
    @Published var isAuthenticated = false
    @Published var showLoginScreen = false
    @Published var showSignupScreen = false
    @Published var showAuthError = false
    @Published var authErrorMessage = ""
    @Published var showPasswordReset = false
    @Published var isAppleSigningIn = false
    
    // Splash & Consent
    @Published var isOver18 = false
    @Published var acceptsDisclaimer = false
    
    let container: DIContainer
    
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
        
        #if DEBUG
        print("📱 OnboardingViewModel init - isRemixFlow: \(container.isRemixFlow), remixIntake: \(container.remixIntake != nil ? "set" : "nil")")
        #endif
        
        // If this is a remix flow, pre-fill with existing preferences
        if container.isRemixFlow {
            // Pre-fill intake if available
            if let remixIntake = container.remixIntake {
                self.intake = remixIntake
                #if DEBUG
                print("✅ Pre-filled intake from remix - goals: \(remixIntake.goals.count), age: \(remixIntake.basics.age), priority: '\(remixIntake.topPriorityText)'")
                #endif
            } else {
                #if DEBUG
                print("⚠️ Remix flow but remixIntake is nil - forms will be empty")
                #endif
            }
            // Skip welcome step since user is already authenticated
            self.currentStep = .splash
            self.isAuthenticated = true
            // Pre-check consent boxes since user has already done this
            self.isOver18 = true
            self.acceptsDisclaimer = true
        }
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
            return true
        case .priority:
            return !intake.topPriorityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .review, .generating:
            return true
        }
    }
    
    public func nextStep() {
        guard canProceed() else { return }
        
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
    
    public func skipGoals() {
        intake.goals = []
        goToStep(.basics)
    }
    
    // MARK: - Business Logic
    
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
                
                container.currentUser = user
            }
            
            // Generate stack (this will also save preferences to the API)
            intake.isOver18Confirmed = isOver18
            intake.acceptsDisclaimerConfirmed = acceptsDisclaimer
            if isOver18 && acceptsDisclaimer {
                intake.consentAcceptedAt = Date()
            }
            try await container.generateStack(from: intake)
            
            // Mark onboarding as complete
            container.onboardingCompleted = true
            
            // Clean up remix flow flags if this was a remix
            if container.isRemixFlow {
                container.isRemixFlow = false
                container.remixIntake = nil
            }
            
        } catch {
            #if DEBUG
            print("❌ Failed to generate stack: \(error)")
            #endif
            if let networkError = error as? NetworkError {
                self.error = "Failed to generate your stack: \(networkError.localizedDescription)"
            } else {
                self.error = "Failed to generate your stack. Please try again."
            }
            currentStep = .review
        }
        
        isLoading = false
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
    
    public func signup(name: String, email: String, password: String, firstName: String? = nil, lastName: String? = nil, phoneNumber: String? = nil) async {
        isLoading = true
        authErrorMessage = ""
        showAuthError = false
        
        do {
            let user = try await container.authService.signUpEmail(
                name: name, 
                email: email, 
                password: password,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber
            )
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
        isAppleSigningIn = true
        authErrorMessage = ""
        showAuthError = false
        
        do {
            let user = try await container.authService.signInApple()
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
        } catch let error as AppleSignInError {
            // Handle specific Apple Sign In errors
            switch error {
            case .cancelled:
                // User cancelled, don't show error
                break
            default:
                authErrorMessage = error.localizedDescription
                showAuthError = true
            }
        } catch {
            if let networkError = error as? NetworkError {
                authErrorMessage = networkError.localizedDescription
            } else {
                authErrorMessage = "Failed to sign in with Apple. Please try again."
            }
            showAuthError = true
        }
        
        isAppleSigningIn = false
    }

    public func signInWithApple(result: Result<ASAuthorization, Error>) async {
        isAppleSigningIn = true
        authErrorMessage = ""
        showAuthError = false

        do {
            let authorization = try result.get()
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw AppleSignInError.invalidCredential
            }
            guard let tokenData = appleCredential.identityToken else {
                throw AppleSignInError.missingIdentityToken
            }
            guard let identityToken = String(data: tokenData, encoding: .utf8) else {
                throw AppleSignInError.tokenEncodingFailed
            }

            let authorizationCode = appleCredential.authorizationCode.flatMap {
                String(data: $0, encoding: .utf8)
            }

            let user = try await container.authService.signInApple(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                email: appleCredential.email
            )

            container.currentUser = user
            isAuthenticated = true

            await container.loadCurrentStack()
            if container.currentStack != nil {
                container.onboardingCompleted = true
            } else {
                withAnimation(Theme.Animation.standard) {
                    currentStep = .splash
                }
            }
        } catch let error as ASAuthorizationError {
            if error.code != .canceled {
                authErrorMessage = error.localizedDescription
                showAuthError = true
            }
        } catch let error as AppleSignInError {
            switch error {
            case .cancelled:
                break
            default:
                authErrorMessage = error.localizedDescription
                showAuthError = true
            }
        } catch {
            if let networkError = error as? NetworkError {
                authErrorMessage = networkError.localizedDescription
            } else {
                authErrorMessage = "Failed to sign in with Apple. Please try again."
            }
            showAuthError = true
        }

        isAppleSigningIn = false
    }
}
