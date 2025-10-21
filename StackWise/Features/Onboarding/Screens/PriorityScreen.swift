import SwiftUI

// MARK: - PriorityScreen
struct PriorityScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("What's your top priority?")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Tell us in your own words")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, Theme.Spacing.xxl)
            
            // Progress indicator
            ProgressView(value: viewModel.currentStep.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.Colors.primary))
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.top, Theme.Spacing.lg)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Info banner
                    Banner(
                        type: .info,
                        title: "Be Specific",
                        message: "The more specific you are, the better we can tailor your recommendations."
                    )
                    
                    // Text input
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Your Priority")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        TextField(
                            "e.g., fall asleep faster; increase 5RM squat; reduce daily anxiety",
                            text: $viewModel.intake.topPriorityText,
                            axis: .vertical
                        )
                        .font(Theme.Typography.body)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.md)
                                .fill(Theme.Colors.surfaceAlt)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radii.md)
                                .stroke(
                                    isTextFieldFocused ? Theme.Colors.primary : Theme.Colors.border,
                                    lineWidth: isTextFieldFocused ? 2 : 1
                                )
                        )
                        .focused($isTextFieldFocused)
                        .lineLimit(3...6)
                    }
                    
                    // Example priorities
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Examples")
                            .font(Theme.Typography.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            ExamplePriorityRow(
                                icon: "moon.zzz.fill",
                                text: "I want to fall asleep within 30 minutes every night"
                            ) {
                                viewModel.intake.topPriorityText = "I want to fall asleep within 30 minutes every night"
                            }
                            
                            ExamplePriorityRow(
                                icon: "figure.strengthtraining.traditional",
                                text: "Increase my bench press by 20 pounds in 3 months"
                            ) {
                                viewModel.intake.topPriorityText = "Increase my bench press by 20 pounds in 3 months"
                            }
                            
                            ExamplePriorityRow(
                                icon: "brain.head.profile",
                                text: "Stay focused during long work sessions without jitters"
                            ) {
                                viewModel.intake.topPriorityText = "Stay focused during long work sessions without jitters"
                            }
                            
                            ExamplePriorityRow(
                                icon: "heart.text.square",
                                text: "Manage daily stress and anxiety naturally"
                            ) {
                                viewModel.intake.topPriorityText = "Manage daily stress and anxiety naturally"
                            }
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radii.lg)
                            .fill(Theme.Colors.surfaceAlt.opacity(0.5))
                    )
                }
                .padding(Theme.Spacing.gutter)
            }
            
            Spacer()
            
            // Footer buttons
            HStack(spacing: Theme.Spacing.md) {
                SecondaryButton(
                    title: "Back",
                    icon: "chevron.left",
                    action: { viewModel.previousStep() }
                )
                
                PrimaryButton(
                    title: "Next",
                    action: { viewModel.nextStep() },
                    isDisabled: !viewModel.canProceed()
                )
            }
            .padding(Theme.Spacing.gutter)
        }
        .background(Theme.Colors.surface)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - ExamplePriorityRow
struct ExamplePriorityRow: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 24)
                
                Text(text)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
