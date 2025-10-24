import Foundation

// MARK: - ChatService Protocol
public protocol ChatService {
    func send(message: Message, context: ChatContext) async throws -> [Message]
    func createSession(title: String?) async throws -> ChatSession
    func fetchSessions(limit: Int, cursor: String?) async throws -> [ChatSession]
    func fetchSessionMessages(sessionId: String, limit: Int, before: String?) async throws -> [Message]
    func setCurrentSession(_ sessionId: String?)
    func getCurrentSessionId() -> String?
    func getCachedSessions() -> [ChatSession]
    func getCachedMessages(for sessionId: String) -> [Message]
    func clearCache()
}

// MARK: - ChatContext
public struct ChatContext {
    public let user: User?
    public let stack: Stack?
    
    public init(user: User? = nil, stack: Stack? = nil) {
        self.user = user
        self.stack = stack
    }
}
