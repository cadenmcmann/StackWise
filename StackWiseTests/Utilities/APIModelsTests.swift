import Testing
import Foundation
@testable import StackWise

@Suite("APIModels Conversion Tests")
struct APIModelsTests {
    
    // MARK: - APIPreferences.toIntake Tests
    
    @Test("APIPreferences.toIntake maps all fields correctly")
    func apiPreferencesToIntake() {
        let preferences = APIPreferences(
            id: "pref-1",
            userId: "user-1",
            goals: ["Build Muscle", "Improve Focus / Concentration"],
            age: 30,
            sex: "male",
            heightCm: 175,
            weightKg: 75,
            bodyFatPct: 15.5,
            stimulantTolerance: "moderate",
            priorityText: "Build muscle while improving focus",
            updatedAt: nil
        )
        
        let intake = preferences.toIntake()
        
        #expect(intake.goals.contains(.buildMuscle))
        #expect(intake.goals.contains(.improveFocus))
        #expect(intake.basics.age == 30)
        #expect(intake.basics.sex == .male)
        #expect(intake.basics.height == 175)
        #expect(intake.basics.weight == 75)
        #expect(intake.basics.bodyFat == 15.5)
        #expect(intake.basics.stimulantTolerance == .moderate)
        #expect(intake.topPriorityText == "Build muscle while improving focus")
    }
    
    @Test("APIPreferences.toIntake handles nil values")
    func apiPreferencesToIntakeNilValues() {
        let preferences = APIPreferences(
            id: nil,
            userId: "user-1",
            goals: [],
            age: nil,
            sex: nil,
            heightCm: nil,
            weightKg: nil,
            bodyFatPct: nil,
            stimulantTolerance: nil,
            priorityText: nil,
            updatedAt: nil
        )
        
        let intake = preferences.toIntake()
        
        // Should use default values
        #expect(intake.basics.age == 25) // Default age
        #expect(intake.basics.sex == .other) // Default sex
        #expect(intake.basics.stimulantTolerance == .moderate) // Default tolerance
        #expect(intake.topPriorityText == "")
    }
    
    @Test("APIPreferences sex mapping works correctly")
    func apiPreferencesSexMapping() {
        let malePrefs = APIPreferences(
            id: nil,
            userId: "user-1",
            goals: [],
            age: 25,
            sex: "male",
            heightCm: 170,
            weightKg: 70,
            bodyFatPct: nil,
            stimulantTolerance: nil,
            priorityText: nil,
            updatedAt: nil
        )
        
        let femalePrefs = APIPreferences(
            id: nil,
            userId: "user-1",
            goals: [],
            age: 25,
            sex: "female",
            heightCm: 170,
            weightKg: 70,
            bodyFatPct: nil,
            stimulantTolerance: nil,
            priorityText: nil,
            updatedAt: nil
        )
        
        #expect(malePrefs.toIntake().basics.sex == .male)
        #expect(femalePrefs.toIntake().basics.sex == .female)
    }
    
    @Test("APIPreferences stimulant tolerance mapping works correctly")
    func apiPreferencesStimulantMapping() {
        func makePrefsWithTolerance(_ tolerance: String) -> APIPreferences {
            APIPreferences(
                id: nil,
                userId: "user-1",
                goals: [],
                age: 25,
                sex: nil,
                heightCm: 170,
                weightKg: 70,
                bodyFatPct: nil,
                stimulantTolerance: tolerance,
                priorityText: nil,
                updatedAt: nil
            )
        }
        
        #expect(makePrefsWithTolerance("none").toIntake().basics.stimulantTolerance == .none)
        #expect(makePrefsWithTolerance("low").toIntake().basics.stimulantTolerance == .low)
        #expect(makePrefsWithTolerance("moderate").toIntake().basics.stimulantTolerance == .moderate)
        #expect(makePrefsWithTolerance("high").toIntake().basics.stimulantTolerance == .high)
    }
    
    // MARK: - Intake.toPreferencesRequest Tests
    
    @Test("Intake.toPreferencesRequest converts goals to strings")
    func intakeToPreferencesRequestGoals() {
        var intake = Intake()
        intake.goals = [.buildMuscle, .improveFocus]
        intake.basics = TestHelpers.makeBasics(age: 30, sex: .male)
        intake.topPriorityText = "Test priority"
        
        let request = intake.toPreferencesRequest()
        
        #expect(request.goals.contains("Build Muscle"))
        #expect(request.goals.contains("Improve Focus / Concentration"))
        #expect(request.age == 30)
        #expect(request.sex == "male")
        #expect(request.priorityText == "Test priority")
    }
    
    @Test("Intake.toPreferencesRequest handles empty priority text")
    func intakeToPreferencesRequestEmptyPriority() {
        var intake = Intake()
        intake.topPriorityText = ""
        
        let request = intake.toPreferencesRequest()
        
        #expect(request.priorityText == nil)
    }
    
    // MARK: - APIStack.toStack Tests
    
    @Test("APIStack.toStack creates supplements correctly")
    func apiStackToStack() {
        let apiStack = APIStack(
            id: "stack-1",
            userId: "user-1",
            supplements: [
                APIStackSupplement(
                    supplementId: "supp-1",
                    name: "Vitamin D3",
                    dose: "2000 IU",
                    schedule: APISupplementSchedule(daysOfWeek: ["monday"], times: ["morning"]),
                    tags: ["essential"],
                    rationale: "Good for bone health",
                    active: true,
                    purposeShort: "Short purpose",
                    purposeLong: "Long purpose",
                    scientificFunction: nil
                )
            ],
            createdAt: "2025-01-15T10:00:00.000Z"
        )
        
        let stack = apiStack.toStack()
        
        #expect(stack.id == "stack-1")
        #expect(stack.minimal.count == 1)
        #expect(stack.minimal[0].id == "supp-1")
        #expect(stack.minimal[0].name == "Vitamin D3")
        #expect(stack.minimal[0].doseRangeText == "2000 IU")
        #expect(stack.minimal[0].rationale == "Good for bone health")
        #expect(stack.minimal[0].active == true)
        #expect(stack.minimal[0].schedule?.daysOfWeek.contains("monday") == true)
        #expect(stack.minimal[0].schedule?.times.contains("morning") == true)
    }
    
    @Test("APIStack.toStack puts all supplements in minimal array")
    func apiStackToStackMinimalArray() {
        let apiStack = APIStack(
            id: "stack-1",
            userId: "user-1",
            supplements: [
                APIStackSupplement(
                    supplementId: "s1",
                    name: "Supp 1",
                    dose: "100mg",
                    schedule: APISupplementSchedule(daysOfWeek: [], times: []),
                    tags: [],
                    rationale: "",
                    active: true,
                    purposeShort: nil,
                    purposeLong: nil,
                    scientificFunction: nil
                ),
                APIStackSupplement(
                    supplementId: "s2",
                    name: "Supp 2",
                    dose: "200mg",
                    schedule: APISupplementSchedule(daysOfWeek: [], times: []),
                    tags: [],
                    rationale: "",
                    active: false,
                    purposeShort: nil,
                    purposeLong: nil,
                    scientificFunction: nil
                )
            ],
            createdAt: "2025-01-15T10:00:00.000Z"
        )
        
        let stack = apiStack.toStack()
        
        #expect(stack.minimal.count == 2)
        #expect(stack.addons.count == 0)
    }
    
    // MARK: - APIUser.toUser Tests
    
    @Test("APIUser.toUser handles optional preferences")
    func apiUserToUser() {
        let apiUser = APIUser(
            id: "user-1",
            email: "test@example.com",
            phoneNumber: nil,
            firstName: "John",
            lastName: "Doe",
            createdAt: "2025-01-15T10:00:00.000Z"
        )
        
        let user = apiUser.toUser()
        
        #expect(user.id == "user-1")
        #expect(user.email == "test@example.com")
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        // Default values when no preferences
        #expect(user.age == 25)
        #expect(user.sex == .other)
    }
    
    @Test("APIUser.toUser applies preferences when provided")
    func apiUserToUserWithPreferences() {
        let apiUser = APIUser(
            id: "user-1",
            email: "test@example.com",
            phoneNumber: nil,
            firstName: "John",
            lastName: "Doe",
            createdAt: nil
        )
        
        let preferences = APIPreferences(
            id: nil,
            userId: "user-1",
            goals: [],
            age: 35,
            sex: "female",
            heightCm: 165,
            weightKg: 60,
            bodyFatPct: 20.0,
            stimulantTolerance: "low",
            priorityText: nil,
            updatedAt: nil
        )
        
        let user = apiUser.toUser(withPreferences: preferences)
        
        #expect(user.age == 35)
        #expect(user.sex == .female)
        #expect(user.height == 165)
        #expect(user.weight == 60)
        #expect(user.bodyFat == 20.0)
        #expect(user.stimulantTolerance == .low)
    }
    
    // MARK: - AuthResponse Tests
    
    @Test("AuthResponse has expected fields")
    func authResponseFields() throws {
        let json = """
        {
            "token": "test-token-123",
            "user": {
                "id": "user-1",
                "email": "test@example.com"
            },
            "hasActiveStack": true,
            "needsOnboarding": false
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(AuthResponse.self, from: json)
        
        #expect(response.token == "test-token-123")
        #expect(response.user.id == "user-1")
        #expect(response.hasActiveStack == true)
        #expect(response.needsOnboarding == false)
    }
    
    // MARK: - SendCodeResponse Tests
    
    @Test("SendCodeResponse decodes correctly")
    func sendCodeResponseDecodes() throws {
        let json = """
        {
            "success": true,
            "message": "Code sent successfully",
            "delivery_method": "email"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(SendCodeResponse.self, from: json)
        
        #expect(response.success == true)
        #expect(response.message == "Code sent successfully")
        #expect(response.deliveryMethod == "email")
    }
    
    // MARK: - StackJobStatus Tests
    
    @Test("StackJobStatus has correct cases")
    func stackJobStatusCases() {
        let pending = StackJobStatus.pending
        let processing = StackJobStatus.processing
        let completed = StackJobStatus.completed(stackId: "stack-1")
        let failed = StackJobStatus.failed(errorMessage: "Something went wrong")
        
        switch pending {
        case .pending: #expect(true)
        default: #expect(Bool(false))
        }
        
        switch processing {
        case .processing: #expect(true)
        default: #expect(Bool(false))
        }
        
        switch completed {
        case .completed(let stackId):
            #expect(stackId == "stack-1")
        default: #expect(Bool(false))
        }
        
        switch failed {
        case .failed(let message):
            #expect(message == "Something went wrong")
        default: #expect(Bool(false))
        }
    }
}

