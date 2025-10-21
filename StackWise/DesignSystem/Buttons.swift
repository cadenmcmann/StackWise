import SwiftUI

// MARK: - PrimaryButton
public struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    public init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                
                Text(title)
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Accessibility
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .fill(isDisabled ? Theme.Colors.disabled : Theme.Colors.primary)
            )
            .foregroundColor(.white)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - SecondaryButton
public struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDisabled: Bool
    
    public init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                
                Text(title)
                    .font(Theme.Typography.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Accessibility
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .stroke(isDisabled ? Theme.Colors.disabled : Theme.Colors.primary, lineWidth: 1.5)
            )
            .foregroundColor(isDisabled ? Theme.Colors.disabled : Theme.Colors.primary)
        }
        .disabled(isDisabled)
    }
}

// MARK: - TextButton
public struct TextButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
