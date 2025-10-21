import SwiftUI

// MARK: - StackView
public struct StackView: View {
    @StateObject private var viewModel: StackViewModel
    @State private var showExportSuccess = false
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: StackViewModel(container: container))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if let stack = viewModel.filteredStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                            // Stack section
                            if !stack.minimal.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Your personalized stack")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    
                                    ForEach(stack.minimal) { supplement in
                                        SupplementCard(
                                            supplement: supplement,
                                            isExpanded: viewModel.expandedSupplementIds.contains(supplement.id)
                                        ) {
                                            viewModel.toggleSupplementExpanded(supplement.id)
                                        }
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    }
                                }
                            }
                            
                            // Optional Add-Ons section
                            if !stack.addons.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                    Text("Optional Add-Ons")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    
                                    Text("Consider these for enhanced benefits")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .padding(.horizontal, Theme.Spacing.gutter)
                                    
                                    ForEach(stack.addons) { supplement in
                                        SupplementCard(
                                            supplement: supplement,
                                            isExpanded: viewModel.expandedSupplementIds.contains(supplement.id)
                                        ) {
                                            viewModel.toggleSupplementExpanded(supplement.id)
                                        }
                                        .padding(.horizontal, Theme.Spacing.gutter)
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
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Card(
            title: supplement.name,
            subtitle: supplement.purpose,
            tags: createTags(),
            isExpanded: .constant(isExpanded)
        ) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Dose and form
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Image(systemName: "pills.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("Dose: \(supplement.doseRangeText)")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    
                    if let formNote = supplement.formNote {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.textSecondary)
                            Text(formNote)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
                
                // Why this section
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Why this?")
                        .font(Theme.Typography.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(supplement.rationale)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Study references
                if !supplement.citations.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Study References")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        ForEach(supplement.citations, id: \.url) { citation in
                            Link(destination: URL(string: citation.url)!) {
                                HStack {
                                    Text("• \(citation.title)")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.Colors.primary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture(perform: onTap)
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
