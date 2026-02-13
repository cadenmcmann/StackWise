import Testing
import Foundation
@testable import StackWise

@Suite("Intake Model Tests")
struct IntakeTests {
    
    // MARK: - Risk.isHardStop Tests
    
    @Test("isHardStop returns true for pregnancy")
    func pregnancyIsHardStop() {
        #expect(Risk.pregnancy.isHardStop == true)
    }
    
    @Test("isHardStop returns true for cancer")
    func cancerIsHardStop() {
        #expect(Risk.cancer.isHardStop == true)
    }
    
    @Test("isHardStop returns true for kidney disease")
    func kidneyDiseaseIsHardStop() {
        #expect(Risk.kidneyDisease.isHardStop == true)
    }
    
    @Test("isHardStop returns true for liver disease")
    func liverDiseaseIsHardStop() {
        #expect(Risk.liverDisease.isHardStop == true)
    }
    
    @Test("isHardStop returns false for non-critical risks")
    func nonCriticalRisksAreNotHardStop() {
        let nonHardStopRisks: [Risk] = [
            .bloodPressureMeds,
            .bloodThinners,
            .antidepressants,
            .anxietyMeds,
            .diabetesMeds,
            .thyroidMeds,
            .heartCondition,
            .autoimmune
        ]
        
        for risk in nonHardStopRisks {
            #expect(risk.isHardStop == false, "Expected \(risk) to not be a hard stop")
        }
    }
    
    // MARK: - Risk.warningMessage Tests
    
    @Test("warningMessage returns non-empty strings for all risks")
    func warningMessagesAreNotEmpty() {
        for risk in Risk.allCases {
            #expect(!risk.warningMessage.isEmpty, "Expected warning message for \(risk)")
        }
    }
    
    @Test("warningMessage for bloodPressureMeds mentions blood pressure")
    func bloodPressureMedsWarning() {
        let message = Risk.bloodPressureMeds.warningMessage
        #expect(message.lowercased().contains("blood pressure"))
    }
    
    @Test("warningMessage for pregnancy mentions pregnancy-safe")
    func pregnancyWarning() {
        let message = Risk.pregnancy.warningMessage
        #expect(message.lowercased().contains("pregnancy"))
    }
    
    // MARK: - Goal Enum Tests
    
    @Test("Goal enum has all expected categories")
    func goalEnumHasExpectedCases() {
        // Energy
        #expect(Goal.boostEnergyStimulant != nil)
        #expect(Goal.boostEnergyNonStimulant != nil)
        
        // Muscle & Recovery
        #expect(Goal.buildMuscle != nil)
        #expect(Goal.enhanceRecovery != nil)
        #expect(Goal.increaseStrength != nil)
        
        // Sleep
        #expect(Goal.fallAsleepFaster != nil)
        #expect(Goal.improveSleepQuality != nil)
        
        // Mental
        #expect(Goal.improveFocus != nil)
        #expect(Goal.improveMood != nil)
        #expect(Goal.reduceAnxiety != nil)
    }
    
    @Test("Goal count is correct")
    func goalCount() {
        // Verify we have a reasonable number of goals
        #expect(Goal.allCases.count > 20)
    }
    
    @Test("Goal raw values are human-readable strings")
    func goalRawValuesAreReadable() {
        #expect(Goal.buildMuscle.rawValue == "Build Muscle")
        #expect(Goal.improveFocus.rawValue == "Improve Focus / Concentration")
        #expect(Goal.boostEnergyStimulant.rawValue == "Boost Energy (caffeine/stimulant)")
    }
    
    // MARK: - Codable Tests
    
    @Test("Intake encodes and decodes correctly")
    func intakeCodableRoundtrip() throws {
        let intake = TestHelpers.makeIntake(
            goals: [.buildMuscle, .improveFocus, .fallAsleepFaster],
            risks: [.bloodPressureMeds],
            topPriorityText: "Build muscle while improving sleep"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(intake)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Intake.self, from: data)
        
        #expect(decoded.goals == intake.goals)
        #expect(decoded.risks == intake.risks)
        #expect(decoded.topPriorityText == intake.topPriorityText)
    }
    
    @Test("Basics encodes and decodes correctly")
    func basicsCodableRoundtrip() throws {
        let basics = TestHelpers.makeBasics(
            age: 35,
            sex: .female,
            height: 165,
            weight: 60,
            bodyFat: 22.0,
            stimulantTolerance: .low
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(basics)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Basics.self, from: data)
        
        #expect(decoded.age == basics.age)
        #expect(decoded.sex == basics.sex)
        #expect(decoded.height == basics.height)
        #expect(decoded.weight == basics.weight)
        #expect(decoded.bodyFat == basics.bodyFat)
        #expect(decoded.stimulantTolerance == basics.stimulantTolerance)
    }
    
    // MARK: - Default Values Tests
    
    @Test("Intake has correct default values")
    func intakeDefaults() {
        let intake = Intake()
        
        #expect(intake.goals.isEmpty)
        #expect(intake.risks.isEmpty)
        #expect(intake.topPriorityText == "")
    }
    
    @Test("Basics has correct default values")
    func basicsDefaults() {
        let basics = Basics()
        
        #expect(basics.age == 0)
        #expect(basics.sex == .other)
        #expect(basics.height == 0)
        #expect(basics.weight == 0)
        #expect(basics.bodyFat == nil)
        #expect(basics.stimulantTolerance == .moderate)
    }
    
    // MARK: - Risk All Cases Tests
    
    @Test("Risk enum has all expected cases")
    func riskEnumCases() {
        let expectedCases: Set<Risk> = [
            .bloodPressureMeds,
            .bloodThinners,
            .antidepressants,
            .anxietyMeds,
            .diabetesMeds,
            .thyroidMeds,
            .heartCondition,
            .kidneyDisease,
            .liverDisease,
            .pregnancy,
            .cancer,
            .autoimmune
        ]
        
        let actualCases = Set(Risk.allCases)
        #expect(actualCases == expectedCases)
    }
}

