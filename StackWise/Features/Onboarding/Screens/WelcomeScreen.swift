import SwiftUI

// MARK: - WelcomeScreen
struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and branding
            VStack(spacing: Theme.Spacing.xl) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)
                
                VStack(spacing: Theme.Spacing.sm) {
                    Text("StackWise")
                        .font(Theme.Typography.titleXL)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Your personalized supplement guide")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Auth buttons
            VStack(spacing: Theme.Spacing.md) {
                // Sign in with Apple
                Button {
                    Task {
                        await viewModel.signInWithApple()
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 20))
                        Text("Continue with Apple")
                            .font(Theme.Typography.body)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.Radii.md)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Divider
                HStack(spacing: Theme.Spacing.md) {
                    Rectangle()
                        .fill(Theme.Colors.border)
                        .frame(height: 1)
                    
                    Text("or")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Rectangle()
                        .fill(Theme.Colors.border)
                        .frame(height: 1)
                }
                .padding(.vertical, Theme.Spacing.sm)
                
                // Email sign up
                PrimaryButton(
                    title: "Sign up with Email",
                    icon: "envelope.fill",
                    action: {
                        viewModel.showSignupScreen = true
                    }
                )
                
                // Login link
                HStack(spacing: Theme.Spacing.xs) {
                    Text("Already have an account?")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Button {
                        viewModel.showLoginScreen = true
                    } label: {
                        Text("Log in")
                            .font(Theme.Typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
                .padding(.top, Theme.Spacing.sm)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            
            // Legal text
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.top, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.surface)
        .sheet(isPresented: $viewModel.showLoginScreen) {
            LoginScreen(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSignupScreen) {
            SignupScreen(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showPasswordReset) {
            PasswordResetScreen(viewModel: viewModel)
        }
        .alert("Authentication Error", isPresented: $viewModel.showAuthError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.authErrorMessage)
        }
    }
}

