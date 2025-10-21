import SwiftUI

// MARK: - Chip
public struct Chip: View {
    let label: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        label: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(label)
                    .font(Theme.Typography.subhead)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.xl)
                    .fill(isSelected ? Theme.Colors.primary : Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radii.xl)
                            .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.border, lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : Theme.Colors.textPrimary)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .frame(minHeight: 44) // Accessibility minimum touch target
        .animation(Theme.Animation.quick, value: isSelected)
    }
}

// MARK: - ChipGroup
public struct ChipGroup: View {
    let chips: [ChipData]
    @Binding var selectedIds: Set<String>
    let allowMultipleSelection: Bool
    
    public struct ChipData: Identifiable {
        public let id: String
        public let label: String
        public let icon: String?
        
        public init(id: String, label: String, icon: String? = nil) {
            self.id = id
            self.label = label
            self.icon = icon
        }
    }
    
    public init(
        chips: [ChipData],
        selectedIds: Binding<Set<String>>,
        allowMultipleSelection: Bool = true
    ) {
        self.chips = chips
        self._selectedIds = selectedIds
        self.allowMultipleSelection = allowMultipleSelection
    }
    
    public var body: some View {
        FlowLayout(spacing: Theme.Spacing.sm) {
            ForEach(chips) { chip in
                Chip(
                    label: chip.label,
                    icon: chip.icon,
                    isSelected: selectedIds.contains(chip.id)
                ) {
                    if allowMultipleSelection {
                        if selectedIds.contains(chip.id) {
                            selectedIds.remove(chip.id)
                        } else {
                            selectedIds.insert(chip.id)
                        }
                    } else {
                        selectedIds = [chip.id]
                    }
                }
            }
        }
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                     y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let dimensions = subview.dimensions(in: .unspecified)
                
                if x + dimensions.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                
                x += dimensions.width + spacing
                lineHeight = max(lineHeight, dimensions.height)
                size.width = max(size.width, x - spacing)
            }
            size.height = y + lineHeight
        }
    }
}
