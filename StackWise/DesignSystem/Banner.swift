import SwiftUI

// MARK: - Banner
public struct Banner: View {
    public enum BannerType {
        case info
        case warning
        case danger
        case success
        
        var backgroundColor: Color {
            switch self {
            case .info: return Theme.Colors.info.opacity(0.1)
            case .warning: return Theme.Colors.warning.opacity(0.1)
            case .danger: return Theme.Colors.danger.opacity(0.1)
            case .success: return Theme.Colors.success.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .info: return Theme.Colors.info
            case .warning: return Theme.Colors.warning
            case .danger: return Theme.Colors.danger
            case .success: return Theme.Colors.success
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .danger: return "xmark.octagon.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
    }
    
    let type: BannerType
    let title: String
    let message: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    public init(
        type: BannerType,
        title: String,
        message: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.action = action
        self.actionTitle = actionTitle
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.borderColor)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if let message = message {
                    Text(message)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(type.borderColor)
                    }
                    .padding(.top, Theme.Spacing.xs)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(type.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .stroke(type.borderColor.opacity(0.3), lineWidth: 1)
        )
    }
}
