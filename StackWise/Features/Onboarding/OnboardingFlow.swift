import SwiftUI

// MARK: - OnboardingFlow
public struct OnboardingFlow: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(container: container))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.Colors.surface
                    .ignoresSafeArea()
                
                // Current screen
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeScreen(viewModel: viewModel)
                    case .splash:
                        SplashScreen(viewModel: viewModel)
                    case .goals:
                        GoalsScreen(viewModel: viewModel)
                    case .basics:
                        BasicsScreen(viewModel: viewModel)
                    case .risks:
                        RisksScreen(viewModel: viewModel)
                    case .priority:
                        PriorityScreen(viewModel: viewModel)
                    case .review:
                        ReviewScreen(viewModel: viewModel)
                    case .generating:
                        GeneratingScreen(viewModel: viewModel)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            .navigationBarHidden(true)
        }
    }
}
