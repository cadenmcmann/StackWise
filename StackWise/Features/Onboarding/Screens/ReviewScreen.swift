import SwiftUI

// MARK: - ReviewScreen
struct ReviewScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Review Your Information")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Make sure everything looks right")
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
                    // Goals card
                    ReviewCard(
                        title: "Goals",
                        onEdit: { viewModel.goToStep(.goals) }
                    ) {
                        if viewModel.intake.goals.isEmpty {
                            Text("No goals selected")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        } else {
                            FlowLayout(spacing: Theme.Spacing.sm) {
                                ForEach(Array(viewModel.intake.goals), id: \.self) { goal in
                                    Tag(
                                        text: goal.rawValue,
                                        type: .info
                                    )
                                }
                            }
                        }
                    }
                    
                    // Basics card
                    ReviewCard(
                        title: "Basic Information",
                        onEdit: { viewModel.goToStep(.basics) }
                    ) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            InfoRow(label: "Age", value: "\(viewModel.intake.basics.age) years")
                            InfoRow(label: "Sex", value: viewModel.intake.basics.sex.rawValue)
                            InfoRow(label: "Height", value: "\(Int(viewModel.intake.basics.height)) cm")
                            InfoRow(label: "Weight", value: "\(Int(viewModel.intake.basics.weight)) kg")
                            if let bodyFat = viewModel.intake.basics.bodyFat {
                                InfoRow(label: "Body Fat", value: "\(Int(bodyFat))%")
                            }
                            InfoRow(label: "Stimulant Tolerance", value: viewModel.intake.basics.stimulantTolerance.rawValue)
                            InfoRow(label: "Budget", value: "$\(Int(viewModel.intake.basics.budgetPerMonth))/month")
                            
                            if !viewModel.intake.basics.dietaryPreferences.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("Dietary Preferences")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    FlowLayout(spacing: Theme.Spacing.xs) {
                                        ForEach(Array(viewModel.intake.basics.dietaryPreferences), id: \.self) { pref in
                                            Tag(text: pref.rawValue, type: .dietary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Risks card
                    ReviewCard(
                        title: "Health & Safety",
                        onEdit: { viewModel.goToStep(.risks) }
                    ) {
                        if viewModel.intake.risks.isEmpty {
                            Text("No health concerns selected")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        } else {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                ForEach(Array(viewModel.intake.risks), id: \.self) { risk in
                                    HStack(spacing: Theme.Spacing.sm) {
                                        Image(systemName: risk.isHardStop ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(risk.isHardStop ? Theme.Colors.danger : Theme.Colors.warning)
                                        
                                        Text(risk.rawValue)
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Priority card
                    ReviewCard(
                        title: "Top Priority",
                        onEdit: { viewModel.goToStep(.priority) }
                    ) {
                        Text(viewModel.intake.topPriorityText.isEmpty ? "No priority set" : viewModel.intake.topPriorityText)
                            .font(Theme.Typography.body)
                            .foregroundColor(viewModel.intake.topPriorityText.isEmpty ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Theme.Spacing.gutter)
            }
            
            // Footer button
            PrimaryButton(
                title: "Generate My Stack",
                icon: "sparkles",
                action: { viewModel.nextStep() }
            )
            .padding(Theme.Spacing.gutter)
        }
        .background(Theme.Colors.surface)
    }
}

// MARK: - ReviewCard
struct ReviewCard<Content: View>: View {
    let title: String
    let onEdit: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text(title)
                    .font(Theme.Typography.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: onEdit) {
                    Text("Edit")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            
            content()
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
    }
}

// MARK: - InfoRow
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}
