import SwiftUI

// MARK: - StackView
public struct StackView: View {
    @StateObject private var viewModel: StackViewModel
    @State private var showExportSuccess = false
    @State private var selectedSupplement: Supplement?
    @State private var showInactiveSupplements = false
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: StackViewModel(container: container))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if let stack = viewModel.stack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                            // Active supplements
                            if !stack.activeSupplements.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Your personalized stack")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    
                                    ForEach(stack.activeSupplements) { supplement in
                                        SupplementCard(supplement: supplement) {
                                            selectedSupplement = supplement
                                        }
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    }
                                }
                            }
                            
                            // Show/Hide inactive supplements button
                            if !stack.inactiveSupplements.isEmpty {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showInactiveSupplements.toggle()
                                    }
                                } label: {
                                    HStack(spacing: Theme.Spacing.xs) {
                                        Text(showInactiveSupplements ? "Hide inactive supplements" : "Show inactive supplements")
                                            .font(Theme.Typography.caption)
                                        Image(systemName: showInactiveSupplements ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(Theme.Colors.textSecondary)
                                }
                                .padding(.horizontal, Theme.Spacing.gutter)
                                .padding(.vertical, Theme.Spacing.sm)
                            }
                            
                            // Inactive supplements section (when shown)
                            if showInactiveSupplements && !stack.inactiveSupplements.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Inactive Supplements")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    
                                    ForEach(stack.inactiveSupplements) { supplement in
                                        SupplementCard(supplement: supplement) {
                                            selectedSupplement = supplement
                                        }
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                        .opacity(0.7)
                                    }
                                }
                            }
                            
                            // Action buttons
                            VStack(spacing: Theme.Spacing.md) {
                                PrimaryButton(
                                    title: "Start Schedule",
                                    icon: "calendar",
                                    action: { viewModel.startSchedule() }
                                )
                                
                                SecondaryButton(
                                    title: "Remix Stack",
                                    icon: "arrow.triangle.2.circlepath",
                                    action: { viewModel.showRemixSheet = true }
                                )
                            }
                            .padding(Theme.Spacing.gutter)
                        }
                        .padding(.vertical, Theme.Spacing.lg)
                    }
                } else {
                    EmptyStateView()
                }
                
                if viewModel.isLoading {
                    LoadingView(message: "Updating your stack...")
                }
            }
            .navigationTitle("Stack")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    Task {
                        if await viewModel.exportStack() != nil {
                            showExportSuccess = true
                        }
                    }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showRemixSheet) {
                RemixSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedSupplement) { supplement in
                if let binding = viewModel.bindingForSupplement(supplement) {
                    SupplementDetailSheet(
                        supplement: supplement,
                        stackId: viewModel.stack?.id,
                        isActive: binding,
                        onToggleActive: { newValue in
                            await viewModel.toggleSupplementActive(supplementId: supplement.id, active: newValue)
                        }
                    )
                }
            }
        }
        .toast(
            isShowing: $showExportSuccess,
            message: "Stack exported successfully",
            type: .success
        )
    }
}

// MARK: - SupplementCard
struct SupplementCard: View {
    let supplement: Supplement
    let onTap: () -> Void
    
    var body: some View {
        Card(
            title: supplement.name,
            subtitle: supplement.purposeShort ?? supplement.rationale,
            tags: createTags(),
            isExpanded: nil,  // Don't use expand/collapse - we'll show details in modal
            onTap: onTap  // Pass through our custom tap handler
        ) {
            // Dose info
            HStack(spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text(supplement.doseRangeText)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                if let formNote = supplement.formNote {
                    Text("• \(formNote)")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Tap to view details hint
                HStack(spacing: Theme.Spacing.xs) {
                    Text("Tap for details")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primary)
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }
    
    private func createTags() -> [CardTagData] {
        var tags: [CardTagData] = []
        
        // Add blue timing tags from schedule.times
        if let schedule = supplement.schedule {
            for time in schedule.times {
                tags.append(CardTagData(
                    text: time.capitalized,
                    type: .timing
                ))
            }
        }
        
        // Add green goal tags from tags array
        for tag in supplement.tags {
            tags.append(CardTagData(
                text: tag,
                type: .info
            ))
        }
        
        return tags
    }
}

// MARK: - FilterChip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Chip(
            label: label,
            icon: isSelected ? "checkmark" : nil,
            isSelected: isSelected,
            action: action
        )
    }
}

// MARK: - RemixSheet
struct RemixSheet: View {
    @ObservedObject var viewModel: StackViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    Text("Adjust your stack based on your preferences")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    VStack(spacing: Theme.Spacing.lg) {
                        CustomToggle(
                            title: "Fewer Pills",
                            subtitle: "Reduce the number of supplements",
                            isOn: $viewModel.remixOptions.fewerPills
                        )
                        
                        CustomToggle(
                            title: "Cheaper Options",
                            subtitle: "Optimize for budget-friendly choices",
                            isOn: $viewModel.remixOptions.cheaper
                        )
                        
                        CustomToggle(
                            title: "Stimulant-Free",
                            subtitle: "Remove all stimulants",
                            isOn: $viewModel.remixOptions.stimulantFree
                        )
                        
                        CustomToggle(
                            title: "Athlete Mode",
                            subtitle: "Optimize for athletic performance",
                            isOn: $viewModel.remixOptions.athleteMode
                        )
                    }
                }
                .padding(Theme.Spacing.gutter)
                
                Spacer()
                
                VStack(spacing: Theme.Spacing.md) {
                    PrimaryButton(
                        title: "Apply Changes",
                        action: {
                            Task {
                                await viewModel.remixStack()
                                dismiss()
                            }
                        },
                        isLoading: viewModel.isLoading
                    )
                    
                    SecondaryButton(
                        title: "Cancel",
                        action: { dismiss() }
                    )
                }
                .padding(Theme.Spacing.gutter)
            }
            .navigationTitle("Remix Options")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    var body: some View {
        EmptyState(
            icon: "pills",
            title: "No Stack Generated",
            subtitle: "Complete the onboarding to get your personalized supplement recommendations",
            primaryAction: {
                // TODO: Navigate to onboarding
            },
            primaryActionTitle: "Get Started"
        )
    }
}
