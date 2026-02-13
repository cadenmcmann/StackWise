import SwiftUI
import AuthenticationServices

// MARK: - SignupScreen
struct SignupScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var acceptTerms = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case firstName
        case lastName
        case email
        case password
        case confirmPassword
    }
    
    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    private var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private var canSignUp: Bool {
        return isValidEmail && password.count >= 8 && passwordsMatch && acceptTerms
    }
    
    private var passwordStrength: PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 8 {
            return .weak
        } else if password.count >= 12 && password.rangeOfCharacter(from: .decimalDigits) != nil && 
                  password.rangeOfCharacter(from: .punctuationCharacters) != nil {
            return .strong
        } else {
            return .medium
        }
    }
    
    enum PasswordStrength {
        case none, weak, medium, strong
        
        var color: Color {
            switch self {
            case .none: return Color.clear
            case .weak: return Theme.Colors.danger
            case .medium: return Theme.Colors.warning
            case .strong: return Theme.Colors.success
            }
        }
        
        var text: String {
            switch self {
            case .none: return ""
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Create Account")
                            .font(Theme.Typography.titleL)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Start your personalized supplement journey")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.xxl)
                    
                    // Form fields
                    VStack(spacing: Theme.Spacing.lg) {
                        // Name fields
                        HStack(spacing: Theme.Spacing.md) {
                            // First name field
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("First Name")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    Image(systemName: "person")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    TextField("First", text: $firstName)
                                        .font(Theme.Typography.body)
                                        .focused($focusedField, equals: .firstName)
                                }
                                .padding(Theme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radii.md)
                                        .fill(Theme.Colors.surfaceAlt)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Radii.md)
                                        .stroke(
                                            focusedField == .firstName ? Theme.Colors.primary : Theme.Colors.border,
                                            lineWidth: focusedField == .firstName ? 2 : 1
                                        )
                                )
                                
                                Text("Optional")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.8))
                            }
                            
                            // Last name field
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Last Name")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    TextField("Last", text: $lastName)
                                        .font(Theme.Typography.body)
                                        .focused($focusedField, equals: .lastName)
                                }
                                .padding(Theme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radii.md)
                                        .fill(Theme.Colors.surfaceAlt)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Radii.md)
                                        .stroke(
                                            focusedField == .lastName ? Theme.Colors.primary : Theme.Colors.border,
                                            lineWidth: focusedField == .lastName ? 2 : 1
                                        )
                                )
                                
                                Text("Optional")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.8))
                            }
                        }
                        
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
                            
                            if !email.isEmpty && !isValidEmail {
                                Text("Please enter a valid email address")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.danger)
                            }
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
                            
                            // Password strength indicator
                            HStack(spacing: Theme.Spacing.sm) {
                                Text("At least 8 characters")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(password.count >= 8 ? Theme.Colors.success : Theme.Colors.textSecondary)
                                
                                Spacer()
                                
                                if passwordStrength != .none {
                                    HStack(spacing: Theme.Spacing.xs) {
                                        ForEach(0..<3) { index in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(index < strengthLevel(passwordStrength) ? passwordStrength.color : Theme.Colors.border)
                                                .frame(width: 20, height: 4)
                                        }
                                        
                                        Text(passwordStrength.text)
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(passwordStrength.color)
                                    }
                                }
                            }
                        }
                        
                        // Confirm password field
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Confirm Password")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "lock")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                if showConfirmPassword {
                                    TextField("Confirm password", text: $confirmPassword)
                                        .font(Theme.Typography.body)
                                        .focused($focusedField, equals: .confirmPassword)
                                } else {
                                    SecureField("Confirm password", text: $confirmPassword)
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
                            
                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("Passwords do not match")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.danger)
                            }
                        }
                        
                        // Terms acceptance
                        HStack(alignment: .top, spacing: Theme.Spacing.md) {
                            Button {
                                acceptTerms.toggle()
                            } label: {
                                Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20))
                                    .foregroundColor(acceptTerms ? Theme.Colors.primary : Theme.Colors.border)
                            }
                            
                            Text(.init("I agree to the [Terms of Service](\(AppConfig.termsOfServiceURLString)) and [Privacy Policy](\(AppConfig.privacyPolicyURLString))."))
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .tint(Theme.Colors.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .sensoryFeedback(.selection, trigger: acceptTerms)
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
                    SignInWithAppleButton(.signUp) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        Task {
                            await viewModel.signInWithApple(result: result)
                            if viewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radii.md))
                    .disabled(viewModel.isAppleSigningIn)
                    .overlay {
                        if viewModel.isAppleSigningIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    
                    // Sign up button
                    PrimaryButton(
                        title: "Sign up",
                        action: {
                            Task {
                                await performSignup()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !canSignUp
                    )
                    
                    // Login link
                    HStack(spacing: Theme.Spacing.xs) {
                        Text("Already have an account?")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Button {
                            dismiss()
                            viewModel.showLoginScreen = true
                        } label: {
                            Text("Log in")
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
    }
    
    // MARK: - Helper Methods
    
    private func strengthLevel(_ strength: PasswordStrength) -> Int {
        switch strength {
        case .none: return 0
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }
    
    private func handleOnSubmit() {
        switch focusedField {
        case .firstName:
            focusedField = .lastName
        case .lastName:
            focusedField = .email
        case .email:
            focusedField = .password
        case .password:
            focusedField = .confirmPassword
        case .confirmPassword:
            if canSignUp {
                Task {
                    await performSignup()
                }
            }
        case .none:
            break
        }
    }
    
    private func performSignup() async {
        let displayName = [firstName, lastName]
            .compactMap { $0.isEmpty ? nil : $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        
        await viewModel.signup(
            name: displayName.isEmpty ? email : displayName,
            email: email,
            password: password,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            phoneNumber: nil
        )
        
        if viewModel.isAuthenticated {
            dismiss()
        }
    }
}
