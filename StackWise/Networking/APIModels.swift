import Foundation

// MARK: - Auth Models

public struct SignupRequest: Codable {
    let email: String
    let password: String
}

public struct LoginRequest: Codable {
    let email: String
    let password: String
}

public struct AuthResponse: Codable {
    let token: String
    let user: APIUser
}

public struct APIUser: Codable {
    let id: String
    let email: String
    let createdAt: String?
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
    let id: String
    let userId: String
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
            bodyFat: bodyFatPct,
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
        guard let tolerance = tolerance else { return .medium }
        switch tolerance.lowercased() {
        case "low": return .low
        case "high": return .high
        default: return .medium
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
