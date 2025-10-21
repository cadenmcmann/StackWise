import SwiftUI

// MARK: - SignupScreen
struct SignupScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var acceptTerms = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case name
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
        !name.isEmpty && isValidEmail && passwordsMatch && acceptTerms
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
                        // Name field
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Name")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "person")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextField("Your name", text: $name)
                                    .font(Theme.Typography.body)
                                    .focused($focusedField, equals: .name)
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .fill(Theme.Colors.surfaceAlt)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .stroke(
                                        focusedField == .name ? Theme.Colors.primary : Theme.Colors.border,
                                        lineWidth: focusedField == .name ? 2 : 1
                                    )
                            )
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
                            
                            Text("At least 8 characters")
                                .font(Theme.Typography.caption)
                                .foregroundColor(password.count >= 8 ? Theme.Colors.success : Theme.Colors.textSecondary)
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
                            
                            Text("I agree to the Terms of Service and Privacy Policy")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.leading)
                                .onTapGesture {
                                    acceptTerms.toggle()
                                }
                            
                            Spacer()
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
                    
                    // Sign up button
                    PrimaryButton(
                        title: "Sign up",
                        action: {
                            Task {
                                await viewModel.signup(name: name, email: email, password: password)
                                if viewModel.isAuthenticated {
                                    dismiss()
                                }
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
            switch focusedField {
            case .name:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                if canSignUp {
                    Task {
                        await viewModel.signup(name: name, email: email, password: password)
                        if viewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                }
            case .none:
                break
            }
        }
    }
}

