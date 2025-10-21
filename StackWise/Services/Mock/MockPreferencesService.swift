import Foundation

// MARK: - MockPreferencesService
public class MockPreferencesService: PreferencesService {
    private var storedIntake: Intake?
    
    public init() {}
    
    public func savePreferences(_ intake: Intake) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        storedIntake = intake
    }
    
    public func fetchPreferences() async throws -> Intake? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return storedIntake
    }
}
