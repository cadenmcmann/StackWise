import Foundation

// MARK: - Message
public struct Message: Identifiable, Codable {
    public let id: String
    public let role: Role
    public let text: String
    public let createdAt: Date
    
    public enum Role: String, Codable {
        case user
        case assistant
        case system
    }
    
    public init(
        id: String = UUID().uuidString,
        role: Role,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}
