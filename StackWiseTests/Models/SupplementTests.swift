import Testing
import Foundation
@testable import StackWise

@Suite("Supplement and Stack Model Tests")
struct SupplementTests {
    
    // MARK: - Stack.allSupplements Tests
    
    @Test("allSupplements returns minimal and addons combined")
    func allSupplementsCombined() {
        let stack = TestHelpers.makeStack()
        
        #expect(stack.allSupplements.count == 5)
        #expect(stack.minimal.count == 3)
        #expect(stack.addons.count == 2)
    }
    
    @Test("allSupplements returns empty when stack is empty")
    func allSupplementsEmpty() {
        let stack = TestHelpers.makeEmptyStack()
        #expect(stack.allSupplements.isEmpty)
    }
    
    // MARK: - Stack.activeSupplements Tests
    
    @Test("activeSupplements filters correctly")
    func activeSupplementsFilters() {
        // Create stack with mixed active/inactive supplements
        let stack = TestHelpers.makeStack(
            minimal: [
                TestHelpers.makeSupplement(id: "1", name: "Active1", active: true),
                TestHelpers.makeSupplement(id: "2", name: "Inactive1", active: false)
            ],
            addons: [
                TestHelpers.makeSupplement(id: "3", name: "Active2", active: true),
                TestHelpers.makeSupplement(id: "4", name: "Inactive2", active: false)
            ]
        )
        
        let active = stack.activeSupplements
        #expect(active.count == 2)
        #expect(active.allSatisfy { $0.active })
    }
    
    // MARK: - Stack.inactiveSupplements Tests
    
    @Test("inactiveSupplements filters correctly")
    func inactiveSupplementsFilters() {
        let stack = TestHelpers.makeStack(
            minimal: [
                TestHelpers.makeSupplement(id: "1", name: "Active1", active: true),
                TestHelpers.makeSupplement(id: "2", name: "Inactive1", active: false)
            ],
            addons: [
                TestHelpers.makeSupplement(id: "3", name: "Active2", active: true),
                TestHelpers.makeSupplement(id: "4", name: "Inactive2", active: false)
            ]
        )
        
        let inactive = stack.inactiveSupplements
        #expect(inactive.count == 2)
        #expect(inactive.allSatisfy { !$0.active })
    }
    
    // MARK: - Stack.toggleSupplementActive Tests
    
    @Test("toggleSupplementActive toggles supplement in minimal array")
    func toggleInMinimalArray() {
        var stack = TestHelpers.makeStack(
            minimal: [TestHelpers.makeSupplement(id: "test-id", active: true)],
            addons: []
        )
        
        #expect(stack.minimal[0].active == true)
        
        stack.toggleSupplementActive(supplementId: "test-id")
        
        #expect(stack.minimal[0].active == false)
    }
    
    @Test("toggleSupplementActive toggles supplement in addons array")
    func toggleInAddonsArray() {
        var stack = TestHelpers.makeStack(
            minimal: [],
            addons: [TestHelpers.makeSupplement(id: "addon-id", active: false)]
        )
        
        #expect(stack.addons[0].active == false)
        
        stack.toggleSupplementActive(supplementId: "addon-id")
        
        #expect(stack.addons[0].active == true)
    }
    
    @Test("toggleSupplementActive does nothing for non-existent ID")
    func toggleNonExistent() {
        var stack = TestHelpers.makeStack(
            minimal: [TestHelpers.makeSupplement(id: "existing-id", active: true)],
            addons: []
        )
        
        stack.toggleSupplementActive(supplementId: "non-existent-id")
        
        // Should remain unchanged
        #expect(stack.minimal[0].active == true)
    }
    
    // MARK: - EvidenceLevel Tests
    
    @Test("EvidenceLevel.description returns correct strings")
    func evidenceLevelDescriptions() {
        #expect(Supplement.EvidenceLevel.a.description == "Strong evidence")
        #expect(Supplement.EvidenceLevel.b.description == "Moderate evidence")
        #expect(Supplement.EvidenceLevel.c.description == "Emerging evidence")
    }
    
    @Test("EvidenceLevel has correct raw values")
    func evidenceLevelRawValues() {
        #expect(Supplement.EvidenceLevel.a.rawValue == "A")
        #expect(Supplement.EvidenceLevel.b.rawValue == "B")
        #expect(Supplement.EvidenceLevel.c.rawValue == "C")
    }
    
    // MARK: - TimingTag Tests
    
    @Test("TimingTag has correct raw values")
    func timingTagRawValues() {
        #expect(Supplement.TimingTag.morning.rawValue == "AM")
        #expect(Supplement.TimingTag.noon.rawValue == "Lunch")
        #expect(Supplement.TimingTag.evening.rawValue == "PM")
        #expect(Supplement.TimingTag.night.rawValue == "Night")
    }
    
    // MARK: - Codable Tests
    
    @Test("Supplement encodes and decodes correctly")
    func supplementCodableRoundtrip() throws {
        let supplement = TestHelpers.makeSupplement(
            id: "test-supp",
            name: "Vitamin D3",
            purposeShort: "Bone health",
            doseRangeText: "2000 IU",
            timingTag: .morning,
            evidenceLevel: .a,
            active: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(supplement)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Supplement.self, from: data)
        
        #expect(decoded.id == supplement.id)
        #expect(decoded.name == supplement.name)
        #expect(decoded.purposeShort == supplement.purposeShort)
        #expect(decoded.doseRangeText == supplement.doseRangeText)
        #expect(decoded.timingTag == supplement.timingTag)
        #expect(decoded.evidenceLevel == supplement.evidenceLevel)
        #expect(decoded.active == supplement.active)
    }
    
    @Test("Stack encodes and decodes correctly")
    func stackCodableRoundtrip() throws {
        let stack = TestHelpers.makeStack()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(stack)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Stack.self, from: data)
        
        #expect(decoded.id == stack.id)
        #expect(decoded.minimal.count == stack.minimal.count)
        #expect(decoded.addons.count == stack.addons.count)
    }
    
    // MARK: - SupplementSchedule Tests
    
    @Test("SupplementSchedule initializes correctly")
    func scheduleInitialization() {
        let schedule = SupplementSchedule(
            daysOfWeek: ["monday", "wednesday", "friday"],
            times: ["morning", "evening"]
        )
        
        #expect(schedule.daysOfWeek.count == 3)
        #expect(schedule.times.count == 2)
        #expect(schedule.daysOfWeek.contains("monday"))
        #expect(schedule.times.contains("morning"))
    }
    
    // MARK: - RemixOptions Tests
    
    @Test("RemixOptions has correct default values")
    func remixOptionsDefaults() {
        let options = RemixOptions()
        
        #expect(options.fewerPills == false)
        #expect(options.cheaper == false)
        #expect(options.stimulantFree == false)
        #expect(options.athleteMode == false)
    }
    
    @Test("RemixOptions initializes with custom values")
    func remixOptionsCustomValues() {
        let options = RemixOptions(
            fewerPills: true,
            cheaper: true,
            stimulantFree: false,
            athleteMode: true
        )
        
        #expect(options.fewerPills == true)
        #expect(options.cheaper == true)
        #expect(options.stimulantFree == false)
        #expect(options.athleteMode == true)
    }
}

