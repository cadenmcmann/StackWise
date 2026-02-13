import Testing
import Foundation
@testable import StackWise

@Suite("TrackViewModel Tests")
@MainActor
struct TrackViewModelTests {
    
    // MARK: - Helper Methods
    
    private func makeContainer(
        trackingService: MockTrackingService = MockTrackingService()
    ) -> DIContainer {
        return DIContainer(
            trackingService: trackingService,
            skipInitialLoad: true
        )
    }
    
    // MARK: - loadWeekData Tests
    
    @Test("loadWeekData fetches and syncs data")
    func loadWeekDataFetchesAndSyncs() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = TestHelpers.makeWeeklyIntakeResponse()
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        await viewModel.loadWeekData()
        
        #expect(mockTracking.getWeeklyIntakeCallCount >= 1)
        #expect(viewModel.weeklyIntakeData != nil)
    }
    
    @Test("loadWeekData sets error on failure")
    func loadWeekDataSetsErrorOnFailure() async {
        let mockTracking = MockTrackingService()
        mockTracking.errorToThrow = MockError.simulatedError
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        await viewModel.loadWeekData()
        
        #expect(viewModel.showError == true)
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - selectDate Tests
    
    @Test("selectDate toggles selection correctly")
    func selectDateToggles() {
        let container = makeContainer()
        let viewModel = TrackViewModel(container: container)
        
        // Use a different date than today (which is selected by default)
        let testDate = TestHelpers.date(daysFromToday: -2)
        
        // First, clear the default selection by toggling today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        viewModel.selectDate(today) // This should deselect today
        #expect(viewModel.selectedDate == nil)
        
        // Now select a specific date
        viewModel.selectDate(testDate)
        #expect(viewModel.selectedDate != nil)
        
        // Select same date again should deselect
        viewModel.selectDate(testDate)
        #expect(viewModel.selectedDate == nil)
    }
    
    @Test("selectDate normalizes to start of day")
    func selectDateNormalizesToStartOfDay() {
        let container = makeContainer()
        let viewModel = TrackViewModel(container: container)
        
        // Create a date with specific time
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 15
        components.minute = 30
        let dateWithTime = calendar.date(from: components)!
        
        viewModel.selectDate(dateWithTime)
        
        if let selected = viewModel.selectedDate {
            let hour = calendar.component(.hour, from: selected)
            let minute = calendar.component(.minute, from: selected)
            #expect(hour == 0)
            #expect(minute == 0)
        }
    }
    
    // MARK: - navigateWeek Tests
    
    @Test("navigateWeek changes week forward")
    func navigateWeekForward() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = TestHelpers.makeWeeklyIntakeResponse()
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        let originalWeek = viewModel.currentWeekStartDate
        
        viewModel.navigateWeek(forward: true)
        
        let calendar = Calendar.current
        let expectedWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: originalWeek)
        
        #expect(calendar.isDate(viewModel.currentWeekStartDate, inSameDayAs: expectedWeek!))
    }
    
    @Test("navigateWeek changes week backward")
    func navigateWeekBackward() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = TestHelpers.makeWeeklyIntakeResponse()
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        let originalWeek = viewModel.currentWeekStartDate
        
        viewModel.navigateWeek(forward: false)
        
        let calendar = Calendar.current
        let expectedWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: originalWeek)
        
        #expect(calendar.isDate(viewModel.currentWeekStartDate, inSameDayAs: expectedWeek!))
    }
    
    @Test("navigateWeek clears selection")
    func navigateWeekClearsSelection() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = TestHelpers.makeWeeklyIntakeResponse()
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        // Today is selected by default, so just verify and navigate
        // The selection should be cleared after navigation
        viewModel.navigateWeek(forward: true)
        
        #expect(viewModel.selectedDate == nil)
    }
    
    // MARK: - completionForDate Tests
    
    @Test("completionForDate calculates percentage correctly")
    func completionForDateCalculates() async {
        let mockTracking = MockTrackingService()
        let today = TestHelpers.apiDateString(for: TestHelpers.date(daysFromToday: -1)) // Yesterday
        
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [
            DayIntakeData(
                date: today,
                stackId: "stack-1",
                stackIntakeData: [
                    SupplementIntakeData(supplementId: "s1", supplementName: "Supp 1", time: "morning", taken: true),
                    SupplementIntakeData(supplementId: "s2", supplementName: "Supp 2", time: "morning", taken: false)
                ]
            )
        ])
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        await viewModel.loadWeekData()
        
        let completion = viewModel.completionForDate(TestHelpers.date(daysFromToday: -1))
        #expect(completion == 0.5) // 1 of 2 taken
    }
    
    @Test("completionForDate returns 0 when no data")
    func completionForDateReturnsZeroWhenNoData() {
        let container = makeContainer()
        let viewModel = TrackViewModel(container: container)
        
        let completion = viewModel.completionForDate(TestHelpers.today)
        #expect(completion == 0)
    }
    
    // MARK: - getSupplementsByTime Tests
    
    @Test("getSupplementsByTime groups by time correctly")
    func getSupplementsByTimeGroups() async {
        let mockTracking = MockTrackingService()
        let today = TestHelpers.apiDateString(for: TestHelpers.date(daysFromToday: -1))
        
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [
            DayIntakeData(
                date: today,
                stackId: "stack-1",
                stackIntakeData: [
                    SupplementIntakeData(supplementId: "s1", supplementName: "Morning Supp", time: "morning", taken: false),
                    SupplementIntakeData(supplementId: "s2", supplementName: "Evening Supp", time: "evening", taken: false),
                    SupplementIntakeData(supplementId: "s3", supplementName: "Another Morning", time: "morning", taken: false)
                ]
            )
        ])
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        await viewModel.loadWeekData()
        
        let grouped = viewModel.getSupplementsByTime(for: TestHelpers.date(daysFromToday: -1))
        
        // Should have morning and evening groups
        let morningGroup = grouped.first { $0.time == "morning" }
        let eveningGroup = grouped.first { $0.time == "evening" }
        
        #expect(morningGroup?.supplements.count == 2)
        #expect(eveningGroup?.supplements.count == 1)
    }
    
    // MARK: - isCurrentWeek Tests
    
    @Test("isCurrentWeek returns true for current week")
    func isCurrentWeekReturnsTrue() {
        let container = makeContainer()
        let viewModel = TrackViewModel(container: container)
        
        #expect(viewModel.isCurrentWeek == true)
    }
    
    @Test("isCurrentWeek returns false after navigation")
    func isCurrentWeekReturnsFalseAfterNavigation() async {
        let mockTracking = MockTrackingService()
        mockTracking.weeklyIntakeToReturn = TestHelpers.makeWeeklyIntakeResponse()
        
        let container = makeContainer(trackingService: mockTracking)
        let viewModel = TrackViewModel(container: container)
        
        viewModel.navigateWeek(forward: false)
        
        #expect(viewModel.isCurrentWeek == false)
    }
    
    // MARK: - toggleSupplement Tests
    
    @Test("toggleSupplement uses IntakeLogManager")
    func toggleSupplementUsesIntakeLogManager() {
        let container = makeContainer()
        let viewModel = TrackViewModel(container: container)
        let today = TestHelpers.today
        
        viewModel.toggleSupplement(
            supplementId: "supp-1",
            time: "morning",
            date: today,
            currentState: false
        )
        
        let key = "\(today.apiDateString)|supp-1|morning"
        #expect(container.intakeLogManager.localIntakeState[key] == true)
    }
    
    // MARK: - isSupplementTaken Tests
    
    @Test("isSupplementTaken uses IntakeLogManager")
    func isSupplementTakenUsesIntakeLogManager() {
        let container = makeContainer()
        
        // Set local state first
        container.intakeLogManager.toggleSupplement(
            supplementId: "supp-1",
            time: "morning",
            date: TestHelpers.today,
            currentState: false
        )
        
        let viewModel = TrackViewModel(container: container)
        
        let result = viewModel.isSupplementTaken(
            supplementId: "supp-1",
            time: "morning",
            date: TestHelpers.today,
            apiState: false
        )
        
        #expect(result == true)
    }
    
    // MARK: - Active Supplement Filtering Tests
    
    @Test("getSupplementsByTime filters active supplements for today")
    func getSupplementsByTimeFiltersActiveForToday() async {
        let mockTracking = MockTrackingService()
        let todayString = TestHelpers.apiDateString(for: TestHelpers.today)
        
        mockTracking.weeklyIntakeToReturn = WeeklyIntakeResponse(weekData: [
            DayIntakeData(
                date: todayString,
                stackId: "stack-1",
                stackIntakeData: [
                    SupplementIntakeData(supplementId: "active-supp", supplementName: "Active", time: "morning", taken: false),
                    SupplementIntakeData(supplementId: "inactive-supp", supplementName: "Inactive", time: "morning", taken: false)
                ]
            )
        ])
        
        let container = makeContainer(trackingService: mockTracking)
        
        // Set up a stack where only one supplement is active
        container.currentStack = TestHelpers.makeStack(
            minimal: [
                TestHelpers.makeSupplement(id: "active-supp", name: "Active", active: true),
                TestHelpers.makeSupplement(id: "inactive-supp", name: "Inactive", active: false)
            ],
            addons: []
        )
        
        let viewModel = TrackViewModel(container: container)
        await viewModel.loadWeekData()
        
        let grouped = viewModel.getSupplementsByTime(for: TestHelpers.today)
        let allSupplementIds = grouped.flatMap { $0.supplements.map { $0.supplementId } }
        
        #expect(allSupplementIds.contains("active-supp"))
        #expect(!allSupplementIds.contains("inactive-supp"))
    }
}

