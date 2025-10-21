import Foundation

// MARK: - TrackingService Protocol
public protocol TrackingService {
    func getWeekEntries(startingFrom date: Date) async throws -> [TrackEntry]
    func getEntry(for date: Date) async throws -> TrackEntry?
    func saveNote(date: Date, text: String) async throws
    func getStreak() async throws -> Int
    func getWeeklyIntake(startDate: Date) async throws -> WeeklyIntakeResponse
}
