import SwiftUI

// MARK: - RisksScreen
struct RisksScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedRisks: Set<Risk> = []
    @State private var showHardStopAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Health & Safety")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Select any that apply to you")
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
                VStack(spacing: Theme.Spacing.lg) {
                    // Medications section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Medications")
                            .font(Theme.Typography.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        ForEach(medicationRisks, id: \.self) { risk in
                            RiskToggleRow(
                                risk: risk,
                                isSelected: selectedRisks.contains(risk),
                                onToggle: { toggleRisk(risk) }
                            )
                        }
                    }
                    
                    Divider()
                    
                    // Health conditions section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Health Conditions")
                            .font(Theme.Typography.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        ForEach(conditionRisks, id: \.self) { risk in
                            RiskToggleRow(
                                risk: risk,
                                isSelected: selectedRisks.contains(risk),
                                onToggle: { toggleRisk(risk) }
                            )
                        }
                    }
                    
                    // Warning banners for selected risks
                    if !selectedRisks.isEmpty {
                        VStack(spacing: Theme.Spacing.md) {
                            ForEach(Array(selectedRisks), id: \.self) { risk in
                                Banner(
                                    type: risk.isHardStop ? .danger : .warning,
                                    title: risk.isHardStop ? "Important Notice" : "Adjustment Made",
                                    message: risk.warningMessage
                                )
                            }
                        }
                        .padding(.top, Theme.Spacing.lg)
                    }
                }
                .padding(Theme.Spacing.gutter)
            }
            
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
                        saveRisks()
                        if hasHardStopRisk() {
                            showHardStopAlert = true
                        } else {
                            viewModel.nextStep()
                        }
                    }
                )
            }
            .padding(Theme.Spacing.gutter)
        }
        .background(Theme.Colors.surface)
        .onAppear {
            selectedRisks = viewModel.intake.risks
        }
        .alert("Unable to Continue", isPresented: $showHardStopAlert) {
            Button("Download Summary", role: .none) {
                Task {
                    _ = await viewModel.exportSummaryForClinician()
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Based on your selections, we cannot safely recommend supplements. Please consult with your healthcare provider. You can download a summary to share with them.")
        }
    }
    
    private var medicationRisks: [Risk] {
        [.bloodPressureMeds, .bloodThinners, .antidepressants, .anxietyMeds, .diabetesMeds, .thyroidMeds]
    }
    
    private var conditionRisks: [Risk] {
        [.heartCondition, .kidneyDisease, .liverDisease, .pregnancy, .cancer, .autoimmune]
    }
    
    private func toggleRisk(_ risk: Risk) {
        if selectedRisks.contains(risk) {
            selectedRisks.remove(risk)
        } else {
            selectedRisks.insert(risk)
        }
    }
    
    private func saveRisks() {
        viewModel.intake.risks = selectedRisks
    }
    
    private func hasHardStopRisk() -> Bool {
        selectedRisks.contains { $0.isHardStop }
    }
}

// MARK: - RiskToggleRow
struct RiskToggleRow: View {
    let risk: Risk
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(risk.rawValue)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if risk.isHardStop {
                    Text("Requires medical consultation")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.danger)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(isSelected))
                .labelsHidden()
                .onTapGesture { onToggle() }
        }
        .padding(.vertical, Theme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}
