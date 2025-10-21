import Foundation

// MARK: - TrackEntry
public struct TrackEntry: Identifiable, Codable {
    public let id: String
    public let date: Date
    public var takenSupplementIds: Set<String>
    public var note: String?
    
    public init(
        id: String = UUID().uuidString,
        date: Date,
        takenSupplementIds: Set<String> = [],
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.takenSupplementIds = takenSupplementIds
        self.note = note
    }
    
    public func percentageCompleted(totalSupplements: Int) -> Double {
        guard totalSupplements > 0 else { return 0 }
        return Double(takenSupplementIds.count) / Double(totalSupplements)
    }
}
