import SwiftUI

// MARK: - LoginScreen
struct LoginScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Welcome back")
                            .font(Theme.Typography.titleL)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Log in to your account")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xxl)
                    
                    // Form fields
                    VStack(spacing: Theme.Spacing.lg) {
                        // Email field
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Email")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextField("you@example.com", text: $email)
                                    .font(Theme.Typography.body)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .fill(Theme.Colors.surfaceAlt)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .stroke(
                                        focusedField == .email ? Theme.Colors.primary : Theme.Colors.border,
                                        lineWidth: focusedField == .email ? 2 : 1
                                    )
                            )
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Password")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "lock")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .font(Theme.Typography.body)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Password", text: $password)
                                        .font(Theme.Typography.body)
                                        .focused($focusedField, equals: .password)
                                }
                                
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .fill(Theme.Colors.surfaceAlt)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .stroke(
                                        focusedField == .password ? Theme.Colors.primary : Theme.Colors.border,
                                        lineWidth: focusedField == .password ? 2 : 1
                                    )
                            )
                        }
                        
                        // Forgot password
                        HStack {
                            Spacer()
                            Button {
                                // TODO: Implement forgot password
                            } label: {
                                Text("Forgot password?")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.primary)
                            }
                        }
                    }
                    
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
                    
                    // Sign in with Apple
                    Button {
                        Task {
                            await viewModel.signInWithApple()
                            dismiss()
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
                    
                    // Login button
                    PrimaryButton(
                        title: "Log in",
                        action: {
                            Task {
                                await viewModel.login(email: email, password: password)
                                if viewModel.isAuthenticated {
                                    dismiss()
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: email.isEmpty || password.isEmpty
                    )
                    
                    // Sign up link
                    HStack(spacing: Theme.Spacing.xs) {
                        Text("Don't have an account?")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Button {
                            dismiss()
                            viewModel.showSignupScreen = true
                        } label: {
                            Text("Sign up")
                                .font(Theme.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .background(Theme.Colors.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
        }
        .onSubmit {
            if focusedField == .email {
                focusedField = .password
            } else {
                Task {
                    await viewModel.login(email: email, password: password)
                    if viewModel.isAuthenticated {
                        dismiss()
                    }
                }
            }
        }
    }
}

