import Foundation

// MARK: - ExportService Protocol
public protocol ExportService {
    func generateRegimenPDF(stack: Stack, user: User) async throws -> URL
    func generateCalendarICS(reminders: [Reminder]) async throws -> URL
}
