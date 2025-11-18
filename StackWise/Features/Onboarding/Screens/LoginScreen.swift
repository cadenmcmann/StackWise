import SwiftUI

// MARK: - LoginScreen
struct LoginScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var verificationCode = ""
    @State private var showPassword = false
    @State private var contactMethod = ContactMethod.email
    @State private var useVerificationCode = false
    @State private var isWaitingForCode = false
    @State private var isSendingCode = false
    @State private var isVerifyingCode = false
    @State private var showPasswordFailedAlert = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case email
        case phone
        case password
        case code
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
                    
                    // Contact method toggle
                    ContactMethodToggle(selectedMethod: $contactMethod)
                        .padding(.horizontal, Theme.Spacing.xl)
                    
                    // Form fields
                    VStack(spacing: Theme.Spacing.lg) {
                        // Contact input (Email or Phone)
                        if contactMethod == .email {
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
                        } else {
                            // Phone field
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Phone Number")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    // Country code
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        
                                        Text("+1")
                                            .font(Theme.Typography.body)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    .padding(.leading, Theme.Spacing.xs)
                                    
                                    Divider()
                                        .frame(height: 24)
                                    
                                    TextField("(555) 123-4567", text: $phoneNumber)
                                        .font(Theme.Typography.body)
                                        .keyboardType(.phonePad)
                                        .focused($focusedField, equals: .phone)
                                        .onChange(of: phoneNumber) { oldValue, newValue in
                                            phoneNumber = formatPhoneNumber(newValue)
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
                                            focusedField == .phone ? Theme.Colors.primary : Theme.Colors.border,
                                            lineWidth: focusedField == .phone ? 2 : 1
                                        )
                                )
                            }
                        }
                        
                        // Auth method toggle
                        HStack(spacing: Theme.Spacing.xs) {
                            Text("Use")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Button {
                                withAnimation(Theme.Animation.quick) {
                                    useVerificationCode.toggle()
                                    verificationCode = ""
                                    isWaitingForCode = false
                                }
                            } label: {
                                Text(useVerificationCode ? "password" : "verification code")
                                    .font(Theme.Typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            
                            Text("to sign in")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                        }
                        
                        if !useVerificationCode {
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
                        } else {
                            // Verification code flow
                            if !isWaitingForCode {
                                // Send code button
                                PrimaryButton(
                                    title: "Send Verification Code",
                                    icon: "paperplane.fill",
                                    action: {
                                        Task {
                                            await sendVerificationCode()
                                        }
                                    },
                                    isLoading: isSendingCode,
                                    isDisabled: (contactMethod == .email && email.isEmpty) || (contactMethod == .phone && phoneNumber.count < 10)
                                )
                            } else {
                                // Verification code input
                                VStack(spacing: Theme.Spacing.lg) {
                                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                        Text("Enter verification code")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        
                                        VerificationCodeInput(
                                            code: $verificationCode,
                                            isError: viewModel.error != nil,
                                            onComplete: { code in
                                                isVerifyingCode = true
                                                Task {
                                                    await verifyAndLogin()
                                                    isVerifyingCode = false
                                                }
                                            }
                                        )
                                    }
                                    
                                    CountdownTimer(expirationTime: 60) {
                                        Task {
                                            await sendVerificationCode()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Forgot password
                        HStack {
                            Spacer()
                            Button {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    viewModel.showPasswordReset = true
                                }
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
                    if !useVerificationCode {
                        PrimaryButton(
                            title: "Log in",
                            action: {
                                Task {
                                    await performPasswordLogin()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isDisabled: isLoginDisabled()
                        )
                    } else if isWaitingForCode {
                        PrimaryButton(
                            title: "Verify & Log in",
                            action: {
                                Task {
                                    await verifyAndLogin()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isDisabled: verificationCode.count < 6
                        )
                    }
                    
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
            handleOnSubmit()
        }
        .alert("Password Login Failed", isPresented: $showPasswordFailedAlert) {
            Button("Try Verification Code") {
                withAnimation(Theme.Animation.quick) {
                    useVerificationCode = true
                    password = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to try logging in with a verification code instead?")
        }
        .overlay {
            if isVerifyingCode {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Theme.Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Verifying code...")
                            .font(Theme.Typography.titleM)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(Theme.Spacing.xxl)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radii.xl)
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: isVerifyingCode)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isLoginDisabled() -> Bool {
        if contactMethod == .email {
            return email.isEmpty || (!useVerificationCode && password.isEmpty)
        } else {
            return phoneNumber.count < 10 || (!useVerificationCode && password.isEmpty)
        }
    }
    
    private func formatPhoneNumber(_ value: String) -> String {
        // Remove all non-digit characters
        let digits = value.filter { $0.isNumber }
        
        // Limit to 10 digits
        let limited = String(digits.prefix(10))
        
        // Format as (XXX) XXX-XXXX
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
    
    private func handleOnSubmit() {
        if contactMethod == .email {
            if focusedField == .email && !useVerificationCode {
                focusedField = .password
            } else if !useVerificationCode {
                Task {
                    await performPasswordLogin()
                }
            }
        } else {
            if focusedField == .phone && !useVerificationCode {
                focusedField = .password
            } else if !useVerificationCode {
                Task {
                    await performPasswordLogin()
                }
            }
        }
    }
    
    private func performPasswordLogin() async {
        do {
            if contactMethod == .email {
                await viewModel.login(email: email, password: password)
            } else {
                let formattedPhone = "+1" + phoneNumber.filter { $0.isNumber }
                await viewModel.loginPhone(phoneNumber: formattedPhone, password: password)
            }
            
            if viewModel.isAuthenticated {
                dismiss()
            } else if viewModel.error != nil {
                // Show alert suggesting verification code
                showPasswordFailedAlert = true
            }
        }
    }
    
    private func sendVerificationCode() async {
        isSendingCode = true
        do {
            if contactMethod == .email {
                _ = try await viewModel.container.services.authService.sendVerificationCode(
                    email: email,
                    phoneNumber: nil,
                    purpose: "login"
                )
            } else {
                let formattedPhone = "+1" + phoneNumber.filter { $0.isNumber }
                _ = try await viewModel.container.services.authService.sendVerificationCode(
                    email: nil,
                    phoneNumber: formattedPhone,
                    purpose: "login"
                )
            }
            
            isSendingCode = false
            withAnimation(Theme.Animation.quick) {
                isWaitingForCode = true
            }
        } catch {
            isSendingCode = false
            if let networkError = error as? NetworkError {
                viewModel.authErrorMessage = networkError.localizedDescription
            } else {
                viewModel.authErrorMessage = "Failed to send verification code. Please try again."
            }
            viewModel.showAuthError = true
        }
    }
    
    private func verifyAndLogin() async {
        do {
            let authResponse: AuthResponse?
            
            if contactMethod == .email {
                authResponse = try await viewModel.container.services.authService.verifyCode(
                    email: email,
                    phoneNumber: nil,
                    code: verificationCode,
                    purpose: "login"
                )
            } else {
                let formattedPhone = "+1" + phoneNumber.filter { $0.isNumber }
                authResponse = try await viewModel.container.services.authService.verifyCode(
                    email: nil,
                    phoneNumber: formattedPhone,
                    code: verificationCode,
                    purpose: "login"
                )
            }
            
            if let response = authResponse {
                // Get the current user from the auth service (already stored there)
                if let user = viewModel.container.services.authService.currentUser() {
                    // Update the container's current user
                    viewModel.container.currentUser = user
                    viewModel.isAuthenticated = true
                    
                    // Check if user has completed onboarding by trying to fetch their stack
                    await viewModel.container.loadCurrentStack()
                    if viewModel.container.currentStack != nil {
                        // User has a stack, they've completed onboarding
                        viewModel.container.onboardingCompleted = true
                    }
                    
                    dismiss()
                }
            }
        } catch {
            if let networkError = error as? NetworkError {
                viewModel.authErrorMessage = networkError.localizedDescription
            } else {
                viewModel.authErrorMessage = "Failed to verify code. Please try again."
            }
            viewModel.showAuthError = true
        }
    }
}

