import Foundation
@testable import StackWise

// MARK: - MockTrackingService
final class MockTrackingService: TrackingService {
    
    // MARK: - Call Tracking
    var getWeekEntriesCallCount = 0
    var getEntryCallCount = 0
    var saveNoteCallCount = 0
    var getStreakCallCount = 0
    var getWeeklyIntakeCallCount = 0
    
    // MARK: - Captured Parameters
    var lastDate: Date?
    var lastNoteText: String?
    var lastStartDate: Date?
    
    // MARK: - Configured Responses
    var weekEntriesToReturn: [TrackEntry] = []
    var entryToReturn: TrackEntry?
    var streakToReturn: Int = 0
    var weeklyIntakeToReturn: WeeklyIntakeResponse?
    var errorToThrow: Error?
    
    // MARK: - TrackingService Implementation
    
    func getWeekEntries(startingFrom date: Date) async throws -> [TrackEntry] {
        getWeekEntriesCallCount += 1
        lastDate = date
        if let error = errorToThrow { throw error }
        return weekEntriesToReturn
    }
    
    func getEntry(for date: Date) async throws -> TrackEntry? {
        getEntryCallCount += 1
        lastDate = date
        if let error = errorToThrow { throw error }
        return entryToReturn
    }
    
    func saveNote(date: Date, text: String) async throws {
        saveNoteCallCount += 1
        lastDate = date
        lastNoteText = text
        if let error = errorToThrow { throw error }
    }
    
    func getStreak() async throws -> Int {
        getStreakCallCount += 1
        if let error = errorToThrow { throw error }
        return streakToReturn
    }
    
    func getWeeklyIntake(startDate: Date) async throws -> WeeklyIntakeResponse {
        getWeeklyIntakeCallCount += 1
        lastStartDate = startDate
        if let error = errorToThrow { throw error }
        guard let response = weeklyIntakeToReturn else {
            throw MockError.notConfigured
        }
        return response
    }
    
    // MARK: - Helper
    func reset() {
        getWeekEntriesCallCount = 0
        getEntryCallCount = 0
        saveNoteCallCount = 0
        getStreakCallCount = 0
        getWeeklyIntakeCallCount = 0
        
        lastDate = nil
        lastNoteText = nil
        lastStartDate = nil
        
        weekEntriesToReturn = []
        entryToReturn = nil
        streakToReturn = 0
        weeklyIntakeToReturn = nil
        errorToThrow = nil
    }
}

