import SwiftUI

// MARK: - GoalsScreen
struct GoalsScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showMoreGoals = false
    @State private var selectedGoals: Set<String> = []
    @State private var availableGoals: [Goal] = []
    @State private var isLoadingGoals = true
    @Environment(\.container) private var container
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("What do you want to improve?")
                    .font(Theme.Typography.titleL)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Select all that apply")
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
                if isLoadingGoals {
                    LoadingView(message: "Loading goals...")
                        .frame(height: 200)
                } else {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Primary goals (first 12)
                        let primaryGoals = Array(availableGoals.prefix(12))
                        let additionalGoals = Array(availableGoals.dropFirst(12))
                        
                        ChipGroup(
                            chips: primaryGoals.map { goal in
                                ChipGroup.ChipData(
                                    id: goal.rawValue,
                                    label: goal.rawValue,
                                    icon: iconForGoal(goal)
                                )
                            },
                            selectedIds: $selectedGoals
                        )
                        
                        // See more button if there are additional goals
                        if !additionalGoals.isEmpty && !showMoreGoals {
                            TextButton(title: "See more goals") {
                                withAnimation(Theme.Animation.standard) {
                                    showMoreGoals = true
                                }
                            }
                        }
                        
                        // Additional goals
                        if showMoreGoals && !additionalGoals.isEmpty {
                            Divider()
                            
                            ChipGroup(
                                chips: additionalGoals.map { goal in
                                    ChipGroup.ChipData(
                                        id: goal.rawValue,
                                        label: goal.rawValue,
                                        icon: iconForGoal(goal)
                                    )
                                },
                                selectedIds: $selectedGoals
                            )
                        }
                    }
                    .padding(Theme.Spacing.gutter)
                }
            }
            
            Spacer()
            
            // Footer buttons
            HStack(spacing: Theme.Spacing.md) {
                SecondaryButton(
                    title: "Skip",
                    action: { viewModel.nextStep() }
                )
                .frame(maxWidth: .infinity)
                
                PrimaryButton(
                    title: "Next",
                    action: {
                        saveGoals()
                        viewModel.nextStep()
                    },
                    isDisabled: selectedGoals.isEmpty
                )
                .frame(maxWidth: .infinity)
            }
            .padding(Theme.Spacing.gutter)
        }
        .background(Theme.Colors.surface)
        .onAppear {
            // Load existing goals if any
            selectedGoals = Set(viewModel.intake.goals.map { $0.rawValue })
            
            // Use all predefined goals (they match the backend exactly)
            availableGoals = Goal.allCases
            isLoadingGoals = false
        }
    }
    
    private func saveGoals() {
        viewModel.intake.goals = Set(selectedGoals.compactMap { Goal(rawValue: $0) })
    }
    
    private func iconForGoal(_ goal: Goal) -> String? {
        switch goal {
        // Energy
        case .boostEnergyStimulant: return "bolt.fill"
        case .boostEnergyNonStimulant: return "bolt"
        
        // Sexual Health
        case .boostLibido: return "heart.fill"
        case .boostTestosterone: return "figure.strengthtraining.traditional"
        
        // Muscle & Recovery
        case .buildMuscle: return "figure.strengthtraining.functional"
        case .enhanceRecovery: return "arrow.triangle.2.circlepath"
        case .increaseStrength: return "dumbbell.fill"
        case .reduceMuscularSoreness: return "bandage"
        
        // Sleep
        case .fallAsleepFaster: return "moon.zzz.fill"
        case .improveSleepQuality: return "bed.double"
        case .wakeRefreshed: return "sun.and.horizon"
        
        // Physical Performance
        case .improveEndurance: return "figure.run"
        case .improveFlexibility: return "figure.yoga"
        
        // Mental Health
        case .improveFocus: return "brain.head.profile"
        case .improveMood: return "sun.max.fill"
        case .reduceAnxiety: return "leaf.fill"
        case .reduceStress: return "leaf"
        case .supportCalm: return "drop.halffull"
        case .supportMemory: return "brain"
        
        // Health & Wellness
        case .improveGutHealth: return "leaf.arrow.circlepath"
        case .reduceInflammation: return "waveform.path.ecg"
        case .strengthenBones: return "figure.stand"
        case .strengthenNails: return "hand.raised.fill"
        case .supportHairGrowth: return "sparkles"
        case .supportHealthyBloodSugar: return "chart.line.uptrend.xyaxis"
        case .supportHealthyEstrogenBalance: return "circle.hexagongrid"
        case .supportHealthyWeightGain: return "plus.circle.fill"
        case .supportHeartHealth: return "heart.circle.fill"
        case .supportHormoneHealthGeneral: return "circle.hexagongrid.fill"
        case .supportImmuneFunction: return "shield.fill"
        case .supportJointHealth: return "figure.walk"
        case .supportLiverHealth: return "cross.circle"
        case .supportLongevity: return "infinity"
        case .supportSkinHealth: return "face.smiling"
        case .supportWeightLoss: return "arrow.down.circle.fill"
        }
    }
}
