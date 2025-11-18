import SwiftUI

// MARK: - ContactMethod
public enum ContactMethod: String, CaseIterable {
    case email = "Email"
    case phone = "Phone"
}

// MARK: - ContactMethodToggle
/// A segmented control for selecting between email and phone contact methods
public struct ContactMethodToggle: View {
    @Binding var selectedMethod: ContactMethod
    @Namespace private var animationNamespace
    
    public init(selectedMethod: Binding<ContactMethod>) {
        self._selectedMethod = selectedMethod
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(ContactMethod.allCases, id: \.self) { method in
                toggleButton(for: method)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(Theme.Colors.surfaceAlt)
        )
    }
    
    private func toggleButton(for method: ContactMethod) -> some View {
        Button {
            withAnimation(Theme.Animation.quick) {
                selectedMethod = method
            }
        } label: {
            Text(method.rawValue)
                .font(Theme.Typography.body)
                .fontWeight(selectedMethod == method ? .semibold : .regular)
                .foregroundColor(selectedMethod == method ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    ZStack {
                        if selectedMethod == method {
                            RoundedRectangle(cornerRadius: Theme.Radii.sm)
                                .fill(Theme.Colors.surface)
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                                .matchedGeometryEffect(id: "selected", in: animationNamespace)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ContactMethodToggle_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedMethod = ContactMethod.email
        
        var body: some View {
            VStack(spacing: Theme.Spacing.xl) {
                ContactMethodToggle(selectedMethod: $selectedMethod)
                
                Text("Selected: \(selectedMethod.rawValue)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.gutter)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
