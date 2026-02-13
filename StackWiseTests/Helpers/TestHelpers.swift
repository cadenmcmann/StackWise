import Foundation
@testable import StackWise

// MARK: - Test Helpers
/// Factory methods and utilities for creating test data

enum TestHelpers {
    
    // MARK: - User Factory
    
    /// Creates a default test user
    static func makeUser(
        id: String = "test-user-id",
        email: String? = "test@example.com",
        phoneNumber: String? = nil,
        firstName: String? = "John",
        lastName: String? = "Doe",
        createdAt: Date? = nil,
        age: Int = 30,
        sex: User.Sex = .male,
        height: Double = 175,
        weight: Double = 75,
        bodyFat: Double? = 15.0,
        stimulantTolerance: User.StimulantTolerance = .moderate
    ) -> User {
        User(
            id: id,
            email: email,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
            age: age,
            sex: sex,
            height: height,
            weight: weight,
            bodyFat: bodyFat,
            stimulantTolerance: stimulantTolerance
        )
    }
    
    // MARK: - Supplement Factory
    
    /// Creates a default test supplement
    static func makeSupplement(
        id: String = UUID().uuidString,
        name: String = "Vitamin D3",
        purposeShort: String? = "Supports bone health",
        purposeLong: String? = "Vitamin D3 is essential for calcium absorption and bone health.",
        scientificFunction: String? = nil,
        doseRangeText: String = "2000-5000 IU",
        formNote: String? = "Take with a meal containing fat",
        timingTag: Supplement.TimingTag? = .morning,
        evidenceLevel: Supplement.EvidenceLevel? = .a,
        flags: Set<Supplement.SupplementFlag> = [],
        citations: [Citation] = [],
        rationale: String = "Based on your goals, Vitamin D3 supports overall health.",
        active: Bool = true,
        schedule: SupplementSchedule? = nil,
        tags: [String] = []
    ) -> Supplement {
        Supplement(
            id: id,
            name: name,
            purposeShort: purposeShort,
            purposeLong: purposeLong,
            scientificFunction: scientificFunction,
            doseRangeText: doseRangeText,
            formNote: formNote,
            timingTag: timingTag,
            evidenceLevel: evidenceLevel,
            flags: flags,
            citations: citations,
            rationale: rationale,
            active: active,
            schedule: schedule,
            tags: tags
        )
    }
    
    /// Creates a supplement with schedule
    static func makeSupplementWithSchedule(
        id: String = UUID().uuidString,
        name: String = "Creatine",
        times: [String] = ["morning"],
        active: Bool = true
    ) -> Supplement {
        makeSupplement(
            id: id,
            name: name,
            active: active,
            schedule: SupplementSchedule(
                daysOfWeek: ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"],
                times: times
            )
        )
    }
    
    // MARK: - Stack Factory
    
    /// Creates a default test stack
    static func makeStack(
        id: String? = "test-stack-id",
        minimal: [Supplement]? = nil,
        addons: [Supplement]? = nil
    ) -> Stack {
        let defaultMinimal = minimal ?? [
            makeSupplement(id: "supp-1", name: "Vitamin D3"),
            makeSupplement(id: "supp-2", name: "Omega-3"),
            makeSupplement(id: "supp-3", name: "Magnesium")
        ]
        let defaultAddons = addons ?? [
            makeSupplement(id: "supp-4", name: "Creatine"),
            makeSupplement(id: "supp-5", name: "Ashwagandha", active: false)
        ]
        
        return Stack(
            id: id,
            minimal: defaultMinimal,
            addons: defaultAddons
        )
    }
    
    /// Creates an empty stack
    static func makeEmptyStack() -> Stack {
        Stack(id: nil, minimal: [], addons: [])
    }
    
    // MARK: - Intake Factory
    
    /// Creates a default test intake
    static func makeIntake(
        goals: Set<Goal> = [.buildMuscle, .improveFocus],
        basics: Basics? = nil,
        risks: Set<Risk> = [],
        topPriorityText: String = "I want to build muscle and improve focus"
    ) -> Intake {
        Intake(
            goals: goals,
            basics: basics ?? makeBasics(),
            risks: risks,
            topPriorityText: topPriorityText
        )
    }
    
    /// Creates default basics
    static func makeBasics(
        age: Int = 30,
        sex: User.Sex = .male,
        height: Double = 175,
        weight: Double = 75,
        bodyFat: Double? = nil,
        stimulantTolerance: User.StimulantTolerance = .moderate
    ) -> Basics {
        Basics(
            age: age,
            sex: sex,
            height: height,
            weight: weight,
            bodyFat: bodyFat,
            stimulantTolerance: stimulantTolerance
        )
    }
    
    // MARK: - TrackEntry Factory
    
    /// Creates a test track entry
    static func makeTrackEntry(
        id: String = UUID().uuidString,
        date: Date = Date(),
        takenSupplementIds: Set<String> = ["supp-1", "supp-2"],
        note: String? = nil
    ) -> TrackEntry {
        TrackEntry(
            id: id,
            date: date,
            takenSupplementIds: takenSupplementIds,
            note: note
        )
    }
    
    // MARK: - Message Factory
    
    /// Creates a test message
    static func makeMessage(
        id: String = UUID().uuidString,
        role: Message.Role = .user,
        text: String = "Hello, I have a question about supplements",
        createdAt: Date = Date()
    ) -> Message {
        Message(
            id: id,
            role: role,
            text: text,
            createdAt: createdAt
        )
    }
    
    /// Creates an assistant message
    static func makeAssistantMessage(
        id: String = UUID().uuidString,
        text: String = "I'd be happy to help with your supplement questions.",
        createdAt: Date = Date()
    ) -> Message {
        makeMessage(id: id, role: .assistant, text: text, createdAt: createdAt)
    }
    
    // MARK: - ChatSession Factory
    
    /// Creates a test chat session
    static func makeChatSession(
        id: String = UUID().uuidString,
        userId: String? = "test-user-id",
        title: String? = "Test Chat",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> ChatSession {
        ChatSession(
            id: id,
            userId: userId,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - API Response Factory
    
    /// Creates a test SendCodeResponse
    static func makeSendCodeResponse(
        success: Bool = true,
        message: String = "Code sent successfully",
        deliveryMethod: String = "email"
    ) -> SendCodeResponse {
        SendCodeResponse(
            success: success,
            message: message,
            deliveryMethod: deliveryMethod
        )
    }
    
    /// Creates a test WeeklyIntakeResponse
    static func makeWeeklyIntakeResponse(
        weekData: [DayIntakeData] = []
    ) -> WeeklyIntakeResponse {
        WeeklyIntakeResponse(weekData: weekData)
    }
    
    /// Creates a test DayIntakeData
    static func makeDayIntakeData(
        date: String,
        stackId: String? = "test-stack-id",
        stackIntakeData: [SupplementIntakeData] = []
    ) -> DayIntakeData {
        DayIntakeData(
            date: date,
            stackId: stackId,
            stackIntakeData: stackIntakeData
        )
    }
    
    /// Creates a test SupplementIntakeData
    static func makeSupplementIntakeData(
        supplementId: String = "supp-1",
        supplementName: String = "Vitamin D3",
        time: String = "morning",
        taken: Bool = false
    ) -> SupplementIntakeData {
        SupplementIntakeData(
            supplementId: supplementId,
            supplementName: supplementName,
            time: time,
            taken: taken
        )
    }
    
    // MARK: - Date Helpers
    
    /// Creates a date for testing (today at midnight)
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    /// Creates a date for a specific day offset from today
    static func date(daysFromToday offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
    }
    
    /// Creates a date string in API format (yyyy-MM-dd)
    static func apiDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// Creates a date from API format string
    static func dateFromAPIString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    /// Gets start of week (Monday) for a date
    static func startOfWeek(for date: Date = Date()) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

