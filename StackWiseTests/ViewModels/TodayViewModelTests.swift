import Testing
import Foundation
@testable import StackWise

@Suite("TodayViewModel Tests")
@MainActor
struct TodayViewModelTests {
    
    // MARK: - Helper Methods
    
    private func makeContainer(
        trackingService: MockTrackingService = MockTrackingService()
    ) -> DIContainer {
        return DIContainer(
            trackingService: trackingService,
            skipInitialLoad: true
        )
    }
    
    // MARK: - loadReminders Tests
    
    @Test("loadReminders generates reminders from stack")
    func loadRemindersGeneratesFromStack() async {
        let container = makeContainer()
        container.currentStack = TestHelpers.makeStack(
            minimal: [TestHelpers.makeSupplementWithSchedule(id: "supp-1", times: ["morning"])],
            addons: []
        )
        
        let viewModel = TodayViewModel(container: container)
        await viewModel.loadReminders()
        
        #expect(!viewModel.reminders.isEmpty)
    }
    
    @Test("loadReminders only includes active supplements")
    func loadRemindersOnlyActiveSupplements() async {
        let container = makeContainer()
        container.currentStack = TestHelpers.makeStack(
            minimal: [
                TestHelpers.makeSupplementWithSchedule(id: "active", times: ["morning"], active: true),
                TestHelpers.makeSupplementWithSchedule(id: "inactive", times: ["morning"], active: false)
            ],
            addons: []
        )
        
        let viewModel = TodayViewModel(container: container)
        await viewModel.loadReminders()
        
        let reminderSupplementIds = viewModel.reminders.map { $0.supplementId }
        #expect(reminderSupplementIds.contains("active"))
        #expect(!reminderSupplementIds.contains("inactive"))
    }
    
    @Test("loadReminders returns empty when no stack")
    func loadRemindersEmptyWhenNoStack() async {
        let container = makeContainer()
        container.currentStack = nil
        
        let viewModel = TodayViewModel(container: container)
        await viewModel.loadReminders()
        
        #expect(viewModel.reminders.isEmpty)
    }
    
    // MARK: - loadTodayData Tests
    
    @Test("loadTodayData syncs with IntakeLogManager")
    func loadTodayDataSyncsWithIntakeLogManager() async {
        let mockTracking = MockTrackingService()
        let today = TestHelpers.apiDateString(for: Date())
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [
            DayIntakeData(
                date: today,
                stackId: "stack-1",
                stackIntakeData: [
                    SupplementIntakeData(supplementId: "supp-1", supplementName: "Vitamin D", time: "morning", taken: true)
                ]
            )
        ])
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TodayViewModel(container: container)
        
        await viewModel.loadTodayData()
        
        #expect(mockTracking.getWeeklyIntakeCallCount >= 1)
    }
    
    @Test("loadTodayData sets error on failure")
    func loadTodayDataSetsErrorOnFailure() async {
        let mockTracking = MockTrackingService()
        mockTracking.errorToThrow = MockError.simulatedError
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TodayViewModel(container: container)
        
        await viewModel.loadTodayData()
        
        #expect(viewModel.showError == true)
        #expect(!viewModel.errorMessage.isEmpty)
    }
    
    // MARK: - toggleTaken Tests
    
    @Test("toggleTaken uses IntakeLogManager correctly")
    func toggleTakenUsesIntakeLogManager() {
        let container = makeContainer()
        container.currentStack = TestHelpers.makeStack()
        
        let viewModel = TodayViewModel(container: container)
        
        // Toggle a supplement
        viewModel.toggleTaken(supplementId: "supp-1", time: "morning")
        
        // Verify IntakeLogManager was used
        let key = "\(Date().apiDateString)|supp-1|morning"
        #expect(container.intakeLogManager.localIntakeState[key] != nil)
    }
    
    // MARK: - isSupplementTaken Tests
    
    @Test("isSupplementTaken checks local state first")
    func isSupplementTakenChecksLocalFirst() {
        let container = makeContainer()
        
        // Set up local state via IntakeLogManager
        container.intakeLogManager.toggleSupplement(
            supplementId: "supp-1",
            time: "morning",
            date: Date(),
            currentState: false
        )
        
        let viewModel = TodayViewModel(container: container)
        
        // Should return true because local state says so
        let result = viewModel.isSupplementTaken(supplementId: "supp-1", time: "morning")
        #expect(result == true)
    }
    
    @Test("isSupplementTaken falls back to API state")
    func isSupplementTakenFallsBackToAPI() async {
        let mockTracking = MockTrackingService()
        let today = TestHelpers.apiDateString(for: Date())
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [
            DayIntakeData(
                date: today,
                stackId: "stack-1",
                stackIntakeData: [
                    SupplementIntakeData(supplementId: "supp-1", supplementName: "Vitamin D", time: "morning", taken: true)
                ]
            )
        ])
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TodayViewModel(container: container)
        
        await viewModel.loadTodayData()
        
        // Should return true from API data
        let result = viewModel.isSupplementTaken(supplementId: "supp-1", time: "morning")
        #expect(result == true)
    }
    
    // MARK: - remindersForSection Tests
    
    @Test("remindersForSection filters by time range")
    func remindersForSectionFilters() async {
        let container = makeContainer()
        
        // Create supplements with different times
        container.currentStack = TestHelpers.makeStack(
            minimal: [
                TestHelpers.makeSupplementWithSchedule(id: "morning-supp", times: ["morning"]),
                TestHelpers.makeSupplementWithSchedule(id: "evening-supp", times: ["evening"])
            ],
            addons: []
        )
        
        let viewModel = TodayViewModel(container: container)
        await viewModel.loadReminders()
        
        let morningReminders = viewModel.remindersForSection(.morning)
        let eveningReminders = viewModel.remindersForSection(.evening)
        
        let morningIds = morningReminders.map { $0.supplementId }
        let eveningIds = eveningReminders.map { $0.supplementId }
        
        #expect(morningIds.contains("morning-supp"))
        #expect(eveningIds.contains("evening-supp"))
    }
    
    // MARK: - timeStringForReminder Tests
    
    @Test("timeStringForReminder maps hours correctly")
    func timeStringForReminderMapsCorrectly() {
        let container = makeContainer()
        let viewModel = TodayViewModel(container: container)
        let calendar = Calendar.current
        
        // Create reminders at different times
        let morningReminder = Reminder(
            supplementId: "test",
            timeOfDay: calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date(),
            enabled: true
        )
        
        let eveningReminder = Reminder(
            supplementId: "test",
            timeOfDay: calendar.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
            enabled: true
        )
        
        let nightReminder = Reminder(
            supplementId: "test",
            timeOfDay: calendar.date(from: DateComponents(hour: 21, minute: 0)) ?? Date(),
            enabled: true
        )
        
        #expect(viewModel.timeStringForReminder(morningReminder) == "morning")
        #expect(viewModel.timeStringForReminder(eveningReminder) == "evening")
        #expect(viewModel.timeStringForReminder(nightReminder) == "night")
    }
    
    // MARK: - getSupplementName Tests
    
    @Test("getSupplementName returns supplement name from stack")
    func getSupplementNameReturnsName() {
        let container = makeContainer()
        container.currentStack = TestHelpers.makeStack(
            minimal: [TestHelpers.makeSupplement(id: "test-supp", name: "Test Vitamin")],
            addons: []
        )
        
        let viewModel = TodayViewModel(container: container)
        
        let name = viewModel.getSupplementName(for: "test-supp")
        #expect(name == "Test Vitamin")
    }
    
    @Test("getSupplementName falls back to capitalized ID")
    func getSupplementNameFallsBackToId() {
        let container = makeContainer()
        container.currentStack = nil
        
        let viewModel = TodayViewModel(container: container)
        
        let name = viewModel.getSupplementName(for: "unknown-supplement")
        // .capitalized capitalizes first letter of each word
        #expect(name == "Unknown-Supplement")
    }
    
    // MARK: - TimeSection Tests
    
    @Test("TimeSection has correct time ranges")
    func timeSectionRanges() {
        #expect(TodayViewModel.TimeSection.morning.timeRange == 5...11)
        #expect(TodayViewModel.TimeSection.noon.timeRange == 12...14)
        #expect(TodayViewModel.TimeSection.evening.timeRange == 15...19)
        #expect(TodayViewModel.TimeSection.night.timeRange == 20...23)
    }
    
    @Test("TimeSection has correct icons")
    func timeSectionIcons() {
        #expect(TodayViewModel.TimeSection.morning.icon == "sun.max.fill")
        #expect(TodayViewModel.TimeSection.noon.icon == "sun.max")
        #expect(TodayViewModel.TimeSection.evening.icon == "sunset.fill")
        #expect(TodayViewModel.TimeSection.night.icon == "moon.fill")
    }
    
    // MARK: - retry Tests
    
    @Test("retry calls both load methods")
    func retryCallsBothLoads() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [])
        
        let container = makeContainer(trackingService: mockTracking)
        container.currentStack = TestHelpers.makeStack()
        
        let viewModel = TodayViewModel(container: container)
        
        // Wait for init's async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Record count after init
        let countAfterInit = mockTracking.getWeeklyIntakeCallCount
        
        await viewModel.retry()
        
        // Retry should call getWeeklyIntake once more
        #expect(mockTracking.getWeeklyIntakeCallCount >= countAfterInit + 1)
    }
}

