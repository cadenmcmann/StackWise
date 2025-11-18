import SwiftUI

// MARK: - PasswordResetScreen
struct PasswordResetScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @StateObject private var resetViewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        _resetViewModel = StateObject(wrappedValue: ForgotPasswordViewModel(container: viewModel.container))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch resetViewModel.currentStep {
                case .contactInput:
                    ContactInputView(viewModel: resetViewModel, dismiss: dismiss)
                case .verifyCode:
                    VerifyCodeView(viewModel: resetViewModel)
                case .newPassword:
                    NewPasswordView(viewModel: resetViewModel)
                case .success:
                    SuccessView(viewModel: resetViewModel, dismiss: dismiss)
                }
            }
            .alert("Error", isPresented: $resetViewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(resetViewModel.errorMessage)
            }
        }
    }
}

// MARK: - ContactInputView
struct ContactInputView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel
    @FocusState private var focusedField: Bool
    let dismiss: DismissAction
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                    .frame(height: Theme.Spacing.xxl)
                
                // Icon
                LockIcon(isUnlocked: false)
                    .padding(.bottom, Theme.Spacing.md)
                
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Reset Password")
                        .font(Theme.Typography.titleL)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Enter your \(viewModel.contactMethod == .email ? "email" : "phone number") and we'll send you a verification code to reset your password")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                
                // Contact method toggle
                ContactMethodToggle(selectedMethod: $viewModel.contactMethod)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .onChange(of: viewModel.contactMethod) { _, _ in
                        // Clear fields when switching
                        viewModel.email = ""
                        viewModel.phoneNumber = ""
                    }
                
                // Contact input
                if viewModel.contactMethod == .email {
                    // Email input
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Email")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            TextField("you@example.com", text: $viewModel.email)
                                .font(Theme.Typography.body)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField)
                        }
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.md)
                                .fill(Theme.Colors.surfaceAlt)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radii.md)
                                .stroke(
                                    focusedField ? Theme.Colors.primary : Theme.Colors.border,
                                    lineWidth: focusedField ? 2 : 1
                                )
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                } else {
                    // Phone input
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Phone Number")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack(spacing: Theme.Spacing.sm) {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text("+1")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            .padding(.leading, Theme.Spacing.sm)
                            
                            Divider()
                                .frame(height: 24)
                            
                            TextField("(555) 123-4567", text: $viewModel.phoneNumber)
                                .font(Theme.Typography.body)
                                .keyboardType(.phonePad)
                                .focused($focusedField)
                                .onChange(of: viewModel.phoneNumber) { oldValue, newValue in
                                    viewModel.phoneNumber = formatPhoneNumber(newValue)
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
                                    focusedField ? Theme.Colors.primary : Theme.Colors.border,
                                    lineWidth: focusedField ? 2 : 1
                                )
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: Theme.Spacing.md) {
                    PrimaryButton(
                        title: "Send Verification Code",
                        icon: "paperplane.fill",
                        action: {
                            focusedField = false
                            Task {
                                await viewModel.sendVerificationCode()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isContactValid
                    )
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to Login")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .background(Theme.Colors.surface)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
    
    private func formatPhoneNumber(_ value: String) -> String {
        let digits = value.filter { $0.isNumber }
        let limited = String(digits.prefix(10))
        
        var formatted = ""
        for (index, character) in limited.enumerated() {
            if index == 0 {
                formatted += "("
            } else if index == 3 {
                formatted += ") "
            } else if index == 6 {
                formatted += "-"
            }
            formatted.append(character)
        }
        
        return formatted
    }
}

// MARK: - VerifyCodeView
struct VerifyCodeView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel
    @State private var isTransitioning = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                    .frame(height: Theme.Spacing.xxl)
                
                // Icon with animation
                LockIcon(isUnlocked: isTransitioning)
                    .padding(.bottom, Theme.Spacing.md)
                
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Verify Your Identity")
                        .font(Theme.Typography.titleL)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("We sent a verification code to \(viewModel.contactMethod == .email ? viewModel.email : viewModel.contactValue)")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                
                // Code input
                VStack(spacing: Theme.Spacing.lg) {
                    VerificationCodeInput(
                        code: $viewModel.verificationCode,
                        isError: viewModel.error != nil,
                        onComplete: { _ in
                            Task {
                                await verifyCode()
                            }
                        }
                    )
                    
                    CountdownTimer {
                        Task {
                            await viewModel.resendCode()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.top, Theme.Spacing.lg)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: Theme.Spacing.md) {
                    PrimaryButton(
                        title: "Verify Code",
                        action: {
                            Task {
                                await verifyCode()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: viewModel.verificationCode.count < 6
                    )
                    
                    Button {
                        viewModel.goBack()
                    } label: {
                        Text("Back")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .background(Theme.Colors.surface)
        .navigationBarHidden(true)
    }
    
    private func verifyCode() async {
        // Trigger unlock animation
        withAnimation(Theme.Animation.standard) {
            isTransitioning = true
        }
        
        await viewModel.verifyCode()
    }
}

// MARK: - NewPasswordView
struct NewPasswordView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case password
        case confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                    .frame(height: Theme.Spacing.xxl)
                
                // Icon (unlocked)
                LockIcon(isUnlocked: true)
                    .padding(.bottom, Theme.Spacing.md)
                
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Create New Password")
                        .font(Theme.Typography.titleL)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Your identity has been verified. Create a new password for your account.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                
                // Password fields
                VStack(spacing: Theme.Spacing.lg) {
                    // New password
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("New Password")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "lock")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            if showPassword {
                                TextField("Password", text: $viewModel.newPassword)
                                    .font(Theme.Typography.body)
                                    .focused($focusedField, equals: .password)
                            } else {
                                SecureField("Password", text: $viewModel.newPassword)
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
                        
                        Text("At least 8 characters")
                            .font(Theme.Typography.caption)
                            .foregroundColor(viewModel.newPassword.count >= 8 ? Theme.Colors.success : Theme.Colors.textSecondary)
                    }
                    
                    // Confirm password
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Confirm Password")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "lock")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            if showConfirmPassword {
                                TextField("Confirm password", text: $viewModel.confirmPassword)
                                    .font(Theme.Typography.body)
                                    .focused($focusedField, equals: .confirmPassword)
                            } else {
                                SecureField("Confirm password", text: $viewModel.confirmPassword)
                                    .font(Theme.Typography.body)
                                    .focused($focusedField, equals: .confirmPassword)
                            }
                            
                            Button {
                                showConfirmPassword.toggle()
                            } label: {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
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
                                    focusedField == .confirmPassword ? Theme.Colors.primary : Theme.Colors.border,
                                    lineWidth: focusedField == .confirmPassword ? 2 : 1
                                )
                        )
                        
                        if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                            Text("Passwords do not match")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.danger)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: Theme.Spacing.md) {
                    PrimaryButton(
                        title: "Reset Password",
                        action: {
                            Task {
                                await viewModel.resetPassword()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isPasswordValid
                    )
                    
                    Button {
                        Task {
                            await viewModel.skipAndLogin()
                        }
                    } label: {
                        Text("Skip for Now")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.primary)
                    }
                    .opacity(viewModel.isLoading ? 0.5 : 1.0)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .background(Theme.Colors.surface)
        .navigationBarHidden(true)
        .onSubmit {
            if focusedField == .password {
                focusedField = .confirmPassword
            } else {
                Task {
                    await viewModel.resetPassword()
                }
            }
        }
    }
}

// MARK: - SuccessView
struct SuccessView: View {
    @ObservedObject var viewModel: ForgotPasswordViewModel
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.success.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.success)
            }
            
            // Success message
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.shouldSkipPasswordReset ? "Logged In Successfully" : "Password Reset Complete")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(viewModel.shouldSkipPasswordReset ? 
                    "You're now logged in to your account" : 
                    "Your password has been successfully reset. You can now log in with your new password.")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Spacer()
            
            // Continue button
            PrimaryButton(
                title: viewModel.shouldSkipPasswordReset ? "Continue" : "Back to Login",
                action: {
                    if viewModel.shouldSkipPasswordReset {
                        // Already logged in
                        dismiss()
                    } else {
                        // Go back to login
                        viewModel.reset()
                        dismiss()
                    }
                }
            )
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.surface)
        .navigationBarHidden(true)
    }
}

// MARK: - LockIcon
struct LockIcon: View {
    let isUnlocked: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.primary.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: isUnlocked ? "lock.open.fill" : "lock.rotation")
                .font(.system(size: 36))
                .foregroundColor(Theme.Colors.primary)
                .rotationEffect(.degrees(isUnlocked ? 15 : 0))
                .animation(Theme.Animation.standard, value: isUnlocked)
        }
    }
}

