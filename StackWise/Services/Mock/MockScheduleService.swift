import Foundation

// MARK: - MockScheduleService
public class MockScheduleService: ScheduleService {
    private var reminders: [Reminder] = []
    private var takenRecords: [String: Set<String>] = [:] // date string -> supplement IDs
    
    public init() {
        setupMockReminders()
    }
    
    private func setupMockReminders() {
        // Create some default reminders
        let calendar = Calendar.current
        let now = Date()
        
        // Morning reminder (8 AM)
        if let morningTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) {
            reminders.append(Reminder(
                supplementId: "creatine",
                timeOfDay: morningTime,
                enabled: true
            ))
            reminders.append(Reminder(
                supplementId: "l-theanine",
                timeOfDay: morningTime,
                enabled: true
            ))
        }
        
        // Night reminder (9 PM)
        if let nightTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now) {
            reminders.append(Reminder(
                supplementId: "magnesium",
                timeOfDay: nightTime,
                enabled: true
            ))
        }
    }
    
    public func getReminders() async throws -> [Reminder] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        return reminders
    }
    
    public func setReminder(_ reminder: Reminder) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Update existing or add new
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }
    }
    
    public func deleteReminder(_ reminderId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        reminders.removeAll { $0.id == reminderId }
    }
    
    public func markTaken(supplementId: String, date: Date) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let dateKey = dateString(from: date)
        if takenRecords[dateKey] == nil {
            takenRecords[dateKey] = []
        }
        takenRecords[dateKey]?.insert(supplementId)
    }
    
    public func unmarkTaken(supplementId: String, date: Date) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let dateKey = dateString(from: date)
        takenRecords[dateKey]?.remove(supplementId)
    }
    
    // Helper method to get taken status
    public func getTakenSupplements(for date: Date) -> Set<String> {
        let dateKey = dateString(from: date)
        return takenRecords[dateKey] ?? []
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
