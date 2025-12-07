import SwiftUI

// MARK: - CustomTextField
public struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let keyboardType: UIKeyboardType
    @FocusState private var isFocused: Bool
    
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
                    .focused($isFocused)
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

// MARK: - Weight Unit
public enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"
    
    public func toKg(_ value: Double) -> Double {
        switch self {
        case .kg: return value
        case .lbs: return value * 0.453592
        }
    }
    
    public func fromKg(_ value: Double) -> Double {
        switch self {
        case .kg: return value
        case .lbs: return value / 0.453592
        }
    }
}

// MARK: - WeightInputField
public struct WeightInputField: View {
    let title: String
    @Binding var weightKg: Double
    @Binding var unit: WeightUnit
    @State private var weightText: String = ""
    @FocusState private var isFocused: Bool
    
    public init(
        title: String = "Weight",
        weightKg: Binding<Double>,
        unit: Binding<WeightUnit>
    ) {
        self.title = title
        self._weightKg = weightKg
        self._unit = unit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: Theme.Spacing.sm) {
                TextField(unit == .kg ? "70" : "154", text: $weightText)
                    .font(Theme.Typography.body)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: weightText) { _, newValue in
                        if let value = Double(newValue), value > 0 {
                            weightKg = unit.toKg(value)
                        }
                    }
                
                Picker("", selection: $unit) {
                    ForEach(WeightUnit.allCases, id: \.self) { u in
                        Text(u.rawValue).tag(u)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
                .onChange(of: unit) { oldUnit, newUnit in
                    // Convert displayed value when unit changes
                    if let currentValue = Double(weightText), currentValue > 0 {
                        let kgValue = oldUnit.toKg(currentValue)
                        let newValue = newUnit.fromKg(kgValue)
                        weightText = String(format: "%.0f", newValue)
                    }
                }
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
        .onAppear {
            if weightKg > 0 {
                weightText = String(format: "%.0f", unit.fromKg(weightKg))
            }
        }
    }
}

// MARK: - Height Unit
public enum HeightUnit: String, CaseIterable {
    case imperial = "ft/in"
    case metric = "cm"
}

// MARK: - HeightInputField
public struct HeightInputField: View {
    let title: String
    @Binding var heightCm: Double
    @Binding var unit: HeightUnit
    @State private var showPicker = false
    
    public init(
        title: String = "Height",
        heightCm: Binding<Double>,
        unit: Binding<HeightUnit>
    ) {
        self.title = title
        self._heightCm = heightCm
        self._unit = unit
    }
    
    private var displayText: String {
        guard heightCm > 0 else { return "Select height" }
        
        switch unit {
        case .imperial:
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        case .metric:
            return "\(Int(heightCm)) cm"
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Button(action: { showPicker = true }) {
                HStack {
                    Text(displayText)
                        .font(Theme.Typography.body)
                        .foregroundColor(heightCm > 0 ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
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
        .sheet(isPresented: $showPicker) {
            HeightPickerSheet(heightCm: $heightCm, unit: $unit)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - HeightPickerSheet
public struct HeightPickerSheet: View {
    @Binding var heightCm: Double
    @Binding var unit: HeightUnit
    @Environment(\.dismiss) private var dismiss
    
    // Imperial values
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 8
    
    // Metric value
    @State private var selectedCm: Int = 170
    
    private let feetRange = Array(3...8)
    private let inchesRange = Array(0...11)
    private let cmRange = Array(100...250)
    
    public init(heightCm: Binding<Double>, unit: Binding<HeightUnit>) {
        self._heightCm = heightCm
        self._unit = unit
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                // Unit toggle
                Picker("", selection: $unit) {
                    ForEach(HeightUnit.allCases, id: \.self) { u in
                        Text(u.rawValue).tag(u)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Theme.Spacing.gutter)
                .onChange(of: unit) { _, _ in
                    syncPickersFromCm()
                }
                
                // Pickers
                switch unit {
                case .imperial:
                    HStack(spacing: 0) {
                        // Feet picker
                        VStack {
                            Text("Feet")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Picker("Feet", selection: $selectedFeet) {
                                ForEach(feetRange, id: \.self) { ft in
                                    Text("\(ft)'").tag(ft)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                            .clipped()
                        }
                        
                        // Inches picker
                        VStack {
                            Text("Inches")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Picker("Inches", selection: $selectedInches) {
                                ForEach(inchesRange, id: \.self) { inch in
                                    Text("\(inch)\"").tag(inch)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                            .clipped()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                case .metric:
                    VStack {
                        Text("Centimeters")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Picker("Centimeters", selection: $selectedCm) {
                            ForEach(cmRange, id: \.self) { cm in
                                Text("\(cm) cm").tag(cm)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 200)
                    }
                }
                
                Spacer()
            }
            .padding(.top, Theme.Spacing.lg)
            .navigationTitle("Select Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveHeight()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadInitialValues()
            }
        }
    }
    
    private func loadInitialValues() {
        if heightCm > 0 {
            selectedCm = Int(heightCm)
            let totalInches = heightCm / 2.54
            selectedFeet = max(3, min(8, Int(totalInches / 12)))
            selectedInches = max(0, min(11, Int(totalInches.truncatingRemainder(dividingBy: 12))))
        } else {
            // Default values
            selectedCm = 170
            selectedFeet = 5
            selectedInches = 8
        }
    }
    
    private func syncPickersFromCm() {
        let totalInches = Double(selectedCm) / 2.54
        selectedFeet = max(3, min(8, Int(totalInches / 12)))
        selectedInches = max(0, min(11, Int(totalInches.truncatingRemainder(dividingBy: 12))))
    }
    
    private func saveHeight() {
        switch unit {
        case .imperial:
            let totalInches = Double(selectedFeet * 12 + selectedInches)
            heightCm = totalInches * 2.54
        case .metric:
            heightCm = Double(selectedCm)
        }
    }
}
