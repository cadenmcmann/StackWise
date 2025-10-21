import Foundation
import SwiftUI
import UserNotifications
import Combine

// MARK: - ScheduleViewModel
@MainActor
public class ScheduleViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var todayIntakeData: DayIntakeData?
    @Published var isLoading = false
    @Published var showNotificationPermission = false
    @Published var showReminderSettings = false
    @Published var selectedReminder: Reminder?
    @Published var refreshTrigger = false // Used to force UI updates
    
    private let container: DIContainer
    private let scheduleService: ScheduleService
    private let trackingService: TrackingService
    private var cancellables = Set<AnyCancellable>()
    
    // Time sections
    enum TimeSection: String, CaseIterable {
        case morning = "Morning"
        case noon = "Noon"
        case evening = "Evening"
        case night = "Night"
        
        var icon: String {
            switch self {
            case .morning: return "sun.max.fill"
            case .noon: return "sun.max"
            case .evening: return "sunset.fill"
            case .night: return "moon.fill"
            }
        }
        
        var timeRange: ClosedRange<Int> {
            switch self {
            case .morning: return 5...11
            case .noon: return 12...14
            case .evening: return 15...19
            case .night: return 20...23
            }
        }
    }
    
    public init(container: DIContainer) {
        self.container = container
        self.scheduleService = container.scheduleService
        self.trackingService = container.trackingService
        
        // Observe IntakeLogManager changes to trigger UI updates
        container.intakeLogManager.$localIntakeState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshTrigger.toggle()
            }
            .store(in: &cancellables)
        
        Task {
            await loadReminders()
            await loadTodayData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadReminders() async {
        isLoading = true
        
        // Load reminders from the user's current stack
        if let stack = container.currentStack {
            reminders = generateRemindersFromStack(stack)
        } else {
            // Try to load from service (mock or real)
            do {
                reminders = try await scheduleService.getReminders()
            } catch {
                print("Failed to load reminders: \(error)")
            }
        }
        
        isLoading = false
    }
    
    func loadTodayData() async {
        do {
            // Get today's date at start of week
            let calendar = Calendar.current
            let today = Date()
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }
            
            // Load the week's data
            let weeklyData = try await trackingService.getWeeklyIntake(startDate: weekStart)
            
            // Sync with IntakeLogManager
            container.intakeLogManager.syncWithAPIData(weeklyData)
            
            // Find today's data
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayString = formatter.string(from: today)
            
            todayIntakeData = weeklyData.weekData.first { $0.date == todayString }
        } catch {
            print("Failed to load today's data: \(error)")
        }
    }
    
    private func generateRemindersFromStack(_ stack: Stack) -> [Reminder] {
        var generatedReminders: [Reminder] = []
        let calendar = Calendar.current
        
        for supplement in stack.allSupplements {
            // Use schedule times from the supplement
            if let schedule = supplement.schedule {
                for timeString in schedule.times {
                    // Map time string to a Date
                    let time = timeForTimeString(timeString)
                    
                    let reminder = Reminder(
                        supplementId: supplement.id,
                        timeOfDay: time,
                        enabled: true
                    )
                    generatedReminders.append(reminder)
                }
            } else {
                // Fallback: create a default morning reminder
                let defaultTime = calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
                let reminder = Reminder(
                    supplementId: supplement.id,
                    timeOfDay: defaultTime,
                    enabled: true
                )
                generatedReminders.append(reminder)
            }
        }
        
        return generatedReminders.sorted { $0.timeOfDay < $1.timeOfDay }
    }
    
    private func timeForTimeString(_ timeString: String) -> Date {
        let calendar = Calendar.current
        
        switch timeString.lowercased() {
        case "morning":
            return calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        case "afternoon":
            return calendar.date(from: DateComponents(hour: 13, minute: 0)) ?? Date()
        case "evening":
            return calendar.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
        case "night":
            return calendar.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
        default:
            return calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        }
    }
    
    // MARK: - Actions
    
    func toggleTaken(supplementId: String, time: String) {
        // Get the ACTUAL current state from isSupplementTaken (includes local changes)
        let currentState = isSupplementTaken(supplementId: supplementId, time: time)
        
        // Use IntakeLogManager to handle the toggle
        container.intakeLogManager.toggleSupplement(
            supplementId: supplementId,
            time: time,
            date: Date(),
            currentState: currentState
        )
    }
    
    func isSupplementTaken(supplementId: String, time: String) -> Bool {
        // Get the API state
        let apiState = todayIntakeData?.stackIntakeData.first {
            $0.supplementId == supplementId && $0.time == time
        }?.taken ?? false
        
        // Return the current state from IntakeLogManager (includes local changes)
        return container.intakeLogManager.isSupplementTaken(
            supplementId: supplementId,
            time: time,
            date: Date(),
            apiState: apiState
        )
    }
    
    func setReminders() {
        // Check notification permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    self.requestNotificationPermission()
                } else if settings.authorizationStatus == .authorized {
                    self.scheduleNotifications()
                } else {
                    self.showNotificationPermission = true
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotifications()
                } else {
                    self.showNotificationPermission = true
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        // Schedule local notifications for reminders
        for reminder in reminders where reminder.enabled {
            scheduleNotification(for: reminder)
        }
    }
    
    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Time for your supplement"
        content.body = "Take your \(getSupplementName(for: reminder.supplementId))"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.timeOfDay)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: reminder.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func updateReminder(_ reminder: Reminder) async {
        do {
            try await scheduleService.setReminder(reminder)
            await loadReminders()
            
            // Reschedule notification if enabled
            if reminder.enabled {
                scheduleNotification(for: reminder)
            } else {
                // Cancel notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
            }
        } catch {
            print("Failed to update reminder: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    func remindersForSection(_ section: TimeSection) -> [Reminder] {
        let calendar = Calendar.current
        return reminders.filter { reminder in
            let hour = calendar.component(.hour, from: reminder.timeOfDay)
            return section.timeRange.contains(hour)
        }
    }
    
    func timeStringForReminder(_ reminder: Reminder) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminder.timeOfDay)
        
        switch hour {
        case 5...11:
            return "morning"
        case 12...14:
            return "afternoon"
        case 15...19:
            return "evening"
        case 20...23:
            return "night"
        default:
            return "morning"
        }
    }
    
    func getSupplementName(for id: String) -> String {
        // Get supplement name from stack
        if let stack = container.currentStack {
            if let supplement = stack.allSupplements.first(where: { $0.id == id }) {
                return supplement.name
            }
        }
        
        // Fallback to ID
        return id.capitalized
    }
    
    func getSupplementIcon(for id: String) -> String {
        // Return appropriate icon based on supplement ID
        switch id.lowercased() {
        case _ where id.contains("creatine"):
            return "bolt.fill"
        case _ where id.contains("magnesium"):
            return "moon.zzz.fill"
        case _ where id.contains("theanine"):
            return "leaf.fill"
        case _ where id.contains("vitamin"):
            return "sun.max.fill"
        default:
            return "pills.fill"
        }
    }
}
