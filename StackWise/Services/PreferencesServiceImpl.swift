import Foundation

// MARK: - PreferencesServiceImpl
public class PreferencesServiceImpl: PreferencesService {
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
            
            #if DEBUG
            print("✅ Fetched preferences successfully")
            #endif
            let intake = response.preferences.toIntake()
            #if DEBUG
            print("📋 Converted to intake - goals: \(intake.goals.count), age: \(intake.basics.age), priority: \(intake.topPriorityText)")
            #endif
            return intake
        } catch {
            // If 404 (no preferences), return nil - handle both error types
            if case NetworkError.httpError(let statusCode) = error, statusCode == 404 {
                #if DEBUG
                print("ℹ️ No preferences found (404 httpError)")
                #endif
                return nil
            }
            if case NetworkError.apiError(_, let statusCode) = error, statusCode == 404 {
                #if DEBUG
                print("ℹ️ No preferences found (404 apiError)")
                #endif
                return nil
            }
            #if DEBUG
            print("❌ Failed to fetch preferences: \(error)")
            #endif
            throw error
        }
    }
}

