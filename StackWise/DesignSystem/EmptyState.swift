import SwiftUI

// MARK: - EmptyState
public struct EmptyState: View {
    let icon: String
    let title: String
    let subtitle: String?
    let primaryAction: (() -> Void)?
    let primaryActionTitle: String?
    
    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        primaryActionTitle: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.primaryAction = primaryAction
        self.primaryActionTitle = primaryActionTitle
    }
    
    public var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            
            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if let action = primaryAction, let title = primaryActionTitle {
                PrimaryButton(title: title, action: action)
                    .padding(.horizontal, Theme.Spacing.xxl)
            }
        }
        .padding(Theme.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
