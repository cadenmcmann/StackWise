import SwiftUI

// MARK: - CardTagData
public struct CardTagData: Identifiable {
    public let id = UUID()
    public let text: String
    public let type: TagType
    
    public enum TagType {
        case timing
        case evidence
        case dietary
        case stimulantFree
        case info
        
        var backgroundColor: Color {
            switch self {
            case .timing: return Theme.Colors.primary.opacity(0.1)
            case .evidence: return Theme.Colors.success.opacity(0.1)
            case .dietary: return Theme.Colors.info.opacity(0.1)
            case .stimulantFree: return Theme.Colors.warning.opacity(0.1)
            case .info: return Theme.Colors.surfaceAlt
            }
        }
        
        var textColor: Color {
            switch self {
            case .timing: return Theme.Colors.primary
            case .evidence: return Theme.Colors.success
            case .dietary: return Theme.Colors.info
            case .stimulantFree: return Theme.Colors.warning
            case .info: return Theme.Colors.textSecondary
            }
        }
    }
    
    public init(text: String, type: TagType) {
        self.text = text
        self.type = type
    }
}

// MARK: - Card
public struct Card<Content: View>: View {
    let title: String
    let subtitle: String?
    let tags: [CardTagData]
    let isExpanded: Binding<Bool>?
    let content: () -> Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        tags: [CardTagData] = [],
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.tags = tags
        self.isExpanded = isExpanded
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(title)
                        .font(Theme.Typography.titleM)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.subhead)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let isExpanded = isExpanded {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
                        .animation(Theme.Animation.quick, value: isExpanded.wrappedValue)
                }
            }
            
            // Tags
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(tags) { tag in
                            Tag(text: tag.text, type: tag.type)
                        }
                    }
                }
            }
            
            // Expandable content
            if let isExpanded = isExpanded, isExpanded.wrappedValue {
                Divider()
                content()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else if isExpanded == nil {
                // Always show content if not expandable
                content()
            }
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
        .contentShape(Rectangle())
        .onTapGesture {
            if let isExpanded = isExpanded {
                withAnimation(Theme.Animation.standard) {
                    isExpanded.wrappedValue.toggle()
                }
            }
        }
    }
}

// MARK: - Tag
public struct Tag: View {
    let text: String
    let type: CardTagData.TagType
    
    public init(text: String, type: CardTagData.TagType) {
        self.text = text
        self.type = type
    }
    
    public var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .foregroundColor(type.textColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.sm)
                    .fill(type.backgroundColor)
            )
    }
}
