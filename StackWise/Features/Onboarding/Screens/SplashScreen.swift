import SwiftUI

// MARK: - SplashScreen
struct SplashScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Title
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.Colors.primary)
                
                Text("StackWise")
                    .font(Theme.Typography.titleXL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Your personalized supplement guide")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Disclaimers
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text(viewModel.container.isRemixFlow ? "Confirm Your Information" : "Important Information")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack(alignment: .top, spacing: Theme.Spacing.md) {
                        Image(systemName: viewModel.isOver18 ? "checkmark.square.fill" : "square")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.isOver18 ? Theme.Colors.primary : Theme.Colors.border)
                            .onTapGesture {
                                viewModel.isOver18.toggle()
                            }
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("I am 18 years or older")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("This app is intended for adults only")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .onTapGesture {
                            viewModel.isOver18.toggle()
                        }
                    }
                    
                    HStack(alignment: .top, spacing: Theme.Spacing.md) {
                        Image(systemName: viewModel.acceptsDisclaimer ? "checkmark.square.fill" : "square")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.acceptsDisclaimer ? Theme.Colors.primary : Theme.Colors.border)
                            .onTapGesture {
                                viewModel.acceptsDisclaimer.toggle()
                            }
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("I understand this is educational content")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Not medical advice. Consult healthcare professionals before starting any supplement regimen.")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .onTapGesture {
                            viewModel.acceptsDisclaimer.toggle()
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.lg)
                    .fill(Theme.Colors.surfaceAlt)
            )
            
            Spacer()
            
            // Continue Button
            PrimaryButton(
                title: "Continue",
                action: { viewModel.nextStep() },
                isDisabled: !viewModel.canProceed()
            )
        }
        .padding(Theme.Spacing.gutter)
        .background(Theme.Colors.surface)
    }
}
