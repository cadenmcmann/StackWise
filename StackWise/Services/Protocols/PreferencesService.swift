import Foundation

// MARK: - PreferencesService Protocol
public protocol PreferencesService {
    func savePreferences(_ intake: Intake) async throws
    func fetchPreferences() async throws -> Intake?
}
