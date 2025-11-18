import SwiftUI

// MARK: - ProfileEditSheet
public struct ProfileEditSheet: View {
    @StateObject private var editViewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case firstName
        case lastName
        case phone
    }
    
    public init(container: DIContainer, user: User) {
        _editViewModel = StateObject(wrappedValue: ProfileEditViewModel(container: container, user: user))
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header info
                    VStack(spacing: Theme.Spacing.xs) {
                        Text("Edit your profile information")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        if let validationMessage = editViewModel.validationMessage {
                            Text(validationMessage)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.danger)
                                .multilineTextAlignment(.center)
                                .padding(.top, Theme.Spacing.xs)
                        }
                    }
                    .padding(.top, Theme.Spacing.lg)
                    
                    // Form fields
                    VStack(spacing: Theme.Spacing.lg) {
                        // First Name
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("First Name")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextField("First", text: $editViewModel.firstName)
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
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Last Name")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextField("Last", text: $editViewModel.lastName)
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
                        }
                        
                        // Email (Read-only)
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                Text("Email")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Spacer()
                                
                                Text("Cannot be changed")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.8))
                            }
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Text(editViewModel.email.isEmpty ? "No email address" : editViewModel.email)
                                    .font(Theme.Typography.body)
                                    .foregroundColor(editViewModel.email.isEmpty ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                                
                                Spacer()
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .fill(Theme.Colors.surfaceAlt.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radii.md)
                                    .stroke(Theme.Colors.border.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Phone Number
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
                                .padding(.leading, Theme.Spacing.xs)
                                
                                Divider()
                                    .frame(height: 24)
                                
                                TextField("(555) 123-4567", text: $editViewModel.phoneNumber)
                                    .font(Theme.Typography.body)
                                    .keyboardType(.phonePad)
                                    .focused($focusedField, equals: .phone)
                                    .onChange(of: editViewModel.phoneNumber) { oldValue, newValue in
                                        editViewModel.phoneNumber = editViewModel.formatPhoneNumber(newValue)
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
                    .padding(.horizontal, Theme.Spacing.gutter)
                }
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .background(Theme.Colors.surface)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        focusedField = nil
                        Task {
                            await editViewModel.saveChanges()
                            if editViewModel.showSuccessMessage {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primary)
                    .disabled(!editViewModel.hasChanges || !editViewModel.isValid || editViewModel.isLoading)
                }
            }
            .alert("Error", isPresented: $editViewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(editViewModel.errorMessage)
            }
            .overlay {
                if editViewModel.showSuccessMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Colors.success)
                            
                            Text(editViewModel.successMessage)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.md)
                                .fill(Theme.Colors.surface)
                                .shadow(
                                    color: Color.black.opacity(0.1),
                                    radius: 10,
                                    x: 0,
                                    y: 4
                                )
                        )
                        .padding(.bottom, Theme.Spacing.xxl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(Theme.Animation.standard, value: editViewModel.showSuccessMessage)
                }
            }
        }
        .interactiveDismissDisabled(editViewModel.hasChanges)
    }
}
