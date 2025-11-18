import Foundation

// MARK: - Auth Models

public struct SignupRequest: Codable {
    let email: String
    let password: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
}

public struct LoginRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let password: String
}

public struct AuthResponse: Codable {
    public let token: String
    public let user: APIUser
    public let hasActiveStack: Bool
    public let needsOnboarding: Bool
}

public struct APIUser: Codable {
    public let id: String
    public let email: String?
    public let phoneNumber: String?
    public let firstName: String?
    public let lastName: String?
    public let createdAt: String?
}

// MARK: - Verification Code Models

public struct SendCodeRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let purpose: String
}

public struct SendCodeResponse: Codable {
    public let success: Bool
    public let message: String
    public let deliveryMethod: String
}

public struct VerifyCodeRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let code: String
    let purpose: String
}

// Using AuthResponse for login verification
// Separate response for password reset verification
public struct VerifyCodeResetResponse: Codable {
    public let verified: Bool
    public let message: String
}

// MARK: - Password Reset Models

public struct ResetPasswordRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let code: String
    let newPassword: String
}

public struct ResetPasswordResponse: Codable {
    public let success: Bool
    public let message: String
}

// MARK: - Profile Update Models

public struct UpdateProfileRequest: Codable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
}

public struct UpdateProfileResponse: Codable {
    public let user: APIUser
    public let message: String
}

// MARK: - Preferences Models

public struct PreferencesRequest: Codable {
    let goals: [String]
    let age: Int?
    let sex: String?
    let heightCm: Int?
    let weightKg: Int?
    let bodyFatPct: Double?
    let stimulantTolerance: String?
    let budgetUsd: Int?
    let dietaryPrefs: [String]
    let priorityText: String?
}

public struct PreferencesResponse: Codable {
    let message: String?
    let preferences: APIPreferences
}

public struct APIPreferences: Codable {
    let id: String?
    let userId: String
    let goals: [String]
    let age: Int?
    let sex: String?
    let heightCm: Int?
    let weightKg: Int?
    let bodyFatPct: String?  // API returns as string "18.00"
    let stimulantTolerance: String?
    let budgetUsd: Int?
    let dietaryPrefs: [String]
    let priorityText: String?
    let updatedAt: String?
}

// MARK: - Goals Models

public struct GoalsResponse: Codable {
    let goals: [APIGoal]
}

public struct APIGoal: Codable {
    let id: String
    let goalName: String
}

// MARK: - Stack Models

public struct StackResponse: Codable {
    let stack: APIStack
    let message: String?
}

public struct APIStack: Codable {
    let id: String
    let userId: String
    let supplements: [APIStackSupplement]
    let createdAt: String
}

public struct APIStackSupplement: Codable {
    let supplementId: String
    let name: String
    let dose: String
    let schedule: APISupplementSchedule
    let tags: [String]
    let rationale: String
    let active: Bool
    // These fields will be populated from the supplement database internally
    let purposeShort: String?
    let purposeLong: String?
    let scientificFunction: String?
}

public struct APISupplementSchedule: Codable {
    let daysOfWeek: [String]
    let times: [String]
}

// MARK: - Stack Generation Job Models

public struct GenerateStackJobResponse: Codable {
    let jobId: String
    let status: String
    let message: String
}

public struct StackJobStatusResponse: Codable {
    let jobId: String
    let status: String
    let stackId: String?
    let errorMessage: String?
    let createdAt: String
    let completedAt: String?
}

public struct RetryJobResponse: Codable {
    let jobId: String
    let status: String
    let message: String
}

public enum StackJobStatus {
    case pending
    case processing
    case completed(stackId: String)
    case failed(errorMessage: String)
}

// MARK: - Toggle Supplement Models

public struct ToggleSupplementsRequest: Codable {
    let updates: [SupplementUpdate]
    
    public struct SupplementUpdate: Codable {
        let supplementId: String
        let active: Bool
    }
}

public struct ToggleSupplementsResponse: Codable {
    let message: String
    let updatedCount: Int
    let updates: [SupplementUpdateResult]
    
    public struct SupplementUpdateResult: Codable {
        let supplementId: String
        let active: Bool
    }
}

// MARK: - Chat Models

// Empty struct for creating session without title
public struct CreateSessionRequest: Codable {
    // Send empty object {} to match what Postman sends
    public init() {}
}

// Struct for creating session with title
public struct CreateSessionWithTitleRequest: Codable {
    let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct CreateSessionResponse: Codable {
    let sessionId: String
    let title: String?
    let createdAt: String
}

public struct ChatSessionsResponse: Codable {
    let sessions: [APIChatSession]
    let nextCursor: String?
}

public struct APIChatSession: Codable {
    let id: String
    let userId: String
    let title: String?
    let createdAt: String
    let updatedAt: String
}

public struct ChatSessionDetailResponse: Codable {
    let session: APIChatSession
    let messages: [APIChatMessage]
    let hasMore: Bool
}

public struct APIChatMessage: Codable {
    let id: String
    let sessionId: String
    let userId: String
    let role: String
    let content: String
    let createdAt: String
}

public struct SendMessageRequest: Codable {
    let message: String
}

public struct SendMessageResponse: Codable {
    let messageId: String
    let content: String
    let role: String
    let createdAt: String
}

// MARK: - Analytics Models

public struct WeeklyIntakeResponse: Codable {
    let weekData: [DayIntakeData]
}

public struct DayIntakeData: Codable {
    let date: String
    let stackId: String?
    let stackIntakeData: [SupplementIntakeData]
}

public struct SupplementIntakeData: Codable {
    let supplementId: String
    let supplementName: String
    let time: String
    let taken: Bool
}

// MARK: - Conversion Extensions

extension APIPreferences {
    func toIntake() -> Intake {
        var intake = Intake()
        
        // Map goals from strings to Goal enum (exact match since we updated the enum)
        intake.goals = Set(goals.compactMap { goalString in
            Goal(rawValue: goalString)
        })
        
        // Map basic information
        intake.basics = Basics(
            age: age ?? 25,
            sex: mapSex(sex),
            height: Double(heightCm ?? 170),
            weight: Double(weightKg ?? 70),
            bodyFat: bodyFatPct.flatMap { Double($0) },  // Convert string to Double
            stimulantTolerance: mapStimulantTolerance(stimulantTolerance),
            budgetPerMonth: Double(budgetUsd ?? 100),
            dietaryPreferences: Set(dietaryPrefs.compactMap { pref in
                DietaryPreference.allCases.first { $0.rawValue.lowercased() == pref.lowercased() }
            })
        )
        
        intake.topPriorityText = priorityText ?? ""
        
        return intake
    }
    
    private func mapSex(_ sex: String?) -> User.Sex {
        guard let sex = sex else { return .other }
        switch sex.lowercased() {
        case "male": return .male
        case "female": return .female
        default: return .other
        }
    }
    
    private func mapStimulantTolerance(_ tolerance: String?) -> User.StimulantTolerance {
        guard let tolerance = tolerance else { return .moderate }
        switch tolerance.lowercased() {
        case "none": return .none
        case "low": return .low
        case "moderate": return .moderate
        case "high": return .high
        default: return .moderate
        }
    }
}

extension Intake {
    func toPreferencesRequest() -> PreferencesRequest {
        // Convert our internal goals to strings for the API
        let goalStrings = goals.map { $0.rawValue }
        
        // Convert dietary preferences to strings
        let dietaryStrings = basics.dietaryPreferences.map { $0.rawValue }
        
        return PreferencesRequest(
            goals: goalStrings,
            age: basics.age,
            sex: basics.sex.rawValue.lowercased(),
            heightCm: Int(basics.height),
            weightKg: Int(basics.weight),
            bodyFatPct: basics.bodyFat,
            stimulantTolerance: basics.stimulantTolerance.rawValue.lowercased(),
            budgetUsd: Int(basics.budgetPerMonth),
            dietaryPrefs: dietaryStrings,
            priorityText: topPriorityText.isEmpty ? nil : topPriorityText
        )
    }
}

extension APIStack {
    func toStack() -> Stack {
        // Convert all supplements - API returns them in one array
        let allSupplements = supplements.map { apiSupplement in
            Supplement(
                id: apiSupplement.supplementId,
                name: apiSupplement.name,
                purposeShort: apiSupplement.purposeShort,
                purposeLong: apiSupplement.purposeLong,
                scientificFunction: apiSupplement.scientificFunction,
                doseRangeText: apiSupplement.dose,
                formNote: nil,
                timingTag: nil, // Using schedule instead
                evidenceLevel: nil, // No longer provided by API
                flags: [], // Could be derived from dietary_flags if needed
                citations: [],
                rationale: apiSupplement.rationale,
                active: apiSupplement.active,
                schedule: SupplementSchedule(
                    daysOfWeek: apiSupplement.schedule.daysOfWeek,
                    times: apiSupplement.schedule.times
                ),
                tags: apiSupplement.tags
            )
        }
        
        // API returns all supplements in one array, we'll put them all in minimal
        // The Stack view will display all of them
        return Stack(id: id, minimal: allSupplements, addons: [])
    }
}

extension APIUser {
    func toUser(withPreferences preferences: APIPreferences? = nil) -> User {
        // Create a user with API fields
        var user = User(
            id: id,
            email: email,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            // Default values for required preference fields
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            stimulantTolerance: .moderate,
            budgetPerMonth: 100
        )
        
        // If preferences are provided, use them to update the user
        if let preferences = preferences {
            user.age = preferences.age ?? user.age
            user.sex = mapSex(preferences.sex)
            user.height = Double(preferences.heightCm ?? Int(user.height))
            user.weight = Double(preferences.weightKg ?? Int(user.weight))
            user.bodyFat = preferences.bodyFatPct.flatMap { Double($0) }  // Convert string to Double
            user.stimulantTolerance = mapStimulantTolerance(preferences.stimulantTolerance)
            user.budgetPerMonth = Double(preferences.budgetUsd ?? Int(user.budgetPerMonth))
            user.dietaryPreferences = Set(preferences.dietaryPrefs.compactMap { pref in
                DietaryPreference.allCases.first { $0.rawValue.lowercased() == pref.lowercased() }
            })
        }
        
        return user
    }
    
    private func mapSex(_ sex: String?) -> User.Sex {
        guard let sex = sex else { return .other }
        switch sex.lowercased() {
        case "male": return .male
        case "female": return .female
        default: return .other
        }
    }
    
    private func mapStimulantTolerance(_ tolerance: String?) -> User.StimulantTolerance {
        guard let tolerance = tolerance else { return .moderate }
        switch tolerance.lowercased() {
        case "none": return .none
        case "low": return .low
        case "moderate": return .moderate
        case "high": return .high
        default: return .moderate
        }
    }
}
