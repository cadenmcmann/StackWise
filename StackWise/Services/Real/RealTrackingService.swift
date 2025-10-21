import Foundation

// MARK: - RealTrackingService
public class RealTrackingService: TrackingService {
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: startDate)
        
        let response = try await networkManager.request(
            endpoint: "analytics/weekly-intake?start_date=\(dateString)",
            method: "GET",
            requiresAuth: true,
            responseType: WeeklyIntakeResponse.self
        )
        
        return response
    }
}
