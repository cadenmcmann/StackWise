import Foundation

// MARK: - ChatSession
public struct ChatSession: Identifiable, Codable {
    public let id: String
    public let userId: String?
    public let title: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        userId: String? = nil,
        title: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Display title with fallback
    public var displayTitle: String {
        title ?? "New Chat"
    }
    
    // Formatted time for display
    public var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
}

// MARK: - API Conversions
extension APIChatSession {
    func toChatSession() -> ChatSession {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdDate = formatter.date(from: createdAt) ?? Date()
        let updatedDate = formatter.date(from: updatedAt) ?? Date()
        
        return ChatSession(
            id: id,
            userId: userId,
            title: title,
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}

extension APIChatMessage {
    func toMessage() -> Message {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = formatter.date(from: createdAt) ?? Date()
        
        let messageRole: Message.Role = {
            switch role.lowercased() {
            case "user": return .user
            case "assistant": return .assistant
            case "system": return .system
            default: return .assistant
            }
        }()
        
        return Message(
            id: id,
            role: messageRole,
            text: content,
            createdAt: date
        )
    }
}
