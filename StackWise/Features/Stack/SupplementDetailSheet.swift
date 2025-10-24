import SwiftUI

struct SupplementDetailSheet: View {
    let supplement: Supplement
    let stackId: String?
    let initialActiveState: Bool
    let onToggleActive: (Bool) async -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isActive: Bool
    @State private var showingActiveTooltip = false
    
    init(supplement: Supplement, stackId: String?, initialActiveState: Bool, onToggleActive: @escaping (Bool) async -> Void) {
        self.supplement = supplement
        self.stackId = stackId
        self.initialActiveState = initialActiveState
        self.onToggleActive = onToggleActive
        self._isActive = State(initialValue: initialActiveState)
    }
    
    private var supplementInfo: SupplementInfo? {
        SupplementDatabase.shared.getSupplementInfo(by: supplement.id) ??
        SupplementDatabase.shared.getSupplementInfo(byName: supplement.name)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero section with supplement name and tags
                    VStack(spacing: Theme.Spacing.md) {
                        // Icon placeholder
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.primary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .padding(.top, Theme.Spacing.lg)
                        
                        Text(supplement.name)
                            .font(Theme.Typography.titleL)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        // Tags
                        HStack(spacing: Theme.Spacing.xs) {
                            ForEach(supplement.tags, id: \.self) { tag in
                                Tag(
                                    text: tag,
                                    type: tagType(for: tag)
                                )
                            }
                        }
                        
                        // Dose info
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.textSecondary)
                            Text(supplement.doseRangeText)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                            if let formNote = supplement.formNote {
                                Text("• \(formNote)")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(.bottom, Theme.Spacing.md)
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    
                    // Active Toggle Section - Simplified
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack {
                            Text("Active")
                                .font(Theme.Typography.body)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingActiveTooltip.toggle()
                                }
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isActive)
                                .labelsHidden()
                                .tint(Theme.Colors.primary)
                                .onChange(of: isActive) { _, newValue in
                                    Task {
                                        await onToggleActive(newValue)
                                    }
                                }
                        }
                        
                        if showingActiveTooltip {
                            Text("Active supplements appear in your daily schedule")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.vertical, Theme.Spacing.xs)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .background(Theme.Colors.surfaceAlt)
                                .cornerRadius(Theme.Radii.sm)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .background(Theme.Colors.surfaceAlt.opacity(0.5))
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.bottom, Theme.Spacing.lg)
                    
                    // Content Sections
                    VStack(spacing: Theme.Spacing.xl) {
                        // Purpose Section
                        if let info = supplementInfo {
                            ContentSection(
                                title: "Purpose",
                                icon: "target",
                                content: info.purposeLong
                            )
                        } else if let purposeShort = supplement.purposeShort {
                            ContentSection(
                                title: "Purpose",
                                icon: "target",
                                content: purposeShort
                            )
                        }
                        
                        // Why for You Section (Rationale)
                        if !supplement.rationale.isEmpty {
                            ContentSection(
                                title: "Why for You",
                                icon: "person.fill",
                                content: supplement.rationale,
                                accentColor: Theme.Colors.success
                            )
                        }
                        
                        // How It Works Section
                        if let info = supplementInfo {
                            ContentSection(
                                title: "How It Works",
                                icon: "gearshape.2.fill",
                                content: info.scientificFunction
                            )
                        }
                        
                        // Research & Citations Section
                        if let info = supplementInfo, !info.citations.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.Colors.primary)
                                    Text("Research & Citations")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    ForEach(info.citations, id: \.self) { citation in
                                        Link(destination: URL(string: citation) ?? URL(string: "https://www.example.com")!) {
                                            HStack {
                                                Image(systemName: "link")
                                                    .font(.system(size: 12))
                                                Text(cleanCitationURL(citation))
                                                    .font(Theme.Typography.caption)
                                                Spacer()
                                                Image(systemName: "arrow.up.right")
                                                    .font(.system(size: 10))
                                            }
                                            .foregroundColor(Theme.Colors.primary)
                                            .padding(Theme.Spacing.sm)
                                            .background(Theme.Colors.primary.opacity(0.05))
                                            .cornerRadius(Theme.Radii.sm)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.gutter)
                        }
                        
                        // Additional Info Section
                        if let info = supplementInfo {
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    Text("Additional Information")
                                        .font(Theme.Typography.titleM)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                
                                VStack(spacing: Theme.Spacing.sm) {
                                    // Timing
                                    DetailInfoRow(
                                        label: "Best Time",
                                        value: info.timingTags.map { $0.capitalized }.joined(separator: ", ")
                                    )
                                    
                                    // Dietary Flags
                                    if !info.dietaryFlags.isEmpty {
                                        DetailInfoRow(
                                            label: "Dietary",
                                            value: info.dietaryFlags.map { 
                                                $0.replacingOccurrences(of: "_", with: " ").capitalized 
                                            }.joined(separator: ", ")
                                        )
                                    }
                                    
                                    // Stimulant Free
                                    DetailInfoRow(
                                        label: "Stimulant",
                                        value: info.stimulantFree ? "Stimulant-Free" : "Contains Stimulants"
                                    )
                                }
                                .padding(Theme.Spacing.md)
                                .background(Theme.Colors.surfaceAlt.opacity(0.5))
                                .cornerRadius(Theme.Radii.md)
                            }
                            .padding(.horizontal, Theme.Spacing.gutter)
                        }
                    }
                    
                    // Bottom padding for scroll content
                    Color.clear
                        .frame(height: Theme.Spacing.xxl)
                }
            }
            .background(Theme.Colors.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.surfaceAlt)
                                .frame(width: 30, height: 30)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
    }
    
    private func tagType(for tag: String) -> CardTagData.TagType {
        if tag.lowercased().contains("morning") || tag.lowercased().contains("afternoon") || 
           tag.lowercased().contains("evening") || tag.lowercased().contains("night") {
            return .timing
        } else if tag.lowercased().contains("build") || tag.lowercased().contains("muscle") || 
                  tag.lowercased().contains("recovery") || tag.lowercased().contains("energy") {
            return .info
        }
        return .info
    }
    
    private func cleanCitationURL(_ url: String) -> String {
        // Remove protocol and www
        var cleaned = url
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
        
        // Remove trailing slash
        if cleaned.hasSuffix("/") {
            cleaned.removeLast()
        }
        
        // Truncate if too long
        if cleaned.count > 30 {
            return String(cleaned.prefix(27)) + "..."
        }
        
        return cleaned
    }
}

// MARK: - Content Section Component
struct ContentSection: View {
    let title: String
    let icon: String
    let content: String
    var accentColor: Color = Theme.Colors.primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(Theme.Typography.titleM)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Text(content)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
    }
}

// MARK: - Detail Info Row Component
struct DetailInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}