import SwiftUI

// MARK: - GeneratingScreen
struct GeneratingScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var animationPhase = 0
    
    var loadingMessages: [String] {
        if viewModel.container.isRemixFlow {
            return [
                "Analyzing your updated goals...",
                "Reviewing your new preferences...",
                "Adjusting supplement selection...",
                "Re-optimizing dosages...",
                "Verifying interactions...",
                "Updating your stack..."
            ]
        } else {
            return [
                "Analyzing your goals...",
                "Reviewing your health profile...",
                "Selecting evidence-based supplements...",
                "Optimizing dosages...",
                "Checking interactions...",
                "Finalizing your stack..."
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animationPhase == 0 ? 1.0 : 1.2)
                    .opacity(animationPhase == 0 ? 1.0 : 0.5)
                
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .scaleEffect(animationPhase == 1 ? 1.0 : 1.3)
                    .opacity(animationPhase == 1 ? 1.0 : 0.5)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.Colors.primary)
                    .rotationEffect(.degrees(animationPhase == 0 ? 0 : 10))
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    animationPhase = 1
                }
            }
            
            VStack(spacing: Theme.Spacing.md) {
                Text(viewModel.container.isRemixFlow ? "Updating Your Stack" : "Creating Your Stack")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(loadingMessages.randomElement() ?? loadingMessages[0])
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.5), value: animationPhase)
            }
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primary))
                .scaleEffect(1.2)
            
            Spacer()
            
            if let error = viewModel.error {
                Banner(
                    type: .danger,
                    title: "Something went wrong",
                    message: error,
                    action: { viewModel.nextStep() },
                    actionTitle: "Try Again"
                )
                .padding(.horizontal, Theme.Spacing.gutter)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.surface)
        .onAppear {
            // Cycle through loading messages
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation {
                    // This will cause a re-render with a new random message
                    animationPhase = animationPhase == 0 ? 1 : 0
                }
            }
        }
    }
}
