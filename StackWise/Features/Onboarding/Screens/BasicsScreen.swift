import SwiftUI

// MARK: - BasicsScreen
struct BasicsScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var ageText = ""
    @State private var bodyFatText = ""
    @State private var weightUnit: WeightUnit = .lbs
    @State private var heightUnit: HeightUnit = .imperial
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Basic Information")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Help us personalize your recommendations")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, Theme.Spacing.xxl)
            
            // Progress indicator
            ProgressView(value: viewModel.currentStep.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.Colors.primary))
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.top, Theme.Spacing.lg)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Personal Information
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        Text("Personal")
                            .font(Theme.Typography.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HStack(spacing: Theme.Spacing.md) {
                            CustomTextField(
                                title: "Age",
                                text: $ageText,
                                placeholder: "25",
                                keyboardType: .numberPad
                            )
                            .frame(maxWidth: .infinity)
                            .onChange(of: ageText) { _, newValue in
                                viewModel.intake.basics.age = Int(newValue) ?? 0
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Sex")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                Picker("Sex", selection: $viewModel.intake.basics.sex) {
                                    ForEach(User.Sex.allCases, id: \.self) { sex in
                                        Text(sex.rawValue).tag(sex)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        HeightInputField(
                            title: "Height",
                            heightCm: $viewModel.intake.basics.height,
                            unit: $heightUnit
                        )
                        
                        WeightInputField(
                            title: "Weight",
                            weightKg: $viewModel.intake.basics.weight,
                            unit: $weightUnit
                        )
                        
                        CustomTextField(
                            title: "Body Fat % (optional)",
                            text: $bodyFatText,
                            placeholder: "20",
                            keyboardType: .decimalPad
                        )
                        .onChange(of: bodyFatText) { _, newValue in
                            viewModel.intake.basics.bodyFat = newValue.isEmpty ? nil : Double(newValue)
                        }
                    }
                    
                    Divider()
                    
                    // Supplement Preferences
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        Text("Supplement Preferences")
                            .font(Theme.Typography.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        SegmentedControl(
                            title: "Stimulant Tolerance",
                            selection: $viewModel.intake.basics.stimulantTolerance,
                            options: User.StimulantTolerance.allCases.map { ($0, $0.rawValue) }
                        )
                    }
                }
                .padding(Theme.Spacing.gutter)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Footer buttons
            HStack(spacing: Theme.Spacing.md) {
                SecondaryButton(
                    title: "Back",
                    icon: "chevron.left",
                    action: { viewModel.previousStep() }
                )
                
                PrimaryButton(
                    title: "Next",
                    action: {
                        saveBasics()
                        viewModel.nextStep()
                    },
                    isDisabled: !viewModel.canProceed()
                )
            }
            .padding(Theme.Spacing.gutter)
        }
        .background(Theme.Colors.surface)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
    }
    
    private func loadExistingData() {
        ageText = viewModel.intake.basics.age > 0 ? "\(viewModel.intake.basics.age)" : ""
        if let bodyFat = viewModel.intake.basics.bodyFat {
            bodyFatText = "\(Int(bodyFat))"
        }
    }
    
    private func saveBasics() {
        viewModel.intake.basics.age = Int(ageText) ?? 0
        viewModel.intake.basics.bodyFat = bodyFatText.isEmpty ? nil : Double(bodyFatText)
    }
}
