import SwiftUI

// MARK: - ProfileView
public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(container: container))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Account Information Section
                        AccountInformationSection(viewModel: viewModel)
                            .padding(.horizontal, Theme.Spacing.gutter)
                        
                        // Security Section
                        SecuritySection(viewModel: viewModel)
                        
                        // Account Actions Section
                        AccountActionsSection(viewModel: viewModel)
                        
                        // Legal & Safety section
                        LegalSafetySection(viewModel: viewModel)
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(Theme.Typography.titleM)
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $viewModel.showEditProfile) {
                if let user = viewModel.user {
                    ProfileEditSheet(container: container, user: user)
                        .onDisappear {
                            viewModel.loadUserData()
                        }
                }
            }
            .sheet(isPresented: $viewModel.showPasswordReset) {
                if let user = viewModel.user {
                    PasswordResetFromProfile(user: user, container: container)
                }
            }
            .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .toast(
            isShowing: $viewModel.showExportSuccess,
            message: "Export successful",
            type: .success
        )
    }
}

// MARK: - AccountInformationSection
struct AccountInformationSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient background top section
            ZStack(alignment: .topTrailing) {
                // Gradient background
                LinearGradient(
                    colors: [
                        Theme.Colors.primary.opacity(0.08),
                        Theme.Colors.primary.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                
                // Edit button
                Button {
                    viewModel.showEditProfile = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.Colors.primary)
                        .background(
                            Circle()
                                .fill(Theme.Colors.surface)
                                .frame(width: 32, height: 32)
                        )
                }
                .padding(Theme.Spacing.md)
            }
            
            // Profile content
            VStack(spacing: Theme.Spacing.lg) {
                // Avatar with initials - overlapping the gradient
                ZStack {
                    Circle()
                        .fill(Theme.Colors.surface)
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.primary.opacity(0.9),
                                    Theme.Colors.primary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 84, height: 84)
                    
                    Text(viewModel.user?.initials ?? "U")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .offset(y: -45)
                .padding(.bottom, -30)
                
                // Name
                if let displayName = viewModel.user?.displayName {
                    Text(displayName)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                
                // Contact info with icons
                VStack(spacing: Theme.Spacing.md) {
                    // Email
                    if let email = viewModel.user?.email, !email.isEmpty {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.primary.opacity(0.7))
                                .frame(width: 20)
                            
                            Text(email)
                                .font(.system(size: 15))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                        }
                    }
                    
                    // Phone
                    if let phone = viewModel.user?.phoneNumber, !phone.isEmpty {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.primary.opacity(0.7))
                                .frame(width: 20)
                            
                            Text(formatPhoneForDisplay(phone))
                                .font(.system(size: 15))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                        }
                    }
                    
                    // Member since
                    if let createdAt = viewModel.user?.createdAt {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.primary.opacity(0.7))
                                .frame(width: 20)
                            
                            Text("Member since \(formatDate(createdAt))")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.xl)
                .fill(Theme.Colors.surface)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    private func formatPhoneForDisplay(_ phone: String) -> String {
        // Remove country code if present and format
        let digits = phone.replacingOccurrences(of: "+1", with: "").filter { $0.isNumber }
        
        guard digits.count >= 10 else { return phone }
        
        let areaCode = String(digits.prefix(3))
        let middle = String(digits.dropFirst(3).prefix(3))
        let last = String(digits.dropFirst(6).prefix(4))
        
        return "(\(areaCode)) \(middle)-\(last)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - SecuritySection
struct SecuritySection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Security")
                .font(Theme.Typography.subhead)
                .fontWeight(.semibold)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.gutter)
            
            VStack(spacing: Theme.Spacing.sm) {
                Button {
                    viewModel.showPasswordReset = true
                } label: {
                    HStack {
                        Image(systemName: "key")
                            .font(.system(size: 20))
                        
                        Text("Change Password")
                            .font(Theme.Typography.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radii.md)
                            .fill(Theme.Colors.surfaceAlt)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, Theme.Spacing.gutter)
        }
    }
}

// MARK: - AccountActionsSection
struct AccountActionsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Account Actions")
                .font(Theme.Typography.subhead)
                .fontWeight(.semibold)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.gutter)
            
            VStack(spacing: Theme.Spacing.sm) {
                Button {
                    Task {
                        await viewModel.signOut()
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                        
                        Text("Sign Out")
                            .font(Theme.Typography.body)
                        
                        Spacer()
                    }
                    .foregroundColor(Theme.Colors.primary)
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radii.md)
                            .fill(Theme.Colors.primary.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    viewModel.showDeleteAccountAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                        
                        Text("Delete Account")
                            .font(Theme.Typography.body)
                        
                        Spacer()
                    }
                    .foregroundColor(Theme.Colors.danger)
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radii.md)
                            .fill(Theme.Colors.danger.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, Theme.Spacing.gutter)
        }
    }
}

// MARK: - LegalSafetySection
struct LegalSafetySection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Legal & Safety")
                .font(Theme.Typography.subhead)
                .fontWeight(.semibold)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.gutter)
            
            VStack(spacing: Theme.Spacing.sm) {
                LegalRow(
                    icon: "doc.text",
                    title: "Terms of Service",
                    action: {
                        // Open terms
                    }
                )
                
                LegalRow(
                    icon: "lock.shield",
                    title: "Privacy Policy",
                    action: {
                        // Open privacy
                    }
                )
                
                LegalRow(
                    icon: "exclamationmark.triangle",
                    title: "Safety Disclaimers",
                    action: {
                        // Open disclaimers
                    }
                )
            }
            .padding(.horizontal, Theme.Spacing.gutter)
        }
    }
}

// MARK: - LegalRow
struct LegalRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .fill(Theme.Colors.surfaceAlt)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PasswordResetFromProfile
struct PasswordResetFromProfile: View {
    let user: User
    let container: DIContainer
    @StateObject private var resetViewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(user: User, container: DIContainer) {
        self.user = user
        self.container = container
        _resetViewModel = StateObject(wrappedValue: ForgotPasswordViewModel(container: container))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch resetViewModel.currentStep {
                case .contactInput:
                    // Pre-fill contact info from user profile
                    ContactInputView(viewModel: resetViewModel, dismiss: dismiss)
                        .onAppear {
                            if let email = user.email, !email.isEmpty {
                                resetViewModel.contactMethod = .email
                                resetViewModel.email = email
                            } else if let phone = user.phoneNumber, !phone.isEmpty {
                                resetViewModel.contactMethod = .phone
                                // Remove country code for display
                                resetViewModel.phoneNumber = phone.replacingOccurrences(of: "+1", with: "")
                                    .filter { $0.isNumber }
                                // Format it
                                resetViewModel.phoneNumber = formatPhoneForPasswordReset(resetViewModel.phoneNumber)
                            }
                        }
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
    
    private func formatPhoneForPasswordReset(_ digits: String) -> String {
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
