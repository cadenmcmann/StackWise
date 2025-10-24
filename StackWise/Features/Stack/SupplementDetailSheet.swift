import SwiftUI

// MARK: - SupplementDetailSheet
public struct SupplementDetailSheet: View {
    let supplement: Supplement
    let stackId: String?
    @Binding var isActive: Bool
    let onToggleActive: (Bool) async -> Void
    
    @State private var isToggling = false
    @State private var showToggleError = false
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Header
                    headerSection
                    
                    Divider()
                    
                    // Purpose section
                    if let purposeLong = supplement.purposeLong {
                        detailSection(
                            title: "Purpose",
                            content: purposeLong,
                            icon: "sparkles"
                        )
                    }
                    
                    // How It Works section
                    if let scientificFunction = supplement.scientificFunction {
                        detailSection(
                            title: "How It Works",
                            content: scientificFunction,
                            icon: "brain"
                        )
                    }
                    
                    // Research & Citations section
                    if !supplement.citations.isEmpty {
                        citationsSection
                    }
                    
                    // Active toggle section
                    activeToggleSection
                }
                .padding(Theme.Spacing.gutter)
            }
            .navigationTitle(supplement.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert("Error", isPresented: $showToggleError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to update supplement status. Please try again.")
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(supplement.name)
                .font(Theme.Typography.titleL)
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    // Timing tags
                    if let schedule = supplement.schedule {
                        ForEach(schedule.times, id: \.self) { time in
                            TagChip(
                                text: time.capitalized,
                                color: Theme.Colors.primary
                            )
                        }
                    }
                    
                    // Goal tags
                    ForEach(supplement.tags, id: \.self) { tag in
                        TagChip(
                            text: tag,
                            color: Theme.Colors.success
                        )
                    }
                }
            }
            
            // Dose and form
            HStack(spacing: Theme.Spacing.md) {
                Label(supplement.doseRangeText, systemImage: "pills.fill")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                if let formNote = supplement.formNote {
                    Text("• \(formNote)")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
    
    private func detailSection(title: String, content: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.primary)
                Text(title)
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Text(content)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var citationsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.primary)
                Text("Research & Citations")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(supplement.citations, id: \.url) { citation in
                    Link(destination: URL(string: citation.url)!) {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(citation.title)
                                    .font(Theme.Typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(citation.authors) • \(citation.journal) (\(citation.year))")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .padding(Theme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.sm)
                                .fill(Theme.Colors.surfaceAlt)
                        )
                    }
                }
            }
        }
    }
    
    private var activeToggleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? Theme.Colors.success : Theme.Colors.textSecondary)
                Text("Active in Your Stack")
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(isActive ? "This supplement is currently active" : "This supplement is currently inactive")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Text(isActive ? "You'll see it in your daily schedule" : "It won't appear in your daily schedule")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isActive)
                    .disabled(isToggling)
                    .onChange(of: isActive) { _, newValue in
                        Task {
                            await toggleActiveStatus(newValue)
                        }
                    }
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.md)
                    .fill(Theme.Colors.surfaceAlt)
            )
        }
    }
    
    // MARK: - Actions
    
    private func toggleActiveStatus(_ newValue: Bool) async {
        isToggling = true
        
        // Call the async handler
        await onToggleActive(newValue)
        
        isToggling = false
    }
}

// MARK: - TagChip
private struct TagChip: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .foregroundColor(color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radii.sm)
                    .fill(color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radii.sm)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}
