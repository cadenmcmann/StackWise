import Foundation
@testable import StackWise

// MARK: - MockPreferencesService
final class MockPreferencesService: PreferencesService {
    
    // MARK: - Call Tracking
    var savePreferencesCallCount = 0
    var fetchPreferencesCallCount = 0
    
    // MARK: - Captured Parameters
    var lastSavedIntake: Intake?
    
    // MARK: - Configured Responses
    var intakeToReturn: Intake?
    var errorToThrow: Error?
    
    // MARK: - PreferencesService Implementation
    
    func savePreferences(_ intake: Intake) async throws {
        savePreferencesCallCount += 1
        lastSavedIntake = intake
        if let error = errorToThrow { throw error }
    }
    
    func fetchPreferences() async throws -> Intake? {
        fetchPreferencesCallCount += 1
        if let error = errorToThrow { throw error }
        return intakeToReturn
    }
    
    // MARK: - Helper
    func reset() {
        savePreferencesCallCount = 0
        fetchPreferencesCallCount = 0
        lastSavedIntake = nil
        intakeToReturn = nil
        errorToThrow = nil
    }
}

