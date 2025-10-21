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
            
            return response.preferences.toIntake()
        } catch {
            // If 404 (no preferences), return nil
            if case NetworkError.httpError(let statusCode) = error, statusCode == 404 {
                return nil
            }
            throw error
        }
    }
}
