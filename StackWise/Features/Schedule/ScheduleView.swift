import SwiftUI

// MARK: - ScheduleView
public struct ScheduleView: View {
    @StateObject private var viewModel: ScheduleViewModel
    @ObservedObject private var intakeLogManager: IntakeLogManager
    @State private var showReminderSuccess = false
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: ScheduleViewModel(container: container))
        self.intakeLogManager = container.intakeLogManager
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.reminders.isEmpty {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.xl) {
                            // Today's progress
                            let takenCount = viewModel.reminders.filter { reminder in
                                viewModel.isSupplementTaken(
                                    supplementId: reminder.supplementId,
                                    time: viewModel.timeStringForReminder(reminder)
                                )
                            }.count
                            
                            TodayProgressCard(
                                taken: takenCount,
                                total: viewModel.reminders.count
                            )
                            .padding(.horizontal, Theme.Spacing.gutter)
                            
                            // Time sections
                            ForEach(ScheduleViewModel.TimeSection.allCases, id: \.self) { section in
                                let sectionReminders = viewModel.remindersForSection(section)
                                if !sectionReminders.isEmpty {
                                    TimeSectionView(
                                        section: section,
                                        reminders: sectionReminders,
                                        viewModel: viewModel
                                    )
                                }
                            }
                            
                            // Set reminders button
                            PrimaryButton(
                                title: "Set Reminders",
                                icon: "bell.fill",
                                action: { viewModel.setReminders() }
                            )
                            .padding(.horizontal, Theme.Spacing.gutter)
                        }
                        .padding(.vertical, Theme.Spacing.lg)
                    }
                } else {
                    EmptyState(
                        icon: "calendar",
                        title: "No Schedule Yet",
                        subtitle: "Generate your stack first to set up your supplement schedule",
                        primaryAction: nil,
                        primaryActionTitle: nil
                    )
                }
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading schedule...")
                }
            }
            .sheet(isPresented: $viewModel.showReminderSettings) {
                if let reminder = viewModel.selectedReminder {
                    ReminderSettingsSheet(
                        reminder: reminder,
                        viewModel: viewModel
                    )
                }
            }
            .alert("Notifications Disabled", isPresented: $viewModel.showNotificationPermission) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enable notifications in Settings to receive supplement reminders.")
            }
        }
        .toast(
            isShowing: $showReminderSuccess,
            message: "Reminders set successfully",
            type: .success
        )
        .task {
            await viewModel.loadReminders()
            await viewModel.loadTodayData()
        }
    }
}

// MARK: - TodayProgressCard
struct TodayProgressCard: View {
    let taken: Int
    let total: Int
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(taken) / Double(total)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return Theme.Colors.success
        } else if progress >= 0.5 {
            return Theme.Colors.warning
        } else {
            return Theme.Colors.primary
        }
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Today's Progress")
                        .font(Theme.Typography.titleM)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("\(taken) of \(total) supplements taken")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Theme.Colors.border, lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(progressColor, lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(Theme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
            }
            
            if progress >= 1.0 {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.success)
                    Text("Great job! All supplements taken today")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.success)
                }
            }
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

// MARK: - TimeSectionView
struct TimeSectionView: View {
    let section: ScheduleViewModel.TimeSection
    let reminders: [Reminder]
    @ObservedObject var viewModel: ScheduleViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: section.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.primary)
                
                Text(section.rawValue)
                    .font(Theme.Typography.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            
            // Reminder rows
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(reminders) { reminder in
                    ReactiveTimelineRow(
                        reminder: reminder,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.gutter)
        }
    }
}

// MARK: - ReactiveTimelineRow
struct ReactiveTimelineRow: View {
    let reminder: Reminder
    @ObservedObject var viewModel: ScheduleViewModel
    
    var body: some View {
        let timeString = viewModel.timeStringForReminder(reminder)
        let isTaken = viewModel.isSupplementTaken(
            supplementId: reminder.supplementId,
            time: timeString
        )
        
        TimelineRow(
            reminder: reminder,
            supplementName: viewModel.getSupplementName(for: reminder.supplementId),
            supplementIcon: viewModel.getSupplementIcon(for: reminder.supplementId),
            isTaken: isTaken,
            onToggle: {
                viewModel.toggleTaken(
                    supplementId: reminder.supplementId,
                    time: timeString
                )
            },
            onSettings: {
                viewModel.selectedReminder = reminder
                viewModel.showReminderSettings = true
            }
        )
        // Force re-render when state changes - include refreshTrigger to trigger updates
        .id("\(reminder.id)-\(isTaken)-\(viewModel.refreshTrigger)")
        .opacity(viewModel.refreshTrigger ? 1.0 : 1.0) // Dummy use of refreshTrigger to force observation
    }
}

// MARK: - TimelineRow
struct TimelineRow: View {
    let reminder: Reminder
    let supplementName: String
    let supplementIcon: String
    let isTaken: Bool
    let onToggle: () -> Void
    let onSettings: () -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminder.timeOfDay)
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Time
            Text(timeString)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            // Icon and name
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: supplementIcon)
                    .font(.system(size: 16))
                    .foregroundColor(isTaken ? Theme.Colors.success : Theme.Colors.primary)
                
                Text(supplementName)
                    .font(Theme.Typography.body)
                    .foregroundColor(isTaken ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                    .strikethrough(isTaken)
            }
            
            Spacer()
            
            // Settings button
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Taken toggle
            Button(action: onToggle) {
                Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isTaken ? Theme.Colors.success : Theme.Colors.border)
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(isTaken ? Theme.Colors.success.opacity(0.05) : Theme.Colors.surfaceAlt)
        )
        .contentShape(Rectangle())
        .animation(Theme.Animation.quick, value: isTaken)
    }
}

// MARK: - ReminderSettingsSheet
struct ReminderSettingsSheet: View {
    @State var reminder: Reminder
    let viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xl) {
                // Time picker
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Reminder Time")
                        .font(Theme.Typography.subhead)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    DatePicker(
                        "",
                        selection: $reminder.timeOfDay,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                
                // Enable toggle
                CustomToggle(
                    title: "Enable Reminder",
                    subtitle: "Get notified when it's time to take this supplement",
                    isOn: $reminder.enabled
                )
                
                Spacer()
                
                // Save button
                PrimaryButton(
                    title: "Save Changes",
                    action: {
                        Task {
                            await viewModel.updateReminder(reminder)
                            dismiss()
                        }
                    }
                )
            }
            .padding(Theme.Spacing.gutter)
            .navigationTitle("Reminder Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
