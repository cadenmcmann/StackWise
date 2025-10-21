import Foundation

// MARK: - Reminder
public struct Reminder: Identifiable, Codable {
    public let id: String
    public let supplementId: String
    public var timeOfDay: Date
    public var enabled: Bool
    
    public init(
        id: String = UUID().uuidString,
        supplementId: String,
        timeOfDay: Date,
        enabled: Bool = true
    ) {
        self.id = id
        self.supplementId = supplementId
        self.timeOfDay = timeOfDay
        self.enabled = enabled
    }
}
