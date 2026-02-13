import Foundation

// MARK: - TrackingServiceImpl
public class TrackingServiceImpl: TrackingService {
    private let networkManager = NetworkManager.shared
    
    public init() {}
    
    public func getWeekEntries(startingFrom date: Date) async throws -> [TrackEntry] {
        // Legacy method - returns empty for now
        return []
    }
    
    public func getEntry(for date: Date) async throws -> TrackEntry? {
        // Legacy method - returns nil for now
        return nil
    }
    
    public func saveNote(date: Date, text: String) async throws {
        // Not implemented yet
    }
    
    public func getStreak() async throws -> Int {
        // Not implemented yet
        return 0
    }
    
    public func getWeeklyIntake(startDate: Date) async throws -> WeeklyIntakeResponse {
        let dateString = startDate.apiDateString
        
        let response = try await networkManager.request(
            endpoint: "analytics/weekly-intake?start_date=\(dateString)",
            method: "GET",
            requiresAuth: true,
            responseType: WeeklyIntakeResponse.self
        )
        
        return response
    }
}

