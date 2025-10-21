import Foundation
import SwiftUI
import Combine

// MARK: - TrackViewModel
@MainActor
public class TrackViewModel: ObservableObject {
    @Published var weeklyIntakeData: WeeklyIntakeResponse?
    @Published var selectedDate: Date?
    @Published var currentWeekStartDate = Date()
    @Published var isLoading = false
    @Published var refreshTrigger = false // Used to force UI updates
    
    private let container: DIContainer
    private let trackingService: TrackingService
    private var cancellables = Set<AnyCancellable>()
    
    public init(container: DIContainer) {
        self.container = container
        self.trackingService = container.trackingService
        
        // Set to start of current week
        let calendar = Calendar.current
        let today = Date()
        if let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start {
            currentWeekStartDate = weekStart
        }
        
        // Select today by default - ensure it's the same day instance
        selectedDate = calendar.startOfDay(for: today)
        
        // Observe IntakeLogManager changes to trigger UI updates
        container.intakeLogManager.$localIntakeState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshTrigger.toggle()
            }
            .store(in: &cancellables)
        
        Task {
            await loadWeekData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadWeekData() async {
        isLoading = true
        
        do {
            weeklyIntakeData = try await trackingService.getWeeklyIntake(startDate: currentWeekStartDate)
            
            // Sync the intake log manager with the API data
            if let data = weeklyIntakeData {
                container.intakeLogManager.syncWithAPIData(data)
            }
        } catch {
            print("Failed to load tracking data: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    
    func selectDate(_ date: Date) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let current = selectedDate,
           calendar.isDate(current, inSameDayAs: normalizedDate) {
            // Deselect if tapping the same date
            selectedDate = nil
        } else {
            selectedDate = normalizedDate
        }
    }
    
    func navigateWeek(forward: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: forward ? 1 : -1, to: currentWeekStartDate) {
            currentWeekStartDate = newDate
            selectedDate = nil // Clear selection when changing weeks
            Task {
                await loadWeekData()
            }
        }
    }
    
    func toggleSupplement(supplementId: String, time: String, date: Date, currentState: Bool) {
        // Use the intake log manager to handle the toggle with smart batching
        container.intakeLogManager.toggleSupplement(
            supplementId: supplementId,
            time: time,
            date: date,
            currentState: currentState
        )
    }
    
    func isSupplementTaken(supplementId: String, time: String, date: Date, apiState: Bool) -> Bool {
        return container.intakeLogManager.isSupplementTaken(
            supplementId: supplementId,
            time: time,
            date: date,
            apiState: apiState
        )
    }
    
    // MARK: - Computed Properties
    
    var weekDateRange: String {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentWeekStartDate) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let start = formatter.string(from: weekInterval.start)
        let end = formatter.string(from: weekInterval.end.addingTimeInterval(-1)) // Subtract 1 second to get last day of week
        
        return "\(start) - \(end)"
    }
    
    var isCurrentWeek: Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentWeekStartDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func completionForDate(_ date: Date) -> Double {
        guard let weeklyData = weeklyIntakeData else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        if let dayData = weeklyData.weekData.first(where: { $0.date == dateString }) {
            let total = dayData.stackIntakeData.count
            
            // Count how many are taken using the IntakeLogManager for accurate state
            let taken = dayData.stackIntakeData.filter { supplement in
                container.intakeLogManager.isSupplementTaken(
                    supplementId: supplement.supplementId,
                    time: supplement.time,
                    date: date,
                    apiState: supplement.taken
                )
            }.count
            
            return total > 0 ? Double(taken) / Double(total) : 0
        }
        
        return 0
    }
    
    func getDayIntakeData(for date: Date) -> DayIntakeData? {
        guard let weeklyData = weeklyIntakeData else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return weeklyData.weekData.first { $0.date == dateString }
    }
    
    func getSupplementsByTime(for date: Date) -> [(time: String, supplements: [SupplementIntakeData])] {
        guard let dayData = getDayIntakeData(for: date) else { return [] }
        
        // Group supplements by time
        let grouped = Dictionary(grouping: dayData.stackIntakeData) { $0.time }
        
        // Order times properly
        let timeOrder = ["morning", "afternoon", "evening", "night"]
        
        return timeOrder.compactMap { time in
            guard let supplements = grouped[time], !supplements.isEmpty else { return nil }
            return (time: time, supplements: supplements)
        }
    }
}
