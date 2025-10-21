import SwiftUI

// MARK: - TrackView
public struct TrackView: View {
    @StateObject private var viewModel: TrackViewModel
    @ObservedObject private var intakeLogManager: IntakeLogManager
    @Environment(\.container) private var container
    
    public init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: TrackViewModel(container: container))
        self.intakeLogManager = container.intakeLogManager
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Week navigation and calendar
                        VStack(spacing: Theme.Spacing.lg) {
                            // Week navigation
                            HStack {
                                Button {
                                    viewModel.navigateWeek(forward: false)
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: Theme.Spacing.xs) {
                                    Text(viewModel.weekDateRange)
                                        .font(Theme.Typography.subhead)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    if viewModel.isCurrentWeek {
                                        Text("Current Week")
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.primary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.navigateWeek(forward: true)
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                .disabled(viewModel.isCurrentWeek)
                            }
                            .padding(.horizontal, Theme.Spacing.gutter)
                            
                            // Weekly calendar
                            WeeklyCalendarView(
                                currentWeekStartDate: viewModel.currentWeekStartDate,
                                selectedDate: viewModel.selectedDate,
                                viewModel: viewModel,
                                intakeLogManager: intakeLogManager
                            )
                        }
                        
                        // Show supplements for selected date
                        if let selectedDate = viewModel.selectedDate {
                            DaySupplementsView(
                                date: selectedDate,
                                viewModel: viewModel,
                                intakeLogManager: intakeLogManager
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .animation(Theme.Animation.quick, value: selectedDate)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                }
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading tracking data...")
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadWeekData()
        }
    }
}

// MARK: - WeeklyCalendarView
struct WeeklyCalendarView: View {
    let currentWeekStartDate: Date
    let selectedDate: Date?
    let viewModel: TrackViewModel
    @ObservedObject var intakeLogManager: IntakeLogManager
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentWeekStartDate) else {
            return []
        }
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(weekDays, id: \.self) { date in
                DayCell(
                    date: date,
                    completion: viewModel.completionForDate(date),
                    isSelected: selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date),
                    isToday: Calendar.current.isDateInToday(date)
                )
                .onTapGesture {
                    withAnimation(Theme.Animation.quick) {
                        viewModel.selectDate(date)
                    }
                }
                // Force re-render when local intake state changes
                .id("\(date)-\(intakeLogManager.localIntakeState.count)")
            }
        }
        .padding(.horizontal, Theme.Spacing.gutter)
    }
}

// MARK: - DayCell
struct DayCell: View {
    let date: Date
    let completion: Double
    let isSelected: Bool
    let isToday: Bool
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var fillColor: Color {
        if completion >= 1.0 {
            return Theme.Colors.success
        } else if completion > 0 {
            return Theme.Colors.warning
        } else {
            return Theme.Colors.border
        }
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(dayFormatter.string(from: date))
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            ZStack {
                Circle()
                    .fill(fillColor.opacity(0.2))
                    .frame(width: isSelected ? 48 : 40, height: isSelected ? 48 : 40)
                    .animation(Theme.Animation.quick, value: isSelected)
                
                if completion > 0 {
                    Circle()
                        .trim(from: 0, to: completion)
                        .stroke(fillColor, lineWidth: isSelected ? 4 : 3)
                        .frame(width: isSelected ? 48 : 40, height: isSelected ? 48 : 40)
                        .rotationEffect(.degrees(-90))
                        .animation(Theme.Animation.standard, value: completion)
                        .animation(Theme.Animation.quick, value: isSelected)
                }
                
                Text(dateFormatter.string(from: date))
                    .font(Theme.Typography.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isToday ? Theme.Colors.primary : Theme.Colors.textPrimary)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(Theme.Animation.standard, value: isSelected)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(isSelected ? Theme.Colors.primary.opacity(0.08) : Color.clear)
        )
    }
}

// MARK: - DaySupplementsView
struct DaySupplementsView: View {
    let date: Date
    @ObservedObject var viewModel: TrackViewModel
    @ObservedObject var intakeLogManager: IntakeLogManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    private var timeIcon: String {
        switch "morning" {
        case "morning": return "sun.max.fill"
        case "afternoon": return "sun.max"
        case "evening": return "sunset.fill"
        case "night": return "moon.fill"
        default: return "clock"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(dateFormatter.string(from: date))
                        .font(Theme.Typography.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    if let dayData = viewModel.getDayIntakeData(for: date) {
                        let taken = dayData.stackIntakeData.filter { $0.taken }.count
                        let total = dayData.stackIntakeData.count
                        Text("\(taken) of \(total) supplements taken")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(Theme.Animation.quick) {
                        viewModel.selectDate(date)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            
            // Supplements by time
            let supplementsByTime = viewModel.getSupplementsByTime(for: date)
            
            if supplementsByTime.isEmpty {
                EmptyStateCard()
                    .padding(.horizontal, Theme.Spacing.gutter)
            } else {
                ForEach(supplementsByTime, id: \.time) { section in
                    TimeSection(
                        time: section.time,
                        supplements: section.supplements,
                        date: date,
                        viewModel: viewModel
                    )
                }
            }
        }
        .padding(.vertical, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .fill(Theme.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, Theme.Spacing.gutter)
    }
}

// MARK: - TimeSection
struct TimeSection: View {
    let time: String
    let supplements: [SupplementIntakeData]
    let date: Date
    let viewModel: TrackViewModel
    
    private var timeIcon: String {
        switch time {
        case "morning": return "sun.max.fill"
        case "afternoon": return "sun.max"
        case "evening": return "sunset.fill"
        case "night": return "moon.fill"
        default: return "clock"
        }
    }
    
    private var timeTitle: String {
        time.capitalized
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: timeIcon)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.primary)
                
                Text(timeTitle)
                    .font(Theme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            
            // Supplements
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(supplements, id: \.supplementId) { supplement in
                    SupplementIntakeRow(
                        supplement: supplement,
                        date: date,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.gutter)
        }
    }
}

// MARK: - SupplementIntakeRow
struct SupplementIntakeRow: View {
    let supplement: SupplementIntakeData
    let date: Date
    @ObservedObject var viewModel: TrackViewModel
    
    var body: some View {
        let isTaken = viewModel.isSupplementTaken(
            supplementId: supplement.supplementId,
            time: supplement.time,
            date: date,
            apiState: supplement.taken
        )
        
        HStack(spacing: Theme.Spacing.md) {
            // Check button
            Button(action: {
                viewModel.toggleSupplement(
                    supplementId: supplement.supplementId,
                    time: supplement.time,
                    date: date,
                    currentState: isTaken
                )
            }) {
                Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isTaken ? Theme.Colors.success : Theme.Colors.border)
            }
            
            // Supplement name
            Text(supplement.supplementName)
                .font(Theme.Typography.body)
                .foregroundColor(isTaken ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                .strikethrough(isTaken)
            
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(isTaken ? Theme.Colors.success.opacity(0.05) : Theme.Colors.surfaceAlt)
        )
        .contentShape(Rectangle())
        .animation(Theme.Animation.quick, value: isTaken)
        // Force re-render when state changes
        .id("\(supplement.supplementId)-\(supplement.time)-\(isTaken)")
    }
}

// MARK: - EmptyStateCard
struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "pills")
                .font(.system(size: 32))
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("No supplements scheduled")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radii.md)
                .fill(Theme.Colors.surfaceAlt)
        )
    }
}