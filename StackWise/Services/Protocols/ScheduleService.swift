import Foundation

// MARK: - ScheduleService Protocol
public protocol ScheduleService {
    func getReminders() async throws -> [Reminder]
    func setReminder(_ reminder: Reminder) async throws
    func deleteReminder(_ reminderId: String) async throws
    func markTaken(supplementId: String, date: Date) async throws
    func unmarkTaken(supplementId: String, date: Date) async throws
}
