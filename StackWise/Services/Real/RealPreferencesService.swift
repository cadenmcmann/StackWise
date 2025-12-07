import Foundation

// MARK: - RealPreferencesService
public class RealPreferencesService: PreferencesService {
    private let networkManager = NetworkManager.shared
    
    public init() {}
    
    public func savePreferences(_ intake: Intake) async throws {
        let request = intake.toPreferencesRequest()
        
        _ = try await networkManager.request(
            endpoint: "preferences",
            method: "POST",
            body: request,
            requiresAuth: true,
            responseType: PreferencesResponse.self
        )
    }
    
    public func fetchPreferences() async throws -> Intake? {
        do {
            let response = try await networkManager.request(
                endpoint: "preferences",
                method: "GET",
                requiresAuth: true,
                responseType: PreferencesResponse.self
            )
            
            print("✅ Fetched preferences successfully")
            let intake = response.preferences.toIntake()
            print("📋 Converted to intake - goals: \(intake.goals.count), age: \(intake.basics.age), priority: \(intake.topPriorityText)")
            return intake
        } catch {
            // If 404 (no preferences), return nil - handle both error types
            if case NetworkError.httpError(let statusCode) = error, statusCode == 404 {
                print("ℹ️ No preferences found (404 httpError)")
                return nil
            }
            if case NetworkError.apiError(_, let statusCode) = error, statusCode == 404 {
                print("ℹ️ No preferences found (404 apiError)")
                return nil
            }
            print("❌ Failed to fetch preferences: \(error)")
            throw error
        }
    }
}
