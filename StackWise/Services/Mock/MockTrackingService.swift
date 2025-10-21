import Foundation

// MARK: - MockTrackingService
public class MockTrackingService: TrackingService {
    private var entries: [TrackEntry] = []
    
    public init() {
        setupMockEntries()
    }
    
    private func setupMockEntries() {
        // Create some mock tracking entries for the past week
        let calendar = Calendar.current
        let today = Date()
        
        for daysAgo in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            
            // Simulate different completion levels
            let completionRate = Double.random(in: 0.5...1.0)
            let takenIds: Set<String> = completionRate > 0.7 ? 
                ["creatine", "magnesium", "l-theanine"] : 
                ["creatine", "magnesium"]
            
            let note: String? = daysAgo == 0 ? "Feeling good today!" : 
                               (daysAgo == 1 ? "Slept better than usual" : nil)
            
            entries.append(TrackEntry(
                date: date,
                takenSupplementIds: takenIds,
                note: note
            ))
        }
    }
    
    public func getWeekEntries(startingFrom date: Date) async throws -> [TrackEntry] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 7, to: date) ?? date
        
        return entries.filter { entry in
            entry.date >= date && entry.date <= endDate
        }.sorted { $0.date < $1.date }
    }
    
    public func getEntry(for date: Date) async throws -> TrackEntry? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let calendar = Calendar.current
        return entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    public func saveNote(date: Date, text: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        let calendar = Calendar.current
        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            entries[index].note = text
        } else {
            entries.append(TrackEntry(
                date: date,
                takenSupplementIds: [],
                note: text
            ))
        }
    }
    
    public func getStreak() async throws -> Int {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Calculate streak based on consecutive days with all supplements taken
        let sortedEntries = entries.sorted { $0.date > $1.date }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for entry in sortedEntries {
            if calendar.isDate(entry.date, inSameDayAs: currentDate) {
                if entry.takenSupplementIds.count >= 3 { // Assuming 3 supplements minimum
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else {
                    break
                }
            } else if entry.date < currentDate {
                // Gap in dates, break streak
                break
            }
        }
        
        return streak
    }
    
    public func getWeeklyIntake(startDate: Date) async throws -> WeeklyIntakeResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var weekData: [DayIntakeData] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            
            let dateString = formatter.string(from: date)
            let isToday = calendar.isDateInToday(date)
            let isPast = date < Date()
            
            // Create mock supplement intake data
            var intakeData: [SupplementIntakeData] = []
            
            // Morning supplements
            intakeData.append(SupplementIntakeData(
                supplementId: "creatine-id",
                supplementName: "Creatine Monohydrate",
                time: "morning",
                taken: isPast ? Bool.random() : false
            ))
            
            // Evening supplements
            intakeData.append(SupplementIntakeData(
                supplementId: "magnesium-id",
                supplementName: "Magnesium Glycinate",
                time: "evening",
                taken: isPast && !isToday ? Bool.random() : false
            ))
            
            intakeData.append(SupplementIntakeData(
                supplementId: "ltheanine-id",
                supplementName: "L-Theanine",
                time: "evening",
                taken: isPast && !isToday ? Bool.random() : false
            ))
            
            weekData.append(DayIntakeData(
                date: dateString,
                stackId: "mock-stack-id",
                stackIntakeData: intakeData
            ))
        }
        
        return WeeklyIntakeResponse(weekData: weekData)
    }
}
