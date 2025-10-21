import SwiftUI

// MARK: - CustomTextField
public struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let keyboardType: UIKeyboardType
    
    public init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .keyboardType(keyboardType)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .fill(Theme.Colors.surfaceAlt)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - CustomSlider
public struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: String
    
    public init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        format: String = "%.0f"
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text(title)
                    .font(Theme.Typography.subhead)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text(String(format: format, value))
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(Theme.Colors.primary)
        }
    }
}

// MARK: - CustomToggle
public struct CustomToggle: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    public init(
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(Theme.Colors.primary)
    }
}

// MARK: - SegmentedControl
public struct SegmentedControl<T: Hashable>: View {
    let title: String?
    @Binding var selection: T
    let options: [(T, String)]
    
    public init(
        title: String? = nil,
        selection: Binding<T>,
        options: [(T, String)]
    ) {
        self.title = title
        self._selection = selection
        self.options = options
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            if let title = title {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
