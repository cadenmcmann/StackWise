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
                        // User info header
                        if let user = viewModel.user {
                            UserHeaderCard(user: user)
                                .padding(.horizontal, Theme.Spacing.gutter)
                        }
                        
                        // Legal & Safety section
                        LegalSafetySection(viewModel: viewModel)
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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
        .toast(
            isShowing: $viewModel.showExportSuccess,
            message: "Export successful",
            type: .success
        )
    }
}

// MARK: - UserHeaderCard
struct UserHeaderCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Text(user.sex.rawValue.prefix(1))
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Profile")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                HStack(spacing: Theme.Spacing.md) {
                    InfoPill(text: "\(user.age) years")
                    InfoPill(text: user.sex.rawValue)
                    InfoPill(text: "$\(Int(user.budgetPerMonth))/mo")
                }
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .fill(Theme.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - InfoPill
struct InfoPill: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.textSecondary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.sm)
                    .fill(Theme.Colors.surfaceAlt)
            )
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
